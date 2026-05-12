// lib/models/notification_model.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum NotifCategory { payment, message, alert }

class NotificationModel {
  final String id;
  final String title;
  final String desc;
  final DateTime timestamp;
  bool isRead;
  final NotifCategory category;

  NotificationModel({
    required this.id,
    required this.title,
    required this.desc,
    required this.timestamp,
    this.isRead = false,
    required this.category,
  });

  // Icon per category
  IconData get icon => switch (category) {
    NotifCategory.payment => Icons.currency_rupee_rounded,
    NotifCategory.message => Icons.chat_bubble_outline_rounded,

    NotifCategory.alert => Icons.notifications_outlined,
  };

  // Human-readable relative time
  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class NotificationController extends GetxController {
  final notifications = <NotificationModel>[].obs;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
  }

  void _loadNotifications() {
    final now = DateTime.now();
    notifications.assignAll([
      NotificationModel(
        id: '1',
        title: 'Payment Received',
        desc: 'You received ₹500 from Amit',
        timestamp: now.subtract(const Duration(minutes: 2)),
        category: NotifCategory.payment,
      ),
      NotificationModel(
        id: '2',
        title: 'New Message',
        desc: 'Support team replied to your query',
        timestamp: now.subtract(const Duration(minutes: 10)),
        isRead: true,
        category: NotifCategory.message,
      ),
    ]);
  }

  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index].isRead = true;
      notifications.refresh();
    }
  }

  void markAllRead() {
    for (var n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
  }

  void dismiss(String id) {
    notifications.removeWhere((n) => n.id == id);
  }
}
