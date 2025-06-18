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
      return 'Big storm with rain might come today! Keep all yam covered now. Don\'t work outside.';
    }
    return 'Big storm might come today. Cover yam storage now and stay inside when it comes.';
  }
  
  // Heavy rain conditions (today's specific timing)
  if ((lower.contains('heavy') && lower.contains('rain')) || 
      lower.contains('heavy intensity rain') || 
      lower.contains('extreme rain')) {
    if (isPlantingSeason) {
      return 'Heavy rain might come today - good for planted yam! Check low places for too much water this evening.';
    }
    if (isHarvestSeason) {
      return 'Heavy rain might fall today. Don\'t harvest yam - wait for tomorrow. Move drying yam to cover now.';
    }
    return 'Heavy rain might fall all day. Cannot dry yam - check storage and barns instead.';
  }
  
  // Light to moderate rain (today's timing matters)
  if (lower.contains('drizzle') || lower.contains('light rain')) {
    if (isDrySeason) {
      return 'Small rain might come during harmattan today - not normal! Wait to see if it stops, then dry yam.';
    }
    if (isMorning) {
      return 'Small rain might come this morning. May stop later - get yam ready to dry if sun comes.';
    }
    return 'Small rain might come today. Some farm work possible - keep covers ready.';
  }
  
  if (lower.contains('rain') || lower.contains('shower')) {
    if (isPlantingSeason) {
      return 'Rain might come today - good for growing yam! Plan to remove weeds tomorrow after ground softens.';
    }
    if (isMorning) {
      return 'Rain might come today. Bring drying yam inside now and don\'t spread new ones.';
    }
    return 'Rain might fall today. Cannot dry yam - good time to arrange barn and fix tools.';
  }
  
  // Clear and sunny conditions (maximize today's opportunity)
  if (lower.contains('clear') || lower.contains('sunny') || 
      (lower.contains('sun') && !lower.contains('cloudy'))) {
    if (isDrySeason) {
      if (isMorning) {
        return 'Good harmattan sun might come today! Start spreading yam early - should be good drying day.';
      }
      return 'Good sunshine might last all day! Great chance to dry yam - work until sunset, collect at night.';
    }
    if (isHarvestSeason) {
      return 'Good sun might come today! Harvest yam early morning, spread quickly for drying. Collect before evening.';
    }
    if (isMorning) {
      return 'Good sunny day might come! Start drying yam now - should be good all day.';
    }
    return 'Good sunshine might come today! Spread yam for drying and do other outside farm work.';
  }
  
  // Harmattan and dusty conditions (today's specific actions)
  if (lower.contains('dust') || lower.contains('sand') || lower.contains('haze')) {
    if (isDrySeason) {
      return 'Heavy harmattan dust might come today. Still good for drying but cover stored yam so dust don\'t settle.';
    }
    return 'Dusty air might come today - protect stored yam and check yesterday\'s dried yam for cracks.';
  }
  
  if (lower.contains('fog') || lower.contains('mist')) {
    if (isMorning) {
      return 'Fog might come early today - wait until it clears around 10am before spreading yam to dry.';
    }
    return 'Misty air might come today. Check stored yam for too much water and make sure air moves well.';
  }
  
  // Cloudy conditions (today's opportunities)
  if (lower.contains('overcast')) {
    return 'Sky might be completely covered today - cannot dry yam. Good day to sort and clean storage.';
  }
  
  if (lower.contains('cloud')) {
    if (isDrySeason) {
      return 'Cloudy harmattan day might come - less hot sun but still try drying if no rain expected.';
    }
    if (isAfternoon) {
      return 'Cloudy afternoon might come - small time for drying. Work on fixing things and plan tomorrow.';
    }
    return 'Cloudy day might come - not good for drying. Good day to sort yam and arrange storage.';
  }
  
  // Windy conditions (today's precautions)
  if (lower.contains('wind') || lower.contains('breezy')) {
    if (isDrySeason) {
      return 'Windy harmattan day might come - normal for this time. Keep covers tight but continue drying.';
    }
    return 'Strong wind might come today. Tie down all storage covers now and watch for weather changes tonight.';
  }
  
  // Today's seasonal defaults
  if (isDrySeason) {
    return 'Normal harmattan day might come - watch weather and use dry weather well for yam work.';
  }
  
  if (isPlantingSeason) {
    return 'Good planting time weather might come today. Check ground water and plan any planting work.';
  }
  
  if (isHarvestSeason) {
    return 'Harvest time weather might come today. Check farm and plan cutting yam based on weather.';
  }
  
  // General today fallback
  return 'Mixed weather might come today. Be ready to change farm work based on weather changes.';
}