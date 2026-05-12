import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/routes/app_routes.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/views/custom_widget/custom_widget.dart';

class AgreementsScreen extends StatefulWidget {
  const AgreementsScreen({super.key});

  @override
  State<AgreementsScreen> createState() => _AgreementsScreenState();
}

class _AgreementsScreenState extends State<AgreementsScreen> {
  int _selectedFilter = 0; // 0=All, 1=Active, 2=Overdue

  final List<Map<String, dynamic>> _allAgreements = [
    {
      'initials': 'AB',
      'name': 'Amit Bhai',
      'subtitle': 'You owe · Auto debit',
      'amount': '₹500',
      'status': 'Active',
      'due': 'Due 15 May 2026',
      'action': 'Chat',
      'isOwed': true,
    },
    {
      'initials': 'PD',
      'name': 'Priya Didi',
      'subtitle': 'She owes · Manual',
      'amount': '₹500',
      'status': 'Active',
      'due': 'Due 10 May 2026',
      'action': 'Remind',
      'isOwed': false,
    },
    {
      'initials': 'AB',
      'name': 'Amit Bhai',
      'subtitle': 'You owe · Auto debit',
      'amount': '₹500',
      'status': 'Active',
      'due': 'Due 15 May 2026',
      'action': 'Chat',
      'isOwed': true,
    },
    {
      'initials': 'PD',
      'name': 'Priya Didi',
      'subtitle': 'She owes · Manual',
      'amount': '₹500',
      'status': 'Active',
      'due': 'Due 10 May 2026',
      'action': 'Remind',
      'isOwed': false,
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_selectedFilter == 1) {
      return _allAgreements.where((a) => a['status'] == 'Active').toList();
    }
    if (_selectedFilter == 2) {
      return _allAgreements.where((a) => a['status'] == 'Overdue').toList();
    }
    return _allAgreements;
  }

  @override
  Widget build(BuildContext context) {
    final counts = [
      _allAgreements.length,
      _allAgreements.where((a) => a['status'] == 'Active').length,
      _allAgreements.where((a) => a['status'] == 'Overdue').length,
    ];

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
              bottom: 20,
              left: 16,
              right: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    backButton(),
                    const SizedBox(width: 12),
                    Text(
                      'Agreements',
                      style: text18(
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Filter chips
                Row(
                  children: [
                    _filterChip('All', 0, counts[0]),
                    const SizedBox(width: 10),
                    _filterChip('Active', 1, counts[1]),
                    const SizedBox(width: 10),
                    _filterChip('Overdue', 2, counts[2]),
                  ],
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filtered.length,
              itemBuilder: (_, i) => _agreementCard(_filtered[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, int index, int count) {
    final selected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.blue : Colors.white10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: text12(
                fontWeight: FontWeight.w500,
                color: selected ? AppColors.white : AppColors.white70,
              ),
            ),
            Text(
              '($count)',
              style: text12(
                fontWeight: FontWeight.bold,
                color: selected ? AppColors.white : AppColors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _agreementCard(Map<String, dynamic> ag) {
    final isActive = ag['status'] == 'Active';
    final statusColor = isActive ? const Color(0xFF27AE60) : AppColors.error;
    final isChat = ag['action'] == 'Chat';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    ag['initials'],
                    style: text14(
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ag['name'],
                        style: text15(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ag['subtitle'],
                        style: text12(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      ag['amount'],
                      style: text15(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        ag['status'],
                        style: text11(
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: AppColors.grey200),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    ag['due'],
                    style: text12(color: AppColors.textSecondary),
                  ),
                ),
                // Secondary action button
                SizedBox(
                  height: 36,
                  child: OutlinedButton(
                    onPressed: () {
                      if (isChat) {
                        Get.toNamed(AppRoutes.myChatPage);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.grey300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text(
                      ag['action'],
                      style: text13(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Pay button
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: Text(
                      'Pay',
                      style: text13(
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
