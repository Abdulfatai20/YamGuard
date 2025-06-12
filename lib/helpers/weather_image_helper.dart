String getWeatherImageFromFeeling(String feel) {
  switch (feel.toLowerCase()) {
    case 'stormy rain':
    return 'assets/images/stormy_rain.png';
    case 'stormy winds':
    return 'assets/images/stormy.png';
    case 'heavy rain':
    return 'assets/images/rainy.png';
    case 'rainy':
    return 'assets/images/rainy.png';
    case 'light rain':
    return 'assets/images/light_rain.png';
    case 'harmattan':
    return 'assets/images/harmattan.png';
    case 'windy':
    return 'assets/images/windy.png';
    case 'very sunny':
    return 'assets/images/sunlight.png';
    case 'mostly sunny':
      return 'assets/images/sunlight.png';
    case 'partly sunny':
      return 'assets/images/partly_sunny.png';
    case 'partly cloudy':
      return 'assets/images/partly_cloudy.png';
    case 'mostly cloudy':
    return 'assets/images/Mostly_cloudy.png';
    default:
      return 'assets/images/cloudy.png';
  }
}
// This function returns the path to the image based on the weather feel.