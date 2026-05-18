import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/data/api_response.dart';
import 'package:leudaar_app/models/response_model/profile_models/chat_list_res_model.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/routes/app_routes.dart';
import 'package:leudaar_app/utils/service/socket_service.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/view_model/after_login/leUdhaar_controller/chat_controller.dart';
import 'package:leudaar_app/views/custom_widget/custom_widget.dart';

class MyChatListScreen extends StatelessWidget {
  const MyChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatListController());

    // Load data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getChatList(); // Changed method name for clarity
    });

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(color: AppColors.primary),
            child: Column(
              children: [
                const SizedBox(height: 50),
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
                const SizedBox(height: 15),
                // Row(
                //   children: [
                //     _buildTab("All", 6, isSelected: true),
                //     const SizedBox(width: 10),
                //     _buildTab("Unread", 2),
                //     const SizedBox(width: 10),
                //     _buildTab("Active deals", 0),
                //   ],
                // ),
                // const SizedBox(height: 15),
              ],
            ),
          ),

          // Real Chat List
          Expanded(
            child: Obx(() {
              final apiResponse = controller.chatListRes.value;

              if (apiResponse.status == Status.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (apiResponse.status == Status.error) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${apiResponse.message}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.getChatList,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final chats = apiResponse.data?.data ?? [];

              if (chats.isEmpty) {
                return const Center(child: Text('No chats found'));
              }

              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  return _chatItem(chat);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _chatItem(ChatListData chat) {
    final socketService = Get.find<SocketService>();
    final other = chat.otherParticipant;
    final lastMsg = chat.lastMessage;

    final time = chat.lastMessageAt != null
        ? _formatTime(chat.lastMessageAt!)
        : '';

    return GestureDetector(
      onTap: () {
        final Map<String, dynamic> otherUser = {
          "id": other?.id ?? '',
          "name": other?.fullName ?? '',
          "phone": other?.phone ?? '',
          "image": other?.profileImage ?? '',
        };
        Get.toNamed(AppRoutes.myChatPage, arguments: otherUser);
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
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primary,
                backgroundImage: (other?.profileImage?.isNotEmpty == true)
                    ? NetworkImage(other!.profileImage!)
                    : null,
                child: (other?.profileImage?.isEmpty ?? true)
                    ? Text(
                        _getInitials(other?.fullName ?? ''),
                        style: text16(
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Obx(() {
                  final online =
                      socketService.onlineUsers[other?.id ?? ''] ?? false;

                  return CircleAvatar(
                    radius: 4,
                    backgroundColor: online
                        ? AppColors.success
                        : AppColors.transparent,
                  );
                }),
              ),
            ],
          ),
          title: Text(
            other?.fullName ?? 'Unknown',
            style: text16(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chat.lastMessageText?.isNotEmpty == true
                    ? chat.lastMessageText!
                    : (lastMsg?.text ?? ''),
                style: text14(color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // You can show amount/status if available in your model
              if (chat.lastMessageText?.contains('₹') == true ||
                  lastMsg?.text?.contains('₹') == true)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Active Deal",
                    style: text13(
                      fontWeight: FontWeight.w500,
                      color: AppColors.error,
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
              Obx(() {
                print("CHAT UI ID => ${chat.id}");
                print("ALL COUNTS => ${socketService.unreadCounts}");

                final count =
                    socketService.unreadCounts[chat.id.toString()] ?? 0;

                return count > 0
                    ? CircleAvatar(
                        radius: 10,
                        child: Text(
                          '$count',
                          style: const TextStyle(fontSize: 12),
                        ),
                      )
                    : const SizedBox();
              }),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    if (dateTime.day == now.day &&
        dateTime.month == now.month &&
        dateTime.year == now.year) {
      return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } else {
      return "Yesterday";
    }
  }
}
