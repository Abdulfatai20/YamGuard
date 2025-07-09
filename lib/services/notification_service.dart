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

  // Updated cleanup method to handle welcome notifications and other types
  Future<int> cleanupOldNotifications() async {
    final userId = _currentUserId;
    if (userId == null) return 0;

    try {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      
      // Get all notifications for this user
      final allUserNotifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      int deleteCount = 0;

      for (final doc in allUserNotifications.docs) {
        final data = doc.data();
        final createdAt = data['createdAt'] as Timestamp?;
        
        if (createdAt != null) {
          final createdDate = createdAt.toDate();
          final notificationType = data['type'] as String?;
          
          // Clean up notifications older than 3 days
          // This includes welcome notifications, weather alerts, and any other types
          if (createdDate.isBefore(threeDaysAgo)) {
            print('Marking for deletion: ${doc.id} - ${data['title']} (Type: $notificationType, Created: $createdDate)');
            batch.delete(doc.reference);
            deleteCount++;
          }
        } else {
          // Delete notifications without timestamp (corrupted data)
          print('Marking for deletion (no timestamp): ${doc.id} - ${data['title']}');
          batch.delete(doc.reference);
          deleteCount++;
        }
      }

      if (deleteCount > 0) {
        await batch.commit();
        print('Successfully deleted $deleteCount old notifications');
      } else {
        print('No notifications found for cleanup');
      }
      
      return deleteCount;
    } catch (e) {
      print('Error cleaning up old notifications: $e');
      return 0;
    }
  }

  // // Optional: Separate method to clean up only welcome notifications if needed
  // Future<int> cleanupWelcomeNotifications() async {
  //   final userId = _currentUserId;
  //   if (userId == null) return 0;

  //   try {
  //     final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      
  //     final welcomeNotifications = await _firestore
  //         .collection('notifications')
  //         .where('userId', isEqualTo: userId)
  //         .where('type', isEqualTo: 'welcome')
  //         .get();

  //     final batch = _firestore.batch();
  //     int deleteCount = 0;

  //     for (final doc in welcomeNotifications.docs) {
  //       final data = doc.data();
  //       final createdAt = data['createdAt'] as Timestamp?;
        
  //       if (createdAt != null) {
  //         final createdDate = createdAt.toDate();
          
  //         if (createdDate.isBefore(threeDaysAgo)) {
  //           print('Deleting welcome notification: ${doc.id} - ${data['title']} (Created: $createdDate)');
  //           batch.delete(doc.reference);
  //           deleteCount++;
  //         }
  //       } else {
  //         // Delete welcome notifications without timestamp
  //         print('Deleting welcome notification (no timestamp): ${doc.id} - ${data['title']}');
  //         batch.delete(doc.reference);
  //         deleteCount++;
  //       }
  //     }

  //     if (deleteCount > 0) {
  //       await batch.commit();
  //       print('Successfully deleted $deleteCount welcome notifications');
  //     }
      
  //     return deleteCount;
  //   } catch (e) {
  //     print('Error cleaning up welcome notifications: $e');
  //     return 0;
  //   }
  // }
}