import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/res/app_colors.dart';

enum SnackBarType { success, error, warning, info }

class AppSnackbar {
  static void show({
    required String message,
    String? title,
    SnackBarType type = SnackBarType.info,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    bool showIcon = true,
    SnackPosition position = SnackPosition.TOP,
    bool isDismissible = true,
  }) {
    final config = _getDefaultConfig(type);

    final bgColor = backgroundColor ?? config.color;
    final txtColor = textColor ?? Colors.white;
    final icn = icon ?? config.icon;

    Get.snackbar(
      title ?? "",
      message,
      titleText: title != null && title.isNotEmpty
          ? Text(
              title,
              style: TextStyle(
                color: txtColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            )
          : const SizedBox.shrink(),
      messageText: Text(
        message,
        style: TextStyle(
          color: txtColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: bgColor,
      colorText: txtColor,
      borderRadius: 14,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      duration: duration,
      snackPosition: position,
      isDismissible: isDismissible,
      forwardAnimationCurve: Curves.easeOut,
      reverseAnimationCurve: Curves.easeIn,
      icon: showIcon ? Icon(icn, color: txtColor, size: 24) : null,
      shouldIconPulse: false,
      animationDuration: const Duration(milliseconds: 400),
    );
  }

  // Default configuration for each type
  static _SnackBarConfig _getDefaultConfig(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return _SnackBarConfig(
          color: AppColors.success,
          icon: Icons.check_circle_rounded,
        );
      case SnackBarType.error:
        return _SnackBarConfig(
          color: AppColors.error,
          icon: Icons.error_rounded,
        );
      case SnackBarType.warning:
        return _SnackBarConfig(
          color: AppColors.warning,
          icon: Icons.warning_rounded,
        );
      case SnackBarType.info:
      default:
        return _SnackBarConfig(
          color: AppColors.button,
          icon: Icons.info_rounded,
        );
    }
  }
}

class _SnackBarConfig {
  final Color color;
  final IconData icon;

  _SnackBarConfig({required this.color, required this.icon});
}
