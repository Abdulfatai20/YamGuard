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

  final isStormy = weatherDesc.contains('storm') || weatherDesc.contains('thunder') || weatherDesc.contains('lightning');
  final isDusty = weatherDesc.contains('dust') || weatherDesc.contains('sand') || weatherDesc.contains('haze') || weatherDesc.contains('smoke');
  final isDrizzle = weatherDesc.contains('drizzle');
  final isRainDesc = weatherDesc.contains('rain') || weatherDesc.contains('shower');
  final isLightRainDesc = weatherDesc.contains('light rain');
  final isHeavyRainDesc = weatherDesc.contains('heavy rain') || weatherDesc.contains('moderate rain') || weatherDesc.contains('extreme rain');

  final isLowHumidity = humidity <= 40;
  final isLowVisibility = visibility < 5000; // Increased threshold for better accuracy
  // final isHighVisibility = visibility >= 10000; // Increased threshold

  // final isVeryClear = cloudiness <= 20; // More restrictive for "very clear"
  // final isMostlyCloudy = cloudiness >= 70; // Simplified condition

  // UV thresholds adjusted for Osogbo's tropical savanna climate
  // UV is consistently high year-round but reduced during harmattan dust
  final isLowUV = uvi <= 3; 
  final isDecentUV = uvi > 3 && uvi <= 6;
  final isStrongUV = uvi > 6 && uvi <= 9;
  final isVeryStrongUV = uvi > 9;

  final isRaining = rainVolume > 0.1 || isRainDesc; // Small threshold to avoid false positives

  // Get current month for seasonal adjustments
  final currentMonth = now.month;
  final isDrySeason = currentMonth >= 11 || currentMonth <= 3; // Nov-Mar (Harmattan season)
  // final isWetSeason = currentMonth >= 4 && currentMonth <= 10; // Apr-Oct

  print(
    'UV: $uvi, Clouds: $cloudiness%, Visibility: ${visibility}m, Humidity: $humidity%, Wind: ${windSpeed}m/s, Rain: ${rainVolume}mm, Temp: $temp°C, Season: ${isDrySeason ? 'Dry' : 'Wet'}, Desc: $weatherDesc',
  );

  // 🌩️ Storm conditions (highest priority)
  if (isStormy) {
    if (rainVolume >= 5.0 || isHeavyRainDesc) return 'Stormy Rain';
    return 'Stormy Winds';
  }

  // 🌧️ Rain conditions
  if (rainVolume >= 5.0 || isHeavyRainDesc) return 'Heavy Rain';
  if (rainVolume >= 1.0 || (isRainDesc && !isLightRainDesc && !isDrizzle)) return 'Rainy';
  if (isDrizzle || isLightRainDesc || (rainVolume > 0.1 && rainVolume < 1.0)) return 'Light Rain';

  // 🌫️ Harmattan conditions (Nov-Mar dry season with dust from Sahara)
  // Harmattan is characterized by dry dusty air, low humidity, reduced visibility
  if (isDrySeason && (isDusty || isLowHumidity || isLowVisibility)) {
    return 'Harmattan';
  }
  // Peak harmattan months (Dec-Jan) with very low humidity
  if ((currentMonth == 12 || currentMonth == 1) && humidity <= 30) {
    return 'Harmattan';
  }
  // General harmattan conditions during dry season
  if (isDrySeason && humidity <= 40 && (visibility < 8000 || temp <= 30)) {
    return 'Harmattan';
  }

  // 💨 Windy conditions (adjusted for seasonal patterns)
  // During harmattan, winds are expected and part of the season
  // During wet season, strong winds often precede thunderstorms
  final isClearlySunny = isDayTime && cloudiness <= 30 && visibility >= 8000 && (isStrongUV || isVeryStrongUV);
  if (windSpeed >= 6 && !isRaining && !isClearlySunny && !isDrySeason) return 'Windy';
  // Higher threshold during dry season since harmattan winds are normal
  if (windSpeed >= 9 && !isRaining && isDrySeason && !isClearlySunny) return 'Windy';

  // ☀️ Daytime conditions (UV and weather description are more reliable than cloud cover)
  if (isDayTime && !isRaining && !isStormy) {
    // Use weather description and UV as primary indicators, clouds as secondary
    final hasSunnyDesc = weatherDesc.contains('clear') || weatherDesc.contains('sun');
    final hasCloudyDesc = weatherDesc.contains('overcast') || weatherDesc.contains('cloud');
    
    // Very sunny: High UV regardless of cloud cover (thin high clouds)
    if ((isVeryStrongUV || isStrongUV) && (hasSunnyDesc || (!hasCloudyDesc && visibility >= 8000))) {
      return 'Very Sunny';
    }
    
    // Mostly sunny: Strong UV with decent visibility
    if ((isVeryStrongUV || isStrongUV) && visibility >= 6000 && !hasCloudyDesc) {
      return 'Mostly Sunny';
    }
    
    // Partly sunny: Decent UV breaking through
    if ((isStrongUV || isDecentUV) && visibility >= 5000) {
      return 'Partly Sunny';
    }
    
    // Use cloud cover only when UV and description are ambiguous
    if (isLowUV && (hasCloudyDesc || cloudiness >= 85)) {
      return 'Mostly Cloudy';
    }
    
    // Mixed conditions
    if (isDecentUV || (!hasCloudyDesc && cloudiness < 80)) {
      return 'Partly Cloudy';
    }
  }

  // 🌙 Nighttime conditions
  if (!isDayTime && !isRaining && !isStormy) {
    if (cloudiness <= 70) return 'Mostly Cloudy';
  
  }

  // Default fallback
  return 'Cloudy';
}






