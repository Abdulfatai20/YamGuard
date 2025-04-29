import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yam_guard/services/weather_service.dart';

final forecastProvider = FutureProvider<List<Map<String, String>>>((ref) async {
  final weatherService = WeatherService();
  return await weatherService.fetch7DayForecast();
});