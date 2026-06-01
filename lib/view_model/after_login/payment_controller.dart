// lib/view_model/after_login/payment_controller/payment_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/models/response_model/leudhaar_res/request_money_res_model.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../repo/payment_repo.dart';

enum PaymentState { idle, creatingOrder, processing, success, failed }

class PaymentController extends GetxController {
  final PaymentRepository _repo = PaymentRepository();

  final Rx<PaymentState> paymentState = PaymentState.idle.obs;
  final RxString errorMessage = ''.obs;

  late Razorpay _razorpay;

  // Razorpay test key — replace with live key in production
  static const String _razorpayKey = 'rzp_test_SuKwFzUvOxUlZD';

  @override
  void onInit() {
    super.onInit();
    _initRazorpay();
  }

  void _initRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  // ── Main entry point ────────────────────────────────────────────────────────
  Future<void> initiatePayment({
    required Datum req,
    required BuildContext context,
  }) async {
    try {
      paymentState.value = PaymentState.creatingOrder;
      errorMessage.value = '';

      // Step 1: Create order from backend
      final orderRes = await _repo.createOrder(
        amount: req.amount ?? 0,
        requestId: req.id ?? '',
      );

      final orderId = orderRes['order']?['id'];
      if (orderId == null) throw Exception('Order ID not received from server');

      // Step 2: Build Razorpay options
      // Lender ko kuch enter nahi karna — Razorpay khud
      // UPI / Card / Net banking options dikhata hai
      final options = _buildOptions(req: req, orderId: orderId);

      paymentState.value = PaymentState.processing;

      // Step 3: Open Razorpay checkout
      _razorpay.open(options);
    } catch (e) {
      paymentState.value = PaymentState.failed;
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Could not initiate payment. Please try again.',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ── Build Razorpay options ───────────────────────────────────────────────────
  Map<String, dynamic> _buildOptions({
    required Datum req,
    required String orderId,
  }) {
    final borrowerName = req.requestFrom?.fullName ?? '';
    final borrowerPhone = req.requestFrom?.phone ?? '';
    final receiveMethod = req.receiveMethod?.toLowerCase() ?? '';

    final options = <String, dynamic>{
      'key': _razorpayKey,
      'amount': (req.amount ?? 0) * 100, // Razorpay paisa mein leta hai
      'order_id': orderId,
      'name': 'Leudaar',
      'description': req.reason ?? 'Money Transfer',
      'prefill': {'name': borrowerName, 'contact': borrowerPhone},
      'theme': {'color': '#3B82F6'},
      'send_sms_hash': true,
      'retry': {'enabled': true, 'max_count': 2},
    };

    options['method'] = {
      'upi': true,
      'card': true,
      'netbanking': true,
      'wallet': true,
    };

    // // ── receiveMethod ke hisaab se preferred method set karo ──────────────────
    // // Lender manually kuch nahi bharta — ye sirf Razorpay ko hint deta hai
    // if (receiveMethod == 'upi') {
    //   options['method'] = {
    //     'upi': true,
    //     'card': false,
    //     'netbanking': false,
    //     'wallet': false,
    //   };

    //   // Agar borrower ka UPI ID hai to prefill kar do
    //   final upiId = req.receiveDetails?.upiId;
    //   if (upiId != null && upiId.isNotEmpty) {
    //     options['prefill']['vpa'] = upiId; // VPA = UPI ID
    //   }
    // } else if (receiveMethod == 'bankTransfer') {
    //   // Bank transfer ke liye NEFT/IMPS
    //   options['method'] = {
    //     'upi': false,
    //     'card': false,
    //     'netbanking': true,
    //     'wallet': false,
    //   };
    // } else {
    //   // 'auto' ya koi bhi — sab methods dikhao
    //   options['method'] = {
    //     'upi': true,
    //     'card': true,
    //     'netbanking': true,
    //     'wallet': true,
    //   };
    // }

    return options;
  }

  // ── Razorpay Callbacks ───────────────────────────────────────────────────────
  void _onPaymentSuccess(PaymentSuccessResponse response) async {
    try {
      paymentState.value = PaymentState.processing;

      // Verify payment with backend
      await _repo.verifyPayment(
        razorpayOrderId: response.orderId ?? '',
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
      );

      paymentState.value = PaymentState.success;

      Get.snackbar(
        'Success!',
        'Payment of has been sent successfully.',
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      // Navigate back to home or success screen
      await Future.delayed(const Duration(milliseconds: 500));
      Get.until((route) => route.isFirst);
    } catch (e) {
      paymentState.value = PaymentState.failed;
      errorMessage.value = 'Payment done but verification failed: $e';
      Get.snackbar(
        'Verification Failed',
        'Payment was made but verification failed. Contact support.',
        backgroundColor: Colors.orange.shade50,
        colorText: Colors.orange,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    paymentState.value = PaymentState.failed;
    errorMessage.value = response.message ?? 'Payment failed';

    Get.snackbar(
      'Payment Failed',
      response.message ?? 'Something went wrong. Please try again.',
      backgroundColor: Colors.red.shade50,
      colorText: Colors.red,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    Get.snackbar(
      'External Wallet',
      'Payment via ${response.walletName}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
