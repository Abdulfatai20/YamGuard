import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yam_guard/auth/auth_service.dart';

class NotificationService {
  final FirebaseFirestore _firestore;
  final AuthService _authService;

  NotificationService(this._firestore, this._authService);

  String? get _currentUserId => _authService.currentUser?.uid;

  // Fixed createNotification method - always include userId
  Future<void> createNotification({
    required String title,
    required String message,
    required String type,
    Map<String, dynamic> data = const {},
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      print('Cannot create notification: No user logged in');
      return;
    }

    try {
      await _firestore.collection('notifications').add({
        'userId': userId, // Always include userId
        'title': title,
        'message': message,
        'type': type,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'data': data,
      });
      print('Notification created successfully for user: $userId');
    } catch (e) {
      print('Error creating notification: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      final doc = await _firestore.collection('notifications').doc(notificationId).get();
      if (!doc.exists || doc.data()?['userId'] != userId) {
        print('Notification not found or access denied');
        return;
      }

      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      final unreadNotifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in unreadNotifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
      print('Marked ${unreadNotifications.docs.length} notifications as read');
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  // Enhanced cleanup method with better logging and error handling
  Future<int> cleanupOldNotifications() async {
    final userId = _currentUserId;
    if (userId == null) {
      print('No user ID found for cleanup');
      return 0;
    }

    try {
      final now = DateTime.now();
      final threeDaysAgo = now.subtract(const Duration(days: 3));
      print('Cleaning up notifications older than: $threeDaysAgo');

      // Get all notifications for this user
      final allUserNotifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();

      print('Total notifications for user: ${allUserNotifications.docs.length}');

      final batch = _firestore.batch();
      int deleteCount = 0;
      final List<String> deletedTypes = [];

      for (final doc in allUserNotifications.docs) {
        final data = doc.data();
        final createdAt = data['createdAt'] as Timestamp?;
        final notificationType = data['type'] as String? ?? 'unknown';
        
        if (createdAt != null) {
          final createdDate = createdAt.toDate();
          
          // Clean up notifications older than 3 days
          // This includes welcome notifications, weather alerts, and any other types
          if (createdDate.isBefore(threeDaysAgo)) {
            print('Marking for deletion: ${doc.id} - ${data['title']} (Type: $notificationType, Created: $createdDate)');
            batch.delete(doc.reference);
            deleteCount++;
            if (!deletedTypes.contains(notificationType)) {
              deletedTypes.add(notificationType);
            }
          }
        } else {
          // Delete notifications without timestamp (corrupted data)
          print('Marking for deletion (no timestamp): ${doc.id} - ${data['title']} (Type: $notificationType)');
          batch.delete(doc.reference);
          deleteCount++;
          if (!deletedTypes.contains(notificationType)) {
            deletedTypes.add(notificationType);
          }
        }
      }

      if (deleteCount > 0) {
        await batch.commit();
        print('Successfully deleted $deleteCount old notifications');
        print('Deleted notification types: ${deletedTypes.join(', ')}');
      } else {
        print('No notifications found for cleanup');
      }
      
      return deleteCount;
    } catch (e) {
      print('Error cleaning up old notifications: $e');
      return 0;
    }
  }

  // Method to force cleanup of specific notification types (for testing)
  Future<int> forceCleanupNotificationType(String notificationType) async {
    final userId = _currentUserId;
    if (userId == null) return 0;

    try {
      final notifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: notificationType)
          .get();

      final batch = _firestore.batch();
      for (final doc in notifications.docs) {
        batch.delete(doc.reference);
      }
      
      if (notifications.docs.isNotEmpty) {
        await batch.commit();
        print('Force deleted ${notifications.docs.length} notifications of type: $notificationType');
      }
      
      return notifications.docs.length;
    } catch (e) {
      print('Error force cleaning up $notificationType notifications: $e');
      return 0;
    }
  }
}