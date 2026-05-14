import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/utils/custom_button.dart';
import 'package:leudaar_app/utils/custom_textfields.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/view_model/after_login/leUdhaar_controller/leudhaar_controller.dart';
import 'package:leudaar_app/views/custom_widget/custom_widget.dart';

class RequestMoneyScreen extends StatefulWidget {
  const RequestMoneyScreen({super.key});

  @override
  State<RequestMoneyScreen> createState() => _RequestMoneyScreenState();
}

class _RequestMoneyScreenState extends State<RequestMoneyScreen> {
  final RequestMoneyController ctr = Get.put(RequestMoneyController());

  @override
  Widget build(BuildContext context) {
    final person = ctr.person;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header (unchanged)
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
                      'Request money',
                      style: text18(
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      'From ${person['name']}',
                      style: text12(color: AppColors.white54),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Person Card (unchanged)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.grey200),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            person['initials'] ?? 'RV',
                            style: text16(
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                person['name'] ?? 'Rahul Verma',
                                style: text16(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "On Le'Udhaar · Verified",
                                style: text13(
                                  color: const Color(0xFF27AE60),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Amount
                  _label('Amount (₹)'),
                  NumberTextField(
                    controller: ctr.amountController,
                    hintText: '0',
                  ),
                  const SizedBox(height: 20),

                  // Reason
                  _label('Reason for request'),
                  AppTextField(
                    controller: ctr.reasonController,
                    hintText: 'Enter reason',
                  ),
                  const SizedBox(height: 20),

                  // Return By
                  _label('I will return by'),
                  GestureDetector(
                    onTap: () => ctr.pickDate(context),
                    child: AbsorbPointer(
                      child: AppTextField(
                        controller: ctr.returnByController,
                        hintText: 'Select date',
                        suffixIcon: const Icon(Icons.calendar_today, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Repayment Mode
                  _label('Repayment Mode'),
                  const SizedBox(height: 12),
                  ...ctr.repaymentModes.map(
                    (mode) => _repaymentOptionCard(mode),
                  ),

                  const SizedBox(height: 24),

                  // Payment Method
                  _label('How will you get money?'),
                  const SizedBox(height: 12),

                  // Payment method chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ctr.paymentMethods.map((method) {
                        return Obx(() {
                          final bool isSelected =
                              ctr.selectedPaymentMethod.value == method['type'];
                          return GestureDetector(
                            onTap: () => ctr.selectedPaymentMethod.value =
                                method['type'].toString(),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.button
                                    : AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.button
                                      : AppColors.grey200,
                                  width: isSelected ? 1.8 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    method['icon'] as IconData,
                                    size: 18,
                                    color: isSelected
                                        ? AppColors.white
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    method['title'].toString(),
                                    style: text13(
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? AppColors.white
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Fields with Obx
                  Obx(() => _buildPaymentFields()),

                  const SizedBox(height: 30),

                  // Send Request Button
                  SafeArea(
                    child: Obx(
                      () => AppButton(
                        title: ctr.isLoading.value
                            ? 'Sending...'
                            : 'Send Request',
                        isLoading: ctr
                            .isLoading
                            .value, // if your button supports loading
                        onTap: ctr.isLoading.value
                            ? null
                            : () => ctr.sendRequest(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Payment Fields (unchanged logic)
  Widget _buildPaymentFields() {
    if (ctr.selectedPaymentMethod.value == 'upi') {
      return Column(
        key: const ValueKey('UPI'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Your UPI ID'),
          AppTextField(
            controller: ctr.upiController,
            hintText: 'e.g. name@upi',
            suffixIcon: const Icon(
              Icons.account_balance_wallet_outlined,
              size: 20,
            ),
          ),
        ],
      );
    }

    if (ctr.selectedPaymentMethod.value == 'bankTransfer') {
      return Column(
        key: const ValueKey('Bank'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Account Holder Name'),
          AppTextField(
            controller: ctr.accountHolderController,
            hintText: 'Enter full name',
          ),
          const SizedBox(height: 14),
          _label('Account Number'),
          NumberTextField(
            controller: ctr.accountNumberController,
            hintText: 'Enter account number',
          ),
          const SizedBox(height: 14),
          _label('IFSC Code'),
          AppTextField(
            controller: ctr.ifscController,
            hintText: 'e.g. SBIN0001234',
            suffixIcon: const Icon(Icons.account_balance_outlined, size: 20),
          ),
        ],
      );
    }

    // Cash / Other
    return Container(
      key: ValueKey(ctr.selectedPaymentMethod.value),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              ctr.selectedPaymentMethod.value == 'Cash'
                  ? 'You will collect cash in person from the sender.'
                  : 'You will coordinate the payment details separately.',
              style: text13(color: AppColors.primary).copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: text14(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _repaymentOptionCard(Map<String, dynamic> mode) {
    return Obx(() {
      final bool isSelected = ctr.selectedRepaymentMode.value == mode['type'];

      return GestureDetector(
        onTap: () => ctr.selectedRepaymentMode.value = mode['type'],
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.button.withOpacity(0.08)
                : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.button : AppColors.grey200,
              width: isSelected ? 1.8 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.button : AppColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  mode['icon'],
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode['title'],
                      style: text16(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      mode['subtitle'],
                      style: text13(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mode['desc'],
                      style: text12(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.button,
                  size: 26,
                ),
            ],
          ),
        ),
      );
    });
  }
}
