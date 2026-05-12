import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/res/app_colors.dart';

Widget backButton() {
  return GestureDetector(
    onTap: () => Get.back(),
    child: Container(
      height: 36,
      width: 36,
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.chevron_left_rounded,
        color: AppColors.white,
        size: 24,
      ),
    ),
  );
}
