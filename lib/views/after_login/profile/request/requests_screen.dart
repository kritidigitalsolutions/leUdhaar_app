import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/routes/app_routes.dart';
import 'package:leudaar_app/utils/custom_button.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/views/custom_widget/custom_widget.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  final List<Map<String, dynamic>> _requests = const [
    {
      'name': 'Amit Bhai',
      'initials': 'AB',
      'description': 'Medical emergency · 30 May',
      'amount': '₹2,000',
      'time': '2:30p',
    },
    {
      'name': 'Amit Bhai',
      'initials': 'AB',
      'description': 'Medical emergency · 30 May',
      'amount': '₹2,000',
      'time': '1:40p',
    },
    {
      'name': 'Amit Bhai',
      'initials': 'AB',
      'description': 'Medical emergency · 30 May',
      'amount': '₹2,000',
      'time': '12:30p',
    },
    {
      'name': 'Amit Bhai',
      'initials': 'AB',
      'description': 'Medical emergency · 30 May',
      'amount': '₹2,000',
      'time': '2:30p',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Requests',
                          style: text18(
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        Text(
                          'People asking you for money',
                          style: text12(color: AppColors.white54),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Warning banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.yellow.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFE0A3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '3 pending requests need your response',
                      style: text13(
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Requests list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _requests.length,
              itemBuilder: (_, i) => _requestCard(_requests[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _requestCard(Map<String, dynamic> req) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary,
                child: Text(
                  req['initials'],
                  style: text13(
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      req['name'],
                      style: text14(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      req['description'],
                      style: text12(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    req['time'],
                    style: text11(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    req['amount'],
                    style: text15(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppOutlineButton(
                  color: AppColors.grey,
                  height: 38,
                  title: "View Request",
                  onTap: () {
                    Get.toNamed(AppRoutes.acceptRequest);
                  },
                ),
              ),

              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  color: AppColors.error,
                  height: 38,
                  title: "Decline",
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
