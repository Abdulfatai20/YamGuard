from meteostat import Point, Daily, Hourly # type: ignore
import pandas as pd
from datetime import datetime
import os

# === LOCATION & DATE RANGE ===
location = Point(7.38, 3.93)  # Ibadan coordinates
start = datetime(2023, 1, 1)
end = datetime.today()

print("📡 Fetching DAILY data...")
daily = Daily(location, start, end)
daily = daily.fetch()
daily = daily[['tavg', 'tmax', 'prcp']].rename(columns={
    'tavg': 'avg_temp',
    'tmax': 'max_temp',
    'prcp': 'rainfall'
})
daily.reset_index(inplace=True)
daily.rename(columns={'time': 'date'}, inplace=True)  

print("📡 Fetching HOURLY humidity...")
hourly = Hourly(location, start, end)
hourly = hourly.fetch()
hourly = hourly[['rhum']].dropna()
hourly = hourly.groupby(hourly.index.date).mean()
hourly.index = pd.to_datetime(hourly.index)
hourly.reset_index(inplace=True)
hourly.rename(columns={'index': 'date', 'rhum': 'humidity'}, inplace=True)

print("🔄 Merging daily and humidity data...")
merged = pd.merge(daily, hourly, on='date', how='inner')

# Reorder columns
merged = merged[['date', 'avg_temp', 'max_temp', 'humidity', 'rainfall']]


# Round values for cleaner data
merged = merged.round(2)

# Save to CSV
output_path = "weather_datasets.csv"
merged.to_csv(output_path, index=False)
print(f"\n✅ Saved merged weather dataset to: {output_path}")
print(merged.head())


