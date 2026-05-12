import 'package:flutter/material.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/views/custom_widget/custom_widget.dart';

class MicroDebitRecoveryScreen extends StatelessWidget {
  const MicroDebitRecoveryScreen({super.key});

  final List<Map<String, dynamic>> _log = const [
    {'day': 'Day 12 · Today', 'date': '08 May 2026', 'amount': '- ₹10'},
    {'day': 'Day 11 · Yesterday', 'date': '07 May 2026', 'amount': '- ₹10'},
    {'day': 'Day 12 · Today', 'date': '08 May 2026', 'amount': '- ₹10'},
    {'day': 'Day 11 · Yesterday', 'date': '07 May 2026', 'amount': '- ₹10'},
    {'day': 'Day 10 · Today', 'date': '06 May 2026', 'amount': '- ₹10'},
  ];

  @override
  Widget build(BuildContext context) {
    const progress = 0.12;
    const progressPercent = '12%';
    const currentDay = 12;
    const totalDays = 30;

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
                      'Micro debit recovery',
                      style: text18(
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      'Daily small deductions',
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
                          'Total debt',
                          '₹4,650',
                          const Color(0xFFE8F5E9),
                          const Color(0xFF27AE60),
                          const Color(0xFF27AE60),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _statCard(
                          'Recovered',
                          '₹120',
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
                          'Remaining',
                          '₹880',
                          const Color(0xFFFFF8E1),
                          const Color(0xFFF59F00),
                          const Color(0xFFF59F00),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _statCard(
                          'Day',
                          '$currentDay/$totalDays',
                          const Color(0xFFFFEBEB),
                          AppColors.error,
                          AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Progress card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.grey200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recovery progress',
                              style: text13(color: AppColors.textSecondary),
                            ),
                            Text(
                              progressPercent,
                              style: text13(
                                fontWeight: FontWeight.bold,
                                color: AppColors.button,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: AppColors.grey200,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹10 deducted daily · 1% of ₹1,000',
                          style: text11(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Daily deduction log',
                    style: text15(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Log list
                  ...(_log.map((entry) => _logTile(entry))),
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

  Widget _logTile(Map<String, dynamic> entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: const BoxDecoration(
              color: Color(0xFF27AE60),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['day'],
                  style: text14(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry['date'],
                  style: text12(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            entry['amount'],
            style: text14(fontWeight: FontWeight.bold, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}
