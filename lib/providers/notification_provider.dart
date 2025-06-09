// providers/notification_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yam_guard/model/notification_item.dart';
import 'package:yam_guard/providers/firestore_provider.dart';
import 'package:yam_guard/services/notification_service.dart';

// Provider for notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final firestore = ref.read(firestoreProvider);
  return NotificationService(firestore);
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