import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/view_model/before_login/auth_controller.dart';
import 'package:leudaar_app/views/befor_login/signup_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

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
                    color: const Color(0xFF1A1A1A),
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

                Text(
                  "Welcome Back",
                  style: text24(
                    fontWeight: FontWeight.w700,
                  ).copyWith(color: AppColors.primary, letterSpacing: -0.3),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  "Login to your Leudaar account",
                  style: text14(
                    fontWeight: FontWeight.normal,
                  ).copyWith(color: const Color(0xFF7A7670)),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 36),

                // ── Mobile field ──────────────────────────────
                const _SectionLabel("Mobile Number"),
                const SizedBox(height: 8),
                PhoneTextField(controller: controller.mobileCtrl),

                const SizedBox(height: 28),

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
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TrustBadge(label: "SSL Secured"),
                    SizedBox(width: 10),
                    TrustBadge(label: "RBI Compliant"),
                  ],
                ),

                const SizedBox(height: 32),

                // ── Divider ───────────────────────────────────
                Row(
                  children: [
                    const Expanded(child: Divider(color: Color(0xFFE4E1DB))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        "New here?",
                        style: text12(
                          fontWeight: FontWeight.normal,
                        ).copyWith(color: const Color(0xFFB0ABA4)),
                      ),
                    ),
                    const Expanded(child: Divider(color: Color(0xFFE4E1DB))),
                  ],
                ),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () => Get.back(),
                  child: Text(
                    "Create an account →",
                    style: text14(
                      fontWeight: FontWeight.w600,
                    ).copyWith(color: const Color(0xFF1A1A1A)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
