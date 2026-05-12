import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/utils/textstyle.dart';

class LeBalanceAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBackPressed;
  final bool showBackButton;

  const LeBalanceAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onBackPressed,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      centerTitle: false,
      elevation: 0,
      automaticallyImplyLeading: false,

      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: text18(fontWeight: FontWeight.w600, color: AppColors.white),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: text14(
                fontWeight: FontWeight.w500,
                color: AppColors.white70,
              ),
            ),
          ],
        ],
      ),

      leading: showBackButton
          ? Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2937),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
                onPressed: onBackPressed ?? () => Get.back(),
                splashRadius: 24,
              ),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
