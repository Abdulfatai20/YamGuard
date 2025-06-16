// services/notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yam_guard/auth/auth_service.dart';

class ExpirationNotificationService {
  final FirebaseFirestore _firestore;
  final AuthService _authService;

  ExpirationNotificationService(this._firestore, this._authService);

  // Get current user ID
  String? get _currentUserId => _authService.currentUser?.uid;

  // Create a notification for the current user
  Future<void> createNotification({
    required String title,
    required String message,
    required String type,
    Map<String, dynamic> data = const {},
  }) async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
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

  // Mark notification as read (with user verification)
  Future<void> markAsRead(String notificationId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      // First verify the notification belongs to the current user
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

  // Mark all notifications as read for current user only
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

  // Delete old notifications for current user only (older than 30 days)
  Future<void> cleanupOldNotifications() async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final oldNotifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
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

  // Check for expiring harvests and create notifications for current user only
  Future<void> checkExpiringHarvests() async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      final now = DateTime.now();
      
      // Query only the current user's active harvests
      final activeHarvests = await _firestore
          .collection('activeHarvests')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in activeHarvests.docs) {
        final data = doc.data();
        
        // Safely extract data with null checks
        final expiryDateTimestamp = data['expiryDate'] as Timestamp?;
        final storageMethod = data['storageMethod'] as String? ?? 'Unknown storage';
        final totalHarvested = data['totalHarvested'] as int? ?? 0;
        
        // Skip if essential data is missing
        if (expiryDateTimestamp == null) {
          print('Skipping harvest ${doc.id}: missing expiryDate');
          continue;
        }
        
        final expiryDate = expiryDateTimestamp.toDate();
        final daysLeft = expiryDate.difference(now).inDays;
        
        // Skip if harvest has already expired
        if (expiryDate.isBefore(now)) {
          print('Skipping harvest ${doc.id}: already expired');
          continue;
        }
        
        // Only create notification if harvest expires within 2 days (0, 1, or 2 days left)
        if (daysLeft <= 2) {
          // Check if we already created a notification for this harvest for this user
          final existingNotification = await _firestore
              .collection('notifications')
              .where('userId', isEqualTo: userId)
              .where('type', isEqualTo: 'expiring_soon')
              .where('data.harvestId', isEqualTo: doc.id)
              .get();

          if (existingNotification.docs.isEmpty) {
            String message;
            if (daysLeft == 0) {
              message = '$totalHarvested tubers ($storageMethod) expire today!';
            } else if (daysLeft == 1) {
              message = '$totalHarvested tubers ($storageMethod) expire tomorrow!';
            } else {
              message = '$totalHarvested tubers ($storageMethod) expire in $daysLeft days';
            }
            
            await createNotification(
              title: 'Harvest Expiring Soon!',
              message: message,
              type: 'expiring_soon',
              data: {
                'harvestId': doc.id,
                'expiryDate': expiryDate.toIso8601String(),
                'storageMethod': storageMethod,
                'totalHarvested': totalHarvested,
                'daysLeft': daysLeft,
              },
            );
            
            print('Created expiring notification for harvest ${doc.id}: $daysLeft days left');
          }
        }
      }
    } catch (e) {
      print('Error checking expiring harvests: $e');
    }
  }
}