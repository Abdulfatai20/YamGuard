# train_models.py
import pandas as pd, os, json, joblib
from prophet import Prophet                           # type: ignore
from sklearn.metrics import mean_absolute_error, mean_squared_error
from datetime import date

CSV          = "weather_datasets.csv"
MODELS_DIR   = "models"
METRICS_PATH = "metrics.json"
FEATURES     = ['avg_temp', 'max_temp', 'humidity', 'rainfall']

def main():
    if not os.path.exists(CSV):
        raise SystemExit(f"❌  {CSV} not found – run fetch_meteostat_data.py first.")

    df = pd.read_csv(CSV, parse_dates=['date'])
    print(f"▶  Training on {len(df)} days   ({df.date.min().date()} → {df.date.max().date()})")

    os.makedirs(MODELS_DIR, exist_ok=True)
    metrics = {}

    def fit_one(col: str):
        data = pd.DataFrame({'ds': df['date'], 'y': df[col]})
        data['wet_season'] = data['ds'].dt.month.between(4, 10).astype(int)
        data.dropna(inplace=True)

        split = int(0.8 * len(data))
        train, val = data.iloc[:split], data.iloc[split:]

        m = Prophet(yearly_seasonality=True)
        m.add_regressor('wet_season')
        m.fit(train)

        joblib.dump(m, f"{MODELS_DIR}/{col}_model.pkl")

        pred = m.predict(val[['ds', 'wet_season']])['yhat']
        mae  = mean_absolute_error(val['y'], pred)
        rmse = mean_squared_error(val['y'], pred, squared=False)
        metrics[col] = {"MAE": round(mae, 2), "RMSE": round(rmse, 2)}
        print(f"  • {col:<10}  MAE={mae:5.2f}  RMSE={rmse:5.2f}")

    for f in FEATURES:
        fit_one(f)

    with open(METRICS_PATH, "w") as f:
        json.dump(metrics, f, indent=2)

    print("✅  Models & metrics updated.")

if __name__ == "__main__":
    main()
