// lib/data/repository/payment_repository.dart

import 'package:flutter/foundation.dart';
import 'package:leudaar_app/data/network/network_api_service.dart';
import 'package:leudaar_app/res/app_urls.dart';
import '../utils/service/local_storage/auth_storage.dart';

class PaymentRepository {
  final _apiServices = NetworkApiService();

  /// Step 1: Create Razorpay Order
  Future<Map<String, dynamic>> createOrder({
    required int amount,
    required String requestId,
  }) async {
    try {
      final token = AuthStorage.getToken();
      _apiServices.setToken(token ?? '');

      final response = await _apiServices.postApi(
        AppUrls.createOrder,
        {
          "amount": amount,

        },
      );

      debugPrint("Create Order Response: $response");

      return response as Map<String, dynamic>;
    } catch (e, stackTrace) {
      debugPrint("Create Order Error: $e");
      debugPrint("Stack Trace: $stackTrace");
      rethrow;
    }
  }

  /// Step 2: Verify Payment
  Future<Map<String, dynamic>> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final token = AuthStorage.getToken();
      _apiServices.setToken(token ?? '');

      final response = await _apiServices.postApi(
        AppUrls.verifyPayment,
        {
          "razorpay_order_id": razorpayOrderId,
          "razorpay_payment_id": razorpayPaymentId,
          "razorpay_signature": razorpaySignature,
        },
      );

      debugPrint("Verify Payment Response: $response");

      return response as Map<String, dynamic>;
    } catch (e, stackTrace) {
      debugPrint("Verify Payment Error: $e");
      debugPrint("Stack Trace: $stackTrace");
      rethrow;
    }
  }
}