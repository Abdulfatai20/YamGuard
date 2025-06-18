// // Fixed notification_item.dart
// import 'package:cloud_firestore/cloud_firestore.dart';

// class NotificationItem {
//   final String id;
//   final String title;
//   final String message;
//   final String type;
//   final DateTime createdAt;
//   final bool isRead;
//   final Map<String, dynamic> data;

//   NotificationItem({
//     required this.id,
//     required this.title,
//     required this.message,
//     required this.type,
//     required this.createdAt,
//     this.isRead = false,
//     this.data = const {},
//   });

//   NotificationItem copyWith({
//     String? id,
//     String? title,
//     String? message,
//     String? type,
//     DateTime? createdAt,
//     bool? isRead,
//     Map<String, dynamic>? data,
//   }) {
//     return NotificationItem(
//       id: id ?? this.id,
//       title: title ?? this.title,
//       message: message ?? this.message,
//       type: type ?? this.type,
//       createdAt: createdAt ?? this.createdAt,
//       isRead: isRead ?? this.isRead,
//       data: data ?? this.data,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'title': title,
//       'message': message,
//       'type': type,
//       'createdAt': Timestamp.fromDate(createdAt),
//       'isRead': isRead,
//       'data': data,
//     };
//   }

//   factory NotificationItem.fromMap(String id, Map<String, dynamic> map) {
//     // Handle createdAt with better null safety
//     DateTime createdAt;
//     try {
//       final createdAtValue = map['createdAt'];
//       if (createdAtValue is Timestamp) {
//         createdAt = createdAtValue.toDate();
//       } else if (createdAtValue is String) {
//         createdAt = DateTime.parse(createdAtValue);
//       } else {
//         createdAt = DateTime.now();
//       }
//     } catch (e) {
//       print('Error parsing createdAt for notification $id: $e');
//       createdAt = DateTime.now();
//     }

//     return NotificationItem(
//       id: id,
//       title: map['title']?.toString() ?? '',
//       message: map['message']?.toString() ?? '',
//       type: map['type']?.toString() ?? '',
//       createdAt: createdAt,
//       isRead: map['isRead'] ?? false,
//       data: Map<String, dynamic>.from(map['data'] ?? {}),
//     );
//   }
// }


// Fixed notification_item.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic> data;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.data = const {},
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'type': type,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'data': data,
    };
  }

  factory NotificationItem.fromMap(String id, Map<String, dynamic> map) {
    // Handle createdAt with better null safety
    DateTime createdAt;
    try {
      final createdAtValue = map['createdAt'];
      if (createdAtValue is Timestamp) {
        createdAt = createdAtValue.toDate();
      } else if (createdAtValue is String) {
        createdAt = DateTime.parse(createdAtValue);
      } else {
        createdAt = DateTime.now();
      }
    } catch (e) {
      print('Error parsing createdAt for notification $id: $e');
      createdAt = DateTime.now();
    }

    return NotificationItem(
      id: id,
      title: map['title']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      createdAt: createdAt,
      isRead: map['isRead'] ?? false,
      data: Map<String, dynamic>.from(map['data'] ?? {}),
    );
  }
}