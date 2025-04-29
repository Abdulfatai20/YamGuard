import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yam_guard/services/weather_service.dart';

final todayForecastProvider = FutureProvider<Map<String, String>>((ref) async {
  final service = WeatherService();
  return await service.fetchTodayForecast();
});
