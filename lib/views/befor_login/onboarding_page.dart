import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/routes/app_routes.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/view_model/before_login/auth_controller.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

    final List<Map<String, dynamic>> pages = [
      {
        "icon": Icons.people_rounded,
        "tag": "Friends & Family",
        "title": "Borrow from friends\n& family",
        "subtitle":
            "Send a request, get it recorded instantly.\nNo awkward follow-ups ever again.",
        "badge": "100% private & secure",
      },
      {
        "icon": Icons.qr_code_scanner_rounded,
        "tag": "Shop Credit",
        "title": "Shop credit\nmade simple",
        "subtitle":
            "Scan the store QR, log the amount.\nAuto-repay on due date.",
        "badge": "Works at 10,000+ stores",
      },
      {
        "icon": Icons.verified_user_rounded,
        "tag": "Legal Protection",
        "title": "Every deal,\nlegally protected",
        "subtitle":
            "Digital agreements you can trust.\nBuilt for India's credit economy.",
        "badge": "RBI compliant",
      },
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // ── Skip button ────────────────────────────────
              Obx(
                () => Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: controller.currentPage.value != pages.length - 1
                        ? 1.0
                        : 0.0,
                    child: GestureDetector(
                      onTap: () => Get.offAllNamed(AppRoutes.registerPage),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 24, 0),
                        child: Text(
                          "Skip",
                          style: text13(
                            fontWeight: FontWeight.w500,
                          ).copyWith(color: AppColors.grey500),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Page slides ────────────────────────────────
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: controller.onPageChanged,
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    final data = pages[index];
                    return _OnboardingPage(data: data);
                  },
                ),
              ),

              // ── Dots + CTA ─────────────────────────────────
              Obx(
                () => Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
                  child: Column(
                    children: [
                      // Dot indicators
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
                                  ? const Color(0xFF1A1A1A)
                                  : const Color(0xFFD3D1C7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Main button
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Single slide ──────────────────────────────────────────────────────────────

class _OnboardingPage extends StatelessWidget {
  final Map<String, dynamic> data;
  const _OnboardingPage({required this.data});

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
              data['icon'] as IconData,
              size: 48,
              color: AppColors.white,
            ),
          ),

          const SizedBox(height: 32),

          // Micro-tag
          Text(
            (data['tag'] as String).toUpperCase(),
            style: text11(
              fontWeight: FontWeight.w600,
              color: AppColors.grey500,
            ).copyWith(letterSpacing: 0.9),
          ),

          const SizedBox(height: 10),

          // Title
          Text(
            data['title'] as String,
            textAlign: TextAlign.center,
            style: text26(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ).copyWith(height: 1.2, letterSpacing: -0.3),
          ),

          const SizedBox(height: 16),

          // Subtitle
          Text(
            data['subtitle'] as String,
            textAlign: TextAlign.center,
            style: text14(color: AppColors.textSecondary).copyWith(height: 1.6),
          ),

          const SizedBox(height: 24),

          // Feature badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEEEAE3),
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
                  data['badge'] as String,
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
