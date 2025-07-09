
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
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

// Updated NotificationService cleanup method
Future<int> cleanupOldNotifications() async {
  final userId = _currentUserId;
  if (userId == null) return 0;

  try {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final oldNotifications = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('createdAt', isLessThan: Timestamp.fromDate(thirtyDaysAgo))
        .get();

    if (oldNotifications.docs.isEmpty) {
      print('No old notifications found for cleanup');
      return 0;
    }

    final batch = _firestore.batch();
    for (final doc in oldNotifications.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    
    print('Successfully deleted ${oldNotifications.docs.length} old notifications');
    return oldNotifications.docs.length;
  } catch (e) {
    print('Error cleaning up old notifications: $e');
    return 0;
  }
}
}