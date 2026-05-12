import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/view_model/after_login/notification_controller.dart';
import 'package:leudaar_app/views/custom_widget/custom_widget.dart';

import '../../res/app_colors.dart';
import '../../utils/textstyle.dart';

class NotificationPage extends StatelessWidget {
  NotificationPage({super.key});

  final ctrl = Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  // ── HEADER with badge + Mark all read ──────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 14,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          backButton(),
          const SizedBox(width: 10),
          Text(
            'Notifications',
            style: text18(fontWeight: FontWeight.bold, color: AppColors.white),
          ),

          // Unread badge
          Obx(
            () => ctrl.unreadCount > 0
                ? Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${ctrl.unreadCount}',
                      style: text11(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          const Spacer(),

          // Mark all read button
          Obx(
            () => ctrl.unreadCount > 0
                ? TextButton(
                    onPressed: ctrl.markAllRead,
                    child: Text(
                      'Mark all read',
                      style: text12(color: Colors.white70),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // ── GROUPED LIST ───────────────────────────────────────
  Widget _buildList() {
    return Obx(() {
      if (ctrl.notifications.isEmpty) return _buildEmpty();

      final unread = ctrl.notifications.where((n) => !n.isRead).toList();
      final read = ctrl.notifications.where((n) => n.isRead).toList();

      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          if (unread.isNotEmpty) ...[
            _sectionLabel('New'),
            ...unread.map(_buildTile),
          ],
          if (read.isNotEmpty) ...[
            _sectionLabel('Earlier'),
            ...read.map(_buildTile),
          ],
        ],
      );
    });
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 4),
    child: Text(
      text,
      style: text12(color: AppColors.grey, fontWeight: FontWeight.w600),
    ),
  );

  // ── SWIPEABLE TILE ─────────────────────────────────────
  Widget _buildTile(NotificationModel item) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => ctrl.dismiss(item.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
      child: GestureDetector(
        onTap: () => ctrl.markAsRead(item.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: item.isRead ? AppColors.white : const Color(0xFFEFFAF3),
            borderRadius: BorderRadius.circular(14),
            border: item.isRead
                ? null
                : Border.all(color: AppColors.success.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              _iconAvatar(item),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: text14(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          item.timeAgo,
                          style: text11(color: AppColors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(item.desc, style: text12(color: AppColors.grey600)),
                  ],
                ),
              ),
              if (!item.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(left: 6),
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── ICON per category ──────────────────────────────────
  Widget _iconAvatar(NotificationModel item) {
    final colors = {
      NotifCategory.payment: (const Color(0xFF22C55E), const Color(0xFFDCFCE7)),
      NotifCategory.message: (const Color(0xFF3B82F6), const Color(0xFFDBEAFE)),
      NotifCategory.alert: (const Color(0xFFEF4444), const Color(0xFFFEE2E2)),
    };
    final (iconColor, bgColor) = colors[item.category]!;
    return CircleAvatar(
      radius: 22,
      backgroundColor: bgColor,
      child: Icon(item.icon, color: iconColor, size: 20),
    );
  }

  // ── EMPTY STATE ────────────────────────────────────────
  Widget _buildEmpty() => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.notifications_off_outlined, size: 56, color: Colors.grey),
        SizedBox(height: 12),
        Text('No notifications', style: TextStyle(color: Colors.grey)),
      ],
    ),
  );
}
