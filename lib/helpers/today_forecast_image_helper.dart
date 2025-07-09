String getStorageAdviceForToday(String description) {
  final lower = description.toLowerCase();

  if (lower.contains('storm') || lower.contains('thunder') || lower.contains('lightning')) {
    return 'Storm is expected today — store all yams indoors and secure covers tightly.';
  }

  if (lower.contains('heavy') && lower.contains('rain')) {
    return 'Heavy rain is likely — store yams indoors and ensure the area stays dry and ventilated.';
  }

  if (lower.contains('light rain') || lower.contains('drizzle')) {
    return 'Light rain might fall — avoid open pit storage and use covered indoor methods if possible.';
  }

  if (lower.contains('shower') || lower.contains('rain') || lower.contains('rainy')) {
    return 'Rainy conditions today — best to store yams in well-ventilated indoor areas.';
  }

  if (lower.contains('clear') || lower.contains('sunny')) {
    return 'Clear and sunny day — good for drying yam before storage in ash/sawdust.';
  }

  if (lower.contains('cloud')) {
    return 'Cloudy weather today — store in dry ventilated spaces to prevent moisture buildup.';
  }

  if (lower.contains('fog') || lower.contains('mist')) {
    return 'Foggy conditions today — keep yams in dry areas with good airflow to prevent rot.';
  }

  if (lower.contains('dust') || lower.contains('haze') || lower.contains('sand')) {
    return 'Dusty air expected — cover yams properly to prevent dust contamination.';
  }

  if (lower.contains('wind')) {
    return 'Windy weather — secure barn roofs and keep storage covers tight.';
  }

  return 'Mixed weather today — choose indoor or protected storage to reduce yam spoilage risk.';
}
