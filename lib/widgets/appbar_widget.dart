import 'package:flutter/material.dart';
import 'package:yam_guard/pages/notifications_page.dart';
import 'package:yam_guard/themes/colors.dart';
import 'package:yam_guard/widgets/notification_badge_widget.dart';

class AppbarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppbarWidget({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor:
          AppColors.primary700, // Transparent to show the background
      elevation: 0, // No shadow
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 46.0, left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Image.asset(
                      'assets/icons/map_icon.png',
                      width: 18,
                      height: 21,
                      color: AppColors.white,
                    ),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'Osogbo',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
              NotificationBadge(
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
            ],
          ),
        ),
      ),
    );
  }
}
