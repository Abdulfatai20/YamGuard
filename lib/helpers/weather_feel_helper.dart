String getFeelsLikeWeather(Map<String, dynamic> data) {
  final current = data['current'];
  final cloudiness = (current['clouds'] as num).floor(); // %
  final visibility = (current['visibility'] as num).floor(); // meters
  final uvi = (current['uvi'] as num).floor();
  final windSpeed = current['wind_speed'];
  final humidity = current['humidity'];
  final temp = current['temp'];
  final weatherDesc = current['weather'][0]['description'].toLowerCase();
  final rainVolume = current['rain']?['1h'] ?? current['rain']?['3h'] ?? 0.0;

  final now = DateTime.fromMillisecondsSinceEpoch(current['dt'] * 1000, isUtc: true);
  final sunrise = DateTime.fromMillisecondsSinceEpoch(current['sunrise'] * 1000, isUtc: true);
  final sunset = DateTime.fromMillisecondsSinceEpoch(current['sunset'] * 1000, isUtc: true);
  final isDayTime = now.isAfter(sunrise) && now.isBefore(sunset);

  final isStormy = weatherDesc.contains('storm') || weatherDesc.contains('thunder') ||  weatherDesc.contains('lightning');
  final isDusty = weatherDesc.contains('dust') || weatherDesc.contains('sand') || weatherDesc.contains('haze') || weatherDesc.contains('smoke');
  final isDrizzle = weatherDesc.contains('drizzle');
  final isRainDesc = weatherDesc.contains('rain') || weatherDesc.contains('shower');
  final isLightRainDesc = weatherDesc.contains('light rain');
  final isHeavyRainDesc = weatherDesc.contains('heavy rain');

  final isLowHumidity = humidity <= 40;
  final isLowVisibility = visibility < 3500;
  final isHighVisibility = visibility >= 8000;

  final isVeryClear = cloudiness <= 50;
  final isMostlyCloudy = cloudiness > 70 && cloudiness <= 100;

  final isLowUV = uvi <= 3;
  final isDecentUV = uvi > 3 && uvi <= 5;
  final isStrongUV = uvi > 5 && uvi <= 7;
  final isVeryStrongUV = uvi > 7;

  final isRaining = rainVolume > 0.0 || isRainDesc;

   print(
    'UV: $uvi, Clouds: $cloudiness, Visibility: $visibility, Time: $now, Sunrise: $sunrise, Sunset: $sunset, rain: $rainVolume, storm: $isStormy, dust: $isDusty',
  );

  // 🌩️ Storm
  if (isStormy && (rainVolume >= 7.0 || isHeavyRainDesc)) return 'Stormy Rain';
  if (isStormy && !isRaining) return 'Stormy Winds';

  // 🌧️ Rain
  if (rainVolume >= 7.0 || isHeavyRainDesc) return 'Heavy Rain';
  if (rainVolume >= 2.0 || (isRainDesc && !isLightRainDesc)) return 'Rainy';
  if (isDrizzle || isLightRainDesc || rainVolume > 0.0) return 'Light Rain';

  // 🌫️ Harmattan
  if ((isDusty && isLowHumidity) || (isLowVisibility && isDusty) || (temp <= 25 && isLowHumidity)) {
    return 'Harmattan';
  }

  // 💨 Windy (but only if it's not bright and sunny)
  final isClearlySunny = isVeryClear && isHighVisibility && (isStrongUV || isVeryStrongUV);
  if (windSpeed >= 8 && !isRaining && !isClearlySunny) return 'Windy';

  // ☀️ Daytime Brightness
  if (isDayTime && !isRaining && !isStormy) {
    if (cloudiness <= 20 && (isVeryStrongUV || isHighVisibility)) return ' Very Sunny';
    if (cloudiness <= 50 && (isVeryStrongUV || isHighVisibility)) return 'Mostly Sunny';
    if (cloudiness <= 70 && (isStrongUV || isHighVisibility)) return 'Partly Sunny';
    if (isMostlyCloudy && (isLowUV || isHighVisibility)) return 'Mostly Cloudy';
    if (isMostlyCloudy && (isDecentUV || isHighVisibility)) return 'Partly Cloudy';
  }

  // 🌙 Nighttime
  if (!isDayTime) {
    if (cloudiness <= 70) return 'Mostly Cloudy';
  }

  // Default
  return 'Cloudy';
}
