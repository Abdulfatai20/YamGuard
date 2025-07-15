import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:yam_guard/config/api_keys.dart';
import 'package:yam_guard/helpers/image_helper.dart';
import 'package:yam_guard/helpers/today_forecast_image_helper.dart';

class WeatherService {
  static const _baseUrl = 'https://api.openweathermap.org/data/3.0/onecall';
  final double _latitude = 7.38; // latitude for Osogbo 7.38, 3.93
  final double _longitude = 3.93; // longitude for Osogbo

  // 🌀 FULL WEATHER DATA (current, hourly, daily, alerts)
  Future<Map<String, dynamic>> fetchWeatherData() async {
    final url = Uri.parse(
      '$_baseUrl?lat=$_latitude&lon=$_longitude&exclude=minutely&units=metric&appid=${ApiKeys.openWeather}',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load weather data: ${response.body}');
    }
  }

  // 📆 CLEAN 7-DAY FORECAST FOR UI DISPLAY
  Future<List<Map<String, String>>> fetch7DayForecast() async {
    final url = Uri.parse(
      '$_baseUrl?lat=$_latitude&lon=$_longitude&exclude=current,minutely,hourly,alerts&units=metric&appid=${ApiKeys.openWeather}',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to load 7-day forecast: ${response.body}');
    }

    String capitalize(String text) => text[0].toUpperCase() + text.substring(1);
    final data = jsonDecode(response.body);
    final List daily = data['daily'];

    return daily.skip(1).map<Map<String, String>>((day) {
      final descriptionRaw = day['weather'][0]['description'];
      final date = DateTime.fromMillisecondsSinceEpoch(day['dt'] * 1000);
      final formattedDate = DateFormat('MMM, d').format(date);
      final description = capitalize(descriptionRaw);
      final temp = '$description, ${day['temp']['day'].round()}°';

      final imagePath = getCustomImageForDescription(description);

      return {'date': formattedDate, 'temp': temp, 'image': imagePath};
    }).toList();
  }

  Future<Map<String, String>> fetchTodayForecast() async {
    final url = Uri.parse(
      '$_baseUrl?lat=$_latitude&lon=$_longitude&exclude=minutely&units=metric&appid=${ApiKeys.openWeather}',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to load today’s forecast: ${response.body}');
    }
    String capitalize(String text) => text[0].toUpperCase() + text.substring(1);

    final data = jsonDecode(response.body);
    final today = data['daily'][0];
    final descriptionRaw = today['weather'][0]['description'];
    final description = capitalize(descriptionRaw);
    final date = DateTime.fromMillisecondsSinceEpoch(today['dt'] * 1000);
    final formattedDate = DateFormat('MMM, d').format(date);
    final temp = '$description, ${today['temp']['day'].round()}°';

    final imagePath = getCustomImageForDescription(description);
    final advice = getStorageAdviceForToday(description);
    return {
    'date': formattedDate,
    'temp': temp,
    'image': imagePath,
    'advice': advice,
  };
  }
}
