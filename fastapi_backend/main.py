# -*- coding: utf-8 -*-
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import joblib, os
import pandas as pd
from prophet.serialize import model_from_json  # type: ignore
from datetime import datetime

app = FastAPI(title="Yam Storage Forecast API", version="2.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------- load Prophet models (.pkl is enough) ----------
MODEL_PATHS = {
    "avg_temp":  "models/avg_temp_model.pkl",
    "max_temp":  "models/max_temp_model.pkl",
    "humidity":  "models/humidity_model.pkl",
    "rainfall":  "models/rainfall_model.pkl",
}
MODELS = {}
for k, p in MODEL_PATHS.items():
    if not os.path.exists(p):
        raise RuntimeError(f"❌ Missing model: {p} - run train_models.py")
    MODELS[k] = joblib.load(p)

# ---------- yam meta ----------
YAM_TYPES = {
    "white yam (Dioscorea rotundata)": "white",
    "yellow yam (Dioscorea cayenensis)": "yellow",
    "bitter yam (Dioscorea dumetorum)": "bitter",
    "water yam (Dioscorea alata)": "water",
}
YAM_ALIASES = {a: full for a, full in [
    ("white yam", "white yam (Dioscorea rotundata)"),
    ("yellow yam", "yellow yam (Dioscorea cayenensis)"),
    ("bitter yam", "bitter yam (Dioscorea dumetorum)"),
    ("water yam", "water yam (Dioscorea alata)"),
    ("white", "white yam (Dioscorea rotundata)"),
    ("yellow", "yellow yam (Dioscorea cayenensis)"),
    ("bitter", "bitter yam (Dioscorea dumetorum)"),
    ("water", "water yam (Dioscorea alata)"),
]}
VALID_COND = {"whole", "cut"}
INTERVAL_MAP = {"14_day": 14, "30_day": 30, "60_day": 60, "90_day": 90}

# ----------- shelf-life rules -----------
SHELF_LIMITS = {
    "white yam (Dioscorea rotundata)": 120,
    "yellow yam (Dioscorea cayenensis)": 100,
    "water yam (Dioscorea alata)": 60,
    "bitter yam (Dioscorea dumetorum)": 45,
}

# ---------- pydantic ----------
class Request(BaseModel):
    yam_type: str
    condition: str
    interval: str

# ---------- helpers ----------
def forecast(model, days: int):
    today = datetime.utcnow().date()
    future = pd.DataFrame({"ds": pd.date_range(start=today, periods=days, freq="D")})
    future['wet_season'] = future['ds'].dt.month.between(4, 10).astype(int)
    fc = model.predict(future)[['ds', 'yhat']]
    fc['ds'] = fc['ds'].dt.strftime('%Y-%m-%d')
    fc['yhat'] = fc['yhat'].round(2)
    return fc.to_dict('records')

def avg(lst): return round(sum(d['yhat'] for d in lst) / len(lst), 2)

# ---------- logic ----------
@app.post("/recommendation/")
def recommend(req: Request):
    yam = YAM_ALIASES.get(req.yam_type.lower().strip(), req.yam_type)
    if yam not in YAM_TYPES:
        raise HTTPException(400, "Unsupported yam type.")
    if req.condition.lower() not in VALID_COND:
        raise HTTPException(400, "condition must be 'whole' or 'cut'.")
    if req.interval not in INTERVAL_MAP:
        raise HTTPException(400, "interval must be 14_day, 30_day, 60_day or 90_day.")

    # CUT yams rule
    if req.condition.lower() == "cut":
        if req.interval != "14_day":
            raise HTTPException(
                400,
                "Cut yams can only be stored for up to 14 days using ash/sawdust." 
            )
        allowed = {"ash/sawdust"}
    else:
        # WHOLE yams rule: check shelf-life limit
        allowed = {"barn", "pit", "ash/sawdust", "ventilated crate"}

    days = INTERVAL_MAP[req.interval]
    fc = {k: forecast(m, days) for k, m in MODELS.items()}

    avg_temp, max_temp = avg(fc['avg_temp']), avg(fc['max_temp'])
    avg_hum, avg_rain = avg(fc['humidity']), avg(fc['rainfall'])
    season = "wet" if avg_hum > 55 or avg_rain > 3 else "dry"

    recs, reason, ios, alerts = [], {}, {}, []

    # barn
    barn_ok = avg_temp < 35 and avg_rain < 4 and max_temp < 37
    if "barn" in allowed and barn_ok:
        recs.append("barn")
        msg = "Recommended for whole yam only: low rain & moderate temp OK."
        if season == "wet":
            msg += "\nMust be well-ventilated and protected from rain in wet season."
        reason["barn"] = msg
        ios["barn"] = "outdoor"
    else:
        reason["barn"] = (
            "Recommended for whole yam only.\n"
            "Needs Temp < 35 deg C, Rainfall < 4 mm, Max Temp < 37 deg C."
        )
        if season == "wet":
            reason["barn"] += "\nMust be protected from wet conditions."

    # pit
    pit_ok = avg_hum > 60 and avg_rain <= 5 and season != 'wet'
    if "pit" in allowed and pit_ok:
        recs.append("pit")
        reason["pit"] = "Recommended for whole yam only.\nWeather is humid & moderate rain - pit suitable."
        ios["pit"] = "outdoor"
    else:
        reason["pit"] = (
            "Recommended for whole yam only.\n"
            "Needs humidity > 60%, Rainfall <= 5 mm."
        )
        if season == "wet":
            reason["pit"] += "\nAvoid during rainy season due to rot risk."

    # ash/sawdust
    ash_ok = avg_temp >= 28 and days <= 120
    if "ash/sawdust" in allowed and ash_ok:
        if season == "wet":
            recs.append("ash/sawdust (indoor)")
            if req.condition.lower() == "cut":
                reason["ash/sawdust (indoor)"] = (
                    "Only method for cut yam (max 14 days).\n"
                    "Warm & wet - use indoors to protect yams."
                )
            else:
                reason["ash/sawdust (indoor)"] = (
                    "Recommended for whole or cut yam (max 14 days).\n"
                    "Weather is warm and wet - store indoors."
                )
            ios["ash/sawdust (indoor)"] = "indoor"
        else:
            recs.append("ash/sawdust")
            if req.condition.lower() == "cut":
                reason["ash/sawdust"] = "Only method for cut yam (max 14 days)."
            else:
                reason["ash/sawdust"] = (
                    "Recommended for whole or cut yam (max 14 days).\n"
                    "Ash protects from heat."
                )
            ios["ash/sawdust"] = "outdoor"
    else:
        reason["ash/sawdust"] = "Needs temp ≥ 28 deg C. Cut yam max: 14 days."

    # ventilated crate
    crate_ok = 28 <= avg_temp <= 35 and days <= 60
    if "ventilated crate" in allowed and crate_ok:
        if season == "wet":
            recs.append("ventilated crate (indoor)")
            reason["ventilated crate (indoor)"] = (
                "Recommended for whole yam only.\n"
                "Warm + wet: use crate indoors."
            )
            ios["ventilated crate (indoor)"] = "indoor"
        else:
            recs.append("ventilated crate")
            reason["ventilated crate"] = (
                "Recommended for whole yam only.\n"
                "Weather is warm and dry - use crate outdoors."
            )
            ios["ventilated crate"] = "outdoor"
    else:
        reason["ventilated crate"] = "Needs 28-35 deg C. Only for whole yam."

    # alerts
    if season == "wet":
        alerts.append("Wet season - keep storage areas dry and covered.")
    if season == "dry":
        alerts.append("Dry season - monitor for dehydration.")
    if max_temp > 36:
        alerts.append("Heat-stress risk (>36 deg C).")

    if not recs:
        recs = ["No optimal storage method under current forecast."]

    selected_explanations = {k: v for k, v in reason.items() if k in recs}
    not_selected_explanations = {k: v for k, v in reason.items() if k not in recs}

    return {
        "yam_type": yam,
        "condition": req.condition,
        "interval": req.interval,
        "season": season,
        "recommended_storage_methods": recs,
        "forecast_summary": {
            "Average_Temp": avg_temp,
            "Average_Max_Temp": max_temp,
            "Average_Humidity": avg_hum,
            "Average_Rainfall": avg_rain
        },
        "alerts": alerts,
        "selected_explanations": selected_explanations,
        "not_selected_explanations": not_selected_explanations
    }

@app.get("/yam-types")
def yam_types():
    return list(YAM_TYPES.keys())
