import 'package:flutter/material.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/views/custom_widget/custom_widget.dart';

class MyWalletScreen extends StatefulWidget {
  const MyWalletScreen({super.key});

  @override
  State<MyWalletScreen> createState() => _MyWalletScreenState();
}

class _MyWalletScreenState extends State<MyWalletScreen> {
  String _selectedPeriod = 'This Week';
  final List<String> _periods = ['This Week', 'This Month', 'This Year'];

  final List<Map<String, dynamic>> _transactions = [
    {
      'title': 'Received from Rahul V.',
      'subtitle': '08 May · Udhaar',
      'amount': '+ ₹500',
      'isCredit': true,
    },
    {
      'title': 'Auto debit · Amit Bhai',
      'subtitle': '07 May · Repayment',
      'amount': '- ₹500',
      'isCredit': false,
    },
    {
      'title': 'Received from Rahul V.',
      'subtitle': '08 May · Udhaar',
      'amount': '+ ₹500',
      'isCredit': true,
    },
    {
      'title': 'Auto debit · Amit Bhai',
      'subtitle': '07 May · Repayment',
      'amount': '- ₹500',
      'isCredit': false,
    },
    {
      'title': 'Received from Rahul V.',
      'subtitle': '08 May · Udhaar',
      'amount': '+ ₹500',
      'isCredit': true,
    },
    {
      'title': 'Auto debit · Amit Bhai',
      'subtitle': '07 May · Repayment',
      'amount': '- ₹500',
      'isCredit': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 10,
              left: 16,
              right: 16,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    backButton(),
                    const SizedBox(width: 12),
                    Text(
                      'My wallet',
                      style: text18(
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available balance',
                      style: text13(color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₹2,350',
                      style: text30(
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Period filter + In/Out summary
                Column(
                  children: [
                    // Period chips
                    Row(children: _periods.map((p) => _periodChip(p)).toList()),
                    const SizedBox(height: 12),
                    // In / Out row
                    Row(
                      children: [
                        Expanded(
                          child: _walletSummaryCard(
                            title: 'Money In',
                            amount: '₹4,650',
                            icon: Icons.arrow_downward_rounded,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _walletSummaryCard(
                            title: 'Money Out',
                            amount: '₹1,000',
                            icon: Icons.arrow_upward_rounded,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Header

          // Balance card
          const SizedBox(height: 16),

          // All transactions label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'All transactions',
              style: text14(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Transactions list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _transactions.length,
              itemBuilder: (_, i) => _transactionTile(_transactions[i]),
            ),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.blue : AppColors.white30,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: text12(fontWeight: FontWeight.w500, color: AppColors.white),
        ),
      ),
    );
  }

  Widget _walletSummaryCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top colored section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: text13(fontWeight: FontWeight.w600, color: color),
                ),
              ],
            ),
          ),

          // Bottom white section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  amount,
                  style: text18(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Icon(Icons.trending_up_rounded, color: color, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionTile(Map<String, dynamic> tx) {
    final isCredit = tx['isCredit'] as bool;
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
          // Arrow icon
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: isCredit
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFEBEB),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isCredit ? AppColors.success : AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx['title'],
                  style: text14(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tx['subtitle'],
                  style: text12(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            tx['amount'],
            style: text14(
              fontWeight: FontWeight.bold,
              color: isCredit ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
