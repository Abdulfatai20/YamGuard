String getAdviceForWeather(String description) {
  final lower = description.toLowerCase();
  if (lower.contains('cloud')) return 'Cloudy today - less sun. Hold off on drying yams.';
  if (lower.contains('rain')) return 'Rain likely. Keep yam covered or inside storage.';
  if (lower.contains('clear') || lower.contains('sun')) {
    return 'Good sun today. You can spread yam to dry.';
  }
  if (lower.contains('fog')) return 'Dry and dusty - check stored yam for cracks.';
  if (lower.contains('wind')) return 'Wind’s strong. Tie down storage covers.';
  return 'Stay prepared for weather changes';
}
