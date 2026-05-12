import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/utils/custom_button.dart';
import 'package:leudaar_app/utils/custom_textfields.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/view_model/after_login/leBalance_controller/leBalance_controller.dart';
import 'package:leudaar_app/views/custom_widget/custom_appbar.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────

class CreditDetailsScreen extends StatelessWidget {
  CreditDetailsScreen({super.key});

  final CreditDetailsController controller = Get.put(CreditDetailsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: LeBalanceAppBar(
        title: 'Credit details',
        subtitle: controller.shopName,
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── What did you buy? ────────────────────────────────
              _Label('What did you buy?'),
              const SizedBox(height: 8),
              AppTextField(
                controller: controller.whatBoughtController,
                hintText: 'Groceries, oil, atta',
                radius: 12,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),

              const SizedBox(height: 20),

              // ── Amount ───────────────────────────────────────────
              _Label('Amount (₹)'),
              const SizedBox(height: 8),
              NumberTextField(
                controller: controller.amountController,
                hintText: '₹0',
                radius: 12,
              ),

              const SizedBox(height: 20),

              // ── Date Taken + Return By ────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Label('Date taken'),
                        const SizedBox(height: 8),
                        Obx(
                          () => _DateField(
                            value: controller.dateTaken.value,
                            onTap: () => controller.pickDateTaken(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Label('Return by'),
                        const SizedBox(height: 8),
                        Obx(
                          () => _DateField(
                            value: controller.returnBy.value,
                            onTap: () => controller.pickReturnBy(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Note ─────────────────────────────────────────────
              _Label('Note'),
              const SizedBox(height: 8),
              AppTextField(
                controller: controller.noteController,
                hintText: 'Add a note...',
                radius: 12,
                maxline: 4,
              ),

              const SizedBox(height: 36),

              // ── Next Button ───────────────────────────────────────
              Obx(
                () => AppButton(
                  radius: 12,
                  title: "Next",
                  isLoading: controller.isLoading.value,
                  onTap: controller.submit,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: text13(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    );
  }
}

class _DateField extends StatelessWidget {
  final String value;
  final VoidCallback onTap;

  const _DateField({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: text14(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
