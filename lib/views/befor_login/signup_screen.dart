import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/routes/app_routes.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/view_model/before_login/auth_controller.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                // ── Logo ──────────────────────────────────────
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "₹",
                    style: text40(
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ).copyWith(height: 1),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Headline ──────────────────────────────────
                Text(
                  "Create your Account",
                  style: text24(
                    fontWeight: FontWeight.w700,
                  ).copyWith(color: AppColors.textPrimary, letterSpacing: -0.3),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  "Join Leudaar and manage your finances smarter",
                  style: text14(
                    fontWeight: FontWeight.normal,
                  ).copyWith(color: AppColors.textSecondary, height: 1.5),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 36),

                // ── Form ──────────────────────────────────────
                _SectionLabel("Full Name"),
                const SizedBox(height: 8),
                _StyledTextField(
                  controller: controller.nameCtrl,
                  hintText: 'ex. Rahul Sharma',
                  icon: Icons.person_outline_rounded,
                ),

                const SizedBox(height: 20),

                _SectionLabel("Mobile Number"),
                const SizedBox(height: 8),
                PhoneTextField(controller: controller.mobileCtrl),

                const SizedBox(height: 32),

                // ── CTA ───────────────────────────────────────
                Obx(
                  () => SendOtpButton(
                    isLoading: controller.isLoading.value,
                    onTap: controller.isLoading.value
                        ? null
                        : controller.sendOtp,
                  ),
                ),

                const SizedBox(height: 20),

                // ── Trust badges ──────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    TrustBadge(label: "SSL Secured"),
                    SizedBox(width: 10),
                    TrustBadge(label: "RBI Compliant"),
                  ],
                ),

                const SizedBox(height: 32),

                // ── Divider ───────────────────────────────────
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.grey300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        "Already a member?",
                        style: text12(
                          fontWeight: FontWeight.normal,
                        ).copyWith(color: AppColors.grey),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.grey300)),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Login link ────────────────────────────────
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.loginPage),
                  child: Text(
                    "Login to your account →",
                    style: text14(
                      fontWeight: FontWeight.w600,
                    ).copyWith(color: AppColors.textPrimary),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text.toUpperCase(),
        style: text11(
          fontWeight: FontWeight.w600,
          color: AppColors.grey500,
        ).copyWith(letterSpacing: 0.8),
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;

  const _StyledTextField({
    required this.controller,
    required this.hintText,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E1DB)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF9E9A94)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Color(0xFFBEB9B2),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: text15(
                color: AppColors.textPrimary,
              ).copyWith(letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }
}

class PhoneTextField extends StatelessWidget {
  final TextEditingController controller;
  const PhoneTextField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E1DB)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Text(
            "+91",
            style: text14(
              fontWeight: FontWeight.w600,
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(width: 10),
          Container(width: 1, height: 20, color: const Color(0xFFE4E1DB)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 10,
              decoration: const InputDecoration(
                hintText: "99xxxxxxxx",
                hintStyle: TextStyle(color: Color(0xFFBEB9B2), fontSize: 15),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                counterText: "",
              ),
              style: text15(
                color: AppColors.textPrimary,
              ).copyWith(letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }
}

class SendOtpButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onTap;
  const SendOtpButton({required this.isLoading, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isLoading ? const Color(0xFF555555) : AppColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Send OTP",
                    style: text16(
                      color: AppColors.white,

                      fontWeight: FontWeight.w600,
                    ).copyWith(letterSpacing: 0.3),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.white,
                    size: 18,
                  ),
                ],
              ),
      ),
    );
  }
}

class TrustBadge extends StatelessWidget {
  final String label;
  const TrustBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          const SizedBox(width: 6),
          Text(
            label,
            style: text11(
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
