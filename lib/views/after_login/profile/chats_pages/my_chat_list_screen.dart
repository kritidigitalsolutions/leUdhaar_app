import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/routes/app_routes.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/views/custom_widget/custom_widget.dart';

class MyChatListScreen extends StatelessWidget {
  const MyChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(color: AppColors.primary),
            child: Column(
              children: [
                SizedBox(height: 50),
                Row(
                  children: [
                    backButton(),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "My chats",
                          style: text20(
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                        Text(
                          "All conversations",
                          style: text15(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(AppRoutes.searchChat);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search,
                              color: AppColors.white70,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Search",
                              style: text15(color: AppColors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    _buildTab("All", 6, isSelected: true),
                    const SizedBox(width: 10),
                    _buildTab("Unread", 2),
                    const SizedBox(width: 10),
                    _buildTab("Active deals", 0),
                  ],
                ),
                SizedBox(height: 15),
              ],
            ),
          ),

          // Chat List
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _chatItem(
                  name: "Amit Bhai",
                  message: "15 ko auto debit ho...",
                  amount: "₹500 due 15 May",
                  amountColor: AppColors.error,
                  time: "10:32 AM",
                  unreadCount: 2,
                ),
                _chatItem(
                  name: "Priya Didi",
                  message: "Haan kar deti hoon kal tak...",
                  amount: "₹500 due 15 May",
                  amountColor: AppColors.success,
                  time: "Yesterday",
                  unreadCount: 2,
                ),
                _chatItem(
                  name: "Priya Didi",
                  message: "Haan kar deti hoon kal tak...",
                  amount: "₹500 due 15 May",
                  amountColor: AppColors.success,
                  time: "Yesterday",
                  unreadCount: 2,
                ),
                _chatItem(
                  name: "Priya Didi",
                  message: "Haan kar deti hoon kal tak...",
                  amount: "₹500 due 15 May",
                  amountColor: AppColors.success,
                  time: "Yesterday",
                  unreadCount: 2,
                ),
                _chatItem(
                  name: "Priya Didi",
                  message: "Haan kar deti hoon kal tak...",
                  amount: "₹500 due 15 May",
                  amountColor: AppColors.success,
                  time: "Yesterday",
                  unreadCount: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int count, {bool isSelected = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.button : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.button : AppColors.grey50,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            "$title ($count)",
            textAlign: TextAlign.center,
            style: text15(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? AppColors.white : AppColors.white70,
            ),
          ),
        ),
      ),
    );
  }

  Widget _chatItem({
    required String name,
    required String message,
    required String amount,
    required Color amountColor,
    required String time,
    required int unreadCount,
  }) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.myChatPage);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(bottom: BorderSide(color: AppColors.grey300)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          leading: CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primary,
            child: Text(
              "AB",
              style: text16(
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
          title: Text(name, style: text16(fontWeight: FontWeight.w600)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: text14(color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: amountColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  amount,
                  style: text13(
                    fontWeight: FontWeight.w500,
                    color: amountColor,
                  ),
                ),
              ),
            ],
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time, style: text12(color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              if (unreadCount > 0)
                CircleAvatar(
                  radius: 10,
                  backgroundColor: AppColors.button,
                  child: Text(
                    unreadCount.toString(),
                    style: text11(
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
