import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yam_guard/services/weather_service.dart';

final weatherProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final weatherService = WeatherService();
  final weatherData = await weatherService.fetchWeatherData();
  return weatherData;
});