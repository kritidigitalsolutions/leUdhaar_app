import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/routes/app_routes.dart';
import 'package:leudaar_app/utils/custom_button.dart';
import 'package:leudaar_app/utils/custom_textfields.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/views/custom_widget/custom_widget.dart';

class RequestMoneyScreen extends StatefulWidget {
  const RequestMoneyScreen({super.key});

  @override
  State<RequestMoneyScreen> createState() => _RequestMoneyScreenState();
}

class _RequestMoneyScreenState extends State<RequestMoneyScreen> {
  final _amountController = TextEditingController(text: '2,000');
  final _reasonController = TextEditingController(text: 'Medical emergency');
  final _returnByController = TextEditingController(text: '30 May 2026');

  String _selectedRepaymentMode = 'AutoPay';

  final List<Map<String, dynamic>> _repaymentModes = [
    {
      'title': 'AutoPay',
      'subtitle': 'Auto debit on due date',
      'desc': 'Automatic deduction + reminders & calling support',
      'icon': Icons.autorenew_rounded,
    },
    {
      'title': 'Micro Debit',
      'subtitle': 'Daily micro-debits',
      'desc': 'Daily small debits + reminders & support',
      'icon': Icons.calendar_today_rounded,
    },
    {
      'title': 'Smart Protect',
      'subtitle': 'Autodebit + Failsafe',
      'desc': 'Autodebit + microdebit backup + recovery workflow',
      'icon': Icons.security_rounded,
    },
    {
      'title': 'Manual Support',
      'subtitle': 'Manual repayment',
      'desc': 'Manual payment with reminders & calling assistance',
      'icon': Icons.support_agent_rounded,
    },
  ];

  // Person data
  Map<String, dynamic> get _person {
    final args = Get.arguments;
    if (args is Map<String, dynamic>) return args;
    return {
      'initials': 'RV',
      'name': 'Rahul Verma',
      'subtitle': 'On Le\'Udhaar · Verified',
    };
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2026, 5, 30),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.button),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _returnByController.text =
            '${picked.day} ${_monthName(picked.month)} ${picked.year}';
      });
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

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    _returnByController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final person = _person;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
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
                  // Person Card
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
                  NumberTextField(controller: _amountController, hintText: "0"),
                  const SizedBox(height: 20),

                  // Reason
                  _label('Reason for request'),
                  AppTextField(
                    controller: _reasonController,
                    hintText: 'Enter reason',
                  ),
                  const SizedBox(height: 20),

                  // Return By
                  _label('I will return by'),
                  GestureDetector(
                    onTap: _pickDate,
                    child: AbsorbPointer(
                      child: AppTextField(
                        controller: _returnByController,
                        hintText: 'Select date',
                        suffixIcon: const Icon(Icons.calendar_today, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Repayment Mode
                  _label('Repayment Mode'),
                  const SizedBox(height: 12),
                  ..._repaymentModes.map((mode) => _repaymentOptionCard(mode)),

                  const SizedBox(height: 32),

                  // Send Request Button
                  AppButton(
                    title: "Send Request",
                    onTap: () => Get.toNamed(AppRoutes.requestSendedScreen),
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

  // Repayment Mode Card
  Widget _repaymentOptionCard(Map<String, dynamic> mode) {
    final bool isSelected = _selectedRepaymentMode == mode['title'];

    return GestureDetector(
      onTap: () {
        setState(() => _selectedRepaymentMode = mode['title']);
      },
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
  }
}
