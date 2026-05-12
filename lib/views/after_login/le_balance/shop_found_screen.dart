import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/utils/custom_button.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/view_model/after_login/leBalance_controller/leBalance_controller.dart';
import 'package:leudaar_app/views/custom_widget/custom_appbar.dart';

class ShopFoundScreen extends StatelessWidget {
  ShopFoundScreen({super.key});

  final ShopFoundController controller = Get.put(ShopFoundController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: LeBalanceAppBar(
        title: 'Shop found',
        subtitle: 'Verify before continuing',
        onBackPressed: controller.rescan,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // ── Shop Card ─────────────────────────────────────────
            Obx(
              () => Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.button.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Shop Icon
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        size: 38,
                        color: AppColors.button,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Shop Name
                    Text(
                      controller.shopName.value,
                      style: text20(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ).copyWith(letterSpacing: -0.3),
                    ),
                    const SizedBox(height: 4),

                    // Address
                    Text(
                      controller.shopAddress.value,
                      style: text13(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Verified Badge
                    if (controller.isVerified.value)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: AppColors.success,
                            size: 16,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Verified merchant',
                            style: text12(
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Confirmation Label ─────────────────────────────────
            Text(
              'Is this the right shop?',
              style: text15(
                fontWeight: FontWeight.w500,
                color: AppColors.grey.shade600,
              ),
            ),

            const SizedBox(height: 20),

            // ── Action Buttons ────────────────────────────────────
            Row(
              children: [
                // No, Rescan
                Expanded(
                  child: AppOutlineButton(
                    radius: 8,
                    title: "No rescan",
                    onTap: controller.rescan,
                  ),
                ),

                const SizedBox(width: 12),

                // Yes, Continue
                Expanded(
                  child: AppButton(
                    radius: 8,
                    title: "Yes, continue",
                    onTap: controller.continueToCredit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
