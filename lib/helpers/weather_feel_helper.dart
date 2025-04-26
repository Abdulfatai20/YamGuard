String getFeelsLikeWeather(Map<String, dynamic> data) {
  final cloudiness = data['current']['clouds']; // %
  final visibility = data['current']['visibility']; // meters
  final uvi = data['current']['uvi']; // UV index
  final windSpeed = data['current']['wind_speed']; // m/s
  final weatherDesc =
      data['current']['weather'][0]['description'].toLowerCase(); // text
  final rainVolume =
      data['current']['rain']?['1h'] ?? data['current']['rain']?['3h'] ?? 0.0;
  final humidity = data['current']['humidity'];
  final temperature = data['current']['temp'];

  final now = DateTime.fromMillisecondsSinceEpoch(
    data['current']['dt'] * 1000,
    isUtc: true,
  );
  final sunrise = DateTime.fromMillisecondsSinceEpoch(
    data['current']['sunrise'] * 1000,
    isUtc: true,
  );
  final sunset = DateTime.fromMillisecondsSinceEpoch(
    data['current']['sunset'] * 1000,
    isUtc: true,
  );

  final isDayTime = now.isAfter(sunrise) && now.isBefore(sunset);

  print(
    'UV: $uvi, Clouds: $cloudiness, Visibility: $visibility, Time: $now, Sunrise: $sunrise, Sunset: $sunset',
  );

  final isDusty =
      weatherDesc.contains('dust') ||
      weatherDesc.contains('sand') ||
      weatherDesc.contains('haze') ||
      weatherDesc.contains('smoke');

  final isVeryClear = cloudiness <= 50;
  final isMostlyCloudy = cloudiness <= 100 && cloudiness > 70;

  final isHighVisibility = visibility >= 8000;
  final isStrongUV = uvi >= 5;
  final isDecentUV = uvi >= 3;

  final isLowHumidity = humidity <= 40;
  final isLowVisibility = visibility < 3500;

  final isRaining = rainVolume > 0.0 || weatherDesc.contains('rain');
  final isStormy =
      weatherDesc.contains('storm') ||
      weatherDesc.contains('thunder') ||
      windSpeed > 20;

  // === RAIN LOGIC (volume + description) ===
  final isHeavyRainDesc = weatherDesc.contains('heavy rain');
  final isLightRainDesc = weatherDesc.contains('light rain');
  final isRainDesc =
      weatherDesc.contains('rain') || weatherDesc.contains('shower');
  final isDrizzle = weatherDesc.contains('drizzle');

  if (isStormy && (rainVolume >= 7.0 || isHeavyRainDesc)) return 'Stormy Rain';
  if (rainVolume >= 7.0 || isHeavyRainDesc) return 'Heavy Rain';
  if (rainVolume >= 2.0 || (isRainDesc && !isLightRainDesc)) return 'Rainy';
  if (rainVolume > 0.0 || isDrizzle || isLightRainDesc) return 'Light Rain';

  // === HARMATTAN (fog or dust) ===
  if ((isDusty && isLowHumidity) ||
      (isLowVisibility && isDusty) ||
      (temperature <= 25 && isLowHumidity)) {
    return 'Harmattan';
  }

  // === WIND LEVELS (only if it's not bright/clear) ===
  if (isStormy && !isRaining) return 'Stormy Winds';
  final isClearlySunny = isVeryClear && isHighVisibility && isStrongUV;
  final isWindDominant = windSpeed >= 8 && !isRaining && !isClearlySunny;

  if (isWindDominant) return 'Windy';

  // During Daytime
  if (isDayTime) {
    // Blazing sunshine (high UV)
    // if (cloudiness <= 30 && isHighVisibility && isStrongUV) {
    //   return 'Sunny';
    // }
    // // Good sunshine (moderate UV)
    // if (cloudiness <= 50 && (isHighVisibility || isStrongUV)) {
    //   return 'Mostly Sunny';
    // }
    // // Moderate sunshine (decent UV)
    // if (cloudiness <= 70 && (isDecentUV || isHighVisibility)) {
    //   return 'Partly Sunny';
    // }

    // Good sunshine (moderate UV)
    if (cloudiness <= 50 && (isStrongUV || isHighVisibility)) {
      return 'Very Sunny';
    }
    // Moderate sunshine (decent UV)
    if (cloudiness <= 70 && (isDecentUV || isHighVisibility)) {
      return 'Sunny';
    }
     if ((isMostlyCloudy || isHighVisibility) && uvi >= 1) {
      return 'Partly Sunny';
    }

    // === Covered skies but not fully dull
    if ((isMostlyCloudy || isHighVisibility) && uvi == 0) {
      return 'Mostly Cloudy';
    }
  }

  // At Night
  if (!isDayTime) {
    // Nighttime: UV index is typically low, so focus on cloudiness and visibility
    if (cloudiness <= 70) {
      return 'Mostly Cloudy';
    } 
  }

  return 'Cloudy';
}
