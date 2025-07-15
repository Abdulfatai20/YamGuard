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

// Fixed notifications stream provider with better error handling
final notificationsStreamProvider = StreamProvider<List<NotificationItem>>((ref) {
  final firestore = ref.read(firestoreProvider);
  final authService = ref.read(authServiceProvider);
  
  final currentUser = authService.currentUser;
  if (currentUser == null) {
    return Stream.value(<NotificationItem>[]);
  }
  
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
              final data = doc.data();
              
              // Skip malformed documents
              if (data['title'] == null || data['message'] == null) {
                print('Skipping malformed notification ${doc.id}: missing required fields');
                continue;
              }
              
              final notification = NotificationItem.fromMap(doc.id, data);
              notifications.add(notification);
            } catch (e) {
              print('Error parsing notification ${doc.id}: $e');
              // Delete corrupted notification
              try {
                await firestore.collection('notifications').doc(doc.id).delete();
                print('Deleted corrupted notification ${doc.id}');
              } catch (deleteError) {
                print('Failed to delete corrupted notification ${doc.id}: $deleteError');
              }
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
      })
      .handleError((error) {
        print('Stream error in notifications: $error');
        return <NotificationItem>[];
      });
});

// Fixed unread notification count provider with better error handling
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
      .where('isRead', isEqualTo: false)
      .snapshots()
      .asyncMap((snapshot) async {
        try {
          int unreadCount = 0;
          
          for (final doc in snapshot.docs) {
            final data = doc.data();
            
            // Skip malformed documents
            if (data['title'] == null || data['message'] == null) {
              continue;
            }
            
            // Only count if isRead is explicitly false or null (default unread)
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
      })
      .handleError((error) {
        print('Stream error in unread count: $error');
        return 0;
      });
});

// Enhanced weather alert checker with cleanup scheduling
final weatherAlertCheckerProvider = Provider<void>((ref) {
  final weatherNotificationService = ref.read(weatherNotificationServiceProvider);
  final notificationService = ref.read(notificationServiceProvider);
  
  // Check every 6 hours for extreme weather conditions
  Stream.periodic(const Duration(hours: 6)).listen((_) {
    weatherNotificationService.checkExtremeWeatherConditions();
  });
  
  // Also check immediately when app starts
  weatherNotificationService.checkExtremeWeatherConditions();
  
  // Clean up old notifications every 12 hours (including welcome notifications)
  Stream.periodic(const Duration(hours: 12)).listen((_) async {
    print('Running periodic cleanup...');
    try {
      final generalCleanup = await notificationService.cleanupOldNotifications();
      final weatherCleanup = await weatherNotificationService.cleanupOldWeatherNotifications();
      print('Cleanup completed: $generalCleanup general, $weatherCleanup weather notifications deleted');
    } catch (e) {
      print('Cleanup error: $e');
    }
  });
  
  // Run cleanup immediately on app start
  Future.delayed(const Duration(seconds: 5), () async {
    print('Running initial cleanup...');
    try {
      final generalCleanup = await notificationService.cleanupOldNotifications();
      final weatherCleanup = await weatherNotificationService.cleanupOldWeatherNotifications();
      print('Initial cleanup completed: $generalCleanup general, $weatherCleanup weather notifications deleted');
    } catch (e) {
      print('Initial cleanup error: $e');
    }
  });
});