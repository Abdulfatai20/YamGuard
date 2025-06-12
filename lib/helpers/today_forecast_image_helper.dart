String getAdviceForWeather(String description) {
  final lower = description.toLowerCase();
  
  // Get current time context for today
  final now = DateTime.now();
  final currentMonth = now.month;
  final currentHour = now.hour;
  final isDrySeason = currentMonth >= 11 || currentMonth <= 3; // Nov-Mar (Harmattan season)
  final isPlantingSeason = currentMonth >= 4 && currentMonth <= 6; // Apr-Jun
  final isHarvestSeason = currentMonth >= 9 && currentMonth <= 11; // Sep-Nov
  final isMorning = currentHour < 12;
  final isAfternoon = currentHour >= 12 && currentHour < 17;
  
  // Storm and heavy rain conditions (immediate action needed)
  if (lower.contains('storm') || lower.contains('thunder') || lower.contains('lightning')) {
    if (lower.contains('rain')) {
      return 'Thunderstorms today! Secure equipment now and keep all yams under cover. No field work.';
    }
    return 'Storms expected today. Secure storage covers immediately and stay indoors during peak intensity.';
  }
  
  // Heavy rain conditions (today's specific timing)
  if ((lower.contains('heavy') && lower.contains('rain')) || 
      lower.contains('heavy intensity rain') || 
      lower.contains('extreme rain')) {
    if (isPlantingSeason) {
      return 'Heavy rain today - great for planted yams! Check low areas for waterlogging this evening.';
    }
    if (isHarvestSeason) {
      return 'Heavy rain today. Don\'t harvest - wait for tomorrow. Move any drying yams to shelter now.';
    }
    return 'Heavy rain all day. No drying possible - focus on storage maintenance and barn checks.';
  }
  
  // Light to moderate rain (today's timing matters)
  if (lower.contains('drizzle') || lower.contains('light rain')) {
    if (isDrySeason) {
      return 'Light rain during harmattan today - unusual! Wait to see if it stops, then resume drying.';
    }
    if (isMorning) {
      return 'Light rain this morning. May clear later - prepare yams for drying if sun comes out.';
    }
    return 'Light rain today. Some farm work possible between showers - keep materials ready to cover.';
  }
  
  if (lower.contains('rain') || lower.contains('shower')) {
    if (isPlantingSeason) {
      return 'Rain today - perfect timing for yam growth! Plan weeding for tomorrow after soil softens.';
    }
    if (isMorning) {
      return 'Rain expected today. Bring in any drying yams now and postpone spreading new ones.';
    }
    return 'Rainy day ahead. No drying today - good time for barn organization and equipment maintenance.';
  }
  
  // Clear and sunny conditions (maximize today's opportunity)
  if (lower.contains('clear') || lower.contains('sunny') || 
      (lower.contains('sun') && !lower.contains('cloudy'))) {
    if (isDrySeason) {
      if (isMorning) {
        return 'Perfect harmattan sun today! Start spreading yams early - excellent drying day ahead.';
      }
      return 'Brilliant sunshine all day! Maximum drying opportunity - work until sunset, collect at dusk.';
    }
    if (isHarvestSeason) {
      return 'Excellent sun today! Harvest early morning, spread immediately for drying. Collect before evening.';
    }
    if (isMorning) {
      return 'Beautiful sunny day ahead! Start drying yams now - should be perfect all day.';
    }
    return 'Great sunshine today! Spread yams for drying and plan other outdoor farm work.';
  }
  
  // Harmattan and dusty conditions (today's specific actions)
  if (lower.contains('dust') || lower.contains('sand') || lower.contains('haze')) {
    if (isDrySeason) {
      return 'Heavy harmattan dust today. Still good for drying but cover stored yams to prevent dust settling.';
    }
    return 'Dusty conditions today - protect stored yams and check for cracks in yesterday\'s dried batch.';
  }
  
  if (lower.contains('fog') || lower.contains('mist')) {
    if (isMorning) {
      return 'Foggy start today - wait until it clears around 10am before spreading yams to dry.';
    }
    return 'Misty conditions today. Check stored yams for excess moisture and ensure good ventilation.';
  }
  
  // Cloudy conditions (today's opportunities)
  if (lower.contains('overcast')) {
    return 'Completely overcast today - no drying possible. Perfect day for sorting, cleaning storage areas.';
  }
  
  if (lower.contains('cloud')) {
    if (isDrySeason) {
      return 'Cloudy harmattan day - less intense sun but still try drying if no rain expected.';
    }
    if (isAfternoon) {
      return 'Cloudy afternoon ahead - limited drying time. Focus on maintenance and planning tomorrow.';
    }
    return 'Cloudy today - not ideal for drying. Good day for yam sorting and storage organization.';
  }
  
  // Windy conditions (today's precautions)
  if (lower.contains('wind') || lower.contains('breezy')) {
    if (isDrySeason) {
      return 'Windy harmattan day - normal for season. Secure light covers but continue drying operations.';
    }
    return 'Very windy today. Secure all storage covers now and watch for weather changes this evening.';
  }
  
  // Today's seasonal defaults
  if (isDrySeason) {
    return 'Typical harmattan day - monitor conditions and make the most of dry weather for yam processing.';
  }
  
  if (isPlantingSeason) {
    return 'Good planting season weather today. Check soil moisture and plan any planting activities.';
  }
  
  if (isHarvestSeason) {
    return 'Harvest season conditions today. Assess fields and plan harvesting based on current weather.';
  }
  
  // General today fallback
  return 'Mixed conditions today. Stay flexible and adjust farm activities based on changing weather.';
}

// String getAdviceForWeather(String description) {
//   final lower = description.toLowerCase();

//   // Check more specific conditions first
//   if ((lower.contains('heavy') && lower.contains('rain')) || lower.contains('heavy intensity rain')) {
//     return 'Heavy rain expected. Secure barns and avoid drying.';
//   }
//   if (lower.contains('rain')) {
//     return 'Rain likely. Keep yam covered or inside storage.';
//   }
//   if (lower.contains('cloud')) {
//     return 'Cloudy today – less sun. Delay drying yams.';
//   }
//   if (lower.contains('clear') || lower.contains('sun')) {
//     return 'Good sun today. You can spread yam to dry.';
//   }
//   if (lower.contains('fog') || lower.contains('haze') || lower.contains('dust')) {
//     return 'Dry air. Check yam in storage for cracks.';
//   }
//   if (lower.contains('wind')) {
//     return 'Wind’s strong. Tie down storage covers.';
//   }

//   return 'Stay alert. Weather may affect yam farming.';
// }
