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
      {'icon': Icons.memory, 'isIcon': true, 'label': 'Yam AI'},
      {'icon': 'assets/icons/Forecast.png', 'isIcon': false, 'label': 'Forecast'},
      {'icon': 'assets/icons/storage_tips.png', 'isIcon': false, 'label': 'Info'},
      {'icon': 'assets/icons/Profile.png', 'isIcon': false, 'label': 'Profile'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: const Color(0xB3BFBFBF),
            width: 1,
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
                item['isIcon'] == true
                    ? Icon(
                        item['icon'] as IconData, // cast
                        size: 24,
                        color: isSelected
                            ? AppColors.primary700
                            : AppColors.secondary900,
                      )
                    : Image.asset(
                        item['icon'] as String, // cast
                        width: 24,
                        height: 24,
                        color: isSelected
                            ? AppColors.primary700
                            : AppColors.secondary900,
                      ),
                const SizedBox(height: 4),
                Text(
                  item['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected
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
