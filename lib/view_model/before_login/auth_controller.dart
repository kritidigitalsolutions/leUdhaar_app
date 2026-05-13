import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/data/api_response.dart';
import 'package:leudaar_app/models/response_model/auth_models/onborading_res_model.dart';
import 'package:leudaar_app/repo/auth_repo.dart';
import 'package:leudaar_app/routes/app_routes.dart';
import 'package:leudaar_app/utils/custom_snackbar.dart';
import 'package:leudaar_app/utils/service/local_storage/auth_storage.dart';

// ================== Onboarding pages ==============================

class OnboardingController extends GetxController {
  final AuthRepo _repo = AuthRepo();
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

  final onboardingResponse = ApiResponse<OnboradingResModel>.loading().obs;

  @override
  void onInit() {
    super.onInit();
    getOnboardingData();
  }

  Future<void> getOnboardingData() async {
    onboardingResponse.value = ApiResponse.loading();

    final res = await _repo.getOnboarding();

    onboardingResponse.value = res;
  }
}
// ======================== Login page =========================

class AuthController extends GetxController {
  final AuthRepo _repo = AuthRepo();
  // Controllers
  TextEditingController nameCtrl = TextEditingController();
  TextEditingController mobileCtrl = TextEditingController();

  TextEditingController loginMobileCtr = TextEditingController();

  // OTP fields
  List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  // =================== register send ==================================

  final registerRes = Rx<ApiResponse<Map<String, dynamic>>?>(null);

  Future<void> register() async {
    registerRes.value = ApiResponse.loading();

    final res = await _repo.register(
      nameCtrl.text.trim(),
      mobileCtrl.text.trim(),
    );

    registerRes.value = res;
    print("STATUS: ${registerRes.value?.status}");
    print("DATA: ${res.data}");
    print("MESSAGE: ${registerRes.value?.message}");

    if (res.data?["success"] == true) {
      AppSnackbar.show(
        duration: Duration(seconds: 10),
        title: "OTP",
        message:
            "${res.data?["data"]["phone"]}, ${res.data?["message"]} ${res.data?["data"]["devOtp"]}",
        type: SnackBarType.success,
      );
      Get.toNamed(AppRoutes.otpPage, arguments: mobileCtrl.text.trim());
    }
  }

  Future<void> sendOtp() async {
    registerRes.value = ApiResponse.loading();

    final res = await _repo.sendOtp(loginMobileCtr.text.trim());

    registerRes.value = res;
    print("STATUS: ${registerRes.value?.status}");
    print("DATA: ${res.data}");
    print("MESSAGE: ${registerRes.value?.message}");

    if (res.data?["success"] == true) {
      AppSnackbar.show(
        duration: Duration(seconds: 10),
        title: "OTP",
        message:
            "${res.data?["data"]["phone"]}, ${res.data?["message"]} ${res.data?["data"]["devOtp"]}",
        type: SnackBarType.success,
      );
      Get.toNamed(AppRoutes.otpPage, arguments: loginMobileCtr.text.trim());
    }
  }

  // ===============verify otp ======================================

  RxBool isLoading = false.obs;

  Future<void> verifyOtp(String phone) async {
    isLoading.value = true;

    final enteredOtp = otpControllers.map((e) => e.text).join();

    if (enteredOtp.length != 6) {
      AppSnackbar.show(
        title: "Error",
        message: "Please enter 6 digit OTP",
        type: SnackBarType.error,
      );
      isLoading.value = false;
      return;
    }

    final res = await _repo.verifyOtp(phone, enteredOtp);

    isLoading.value = false;

    print("STATUS: ${res.status}");
    print("DATA: ${res.data}");
    print("MESSAGE: ${res.message}");

    if (res.data?.success == true) {
      AppSnackbar.show(
        title: "Success",
        message: res.data?.message ?? "OTP verified successfully",
        type: SnackBarType.success,
      );

      await AuthStorage.saveToken(res.data?.data?.token ?? "");

      if (res.data?.data?.user != null) {
        await AuthStorage.saveUser(res.data!.data!.user!);
      }

      Get.offAllNamed(AppRoutes.home);
    } else {
      AppSnackbar.show(
        title: "Error",
        message: res.data?.message ?? "Invalid OTP",
        type: SnackBarType.error,
      );
    }
  }

  void resendOtp() async {
    // Your resend API call here
    // e.g. await _authRepo.resendOtp(phoneNumber);
  }
}
