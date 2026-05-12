import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/routes/app_routes.dart';
import 'package:leudaar_app/utils/custom_snackbar.dart';

// ================== Onboarding pages ==============================

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final currentPage = 0.obs;

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < 2) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Get.toNamed(AppRoutes.registerPage);
    }
  }
}
// ======================== Login page =========================

class AuthController extends GetxController {
  // Controllers
  TextEditingController nameCtrl = TextEditingController();
  TextEditingController mobileCtrl = TextEditingController();

  // OTP fields
  List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  RxBool isLoading = false.obs;

  void sendOtp() {
    if (mobileCtrl.text.isEmpty) {
      AppSnackbar.show(
        title: "Error",
        message: "Enter mobile number",
        type: SnackBarType.warning,
      );

      return;
    }

    isLoading.value = true;

    Future.delayed(const Duration(seconds: 1), () {
      isLoading.value = false;
      Get.toNamed(AppRoutes.otpPage);
      AppSnackbar.show(
        title: "OTP Send",
        message: "OTP sent to ${mobileCtrl.text}",
        type: SnackBarType.success,
      );
    });
  }

  void verifyOtp() {
    String enteredOtp = otpControllers.map((e) => e.text).join();

    if (enteredOtp.isNotEmpty) {
      AppSnackbar.show(
        title: "Success",
        message: "OTP Verified Successfully",
        type: SnackBarType.success,
      );

      // navigate to home or dashboard
      Get.offAndToNamed(AppRoutes.home);
    } else {
      AppSnackbar.show(
        title: "Error",
        message: "Invalid OTP",
        type: SnackBarType.error,
      );
    }
  }

  void resendOtp() async {
    // Your resend API call here
    // e.g. await _authRepo.resendOtp(phoneNumber);
  }
}
