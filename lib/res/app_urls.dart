class AppUrls {
  // static const String baseUrl = "http://192.168.29.185:7000/api";
  static const String baseUrl = "http://192.168.1.40:7000/api";

  //--------------------------------------------------
  //auth
  //----------------------------------------------------

  static const String onBoarding = "$baseUrl/wallpapers";
  static const String sentOtp = "$baseUrl/auth/send-otp";
  static const String otpVerify = "$baseUrl/auth/verify-otp";
  static const String register = "$baseUrl/user/profile-info";

  //-----------------------------------------------------------
  // profile edit
  //-----------------------------------------------

  static const String editProfile = '$baseUrl/user/profile-update';
}
