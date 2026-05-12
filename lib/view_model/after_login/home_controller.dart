import 'package:get/get.dart';
import 'package:leudaar_app/routes/app_routes.dart';
import 'package:leudaar_app/utils/custom_snackbar.dart';

class Transaction {
  final String initials;
  final String name;
  final String dueDate;
  final double amount;
  final String status; // 'Pending' | 'Active' | 'Paid'

  Transaction({
    required this.initials,
    required this.name,
    required this.dueDate,
    required this.amount,
    required this.status,
  });
}

class HomeController extends GetxController {
  // User info
  final userName = 'Rahul Sharma'.obs;
  final userInitials = 'RS'.obs;

  // Balance summary
  final totalPendingAmount = 3550.0.obs;
  final youNeedToPay = 2400.0.obs;
  final youWillReceive = 1150.0.obs;

  // Notifications count
  final notificationCount = 3.obs;

  // Transactions list
  final transactions = <Transaction>[
    Transaction(
      initials: 'AB',
      name: 'Amit Bhai',
      dueDate: 'Due 15 May',
      amount: -500,
      status: 'Pending',
    ),
    Transaction(
      initials: 'AB',
      name: 'Sharma Kirana',
      dueDate: 'Due 20 May',
      amount: -400,
      status: 'Active',
    ),
    Transaction(
      initials: 'RK',
      name: 'Ravi Kumar',
      dueDate: 'Due 18 May',
      amount: 750,
      status: 'Active',
    ),
    Transaction(
      initials: 'MK',
      name: 'Mohan Kiryana',
      dueDate: 'Due 22 May',
      amount: -300,
      status: 'Paid',
    ),
  ].obs;

  void goToLeUdhaar() {
    Get.toNamed(AppRoutes.leUdhaar);
  }

  void goToLeBalance() {
    Get.toNamed(AppRoutes.leBalance);
  }

  void goToLeLegally() {
    AppSnackbar.show(
      message: 'Le\'Legally will be available soon!',
      title: "Coming Soon",
      type: SnackBarType.info,
    );
  }

  void goToNotifications() {
    Get.toNamed(AppRoutes.notification);
  }

  void goToProfile() {
    Get.toNamed(AppRoutes.profile);
  }
}
