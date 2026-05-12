import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/routes/app_routes.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/views/custom_widget/custom_widget.dart';

class LeUdhaarScreen extends StatelessWidget {
  const LeUdhaarScreen({super.key});

  final List<Map<String, dynamic>> _agreements = const [
    {
      'initials': 'AB',
      'name': 'Amit Bhai',
      'due': 'Due 15 May',
      'amount': '₹500',
      'overdue': true,
    },
    {
      'initials': 'PD',
      'name': 'Priya Didi',
      'due': 'Due 10 May',
      'amount': '₹650',
      'overdue': false,
    },
    {
      'initials': 'AB',
      'name': 'Amit Bhai',
      'due': 'Due 15 May',
      'amount': '₹500',
      'overdue': true,
    },
    {
      'initials': 'PD',
      'name': 'Priya Didi',
      'due': 'Due 10 May',
      'amount': '₹650',
      'overdue': false,
    },
    {
      'initials': 'AB',
      'name': 'Amit Bhai',
      'due': 'Due 15 May',
      'amount': '₹500',
      'overdue': true,
    },
    {
      'initials': 'PD',
      'name': 'Priya Didi',
      'due': 'Due 10 May',
      'amount': '₹650',
      'overdue': false,
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
                      "Le'Udhaar",
                      style: text18(
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      'Friends & family credit',
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
                  // Request money card
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.findPersonScreen),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.button,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: AppColors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Request money',
                                style: text16(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                              Text(
                                'Ask a friend or family',
                                style: text12(color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Active agreements header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Active agreements',
                        style: text15(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.dashboard),
                        child: Text(
                          'View Dashboard',
                          style: text12(
                            fontWeight: FontWeight.w500,
                            color: AppColors.button,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Agreement list
                  ...(_agreements.map((a) => _agreementTile(a))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _agreementTile(Map<String, dynamic> ag) {
    final overdue = ag['overdue'] as bool;
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
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary,
            child: Text(
              ag['initials'],
              style: text13(
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
                  style: text14(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(ag['due'], style: text12(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(
            ag['amount'],
            style: text14(
              fontWeight: FontWeight.bold,
              color: overdue ? AppColors.error : const Color(0xFF27AE60),
            ),
          ),
        ],
      ),
    );
  }
}
