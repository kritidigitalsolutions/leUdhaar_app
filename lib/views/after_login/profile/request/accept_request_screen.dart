import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/models/response_model/leudhaar_res/request_money_res_model.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/routes/app_routes.dart';
import 'package:leudaar_app/utils/custom_button.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/views/custom_widget/custom_widget.dart';

class AcceptRequestScreen extends StatefulWidget {
  const AcceptRequestScreen({super.key});

  @override
  State<AcceptRequestScreen> createState() => _AcceptRequestScreenState();
}

class _AcceptRequestScreenState extends State<AcceptRequestScreen> {
  // Datum passed from RequestsScreen via Get.toNamed(arguments: req)
  late final Datum req;

  @override
  void initState() {
    super.initState();
    req = Get.arguments as Datum;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _monthName(int month) {
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
              top: 50,
              bottom: 16,
              left: 16,
              right: 16,
            ),
            child: Row(
              children: [
                backButton(),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Money request',
                      style: text18(
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      'Someone needs your help',
                      style: text12(color: AppColors.white54),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(child: _buildRequestView(name, initials)),
        ],
      ),
    );
  }

  Widget _buildRequestView(String name, String initials) {
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
              child: Text(
                initials,
                style: text24(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Name
            Text(
              name,
              style: text20(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'is requesting money from you',
              style: text13(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),

            // Amount
            Text(
              '₹${req.amount ?? 0}',
              style: text26(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            if (req.reason != null && req.reason!.isNotEmpty)
              Text(req.reason!, style: text13(color: AppColors.textSecondary)),
            const SizedBox(height: 20),

            // Details
            Container(
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _detailRow(
                    'Return date',
                    req.returnDate != null
                        ? '${req.returnDate!.day} ${_monthName(req.returnDate!.month)} ${req.returnDate!.year}'
                        : 'N/A',
                    valueColor: AppColors.button,
                  ),
                  Divider(height: 1, color: AppColors.grey200),
                  _detailRow(
                    'Repayment',
                    _capitalise(req.repaymentMode ?? 'N/A'),
                    valueColor: AppColors.button,
                  ),
                  Divider(height: 1, color: AppColors.grey200),
                  _detailRow(
                    'Receive via',
                    _capitalise(req.receiveMethod ?? 'N/A'),
                  ),
                  if (req.receiveDetails?.upiId != null &&
                      req.receiveDetails!.upiId!.isNotEmpty) ...[
                    Divider(height: 1, color: AppColors.grey200),
                    _detailRow('UPI ID', req.receiveDetails!.upiId!),
                  ],
                  if (req.receiveDetails?.accountNumber != null &&
                      req.receiveDetails!.accountNumber!.isNotEmpty) ...[
                    Divider(height: 1, color: AppColors.grey200),
                    _detailRow(
                      'Account No.',
                      req.receiveDetails!.accountNumber!,
                    ),
                    Divider(height: 1, color: AppColors.grey200),
                    _detailRow('IFSC', req.receiveDetails?.ifscCode ?? 'N/A'),
                  ],
                  if (req.receiveDetails?.accountHolderName != null &&
                      req.receiveDetails!.accountHolderName!.isNotEmpty) ...[
                    Divider(height: 1, color: AppColors.grey200),
                    _detailRow(
                      'Account holder',
                      req.receiveDetails!.accountHolderName!,
                    ),
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
            Row(
              children: [
                Expanded(
                  child: AppOutlineButton(
                    color: AppColors.grey,
                    height: 40,
                    title: "Decline",
                    onTap: () {
                      // TODO: call decline API with req.id, then pop
                      Get.back();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    color: AppColors.success,
                    height: 40,
                    title: "Approve",
                    onTap: () {
                      // TODO: call approve API with req.id
                      Get.toNamed(AppRoutes.confirmedRequest, arguments: req);
                    },
                  ),
                ),
              ],
            ),
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
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: text13(
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
