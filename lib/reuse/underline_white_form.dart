 import 'package:flutter/material.dart';
import 'package:yam_guard/themes/colors.dart';

InputDecoration whiteBorderDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.white, fontSize: 12),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.white, width: 1),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.white, width: 2),
      ),
    );
  }