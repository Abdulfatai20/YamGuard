// Fixed notification_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yam_guard/model/notification_item.dart';
import 'package:yam_guard/providers/auth_service_provider.dart';
import 'package:yam_guard/providers/firestore_provider.dart';
import 'package:yam_guard/services/notification_service.dart';
import 'package:yam_guard/services/weather_notification_service.dart';
import 'package:yam_guard/services/weather_service.dart';

// Provider for notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final firestore = ref.read(firestoreProvider);
  final authService = ref.read(authServiceProvider);
  return NotificationService(firestore, authService);
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
  final authService = ref.read(authServiceProvider);
  return WeatherNotificationService(notificationService, weatherService, firestore, authService);
});

// Fixed notifications stream provider - simplified to avoid hanging
final notificationsStreamProvider = StreamProvider<List<NotificationItem>>((ref) {
  final firestore = ref.read(firestoreProvider);
  final authService = ref.read(authServiceProvider);
  
  final currentUser = authService.currentUser;
  if (currentUser == null) {
    return Stream.value(<NotificationItem>[]);
  }
  
  // First try without orderBy to avoid index issues
  return firestore
      .collection('notifications')
      .where('userId', isEqualTo: currentUser.uid)
      .limit(50)
      .snapshots()
      .asyncMap((snapshot) async {
        try {
          final notifications = <NotificationItem>[];
          
          for (final doc in snapshot.docs) {
            try {
              final notification = NotificationItem.fromMap(doc.id, doc.data());
              notifications.add(notification);
            } catch (e) {
              print('Error parsing notification ${doc.id}: $e');
              continue;
            }
          }
          
          // Sort in memory instead of using orderBy
          notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          
          print('Loaded ${notifications.length} notifications for user ${currentUser.uid}');
          return notifications;
          
        } catch (e) {
          print('Error processing notifications: $e');
          return <NotificationItem>[];
        }
      });
});

// Fixed unread notification count provider - more robust handling
final unreadNotificationCountProvider = StreamProvider<int>((ref) {
  final firestore = ref.read(firestoreProvider);
  final authService = ref.read(authServiceProvider);
  
  final currentUser = authService.currentUser;
  if (currentUser == null) {
    return Stream.value(0);
  }
  
  return firestore
      .collection('notifications')
      .where('userId', isEqualTo: currentUser.uid)
      .snapshots()
      .asyncMap((snapshot) async {
        try {
          int unreadCount = 0;
          
          for (final doc in snapshot.docs) {
            final data = doc.data();
            // Check if isRead field exists and is false, or if it doesn't exist (default to unread)
            final isRead = data['isRead'];
            if (isRead == null || isRead == false) {
              unreadCount++;
            }
          }
          
          print('Unread notifications count: $unreadCount out of ${snapshot.docs.length} total');
          return unreadCount;
        } catch (e) {
          print('Unread count error: $e');
          return 0;
        }
      });
});

// Provider for checking weather conditions periodically
final weatherAlertCheckerProvider = Provider<void>((ref) {
  final weatherNotificationService = ref.read(weatherNotificationServiceProvider);
  
  // Check every 6 hours for extreme weather conditions
  Stream.periodic(const Duration(hours: 6)).listen((_) {
    weatherNotificationService.checkExtremeWeatherConditions();
  });
  
  // Also check immediately when app starts
  weatherNotificationService.checkExtremeWeatherConditions();
  
  // Clean up old weather notifications once daily
  Stream.periodic(const Duration(days: 1)).listen((_) {
    weatherNotificationService.cleanupOldWeatherNotifications();
  });
});