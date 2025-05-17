import 'package:flutter/material.dart';
import 'package:yam_guard/themes/colors.dart';

enum SnackbarType { error, success }

void showCustomSnackbar(
  BuildContext context,
  String message, {
  SnackbarType type = SnackbarType.error,
}) {
  final backgroundColor =
      type == SnackbarType.success ? Colors.green : Colors.red;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: const TextStyle(
              color: AppColors.white, // Yam greens
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),),
      backgroundColor: backgroundColor,
      duration: const Duration(seconds: 3),
    ),
  );
}
