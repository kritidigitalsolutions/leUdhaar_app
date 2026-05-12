import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  @override
  Widget build(BuildContext context) {
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

          Expanded(child: _buildRequestView()),
        ],
      ),
    );
  }

  // ─── Request View ───────────────────────────────────────────────────────────
  Widget _buildRequestView() {
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
                'RV',
                style: text24(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Name
            Text(
              'Rahul Verma',
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
              '₹2,000',
              style: text26(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Medical emergency',
              style: text13(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),

            // Details rows
            Container(
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _detailRow(
                    'Return date',
                    '30 May 2026',
                    valueColor: AppColors.button,
                  ),
                  Divider(height: 1, color: AppColors.grey200),
                  _detailRow(
                    'Repayment',
                    'Auto Debit',
                    valueColor: AppColors.button,
                  ),
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
                    onTap: () {},
                  ),
                ),

                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    color: AppColors.success,
                    height: 40,
                    title: "Approve",
                    onTap: () {
                      Get.toNamed(AppRoutes.confirmedRequest);
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

  // ─── Approved View ──────────────────────────────────────────────────────────

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: text13(color: AppColors.textSecondary)),
          Text(
            value,
            style: text13(
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
