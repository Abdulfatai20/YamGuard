import 'package:flutter/material.dart';
import 'package:yam_guard/pages/notifications_page.dart';
import 'package:yam_guard/themes/colors.dart';
import 'package:yam_guard/widgets/notification_badge_widget.dart';

class AppbarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppbarWidget({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // = 56.0

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary700,
      elevation: 1,
      centerTitle: true,
      title: const Text(
        'Yam Intelligence',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: AppColors.white,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: NotificationBadge(
            iconSize: 24,
            iconColor: AppColors.white,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
