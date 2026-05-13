import 'package:get/get.dart';
import 'package:leudaar_app/data/binding/home_binding.dart';
import 'package:leudaar_app/routes/app_routes.dart';
import 'package:leudaar_app/views/after_login/home_screen.dart';
import 'package:leudaar_app/views/after_login/le_balance/creadit_logged_screen.dart';
import 'package:leudaar_app/views/after_login/le_balance/credit_details_screen.dart';
import 'package:leudaar_app/views/after_login/le_balance/repayment_method_screen.dart';
import 'package:leudaar_app/views/after_login/le_balance/scan_qr_screen.dart';
import 'package:leudaar_app/views/after_login/le_balance/shop_found_screen.dart';
import 'package:leudaar_app/views/after_login/le_udhaar/find_person_screen.dart';
import 'package:leudaar_app/views/after_login/le_udhaar/le_udhaar_screen.dart';
import 'package:leudaar_app/views/after_login/le_udhaar/request_money_screen.dart';
import 'package:leudaar_app/views/after_login/le_udhaar/request_sended_screen.dart';
import 'package:leudaar_app/views/after_login/notification_screen.dart';
import 'package:leudaar_app/views/after_login/profile/agreement_screen.dart';
import 'package:leudaar_app/views/after_login/profile/auto_debit_rec_screen.dart';
import 'package:leudaar_app/views/after_login/profile/chats_pages/my_chat_list_screen.dart';
import 'package:leudaar_app/views/after_login/profile/chats_pages/my_chat_screen.dart';
import 'package:leudaar_app/views/after_login/profile/chats_pages/search_chats_contect_screen.dart';
import 'package:leudaar_app/views/after_login/profile/dashboard_screen.dart';
import 'package:leudaar_app/views/after_login/profile/edit_profile_page.dart';
import 'package:leudaar_app/views/after_login/profile/micro_debit_rec_screen.dart';
import 'package:leudaar_app/views/after_login/profile/my_wallet/my_wallet_screen.dart';
import 'package:leudaar_app/views/after_login/profile/profile_screen.dart';
import 'package:leudaar_app/views/after_login/profile/request/accept_request_screen.dart';
import 'package:leudaar_app/views/after_login/profile/request/confirmed_request_page.dart';
import 'package:leudaar_app/views/after_login/profile/request/requests_screen.dart';
import 'package:leudaar_app/views/befor_login/login_screen.dart';
import 'package:leudaar_app/views/befor_login/onboarding_page.dart';
import 'package:leudaar_app/views/befor_login/otp_screen.dart';
import 'package:leudaar_app/views/befor_login/signup_screen.dart';
import 'package:leudaar_app/views/befor_login/splash_screen.dart';

class AppPages {
  static final pages = [
    // =========================== auth ===========================
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.onBoarding,
      page: () => OnboardingScreen(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.loginPage,
      page: () => LoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.otpPage,
      page: () => OtpScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.registerPage,
      page: () => SignupScreen(),
      transition: Transition.fadeIn,
    ),

    // ====================== Home =========================
    GetPage(
      name: AppRoutes.home,
      page: () => HomeScreen(),
      transition: Transition.fadeIn,
      binding: HomeBinding(),
    ),

    GetPage(
      name: AppRoutes.notification,
      page: () => NotificationPage(),
      transition: Transition.fadeIn,
    ),

    // ============== Le balance ===================
    GetPage(
      name: AppRoutes.leBalance,
      page: () => LeBalanceScreen(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.shopFound,
      page: () => ShopFoundScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.creditDetails,
      page: () => CreditDetailsScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.repaymentMethod,
      page: () => RepaymentMethodScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.creditLogged,
      page: () => CreditLoggedScreen(),
      transition: Transition.fadeIn,
    ),

    // ============== profile pages ===================
    GetPage(
      name: AppRoutes.profile,
      page: () => ProfileScreen(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.editProfile,
      page: () => EditProfileScreen(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.dashboard,
      page: () => DashboardScreen(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.myWallet,
      page: () => MyWalletScreen(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.agreements,
      page: () => AgreementsScreen(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.autoDebit,
      page: () => AutoDebitRecoveryScreen(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.microDebit,
      page: () => MicroDebitRecoveryScreen(),
      transition: Transition.fadeIn,
    ),

    // ==================== request ==================================
    GetPage(
      name: AppRoutes.requestScreen,
      page: () => RequestsScreen(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.acceptRequest,
      page: () => AcceptRequestScreen(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.confirmedRequest,
      page: () => ConfirmedRequestPage(),
      transition: Transition.fadeIn,
    ),

    // ============== chat pages  ===================
    GetPage(
      name: AppRoutes.myChatListScreen,
      page: () => MyChatListScreen(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.searchChat,
      page: () => ChatSearchScreen(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.myChatPage,
      page: () => ChatDetailScreen(),
      transition: Transition.fadeIn,
    ),

    // ============== le udhaar pages  ===================
    GetPage(
      name: AppRoutes.leUdhaar,
      page: () => LeUdhaarScreen(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.findPersonScreen,
      page: () => FindPersonScreen(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.requestMoneyScreen,
      page: () => RequestMoneyScreen(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.requestSendedScreen,
      page: () => RequestSendedScreen(),
      transition: Transition.fadeIn,
    ),

    // ====================== policy ===========================

    //     GetPage(name: AppRoutes.termsConditions,
    //   page: () => const PolicyPage(
    //     type: PolicyType.terms)),
    // GetPage(name: AppRoutes.privacyPolicy,
    //   page: () => const PolicyPage(
    //     type: PolicyType.privacy)),
    // GetPage(name: AppRoutes.helpSupport,
    //   page: () => const HelpSupportPage()),
    // GetPage(name: AppRoutes.aboutApp,
    //   page: () => const AboutAppPage()),
  ];
}
