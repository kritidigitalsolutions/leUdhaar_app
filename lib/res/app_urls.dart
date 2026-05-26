class AppUrls {
  static const String baseUrl = "http://192.168.1.22:8001/api";
  static const String imageBaseUrl = "http://192.168.1.22:8001";

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

  //-----------------------------------------------------------
  // policy
  //-----------------------------------------------

  static const String policy = "$baseUrl/global/legal";
  static const String privacyPolicy = "$baseUrl/global/privacy-policy";
  static const String helpSupport = "$baseUrl/global/help-support";
  static const String aboutUs = "$baseUrl/global/about-app";

  //-----------------------------------------------------------
  // profile related
  //-----------------------------------------------

  static const String contactChecker = '$baseUrl/user/contacts';
  static const String requestMoney = '$baseUrl/user/money-requests';
  static const String dashboard = '$baseUrl/user/dashboard/all';
  static const String chatList = '$baseUrl/user/chats';
  static const String chats = '$baseUrl/user/chats/with';
  static const String message = '$baseUrl/user/chats/messages';
}
