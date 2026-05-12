import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/routes/app_routes.dart';
import 'package:leudaar_app/utils/custom_snackbar.dart';

class LeBalanceController extends GetxController {
  final isScanning = false.obs;
  final shopIdController = ''.obs;
  final manualShopId = ''.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  void startScanning() {
    isScanning.value = true;
    errorMessage.value = '';
    Get.toNamed(AppRoutes.shopFound);
  }

  void stopScanning() {
    isScanning.value = false;
  }

  void handleQrResult(String qrData) {
    isScanning.value = false;
    if (qrData.isEmpty) {
      errorMessage.value = 'Invalid QR code. Please try again.';
      return;
    }
    // Navigate or process QR data
    Get.snackbar(
      'QR Scanned',
      'Shop ID: $qrData',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void submitManualShopId() async {
    if (manualShopId.value.trim().isEmpty) {
      errorMessage.value = 'Please enter a Shop ID.';
      return;
    }
    errorMessage.value = '';
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1)); // simulate API
    isLoading.value = false;
    // Navigate to shop detail or process
    Get.snackbar(
      'Shop Found',
      'Opening shop: ${manualShopId.value}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void goBack() {
    Get.back();
  }
}

// ===================== Shop controller =======================
//
//================================================================

class ShopFoundController extends GetxController {
  final shopName = 'Sharma Kirana'.obs;
  final shopAddress = 'Sector 12, Meerut'.obs;
  final isVerified = true.obs;

  void rescan() => Get.back();

  void continueToCredit() {
    Get.toNamed(
      AppRoutes.creditDetails,
      arguments: {'shopName': shopName.value, 'shopAddress': shopAddress.value},
    );
  }
}

// ===================== credit controller =======================
//
//================================================================

class CreditDetailsController extends GetxController {
  late String shopName;
  late String shopAddress;

  final whatBoughtController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final dateTaken = ''.obs;
  final returnBy = ''.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    shopName = args['shopName'] ?? 'Sharma Kirana';
    shopAddress = args['shopAddress'] ?? '';
    final now = DateTime.now();
    dateTaken.value = _fmt(now);
    returnBy.value = _fmt(now.add(const Duration(days: 12)));
  }

  String _fmt(DateTime dt) {
    const m = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${m[dt.month]} ${dt.year}';
  }

  Future<void> pickDateTaken(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: _datePicker,
    );
    if (picked != null) dateTaken.value = _fmt(picked);
  }

  Future<void> pickReturnBy(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 12)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: _datePicker,
    );
    if (picked != null) returnBy.value = _fmt(picked);
  }

  Widget _datePicker(BuildContext ctx, Widget? child) => Theme(
    data: ThemeData.light().copyWith(
      colorScheme: const ColorScheme.light(primary: AppColors.primary),
    ),
    child: child!,
  );

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;
    Get.toNamed(AppRoutes.repaymentMethod);
    AppSnackbar.show(
      title: 'Credit Added',
      message: '₹${amountController.text} credit recorded for $shopName',
      type: SnackBarType.success,
    );
  }

  @override
  void onClose() {
    whatBoughtController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.onClose();
  }
}

// ===================== repayment controller =======================
//
//================================================================

enum RepaymentMethod { autoPay, manualSupport, microDebit, smartProtect }

class RepaymentController extends GetxController {
  late String shopName;
  late String amount;
  late String dueDate;

  final selectedMethod = RepaymentMethod.autoPay.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    shopName = args['shopName'] ?? 'Sharma Kirana';
    amount = args['amount'] ?? '400';
    dueDate = args['dueDate'] ?? '20 May 2026';
  }

  String get methodLabel {
    switch (selectedMethod.value) {
      case RepaymentMethod.autoPay:
        return 'Auto Debit';
      case RepaymentMethod.manualSupport:
        return 'Manual';
      case RepaymentMethod.microDebit:
        return 'Micro Debit';
      case RepaymentMethod.smartProtect:
        return "Smart Protect";
    }
  }

  void selectMethod(RepaymentMethod method) => selectedMethod.value = method;

  Future<void> next() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;
    Get.toNamed(AppRoutes.creditLogged);
    Get.toNamed(
      '/credit-logged',
      arguments: {
        'shopName': shopName,
        'amount': amount,
        'dueDate': dueDate,
        'repayment': methodLabel,
      },
    );
  }
}

// ===================== CreditLoggedController controller =======================
//
//================================================================

class CreditLoggedController extends GetxController {
  late String shopName;
  late String amount;
  late String dueDate;
  late String repayment;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    shopName = args['shopName'] ?? 'Sharma Kirana';
    amount = args['amount'] ?? '400';
    dueDate = args['dueDate'] ?? '20 May 2026';
    repayment = args['repayment'] ?? 'Auto Debit';
  }

  void goToDashboard() => Get.offAllNamed('/home');
}
