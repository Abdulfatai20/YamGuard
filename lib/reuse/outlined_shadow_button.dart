import 'package:flutter/material.dart';
import 'package:yam_guard/themes/colors.dart';

class OutlinedShadowButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const OutlinedShadowButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 37,
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            offset: Offset(0, 4),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.primary100,
          width: 1,
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 35,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.secondary900,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
