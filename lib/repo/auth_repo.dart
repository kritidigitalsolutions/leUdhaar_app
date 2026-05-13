import 'package:leudaar_app/data/api_response.dart';
import 'package:leudaar_app/data/network/network_api_service.dart';
import 'package:leudaar_app/models/response_model/auth_models/onborading_res_model.dart';
import 'package:leudaar_app/models/response_model/auth_models/verify_res_model.dart';
import 'package:leudaar_app/res/app_urls.dart';

class AuthRepo {
  final _api = NetworkApiService();

  // ===================== Onboarding ==========================

  Future<ApiResponse<OnboradingResModel>> getOnboarding() async {
    try {
      final res = await _api.getApi(AppUrls.onBoarding);
      return ApiResponse.completed(OnboradingResModel.fromJson(res));
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // ===================== register ==========================

  Future<ApiResponse<Map<String, dynamic>>> register(
    String fullName,
    String phone,
  ) async {
    try {
      final res = await _api.postApi(AppUrls.register, {
        "fullName": fullName,
        "phone": phone,
      });
      print("res ---------------------------------$res");
      return ApiResponse.completed(res);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // ===================== Send OTP ==========================

  Future<ApiResponse<Map<String, dynamic>>> sendOtp(String mobile) async {
    try {
      final res = await _api.postApi(AppUrls.sentOtp, {"phone": mobile});
      return ApiResponse.completed(res);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // ===================== Verify OTP ==========================

  Future<ApiResponse<VerifyResModel>> verifyOtp(
    String phone,
    String otp,
  ) async {
    try {
      final res = await _api.postApi(AppUrls.otpVerify, {
        "phone": phone,
        "otp": otp,
      });
      return ApiResponse.completed(VerifyResModel.fromJson(res));
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
