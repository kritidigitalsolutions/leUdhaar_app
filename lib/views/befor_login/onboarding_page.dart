import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/data/api_response.dart';
import 'package:leudaar_app/models/response_model/auth_models/onborading_res_model.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/routes/app_routes.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/view_model/before_login/auth_controller.dart';
import 'package:leudaar_app/views/custom_widget/custom_error_widget.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: // Inside OnboardingScreen > build > Obx
          Obx(() {
            final response = controller.onboardingResponse.value;

            if (response.status == Status.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (response.status == Status.error) {
              return CustomErrorWidget(
                title: "Failed to load onboarding",
                message:
                    response.message ?? "Please check your internet connection",
                onRetry: controller.getOnboardingData,
              );
            }

            final pages = response.data!.data; // List<OnboradingData>

            return Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: controller.currentPage.value != pages.length - 1
                        ? 1.0
                        : 0.0,
                    child: GestureDetector(
                      onTap: () => Get.offAllNamed(AppRoutes.registerPage),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 16, 24, 0),
                        child: Text(
                          "Skip",
                          style: text13(
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: controller.pageController,
                    onPageChanged: controller.onPageChanged,
                    itemCount: pages.length,
                    itemBuilder: (context, index) {
                      return _OnboardingPage(data: pages[index]);
                    },
                  ),
                ),

                // Dots + Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          pages.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: controller.currentPage.value == i ? 24 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: controller.currentPage.value == i
                                  ? AppColors.primary
                                  : AppColors.grey400,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _OnboardingButton(
                        label: controller.currentPage.value == pages.length - 1
                            ? "Get Started"
                            : "Next",
                        isLast:
                            controller.currentPage.value == pages.length - 1,
                        onTap: controller.nextPage,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// ── Single slide ──────────────────────────────────────────────────────────────

class _OnboardingPage extends StatelessWidget {
  final OnboradingData data;
  const _OnboardingPage({required this.data});

  IconData _getIcon(String? iconKey) {
    switch (iconKey?.toLowerCase()) {
      case 'friends':
      case 'people':
        return Icons.people_rounded;
      case 'qr':
      case 'shop':
        return Icons.qr_code_scanner_rounded;
      case 'legal':
      case 'verified':
        return Icons.verified_user_rounded;
      default:
        return Icons.star_rounded; // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon circle
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              _getIcon(data.iconKey),
              size: 48,
              color: AppColors.white,
            ),
          ),

          const SizedBox(height: 32),

          // Micro-tag / Label
          Text(
            (data.label ?? '').toUpperCase(),
            style: text11(
              fontWeight: FontWeight.w600,
              color: AppColors.grey500,
            ).copyWith(letterSpacing: 0.9),
          ),

          const SizedBox(height: 10),

          // Title
          Text(
            data.title ?? '',
            textAlign: TextAlign.center,
            style: text26(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ).copyWith(height: 1.2, letterSpacing: -0.3),
          ),

          const SizedBox(height: 16),

          // Subtitle / Description
          Text(
            data.description ?? '',
            textAlign: TextAlign.center,
            style: text14(color: AppColors.textSecondary).copyWith(height: 1.6),
          ),

          const SizedBox(height: 24),

          // Feature badge
          if (data.badgeText != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    data.badgeText!,
                    style: text11(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── CTA button ────────────────────────────────────────────────────────────────

class _OnboardingButton extends StatelessWidget {
  final String label;
  final bool isLast;
  final VoidCallback onTap;

  const _OnboardingButton({
    required this.label,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                label,
                key: ValueKey(label),
                style: text16(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ).copyWith(letterSpacing: 0.3),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isLast
                  ? Icons.rocket_launch_rounded
                  : Icons.arrow_forward_rounded,
              color: AppColors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
