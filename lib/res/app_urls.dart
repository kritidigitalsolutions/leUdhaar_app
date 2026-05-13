class AppUrls {
  static const String baseUrl = "http://192.168.1.17:5005/api";

  //--------------------------------------------------
  //auth
  //----------------------------------------------------

  static const String onBoarding = "$baseUrl/global/onboarding";
  static const String sentOtp = "$baseUrl/user/auth/login";
  static const String otpVerify = "$baseUrl/user/auth/verify-otp";
  static const String register = "$baseUrl/user/auth/register";

  //-----------------------------------------------------------
  // profile edit
  //-----------------------------------------------

  static const String editProfile = '$baseUrl/user/auth/profile';
}
