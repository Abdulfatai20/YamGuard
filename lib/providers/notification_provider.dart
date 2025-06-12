// providers/notification_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yam_guard/model/notification_item.dart';
import 'package:yam_guard/providers/firestore_provider.dart';
import 'package:yam_guard/services/expiration_notification_service.dart';
import 'package:yam_guard/services/weather_notification_service.dart';
import 'package:yam_guard/services/weather_service.dart';

// Provider for notification service
final notificationServiceProvider = Provider<ExpirationNotificationService>((ref) {
  final firestore = ref.read(firestoreProvider);
  return ExpirationNotificationService(firestore);
});

// Provider for weather service
final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService();
});

// Provider for weather notification service
final weatherNotificationServiceProvider = Provider<WeatherNotificationService>((ref) {
  final notificationService = ref.read(notificationServiceProvider);
  final weatherService = ref.read(weatherServiceProvider);
  final firestore = ref.read(firestoreProvider);
  return WeatherNotificationService(notificationService, weatherService, firestore);
});

// Provider for notifications stream
final notificationsStreamProvider = StreamProvider<List<NotificationItem>>((ref) {
  final firestore = ref.read(firestoreProvider);
  
  return firestore
      .collection('notifications')
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => NotificationItem.fromMap(doc.id, doc.data()))
          .toList());
});

// Provider for unread notification count
final unreadNotificationCountProvider = StreamProvider<int>((ref) {
  final firestore = ref.read(firestoreProvider);
  
  return firestore
      .collection('notifications')
      .where('isRead', isEqualTo: false)
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

// Provider for checking expiring harvests periodically
final expiringHarvestCheckerProvider = Provider<void>((ref) {
  final notificationService = ref.read(notificationServiceProvider);
  
  // Check every hour for expiring harvests
  Stream.periodic(Duration(hours: 1)).listen((_) {
    notificationService.checkExpiringHarvests();
  });
  
  // Also check immediately when app starts
  notificationService.checkExpiringHarvests();
});

// Provider for checking weather conditions periodically
final weatherAlertCheckerProvider = Provider<void>((ref) {
  final weatherNotificationService = ref.read(weatherNotificationServiceProvider);
  
  // Check every 6 hours for extreme weather conditions
  Stream.periodic(Duration(hours: 6)).listen((_) {
    weatherNotificationService.checkExtremeWeatherConditions();
  });
  
  // Also check immediately when app starts
  weatherNotificationService.checkExtremeWeatherConditions();
  
  // Clean up old weather notifications once daily
  Stream.periodic(Duration(days: 1)).listen((_) {
    weatherNotificationService.cleanupOldWeatherNotifications();
  });
});