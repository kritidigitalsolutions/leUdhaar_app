// lib/views/after_login_pages/accept_request_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/models/response_model/leudhaar_res/request_money_res_model.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/utils/custom_button.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/views/custom_widget/custom_widget.dart';

import '../../../../view_model/after_login/payment_controller.dart';

class AcceptRequestScreen extends StatefulWidget {
  const AcceptRequestScreen({super.key});

  @override
  State<AcceptRequestScreen> createState() => _AcceptRequestScreenState();
}

class _AcceptRequestScreenState extends State<AcceptRequestScreen> {
  late final Datum req;
  late final PaymentController _paymentController;

  @override
  void initState() {
    super.initState();
    req = Get.arguments as Datum;
    _paymentController = Get.put(PaymentController());
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _monthName(int month) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month];
  }

  String _capitalise(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1).toLowerCase() : s;

  @override
  Widget build(BuildContext context) {
    final name = req.requestFrom?.fullName ?? 'Unknown';
    final initials = _getInitials(name);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.only(
              top: 50, bottom: 16, left: 16, right: 16,
            ),
            child: Row(
              children: [
                backButton(),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Money request',
                        style: text18(
                            fontWeight: FontWeight.bold,
                            color: AppColors.white)),
                    Text('Someone needs your help',
                        style: text12(color: AppColors.white54)),
                  ],
                ),
              ],
            ),
          ),

          Expanded(child: _buildBody(name, initials, context)),
        ],
      ),
    );
  }

  Widget _buildBody(String name, String initials, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.button, width: 1.5),
        ),
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 38,
              backgroundColor: AppColors.primary,
              child: Text(initials,
                  style: text24(
                      fontWeight: FontWeight.bold, color: AppColors.white)),
            ),
            const SizedBox(height: 14),

            Text(name,
                style: text20(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text('is requesting money from you',
                style: text13(color: AppColors.textSecondary)),
            const SizedBox(height: 18),

            Text('₹${req.amount ?? 0}',
                style: text26(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            if (req.reason != null && req.reason!.isNotEmpty)
              Text(req.reason!, style: text13(color: AppColors.textSecondary)),
            const SizedBox(height: 20),

            // Payment method info chip
            _PaymentMethodChip(req: req),
            const SizedBox(height: 16),

            // Details
            Container(
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _detailRow('Return date',
                      req.returnDate != null
                          ? '${req.returnDate!.day} ${_monthName(req.returnDate!.month)} ${req.returnDate!.year}'
                          : 'N/A',
                      valueColor: AppColors.button),
                  Divider(height: 1, color: AppColors.grey200),
                  _detailRow('Repayment',
                      _capitalise(req.repaymentMode ?? 'N/A'),
                      valueColor: AppColors.button),
                  Divider(height: 1, color: AppColors.grey200),
                  _detailRow('Receive via',
                      _capitalise(req.receiveMethod ?? 'N/A')),
                  if (req.receiveDetails?.upiId != null &&
                      req.receiveDetails!.upiId!.isNotEmpty) ...[
                    Divider(height: 1, color: AppColors.grey200),
                    _detailRow('UPI ID', req.receiveDetails!.upiId!),
                  ],
                  if (req.receiveDetails?.accountNumber != null &&
                      req.receiveDetails!.accountNumber!.isNotEmpty) ...[
                    Divider(height: 1, color: AppColors.grey200),
                    _detailRow('Account No.',
                        req.receiveDetails!.accountNumber!),
                    Divider(height: 1, color: AppColors.grey200),
                    _detailRow('IFSC',
                        req.receiveDetails?.ifscCode ?? 'N/A'),
                    Divider(height: 1, color: AppColors.grey200),
                    _detailRow('Account Holder',
                        req.receiveDetails?.accountHolderName ?? 'N/A'),
                  ],
                  if (req.responseNote != null &&
                      req.responseNote!.isNotEmpty) ...[
                    Divider(height: 1, color: AppColors.grey200),
                    _detailRow('Note', req.responseNote!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Obx(() {
              final isLoading =
                  _paymentController.paymentState.value ==
                      PaymentState.creatingOrder ||
                      _paymentController.paymentState.value ==
                          PaymentState.processing;

              return Row(
                children: [
                  Expanded(
                    child: AppOutlineButton(
                      color: AppColors.grey,
                      height: 44,
                      title: "Decline",
                      onTap: isLoading ? () {} : () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: isLoading
                        ? Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    )
                        : AppButton(
                      color: AppColors.success,
                      height: 44,
                      title: "Send ₹${req.amount ?? 0}",
                      onTap: () => _paymentController.initiatePayment(
                        req: req,
                        context: context,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: text13(color: AppColors.textSecondary)),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: text13(
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}

// ── Payment method indicator chip ────────────────────────────────────────────

class _PaymentMethodChip extends StatelessWidget {
  final Datum req;
  const _PaymentMethodChip({required this.req});

  @override
  Widget build(BuildContext context) {
    final method = req.receiveMethod?.toLowerCase() ?? 'auto';
    final upiId = req.receiveDetails?.upiId;
    final accountNo = req.receiveDetails?.accountNumber;

    IconData icon;
    String label;
    Color color;

    if (method == 'upi' && upiId != null && upiId.isNotEmpty) {
      icon = Icons.account_balance_wallet_outlined;
      label = 'Paying via UPI → $upiId';
      color = Colors.deepPurple;
    } else if (method == 'bank' && accountNo != null && accountNo.isNotEmpty) {
      icon = Icons.account_balance_outlined;
      label = 'Paying via Bank Transfer';
      color = Colors.blue;
    } else {
      icon = Icons.payments_outlined;
      label = 'Choose your payment method';
      color = Colors.teal;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: text12(fontWeight: FontWeight.w600, color: color)),
          ),
        ],
      ),
    );
  }
}