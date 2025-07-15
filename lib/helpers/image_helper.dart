// Helper to map description to local images
String getCustomImageForDescription(String description) {
  description = description.toLowerCase();
  if (description.contains('rain') ||
      description.contains('drizzle') ||
      description.contains('shower')) {
    return 'assets/images/rainy.png';
  }
  if (description.contains('partly') || description.contains('scattered')) {
    return 'assets/images/partly_cloudy.png';
  }

  if (description.contains('cloud') ||
      description.contains('overcast') ||
      description.contains('broken')) {
    return 'assets/images/mostly_cloudy.png';
  }
  if (description.contains('clear') || description.contains('sunny')) {
    return 'assets/images/sunlight.png';
  }

  if (description.contains('thunderstorm') ||
      description.contains('lightning')) {
    return 'assets/images/stormy.png'; // thunderstorm, lightning
  }
  if (description.contains('dust') ||
      description.contains('sand') ||
      description.contains('haze') ||
      description.contains('smoke')) {
    return 'assets/images/harmattan.png'; // dusty, sandy, hazy, smoke — harmattan-like
  }
  if (description.contains('wind') || description.contains('breeze')) {
    return 'assets/images/windy.png'; // strong breeze, windy
  }
  return 'assets/weather/default.png'; // fallback image
}
