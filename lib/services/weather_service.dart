import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:yam_guard/config/api_keys.dart';
import 'package:yam_guard/helpers/forecast_image_helper.dart';

class WeatherService {
  static const _baseUrl = 'https://api.openweathermap.org/data/3.0/onecall';
  final double _latitude = 7.767; // latitude for Osogbo
  final double _longitude = 4.567; // longitude for Osogbo

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

    String capitalize(String text) =>
    text[0].toUpperCase() + text.substring(1);
    final data = jsonDecode(response.body);
    final List daily = data['daily'];

    return daily.skip(1).map<Map<String, String>>((day) {
      final descriptionRaw = day['weather'][0]['description'];
      final date = DateTime.fromMillisecondsSinceEpoch(day['dt'] * 1000);
      final formattedDate = DateFormat('MMM, d').format(date);
      final description = capitalize(descriptionRaw); 
      final temp = '$description, ${day['temp']['day'].round()}°';

      final imagePath = getCustomImageForDescription(description);

      return {
        'date': formattedDate,
        'temp': temp,
        'image': imagePath,
      };
    }).toList();
  }
}
