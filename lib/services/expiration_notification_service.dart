// // Fixed expiration_notification_service.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:yam_guard/auth/auth_service.dart';

// class ExpirationNotificationService {
//   final FirebaseFirestore _firestore;
//   final AuthService _authService;

//   ExpirationNotificationService(this._firestore, this._authService);

//   String? get _currentUserId => _authService.currentUser?.uid;

//   // Fixed createNotification method - always include userId
//   Future<void> createNotification({
//     required String title,
//     required String message,
//     required String type,
//     Map<String, dynamic> data = const {},
//   }) async {
//     final userId = _currentUserId;
//     if (userId == null) {
//       print('Cannot create notification: No user logged in');
//       return;
//     }

//     try {
//       await _firestore.collection('notifications').add({
//         'userId': userId, // Always include userId
//         'title': title,
//         'message': message,
//         'type': type,
//         'createdAt': FieldValue.serverTimestamp(),
//         'isRead': false,
//         'data': data,
//       });
//       print('Notification created successfully for user: $userId');
//     } catch (e) {
//       print('Error creating notification: $e');
//     }
//   }

//   Future<void> markAsRead(String notificationId) async {
//     final userId = _currentUserId;
//     if (userId == null) return;

//     try {
//       final doc = await _firestore.collection('notifications').doc(notificationId).get();
//       if (!doc.exists || doc.data()?['userId'] != userId) {
//         print('Notification not found or access denied');
//         return;
//       }

//       await _firestore.collection('notifications').doc(notificationId).update({
//         'isRead': true,
//       });
//     } catch (e) {
//       print('Error marking notification as read: $e');
//     }
//   }

//   Future<void> markAllAsRead() async {
//     final userId = _currentUserId;
//     if (userId == null) return;

//     try {
//       final unreadNotifications = await _firestore
//           .collection('notifications')
//           .where('userId', isEqualTo: userId)
//           .where('isRead', isEqualTo: false)
//           .get();

//       final batch = _firestore.batch();
//       for (final doc in unreadNotifications.docs) {
//         batch.update(doc.reference, {'isRead': true});
//       }
//       await batch.commit();
//     } catch (e) {
//       print('Error marking all notifications as read: $e');
//     }
//   }

//   Future<void> cleanupOldNotifications() async {
//     final userId = _currentUserId;
//     if (userId == null) return;

//     try {
//       final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
//       final oldNotifications = await _firestore
//           .collection('notifications')
//           .where('userId', isEqualTo: userId)
//           .where('createdAt', isLessThan: Timestamp.fromDate(thirtyDaysAgo))
//           .get();

//       final batch = _firestore.batch();
//       for (final doc in oldNotifications.docs) {
//         batch.delete(doc.reference);
//       }
//       await batch.commit();
//     } catch (e) {
//       print('Error cleaning up old notifications: $e');
//     }
//   }

//   Future<void> checkExpiringHarvests() async {
//     final userId = _currentUserId;
//     if (userId == null) return;

//     try {
//       final now = DateTime.now();
      
//       final activeHarvests = await _firestore
//           .collection('activeHarvests')
//           .where('userId', isEqualTo: userId)
//           .get();

//       for (final doc in activeHarvests.docs) {
//         final data = doc.data();
        
//         final expiryDateTimestamp = data['expiryDate'] as Timestamp?;
//         final storageMethod = data['storageMethod'] as String? ?? 'Unknown storage';
//         final totalHarvested = data['totalHarvested'] as int? ?? 0;
        
//         if (expiryDateTimestamp == null) {
//           print('Skipping harvest ${doc.id}: missing expiryDate');
//           continue;
//         }
        
//         final expiryDate = expiryDateTimestamp.toDate();
//         final daysLeft = expiryDate.difference(now).inDays;
        
//         if (expiryDate.isBefore(now)) {
//           print('Skipping harvest ${doc.id}: already expired');
//           continue;
//         }
        
//         if (daysLeft <= 2) {
//           final existingNotification = await _firestore
//               .collection('notifications')
//               .where('userId', isEqualTo: userId)
//               .where('type', isEqualTo: 'expiring_soon')
//               .where('data.harvestId', isEqualTo: doc.id)
//               .get();

//           if (existingNotification.docs.isEmpty) {
//             String message;
//             if (daysLeft == 0) {
//               message = '$totalHarvested tubers ($storageMethod) expire today!';
//             } else if (daysLeft == 1) {
//               message = '$totalHarvested tubers ($storageMethod) expire tomorrow!';
//             } else {
//               message = '$totalHarvested tubers ($storageMethod) expire in $daysLeft days';
//             }
            
//             await createNotification(
//               title: 'Harvest Expiring Soon!',
//               message: message,
//               type: 'expiring_soon',
//               data: {
//                 'harvestId': doc.id,
//                 'expiryDate': expiryDate.toIso8601String(),
//                 'storageMethod': storageMethod,
//                 'totalHarvested': totalHarvested,
//                 'daysLeft': daysLeft,
//               },
//             );
            
//             print('Created expiring notification for harvest ${doc.id}: $daysLeft days left');
//           }
//         }
//       }
//     } catch (e) {
//       print('Error checking expiring harvests: $e');
//     }
//   }
// }


// Fixed expiration_notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yam_guard/auth/auth_service.dart';

class ExpirationNotificationService {
  final FirebaseFirestore _firestore;
  final AuthService _authService;

  ExpirationNotificationService(this._firestore, this._authService);

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

  Future<void> checkExpiringHarvests() async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      final now = DateTime.now();
      
      final activeHarvests = await _firestore
          .collection('activeHarvests')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in activeHarvests.docs) {
        final data = doc.data();
        
        final expiryDateTimestamp = data['expiryDate'] as Timestamp?;
        final storageMethod = data['storageMethod'] as String? ?? 'Unknown storage';
        final totalHarvested = data['totalHarvested'] as int? ?? 0;
        
        if (expiryDateTimestamp == null) {
          print('Skipping harvest ${doc.id}: missing expiryDate');
          continue;
        }
        
        final expiryDate = expiryDateTimestamp.toDate();
        final daysLeft = expiryDate.difference(now).inDays;
        
        if (expiryDate.isBefore(now)) {
          print('Skipping harvest ${doc.id}: already expired');
          continue;
        }
        
        if (daysLeft <= 2) {
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