import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/data/api_response.dart';
import 'package:leudaar_app/models/request_model/leUdhaar_request/leudhaarReq_modles.dart';
import 'package:leudaar_app/repo/leUdhaar_repo.dart';
import 'package:leudaar_app/routes/app_routes.dart';
import 'package:leudaar_app/utils/custom_snackbar.dart';

class RequestMoneyController extends GetxController {
  final LeudhaarRepo _repo = LeudhaarRepo();
  final isLoading = false.obs;
  // ── Text Controllers ─────────────────────
  final amountController = TextEditingController();
  final reasonController = TextEditingController();
  final returnByController = TextEditingController();

  final upiController = TextEditingController();
  final accountNumberController = TextEditingController();
  final ifscController = TextEditingController();
  final accountHolderController = TextEditingController();

  // ── State ────────────────────────────────
  var selectedRepaymentMode = 'auto-debit'.obs;
  var selectedPaymentMethod = 'upi'.obs;

  Map<String, dynamic> get person {
    final args = Get.arguments;
    if (args is Map<String, dynamic>) return args;

    return {
      'initials': 'RV',
      'name': 'Rahul Verma',
      'subtitle': 'On Le\'Udhaar · Verified',
    };
  }

  // ── Repayment Modes ──────────────────────
  final repaymentModes = [
    {
      'title': 'AutoPay',
      "type": "auto-debit",
      'subtitle': 'Auto debit on due date',
      'desc': 'Automatic deduction + reminders & calling support',
      'icon': Icons.autorenew_rounded,
    },
    {
      'title': 'Micro Debit',
      "type": "micro-debit",
      'subtitle': 'Daily micro-debits',
      'desc': 'Daily small debits + reminders & support',
      'icon': Icons.calendar_today_rounded,
    },
    {
      'title': 'Smart Protect',
      "type": "smart-protect",
      'subtitle': 'Autodebit + Failsafe',
      'desc': 'Autodebit + microdebit backup + recovery workflow',
      'icon': Icons.security_rounded,
    },
    {
      'title': 'Manual Support',
      "type": "manual",
      'subtitle': 'Manual repayment',
      'desc': 'Manual payment with reminders & calling assistance',
      'icon': Icons.support_agent_rounded,
    },
  ];

  // ── Payment Methods ──────────────────────
  final paymentMethods = [
    {
      'title': 'UPI',
      "type": "upi",
      'subtitle': 'Receive via UPI ID',
      'icon': Icons.account_balance_wallet_rounded,
    },
    {
      'title': 'Bank Transfer',
      "type": "bankTransfer",
      'subtitle': 'NEFT / IMPS / RTGS',
      'icon': Icons.account_balance_rounded,
    },
  ];

  // ── Date picker ──────────────────────────
  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2026, 5, 30),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      returnByController.text =
          '${picked.day} ${_monthName(picked.month)} ${picked.year}';
    }
  }

  String _monthName(int m) {
    const months = [
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
    return months[m];
  }

  // ── Payload ──────────────────────────────
  // ── Payload for Success Screen ─────────────────────
  Map<String, dynamic> buildPayload() {
    return {
      'sentTo': person['name'] ?? 'User',
      'amount': amountController.text.trim(),
      'reason': reasonController.text.trim(),
      'returnBy': returnByController.text.trim(),
      'repaymentMode': selectedRepaymentMode.value,
      'paymentMethod': selectedPaymentMethod.value,
    };
  }

  // ── Validation ───────────────────────────
  String? validate() {
    if (amountController.text.trim().isEmpty) {
      return 'Please enter amount';
    }
    if (reasonController.text.trim().isEmpty) {
      return 'Please enter reason';
    }
    if (returnByController.text.trim().isEmpty) {
      return 'Please select date';
    }

    if (selectedPaymentMethod.value == 'UPI' &&
        upiController.text.trim().isEmpty) {
      return 'Enter UPI ID';
    }

    if (selectedPaymentMethod.value == 'Bank Transfer') {
      if (accountHolderController.text.trim().isEmpty) {
        return 'Enter account holder name';
      }
      if (accountNumberController.text.trim().isEmpty) {
        return 'Enter account number';
      }
      if (ifscController.text.trim().isEmpty) {
        return 'Enter IFSC code';
      }
    }

    return null;
  }

  // ── Build Request Model ─────────────────────
  RequestMoneyReqModel _buildRequestModel() {
    final paymentMethod = selectedPaymentMethod.value;

    ReceiveDetails receiveDetails;

    if (paymentMethod == 'upi') {
      receiveDetails = ReceiveDetails(upiId: upiController.text.trim());
    } else if (paymentMethod == 'bankTransfer') {
      receiveDetails = ReceiveDetails(
        accountHolderName: accountHolderController.text.trim(),
        accountNumber: accountNumberController.text.trim(),
        ifscCode: ifscController.text.trim(),
      );
    } else {
      receiveDetails = ReceiveDetails();
    }

    return RequestMoneyReqModel(
      requestTo:
          person['userId'] ??
          person['id'] ??
          '', // Make sure you pass userId from previous screen
      amount: int.tryParse(amountController.text.replaceAll(',', '')) ?? 0,
      reason: reasonController.text.trim(),
      returnDate: returnByController.text.trim(),
      repaymentMode: selectedRepaymentMode.value,
      receiveMethod: paymentMethod,
      receiveDetails: receiveDetails,
      source: '',
    );
  }

  // ── API Call ───────────────────────────────
  Future<void> sendRequest() async {
    final error = validate();
    if (error != null) {
      AppSnackbar.show(
        title: "Error",
        message: error,
        type: SnackBarType.error,
      );

      return;
    }

    isLoading.value = true;

    try {
      final model = _buildRequestModel();
      final response = await _repo.requestMoney(model);

      if (response.status == Status.completed && response.data != null) {
        final success = response.data?['success'] == true;

        if (success) {
          final payload = buildPayload(); // for success screen if needed
          Get.toNamed(AppRoutes.requestSendedScreen, arguments: payload);
        } else {
          AppSnackbar.show(
            title: "Failed",
            message: response.data?['message'] ?? 'Something went wrong',
            type: SnackBarType.error,
          );
        }
      } else {
        AppSnackbar.show(
          title: "Error",
          message: response.message ?? 'Failed to send request',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void disposeControllers() {
    amountController.dispose();
    reasonController.dispose();
    returnByController.dispose();
    upiController.dispose();
    accountNumberController.dispose();
    ifscController.dispose();
    accountHolderController.dispose();
  }

  @override
  void onClose() {
    disposeControllers();
    super.onClose();
  }
}
