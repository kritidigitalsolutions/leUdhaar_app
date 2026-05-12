import 'package:flutter/material.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/views/custom_widget/custom_widget.dart';

class AutoDebitRecoveryScreen extends StatefulWidget {
  const AutoDebitRecoveryScreen({super.key});

  @override
  State<AutoDebitRecoveryScreen> createState() =>
      _AutoDebitRecoveryScreenState();
}

class _AutoDebitRecoveryScreenState extends State<AutoDebitRecoveryScreen> {
  String _selectedPeriod = 'This Week';
  final List<String> _periods = ['This Week', 'This Month', 'This Year'];

  final List<Map<String, dynamic>> _debits = [
    {
      'initials': 'AB',
      'name': 'Amit Bhai',
      'subtitle': 'Auto pull on 15 May',
      'amount': '₹500',
      'done': false,
    },
    {
      'initials': 'RV',
      'name': 'Rahul Verma',
      'subtitle': 'Pulled on 5 May · Done',
      'amount': '₹500',
      'done': true,
    },
    {
      'initials': 'AB',
      'name': 'Amit Bhai',
      'subtitle': 'Auto pull on 15 May',
      'amount': '₹500',
      'done': false,
    },
    {
      'initials': 'RV',
      'name': 'Rahul Verma',
      'subtitle': 'Pulled on 5 May · Done',
      'amount': '₹500',
      'done': true,
    },
  ];

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
                      'Auto debit recovery',
                      style: text18(
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      'Scheduled repayments',
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
                  // Stats grid
                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          'Scheduled',
                          '₹4,650',
                          const Color(0xFFE8F5E9),
                          const Color(0xFF27AE60),
                          const Color(0xFF27AE60),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _statCard(
                          'Completed',
                          '₹2,000',
                          AppColors.white,
                          AppColors.textPrimary,
                          AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          'Upcoming',
                          '₹1,650',
                          const Color(0xFFFFF8E1),
                          const Color(0xFFF59F00),
                          const Color(0xFFF59F00),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _statCard(
                          'Failed',
                          '₹0',
                          const Color(0xFFFFEBEB),
                          AppColors.error,
                          AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Upcoming debits',
                    style: text15(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Period chips
                  Row(children: _periods.map((p) => _periodChip(p)).toList()),
                  const SizedBox(height: 12),

                  // Debit list
                  ...(_debits.map((d) => _debitTile(d))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    String label,
    String value,
    Color bg,
    Color valueColor,
    Color labelColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: text12(color: labelColor)),
          const SizedBox(height: 4),
          Text(
            value,
            style: text18(fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }

  Widget _periodChip(String label) {
    final selected = _selectedPeriod == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.button : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.button : AppColors.grey300,
          ),
        ),
        child: Text(
          label,
          style: text12(
            fontWeight: FontWeight.w500,
            color: selected ? AppColors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _debitTile(Map<String, dynamic> d) {
    final done = d['done'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: done ? const Color(0xFFF0FBF4) : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: done ? const Color(0xFFB7E4C7) : AppColors.grey200,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: done ? const Color(0xFF27AE60) : AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              done ? Icons.check_circle_rounded : Icons.bolt_rounded,
              color: AppColors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d['name'],
                  style: text14(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  d['subtitle'],
                  style: text12(
                    color: done
                        ? const Color(0xFF27AE60)
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            d['amount'],
            style: text15(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
