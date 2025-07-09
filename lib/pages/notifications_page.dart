// pages/notifications_page.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:yam_guard/model/notification_item.dart';
import 'package:yam_guard/providers/notification_provider.dart';
import 'package:yam_guard/themes/colors.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    // Mark all notifications as read when page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationServiceProvider).markAllAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsStreamProvider);
    final notificationService = ref.read(notificationServiceProvider);
    final weatherNotificationService = ref.read(
      weatherNotificationServiceProvider,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 92, // Adds vertical space overall
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primary700),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.primary700,
          ),
        ),
      ),

      body: SafeArea(
        child: notificationsAsync.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: AppColors.secondary900.withOpacity(0.3),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No notifications yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondary900.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 44.0),
              child: ListView.builder(
                padding: EdgeInsets.only(top: 30.0),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return NotificationCard(
                    notification: notification,
                    onTap: () {
                      if (!notification.isRead) {
                        notificationService.markAsRead(notification.id);
                      }
                    },
                  );
                },
              ),
            );
          },
          loading:
              () => Center(
                child: CircularProgressIndicator(color: AppColors.primary700),
              ),
          error:
              (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Error loading notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color:
            notification.isRead
                ? Colors.white
                : AppColors.primary700.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              notification.isRead
                  ? AppColors.secondary900.withOpacity(0.1)
                  : AppColors.primary700.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getNotificationColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getNotificationIcon(),
                    color: _getNotificationColor(),
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    notification.isRead
                                        ? FontWeight.w500
                                        : FontWeight.w600,
                                color: AppColors.secondary900,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.primary700,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.secondary900.withOpacity(0.7),
                          height: 1.3,
                        ),
                      ),
                      if (notification.type == 'weather_alert' &&
                          notification.data.containsKey('severity'))
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getSeverityColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _getSeverityColor().withOpacity(0.3),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              '${notification.data['severity']?.toString().toUpperCase()} SEVERITY',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _getSeverityColor(),
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: 8),
                      Text(
                        _formatTime(notification.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondary900.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor() {
    switch (notification.type) {
      case 'expiring_soon':
        return Colors.orange;
      case 'moved_to_history':
        if (notification.data['status'] == 'expired') {
          return Colors.red;
        } else if (notification.data['status'] == 'consumed') {
          return Colors.green;
        } else if (notification.data['status'] == 'sold') {
          return Colors.blue;
        }
        return AppColors.primary700;
      case 'weather_alert':
        final condition = notification.data['condition'] as String? ?? '';
        switch (condition) {
          case 'heavy_rain':
          case 'severe_storm':
          case 'flood_risk':
            return Colors.red;
          case 'strong_wind':
          case 'extreme_heat':
          case 'drought':
            return Colors.orange;
          case 'moderate_rain':
          case 'heavy_fog':
            return Colors.blue;
          default:
            return Colors.purple;
        }
      default:
        return AppColors.primary700;
    }
  }

  Color _getSeverityColor() {
    final severity = notification.data['severity'] as String? ?? 'low';
    switch (severity) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
      default:
        return Colors.blue;
    }
  }

  IconData _getNotificationIcon() {
    switch (notification.type) {
      case 'expiring_soon':
        return Icons.warning_outlined;
      case 'moved_to_history':
        if (notification.data['status'] == 'expired') {
          return Icons.error_outline;
        } else if (notification.data['status'] == 'consumed') {
          return Icons.check_circle_outline;
        } else if (notification.data['status'] == 'sold') {
          return Icons.sell_outlined;
        }
        return Icons.history;
      case 'weather_alert':
        final condition = notification.data['condition'] as String? ?? '';
        switch (condition) {
          case 'heavy_rain':
            return Icons.thunderstorm_outlined;
          case 'strong_wind':
            return Icons.air_outlined;
          case 'extreme_heat':
            return Icons.wb_sunny_outlined;
          case 'flood_risk':
            return Icons.flood_outlined;
          case 'drought':
            return Icons.wb_sunny;
          case 'severe_storm':
            return Icons.storm_outlined;
          case 'heavy_fog':
            return Icons.foggy;
          case 'moderate_rain':
            return Icons.grain_outlined;
          default:
            return Icons.wb_cloudy_outlined;
        }
      default:
        return Icons.notifications_outlined;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(dateTime);
    }
  }
}
