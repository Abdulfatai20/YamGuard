// services/notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore _firestore;

  NotificationService(this._firestore);

  // Create a notification
  Future<void> createNotification({
    required String title,
    required String message,
    required String type,
    Map<String, dynamic> data = const {},
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'title': title,
        'message': message,
        'type': type,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'data': data,
      });
    } catch (e) {
      print('Error creating notification: $e');
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final unreadNotifications = await _firestore
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in unreadNotifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  // Delete old notifications (older than 30 days)
  Future<void> cleanupOldNotifications() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
      final oldNotifications = await _firestore
          .collection('notifications')
          .where('createdAt', isLessThan: Timestamp.fromDate(thirtyDaysAgo))
          .get();

      final batch = _firestore.batch();
      for (final doc in oldNotifications.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Error cleaning up old notifications: $e');
    }
  }

  // Check for expiring harvests and create notifications
  Future<void> checkExpiringHarvests() async {
    try {
      final now = DateTime.now();
      final twoDaysFromNow = now.add(Duration(days: 2));

      // Query harvests that will expire within 2 days
      final expiringHarvests = await _firestore
          .collection('activeHarvests')
          .where('alertDate', isLessThanOrEqualTo: Timestamp.fromDate(now))
          .get();

      for (final doc in expiringHarvests.docs) {
        final data = doc.data();
        final expiryDate = (data['expiryDate'] as Timestamp).toDate();
        final storageMethod = data['storageMethod'] as String;
        final totalHarvested = data['totalHarvested'] as int;
        
        // Check if we already created a notification for this harvest
        final existingNotification = await _firestore
            .collection('notifications')
            .where('type', isEqualTo: 'expiring_soon')
            .where('data.harvestId', isEqualTo: doc.id)
            .get();

        if (existingNotification.docs.isEmpty) {
          final daysLeft = expiryDate.difference(now).inDays;
          
          await createNotification(
            title: 'Harvest Expiring Soon!',
            message: '$totalHarvested tubers ($storageMethod) expire in $daysLeft days',
            type: 'expiring_soon',
            data: {
              'harvestId': doc.id,
              'expiryDate': expiryDate.toIso8601String(),
              'storageMethod': storageMethod,
              'totalHarvested': totalHarvested,
            },
          );
        }
      }
    } catch (e) {
      print('Error checking expiring harvests: $e');
    }
  }

  // Create notification when harvest moves to history
  Future<void> createHistoryNotification({
    required String harvestId,
    required String status,
    required String storageMethod,
    required int totalHarvested,
  }) async {
    String title = '';
    String message = '';
    
    switch (status) {
      case 'expired':
        title = 'Harvest Expired';
        message = '$totalHarvested tubers ($storageMethod) have expired';
        break;
      case 'consumed':
        title = 'Harvest Consumed';
        message = '$totalHarvested tubers ($storageMethod) marked as consumed';
        break;
      case 'sold':
        title = 'Harvest Sold';
        message = '$totalHarvested tubers ($storageMethod) marked as sold';
        break;
    }

    await createNotification(
      title: title,
      message: message,
      type: 'moved_to_history',
      data: {
        'harvestId': harvestId,
        'status': status,
        'storageMethod': storageMethod,
        'totalHarvested': totalHarvested,
      },
    );
  }
}