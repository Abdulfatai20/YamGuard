String getAdviceForWeather(String description) {
  final lower = description.toLowerCase();
  if (lower.contains('cloud')) {
    return 'Cloudy today - less sun. Hold off on drying yams.';
  }
  if ((lower.contains('heavy') && lower.contains('rain')) || lower.contains('heavy intensity rain')) {
    return 'Heavy rain expected. Secure barns and avoid drying.';
  }
  if (lower.contains('rain')) {
    return 'Rain likely. Keep yam covered or inside storage.';
  }
  if (lower.contains('clear') || lower.contains('sun')) {
    return 'Good sun today. You can spread yam to dry.';
  }
  if (lower.contains('fog')) {
    return 'Dry and dusty - check stored yam for cracks.';
  }
  if (lower.contains('wind')) return 'Wind’s strong. Tie down storage covers.';
  return 'Stay prepared for weather changes';
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