// String getFeelsLikeWeather(Map<String, dynamic> data) {
//   final current = data['current'];
//   final cloudiness = (current['clouds'] as num).floor(); // %
//   final visibility = (current['visibility'] as num).floor(); // meters
//   final uvi = (current['uvi'] as num).floor();
//   final windSpeed = current['wind_speed'];
//   final humidity = current['humidity'];
//   final temp = current['temp'];
//   final weatherDesc = current['weather'][0]['description'].toLowerCase();
//   final rainVolume = current['rain']?['1h'] ?? current['rain']?['3h'] ?? 0.0;

//   final now = DateTime.fromMillisecondsSinceEpoch(current['dt'] * 1000, isUtc: true);
//   final sunrise = DateTime.fromMillisecondsSinceEpoch(current['sunrise'] * 1000, isUtc: true);
//   final sunset = DateTime.fromMillisecondsSinceEpoch(current['sunset'] * 1000, isUtc: true);
//   final isDayTime = now.isAfter(sunrise) && now.isBefore(sunset);

//   final isStormy = weatherDesc.contains('storm') || weatherDesc.contains('thunder') ||  weatherDesc.contains('lightning');
//   final isDusty = weatherDesc.contains('dust') || weatherDesc.contains('sand') || weatherDesc.contains('haze') || weatherDesc.contains('smoke');
//   final isDrizzle = weatherDesc.contains('drizzle');
//   final isRainDesc = weatherDesc.contains('rain') || weatherDesc.contains('shower');
//   final isLightRainDesc = weatherDesc.contains('light rain');
//   final isHeavyRainDesc = weatherDesc.contains('heavy rain');

//   final isLowHumidity = humidity <= 40;
//   final isLowVisibility = visibility < 3500;
//   final isHighVisibility = visibility >= 8000;

//   final isVeryClear = cloudiness <= 50;
//   final isMostlyCloudy = cloudiness > 70 && cloudiness <= 100;

//   final isLowUV = uvi <= 3;
//   final isDecentUV = uvi > 3 && uvi <= 5;
//   final isStrongUV = uvi > 5 && uvi <= 7;
//   final isVeryStrongUV = uvi > 7;

//   final isRaining = rainVolume > 0.0 || isRainDesc;

//    print(
//     'UV: $uvi, Clouds: $cloudiness, Visibility: $visibility, Time: $now, Sunrise: $sunrise, Sunset: $sunset, rain: $rainVolume, storm: $isStormy, dust: $isDusty',
//   );

//   // 🌩️ Storm
//   if (isStormy && (rainVolume >= 7.0 || isHeavyRainDesc)) return 'Stormy Rain';
//   if (isStormy && !isRaining) return 'Stormy Winds';

//   // 🌧️ Rain
//   if (rainVolume >= 7.0 || isHeavyRainDesc) return 'Heavy Rain';
//   if (rainVolume >= 2.0 || (isRainDesc && !isLightRainDesc)) return 'Rainy';
//   if (isDrizzle || isLightRainDesc || rainVolume > 0.0) return 'Light Rain';

//   // 🌫️ Harmattan
//   if ((isDusty && isLowHumidity) || (isLowVisibility && isDusty) || (temp <= 25 && isLowHumidity)) {
//     return 'Harmattan';
//   }

//   // 💨 Windy (but only if it's not bright and sunny)
//   final isClearlySunny = isVeryClear && isHighVisibility && (isStrongUV || isVeryStrongUV);
//   if (windSpeed >= 8 && !isRaining && !isClearlySunny) return 'Windy';

//   // ☀️ Daytime Brightness
//   if (isDayTime && !isRaining && !isStormy) {
//     if (cloudiness <= 20 && (isVeryStrongUV || isHighVisibility)) return ' Very Sunny';
//     if (cloudiness <= 50 && (isVeryStrongUV || isHighVisibility)) return 'Mostly Sunny';
//     if (cloudiness <= 70 && (isStrongUV || isHighVisibility)) return 'Partly Sunny';
//     if (isMostlyCloudy && (isLowUV || isHighVisibility)) return 'Mostly Cloudy';
//     if (isMostlyCloudy && (isDecentUV || isHighVisibility)) return 'Partly Cloudy';
//   }

//   // 🌙 Nighttime
//   if (!isDayTime) {
//     if (cloudiness <= 70) return 'Mostly Cloudy';
//   }

//   // Default
//   return 'Cloudy';
// }
