// services/weather_notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yam_guard/services/expiration_notification_service.dart';
import 'package:yam_guard/services/weather_service.dart';
import 'package:yam_guard/auth/auth_service.dart';

class WeatherNotificationService {
  final ExpirationNotificationService _notificationService;
  final WeatherService _weatherService;
  final FirebaseFirestore _firestore;
  final AuthService _authService;

  WeatherNotificationService(
    this._notificationService,
    this._weatherService,
    this._firestore,
    this._authService,
  );

  // Get current user ID
  String? get _currentUserId => _authService.currentUser?.uid;

  // Check for extreme weather conditions and create notifications
  Future<void> checkExtremeWeatherConditions() async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      // Fetch full weather data including daily forecasts
      final weatherData = await _weatherService.fetchWeatherData();
      final List daily = weatherData['daily'];

      // Check tomorrow's weather (index 1)
      if (daily.length > 1) {
        final tomorrow = daily[1];
        await _checkAndCreateWeatherAlert(tomorrow, 'tomorrow', userId);
      }

      // Check day after tomorrow's weather (index 2)
      if (daily.length > 2) {
        final dayAfterTomorrow = daily[2];
        await _checkAndCreateWeatherAlert(
          dayAfterTomorrow,
          'day_after_tomorrow',
          userId,
        );
      }
    } catch (e) {
      print('Error checking extreme weather conditions: $e');
    }
  }

  Future<void> _checkAndCreateWeatherAlert(
    Map<String, dynamic> dayData,
    String timeframe,
    String userId,
  ) async {
    final weatherCondition = dayData['weather'][0];
    final description =
        weatherCondition['description'].toString().toLowerCase();
    final mainCondition = weatherCondition['main'].toString().toLowerCase();
    final windSpeed = dayData['wind_speed']?.toDouble() ?? 0.0;
    final humidity = dayData['humidity']?.toInt() ?? 0;
    final tempMax = dayData['temp']['max']?.toDouble() ?? 0.0;
    final tempMin = dayData['temp']['min']?.toDouble() ?? 0.0;
    // Fixed precipitation calculation with proper null safety
    double precipitation = 0.0;

    // Check for rain data
    if (dayData['rain'] != null && dayData['rain'] is Map) {
      final rainData = dayData['rain'] as Map<String, dynamic>;
      precipitation = rainData['1h']?.toDouble() ?? 0.0;
    }

    final alertDate = DateTime.fromMillisecondsSinceEpoch(dayData['dt'] * 1000);
    final timeframeText = timeframe == 'tomorrow' ? 'tomorrow' : 'in 2 days';

    // Check for extreme weather conditions
    final weatherAlert = _getWeatherAlert(
      description,
      mainCondition,
      windSpeed,
      humidity,
      tempMax,
      tempMin,
      precipitation,
      timeframeText,
      alertDate,
    );

    if (weatherAlert != null) {
      // Check if we already created a notification for this date and condition for this user
      final existingNotification =
          await _firestore
              .collection('notifications')
              .where('userId', isEqualTo: userId)
              .where('type', isEqualTo: 'weather_alert')
              .where('data.alertDate', isEqualTo: alertDate.toIso8601String())
              .where('data.condition', isEqualTo: weatherAlert['condition'])
              .get();

      if (existingNotification.docs.isEmpty) {
        await _notificationService.createNotification(
          title: weatherAlert['title']!,
          message: weatherAlert['message']!,
          type: 'weather_alert',
          data: {
            'alertDate': alertDate.toIso8601String(),
            'condition': weatherAlert['condition']!,
            'severity': weatherAlert['severity']!,
            'timeframe': timeframe,
            'windSpeed': windSpeed,
            'humidity': humidity,
            'tempMax': tempMax,
            'tempMin': tempMin,
            'precipitation': precipitation,
          },
        );
      }
    }
  }

  Map<String, String>? _getWeatherAlert(
    String description,
    String mainCondition,
    double windSpeed,
    int humidity,
    double tempMax,
    double tempMin,
    double precipitation,
    String timeframe,
    DateTime alertDate,
  ) {
    // Heavy Rain Alert
    if ((description.contains('heavy') && description.contains('rain')) ||
        precipitation > 10.0 ||
        mainCondition == 'thunderstorm') {
      return {
        'title': 'Heavy Rain Coming! ⛈️',
        'message':
            'Heavy rain might come $timeframe. Keep yam covered and don\'t dry outside.',
        'condition': 'heavy_rain',
        'severity': 'high',
      };
    }

    // Strong Wind Alert
    if (windSpeed > 10.0 || description.contains('wind')) {
      return {
        'title': 'Strong Wind Coming! 💨',
        'message':
            'Strong wind might come $timeframe. Tie down covers and make drying area safe.',
        'condition': 'strong_wind',
        'severity': 'medium',
      };
    }

    // Extreme Heat Alert
    if (tempMax > 38.0) {
      return {
        'title': 'Very Hot Day Coming! 🌡️',
        'message':
            'Very hot weather $timeframe (${tempMax.round()}°C). Check yam storage - don\'t let it get too hot.',
        'condition': 'extreme_heat',
        'severity': 'medium',
      };
    }

    // Flooding Risk Alert (Heavy rain + high humidity)
    if (precipitation > 5.0 && humidity > 85) {
      return {
        'title': 'Flood Risk Coming! 🌊',
        'message':
            'Heavy rain and wet air $timeframe. Water might flood - put yam higher up.',
        'condition': 'flood_risk',
        'severity': 'high',
      };
    }

    // Drought Conditions Alert
    if (tempMax > 35.0 && humidity < 30 && precipitation == 0.0) {
      return {
        'title': 'Very Dry Weather Coming! ☀️',
        'message':
            'Very dry weather $timeframe. Watch stored yam for cracks and drying out.',
        'condition': 'drought',
        'severity': 'medium',
      };
    }

    // Hail/Storm Alert
    if (description.contains('hail') ||
        (mainCondition == 'thunderstorm' && windSpeed > 8.0)) {
      return {
        'title': 'Big Storm Coming! ⛈️',
        'message':
            'Big storm might come $timeframe. Move yam to strong indoor storage.',
        'condition': 'severe_storm',
        'severity': 'high',
      };
    }

    // Fog/Low Visibility Alert
    if (description.contains('fog') || description.contains('mist')) {
      return {
        'title': 'Heavy Fog Coming! 🌫️',
        'message':
            'Thick fog might come $timeframe. Don\'t transport yam - visibility low.',
        'condition': 'heavy_fog',
        'severity': 'low',
      };
    }

    // Moderate Rain Alert (still important for yam farming)s
    if (mainCondition == 'rain' && precipitation > 2.0) {
      return {
        'title': 'Rain Coming! 🌧️',
        'message':
            'Rain might come $timeframe. Cover drying yam and make storage safe.',
        'condition': 'moderate_rain',
        'severity': 'low',
      };
    }

    return null; // No extreme weather detected
  }

  // Clean up old weather notifications for current user only (older than 3 days)
  Future<void> cleanupOldWeatherNotifications() async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      final oldWeatherNotifications =
          await _firestore
              .collection('notifications')
              .where('userId', isEqualTo: userId)
              .where('type', isEqualTo: 'weather_alert')
              .where('createdAt', isLessThan: Timestamp.fromDate(threeDaysAgo))
              .get();

      final batch = _firestore.batch();
      for (final doc in oldWeatherNotifications.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Error cleaning up old weather notifications: $e');
    }
  }
}