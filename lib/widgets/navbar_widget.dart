import 'package:flutter/material.dart';
import 'package:yam_guard/themes/colors.dart';

class NavbarWidget extends StatelessWidget {
  const NavbarWidget({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final navItems = [
      {'icon': 'assets/icons/Forecast.png', 'label': 'Forecast'},
      {'icon': 'assets/icons/loss_tracker.png', 'label': 'Loss Tracker'},
      {'icon': 'assets/icons/storage_tips.png', 'label': 'Storage Tips'},
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
       decoration: BoxDecoration(
        color: Colors.white, // Navbar background color
        border: Border(
          top: BorderSide(
            color: Color(0xB3BFBFBF),// Color: BFBFBF with 70% opacity
            width: 1, // Stroke width at the top
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(navItems.length, (index) {
          final isSelected = index == selectedIndex;
          final item = navItems[index];

          return GestureDetector(
            onTap: () => onTap(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  item['icon']!,
                  width: 24.0,
                  height: 24.0,
                  color:
                      isSelected
                          ? AppColors.primary700
                          : AppColors.secondary900,
                ),
                Text(
                  item['label']!,
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color:
                        isSelected
                            ? AppColors.primary700
                            : AppColors.secondary900,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
