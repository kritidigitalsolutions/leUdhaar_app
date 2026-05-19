import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:leudaar_app/data/api_response.dart';
import 'package:leudaar_app/models/request_model/leUdhaar_request/leudhaarReq_modles.dart';
import 'package:leudaar_app/repo/leUdhaar_repo.dart';

import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/utils/custom_button.dart';
import 'package:leudaar_app/utils/custom_snackbar.dart';
import 'package:leudaar_app/utils/service/socket_service.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/view_model/after_login/leUdhaar_controller/chat_controller.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final controller = Get.put(ChatController());

  final data = Get.arguments as Map<String, dynamic>;

  // Add this in ChatDetailScreen class
  final ScrollController _scrollController = ScrollController();
  final socketService = Get.find<SocketService>();

  // Replace the ever listener with this:
  // 1. REPLACE initState() with this:
  @override
  void initState() {
    super.initState();

    ever(controller.messages, (_) {
      _scrollToBottom();
    });

    // Scroll after first history load too
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  // 2. REPLACE _scrollToBottom() with this:
  void _scrollToBottom() {
    // Wait for current frame to finish, then wait one more frame
    // so ListView has actually laid out the new item.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      // Use jumpTo for instant snap on first load,
      // animateTo for new messages
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  String _getLastSeenText(DateTime? lastSeen) {
    if (lastSeen == null) return "Offline";
    final diff = DateTime.now().difference(lastSeen);
    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2EFE9),

      // ── AppBar ─────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: AppColors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.primary,
          ),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    'AK',
                    style: text12(
                      fontWeight: FontWeight.w700,
                    ).copyWith(color: AppColors.white),
                  ),
                ),
                // Online dot
                Obx(
                  () => controller.isOtherUserOnline.value
                      ? Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.white,
                                width: 1.5,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data["name"] ?? '',
                  style: text14(
                    fontWeight: FontWeight.w600,
                  ).copyWith(color: AppColors.primary),
                ),
                Obx(
                  () => Text(
                    controller.isOtherTyping.value
                        ? 'typing…'
                        : controller.isOtherUserOnline.value
                        ? 'Online'
                        : _getLastSeenText(controller.otherUserLastSeen.value),
                    style: text11(fontWeight: FontWeight.w400).copyWith(
                      color: controller.isOtherUserOnline.value
                          ? AppColors.success
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.call_outlined,
              color: Color(0xFF4A4845),
              size: 20,
            ),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            color: AppColors.white,
            icon: const Icon(
              Icons.more_vert,
              color: Color(0xFF4A4845),
              size: 20,
            ),
            onSelected: (value) {
              if (value == 'delete') {
                _confirmClearAllChat(context, controller); // ← was Get.snackbar
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete_sweep_outlined,
                      size: 18,
                      color: Color(0xFFE53935),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Clear Chat',
                      style: text14(color: const Color(0xFFE53935)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0.5),
          child: Divider(height: 0.5, color: Color(0xFFE4E1DB)),
        ),
      ),

      // ── Body ───────────────────────────────────────────────────────────────
      body: Column(
        children: [
          // Messages list
          // ── Replace the Expanded messages block in build() ─────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoadingHistory.value &&
                  controller.messages.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }

              return NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollStartNotification &&
                      _scrollController.hasClients &&
                      _scrollController.position.pixels <=
                          _scrollController.position.minScrollExtent + 80) {
                    controller.loadMoreHistory();
                  }
                  return false;
                },
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: controller.refreshHistory,
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: false,
                    shrinkWrap: false,
                    key: const PageStorageKey('chat_messages'),
                    padding: const EdgeInsets.only(
                      left: 12,
                      right: 12,
                      top: 12,
                      // Extra bottom padding so last message
                      // is never hidden behind the input bar
                      bottom: 8,
                    ),
                    itemCount:
                        (controller.isLoadingMore.value ? 1 : 0) +
                        controller.messages.length,
                    itemBuilder: (_, index) {
                      if (controller.isLoadingMore.value && index == 0) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }

                      final msgIndex = controller.isLoadingMore.value
                          ? index - 1
                          : index;
                      final msg = controller.messages[msgIndex];
                      final showDate =
                          msgIndex == 0 ||
                          !_isSameDay(
                            controller.messages[msgIndex - 1].time,
                            msg.time,
                          );

                      return Column(
                        children: [
                          if (showDate) _DateSeparator(msg.time),
                          _buildMessage(context, msg),
                        ],
                      );
                    },
                  ),
                ),
              );
            }),
          ),
          // Typing indicator row (above input)
          Obx(
            () => controller.isOtherTyping.value
                ? _TypingIndicator(name: data['name'] ?? '')
                : const SizedBox.shrink(),
          ),

          // Input bar
          SafeArea(child: _ChatInputBar(controller: controller)),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildMessage(BuildContext context, ChatMessage msg) {
    if (msg.type == MessageType.udhaar) {
      return _UdhaarCardBubble(msg: msg, controller: controller);
    }
    if (msg.type == MessageType.status) {
      return _WaitingPill(text: msg.text ?? '');
    }

    return GestureDetector(
      onLongPress: () => _confirmDeleteMessage(context, controller, msg),
      child: Align(
        alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: msg.isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 2),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              constraints: BoxConstraints(maxWidth: Get.width * 0.72),
              decoration: BoxDecoration(
                color: msg.isMe ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
                  bottomRight: Radius.circular(msg.isMe ? 4 : 16),
                ),
                boxShadow: msg.isMe
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: _MessageContent(msg: msg),
            ),

            // Time + Status Row
            Padding(
              padding: const EdgeInsets.only(
                top: 2,
                bottom: 8,
                left: 4,
                right: 4,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('hh:mm a').format(msg.time),
                    style: text10(
                      fontWeight: FontWeight.w400,
                    ).copyWith(color: const Color(0xFF9E9A94)),
                  ),

                  if (msg.isMe) ...[
                    const SizedBox(width: 6),
                    _buildMessageStatus(msg),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageStatus(ChatMessage msg) {
    // Pending (sending)
    if (msg.isPending) {
      return const Icon(
        Icons.schedule_rounded,
        size: 14,
        color: Color(0xFFBEB9B2),
      );
    }

    final isOnline = controller.isOtherUserOnline.value;

    if (!isOnline) {
      // Single Tick - Grey (Sent but not delivered)
      return const Icon(Icons.check, size: 14, color: Color(0xFF9E9A94));
    } else {
      // Double Tick
      final color = (msg.status == 'read')
          ? const Color(0xFF3D9C6E) // Blue/Green when read
          : const Color(0xFF9E9A94); // Grey when delivered

      return Icon(Icons.done_all_rounded, size: 14, color: color);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DATE SEPARATOR
// ─────────────────────────────────────────────────────────────────────────────

class _DateSeparator extends StatelessWidget {
  final DateTime date;
  const _DateSeparator(this.date);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFE4E1DB),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            DateFormat('MMMM d, y').format(date),
            style: text11(
              fontWeight: FontWeight.w500,
            ).copyWith(color: const Color(0xFF7A7670)),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MESSAGE CONTENT
// ─────────────────────────────────────────────────────────────────────────────

class _MessageContent extends StatelessWidget {
  final ChatMessage msg;
  const _MessageContent({required this.msg});

  @override
  Widget build(BuildContext context) {
    switch (msg.type) {
      case MessageType.image:
        // Priority 1: Use server URL (for received & successfully sent images)
        if (msg.imageUrl != null && msg.imageUrl!.isNotEmpty) {
          print(msg.imageUrl!);
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              msg.imageUrl!,
              height: 200,
              width: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const SizedBox(
                  height: 200,
                  width: 200,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  width: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, color: Colors.red),
                );
              },
            ),
          );
        }

        // Priority 2: Use local path (for optimistic/sending images)
        if (msg.imagePath != null && msg.imagePath!.isNotEmpty) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              File(msg.imagePath!),
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            ),
          );
        }

        // Fallback
        return SizedBox(
          height: 200,
          width: 200,
          child: Center(
            child: Text(
              "Image unavailable",
              style: text13(
                color: msg.isMe ? AppColors.white : AppColors.textPrimary,
              ),
            ),
          ),
        );

      case MessageType.file:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.insert_drive_file_outlined, size: 24),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                msg.fileName ?? 'Unknown File',
                style: text13(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (msg.fileUrl != null && msg.fileUrl!.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.download, size: 18),
                onPressed: () {
                  // TODO: Implement download
                  Get.snackbar('Download', 'Downloading ${msg.fileName}...');
                },
              ),
          ],
        );

      case MessageType.text:
      default:
        return Text(
          msg.text ?? '',
          style: text14(
            color: msg.isMe ? AppColors.white : AppColors.textPrimary,
          ).copyWith(height: 1.4),
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UDHAAR CARD BUBBLE
// ─────────────────────────────────────────────────────────────────────────────

class _UdhaarCardBubble extends StatelessWidget {
  final ChatMessage msg;
  final ChatController controller;
  const _UdhaarCardBubble({required this.msg, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isUpi = msg.paymentMethod == PaymentMethod.upi;
    final isPending = msg.requestStatus == 'pending';

    // ── Repayment mode label ──
    final repaymentLabel = _repaymentLabel(msg.udhaarProtection);

    // ── Due date formatting ──
    String dueDateDisplay = msg.udhaarDueDate ?? '';
    if (dueDateDisplay.isNotEmpty) {
      final parsed = DateTime.tryParse(dueDateDisplay);
      if (parsed != null) {
        dueDateDisplay = DateFormat('d MMM yyyy').format(parsed);
      }
    }

    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(16),
        width: Get.width * 0.72,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
            bottomRight: Radius.circular(msg.isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Label ─────────────────────────────────────────────
            Row(
              children: [
                const Icon(
                  Icons.currency_rupee_rounded,
                  size: 13,
                  color: Color(0xFF9E9A94),
                ),
                const SizedBox(width: 4),
                Text(
                  msg.isMe
                      ? 'Udhaar requested'
                      : 'Udhaar request from ${msg.accountHolder ?? ''}',
                  style: text11(
                    fontWeight: FontWeight.w500,
                  ).copyWith(color: const Color(0xFF9E9A94)),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // ── Amount ────────────────────────────────────────────
            Text(
              '₹${NumberFormat('#,##,###').format(msg.udhaarAmount ?? 0)}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 10),

            // ── Due date ──────────────────────────────────────────
            if (dueDateDisplay.isNotEmpty)
              _UdhaarRow(
                icon: Icons.calendar_today_outlined,
                text: 'Due: $dueDateDisplay',
              ),
            const SizedBox(height: 4),

            // ── Repayment mode ────────────────────────────────────
            if (repaymentLabel.isNotEmpty)
              _UdhaarRow(icon: Icons.autorenew_rounded, text: repaymentLabel),
            const SizedBox(height: 4),

            // ── Payment method ────────────────────────────────────
            _UdhaarRow(
              icon: isUpi
                  ? Icons.account_balance_wallet_outlined
                  : Icons.account_balance_outlined,
              text: isUpi
                  ? 'UPI: ${msg.upiId ?? ''}'
                  : 'Bank: ${msg.accountNumber ?? ''} · ${msg.ifscCode ?? ''}',
            ),
            const SizedBox(height: 4),

            // ── Reason ────────────────────────────────────────────
            if (msg.text != null &&
                msg.text!.isNotEmpty &&
                msg.text != 'Udhaar request')
              _UdhaarRow(
                icon: Icons.chat_bubble_outline_rounded,
                text: msg.text!,
              ),

            const SizedBox(height: 12),

            // ── Divider ───────────────────────────────────────────
            const Divider(color: Color(0x14FFFFFF), height: 1),
            const SizedBox(height: 12),

            if (!msg.isMe && isPending) ...[
              Row(
                children: [
                  // ── Reject ──
                  Expanded(
                    child: Obx(() {
                      final isLoadingThis =
                          controller.rejectingRequestId.value == msg.requestId;
                      final anyLoading =
                          controller.acceptingRequestId.value.isNotEmpty ||
                          controller.rejectingRequestId.value.isNotEmpty;

                      return GestureDetector(
                        onTap: anyLoading
                            ? null
                            : () => controller.respondToRequest(
                                requestId: msg.requestId ?? '',
                                status: 'declined',
                                msg: msg,
                              ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0x26E53935),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0x40E53935)),
                          ),
                          child: isLoadingThis
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFFFF6B6B),
                                  ),
                                )
                              : Text(
                                  'Reject',
                                  style: text13(
                                    fontWeight: FontWeight.w600,
                                  ).copyWith(color: const Color(0xFFFF6B6B)),
                                ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(width: 8),

                  // ── Accept ──
                  Expanded(
                    child: Obx(() {
                      final isLoadingThis =
                          controller.acceptingRequestId.value == msg.requestId;
                      final anyLoading =
                          controller.acceptingRequestId.value.isNotEmpty ||
                          controller.rejectingRequestId.value.isNotEmpty;

                      return GestureDetector(
                        onTap: anyLoading
                            ? null
                            : () => controller.respondToRequest(
                                requestId: msg.requestId ?? '',
                                status: 'approved',
                                msg: msg,
                              ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0x303D9C6E),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0x4D3D9C6E)),
                          ),
                          child: isLoadingThis
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF3D9C6E),
                                  ),
                                )
                              : Text(
                                  'Accept',
                                  style: text13(
                                    fontWeight: FontWeight.w600,
                                  ).copyWith(color: const Color(0xFF3D9C6E)),
                                ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],

            // ── Status pill + time ────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatusPill(
                  status: msg.requestStatus ?? 'pending',
                  isMe: msg.isMe,
                ),
                Text(
                  DateFormat('hh:mm a').format(msg.time),
                  style: text10(
                    fontWeight: FontWeight.w400,
                  ).copyWith(color: const Color(0xFF7A7670)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _repaymentLabel(String? mode) {
    switch (mode) {
      case 'auto-debit':
        return 'AutoPay (auto-debit)';
      case 'micro-debit':
        return 'Micro debit (daily)';
      case 'smart-protect':
        return 'Smart protect';
      case 'manual':
        return 'Manual repayment';
      default:
        return mode ?? '';
    }
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  final bool isMe;
  const _StatusPill({required this.status, required this.isMe});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    String label;

    switch (status) {
      case 'approved':
        bg = const Color(0x303D9C6E);
        fg = const Color(0xFF3D9C6E);
        label = isMe ? 'Accepted' : 'You accepted';
        break;
      case 'declined':
        bg = const Color(0x26E53935);
        fg = const Color(0xFFFF6B6B);
        label = isMe ? 'Declined' : 'You declined';
        break;
      case 'pending':
      default:
        bg = const Color(0x26FAC775);
        fg = const Color(0xFFFAC775);
        label = isMe ? 'Pending acceptance' : 'Awaiting your response';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: text10(fontWeight: FontWeight.w600).copyWith(color: fg),
      ),
    );
  }
}

class _UdhaarRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _UdhaarRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 12, color: const Color(0xFFBEB9B2)),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: text11(
              fontWeight: FontWeight.w400,
            ).copyWith(color: const Color(0xFFBEB9B2), height: 1.4),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WAITING / STATUS PILL
// ─────────────────────────────────────────────────────────────────────────────

class _WaitingPill extends StatelessWidget {
  final String text;
  const _WaitingPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFEEEAE3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shield_outlined,
              size: 13,
              color: Color(0xFF3D9C6E),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: text11(
                  fontWeight: FontWeight.w500,
                ).copyWith(color: const Color(0xFF5A5651)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TYPING INDICATOR
// ─────────────────────────────────────────────────────────────────────────────

class _TypingIndicator extends StatefulWidget {
  final String name;
  const _TypingIndicator({required this.name});

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ac;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 12, bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return AnimatedBuilder(
              animation: _ac,
              builder: (_, _) {
                final phase = (_ac.value - i * 0.2).clamp(0.0, 1.0);
                final scale =
                    0.6 + 0.4 * (phase < 0.5 ? phase * 2 : (1 - phase) * 2);
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.5 + 0.5 * scale),
                    shape: BoxShape.circle,
                  ),
                  transform: Matrix4.identity()
                    ..translate(0.0, -3.0 * (scale - 0.6) / 0.4),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHAT INPUT BAR
// ─────────────────────────────────────────────────────────────────────────────

class _ChatInputBar extends StatelessWidget {
  final ChatController controller;
  const _ChatInputBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: Color(0xFFE4E1DB), width: 0.5)),
      ),
      child: Row(
        children: [
          // ── ₹ Udhaar button ──────────────────────────────────────
          GestureDetector(
            onTap: () => _showUdhaarSheet(context, controller),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '₹',
                style: text16(
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ).copyWith(height: 1),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // ── Text input ───────────────────────────────────────────
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F5F1),
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                controller: controller.messageController,
                onChanged: controller.onTypingChanged,
                onSubmitted: (_) => controller.sendText(),
                style: text14().copyWith(color: const Color(0xFF1A1A1A)),
                decoration: const InputDecoration(
                  hintText: 'Message…',
                  hintStyle: TextStyle(color: Color(0xFFBEB9B2), fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          const SizedBox(width: 6),

          // ── Attachment ───────────────────────────────────────────
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.attach_file_rounded,
              color: Color(0xFF9E9A94),
              size: 20,
            ),
            color: AppColors.white,
            onSelected: (value) {
              if (value == 'image') controller.sendImage();
              if (value == 'file') controller.sendFile();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'image', child: Text('Send Image')),
              PopupMenuItem(value: 'file', child: Text('Send File')),
            ],
          ),

          // ── Send button ──────────────────────────────────────────
          Obx(
            () => GestureDetector(
              onTap: controller.isSending.value ? null : controller.sendText,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: controller.isSending.value
                      ? AppColors.primary.withOpacity(0.5)
                      : AppColors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: controller.isSending.value
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: AppColors.white,
                        size: 16,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// UDHAAR BOTTOM SHEET  (2-step: loan details → payment method)
// ═════════════════════════════════════════════════════════════════════════════

void _showUdhaarSheet(BuildContext context, ChatController controller) {
  final amountCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final reasonCtr = TextEditingController();
  final upiCtrl = TextEditingController();
  final accNumberCtrl = TextEditingController();
  final ifscCtrl = TextEditingController();
  final holderCtrl = TextEditingController();

  final selectedRepaymentMode = 'auto-debit'.obs;
  final selectedPayment = Rxn<PaymentMethod>(PaymentMethod.upi);
  DateTime? pickedDate;

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF1A1A1A)),
        ),
        child: child!,
      ),
    );
    if (date != null) {
      pickedDate = date;
      dateCtrl.text = DateFormat('yyyy-MM-dd').format(date);
    }
  }

  RequestMoneyReqModel buildRequestModel() {
    String receiveMethodStr = '';

    if (selectedPayment.value == PaymentMethod.upi) {
      receiveMethodStr = 'upi';
    } else if (selectedPayment.value == PaymentMethod.bank) {
      receiveMethodStr = 'bankTransfer';
    }

    ReceiveDetails receiveDetails;

    if (selectedPayment.value == PaymentMethod.upi) {
      receiveDetails = ReceiveDetails(upiId: upiCtrl.text.trim());
    } else if (selectedPayment.value == PaymentMethod.bank) {
      receiveDetails = ReceiveDetails(
        accountHolderName: holderCtrl.text.trim(),
        accountNumber: accNumberCtrl.text.trim(),
        ifscCode: ifscCtrl.text.trim(),
      );
    } else {
      receiveDetails = ReceiveDetails();
    }

    return RequestMoneyReqModel(
      requestTo: controller.otherUserId, // ← Important: Get from ChatController
      amount:
          int.tryParse(amountCtrl.text.trim()) ??
          0, // or keep as double if your model supports it
      reason: reasonCtr.text.trim(), // You can make this dynamic
      returnDate: DateFormat('yyyy-MM-dd').format(pickedDate!),
      repaymentMode: selectedRepaymentMode.value,
      receiveMethod: receiveMethodStr,
      receiveDetails: receiveDetails,
      source: "chat",
    );
  }

  void sendRequest() async {
    final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;

    // ── Validation (same as before) ──
    if (amount <= 0 || pickedDate == null) {
      AppSnackbar.show(
        title: 'Missing info',
        message: 'Please enter amount and select a date',
        type: SnackBarType.error,
      );
      return;
    }
    if (selectedPayment.value == null) {
      AppSnackbar.show(
        title: 'Missing info',
        message: 'Please select a payment method',
        type: SnackBarType.error,
      );
      return;
    }
    if (selectedPayment.value == PaymentMethod.upi &&
        upiCtrl.text.trim().isEmpty) {
      AppSnackbar.show(
        title: 'Missing info',
        message: 'Please enter your UPI ID',
        type: SnackBarType.error,
      );
      return;
    }
    if (selectedPayment.value == PaymentMethod.bank &&
        (accNumberCtrl.text.trim().isEmpty ||
            ifscCtrl.text.trim().isEmpty ||
            holderCtrl.text.trim().isEmpty)) {
      AppSnackbar.show(
        title: 'Missing info',
        message: 'Please fill all bank details',
        type: SnackBarType.error,
      );
      return;
    }

    Get.back(); // ← pehle sheet band karo

    // ── Controller ke through bhejo ──
    await controller.sendUdhaarFromSheet(
      model: buildRequestModel(),
      amount: amount,
      returnDate: DateFormat('yyyy-MM-dd').format(pickedDate!),
      repaymentMode: selectedRepaymentMode.value,
      receiveMethod: selectedPayment.value == PaymentMethod.upi
          ? 'upi'
          : 'bankTransfer',
      upiId: upiCtrl.text.trim().isEmpty ? null : upiCtrl.text.trim(),
      accountNumber: accNumberCtrl.text.trim().isEmpty
          ? null
          : accNumberCtrl.text.trim(),
      ifscCode: ifscCtrl.text.trim().isEmpty ? null : ifscCtrl.text.trim(),
      accountHolderName: holderCtrl.text.trim().isEmpty
          ? null
          : holderCtrl.text.trim(),
      reason: reasonCtr.text.trim().isEmpty ? null : reasonCtr.text.trim(),
    );
  }

  Get.bottomSheet(
    Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: _buildLoanDetailsStep(
          key: const ValueKey('loan'),
          amountCtrl: amountCtrl,
          dateCtrl: dateCtrl,
          reasonCtr: reasonCtr,
          selectedRepaymentMode: selectedRepaymentMode,
          selectedPayment: selectedPayment,
          upiCtrl: upiCtrl,
          accNumberCtrl: accNumberCtrl,
          ifscCtrl: ifscCtrl,
          holderCtrl: holderCtrl,
          context: context,
          onPickDate: pickDate,
          onSend: sendRequest,
        ),
      ),
    ),
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  );
}
// ── Step 1 builder ────────────────────────────────────────────────────────────

Widget _buildLoanDetailsStep({
  Key? key,
  required TextEditingController amountCtrl,
  required TextEditingController dateCtrl,
  required TextEditingController reasonCtr,
  required RxString selectedRepaymentMode,
  required Rxn<PaymentMethod> selectedPayment,
  required TextEditingController upiCtrl,
  required TextEditingController accNumberCtrl,
  required TextEditingController ifscCtrl,
  required TextEditingController holderCtrl,
  required BuildContext context,
  required VoidCallback onPickDate,
  required VoidCallback onSend,
}) {
  return Column(
    key: key,
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      // Handle
      _SheetHandle(),
      const SizedBox(height: 20),

      Text(
        'Request Udhaar',
        style: text20(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ).copyWith(letterSpacing: -0.3),
      ),

      const SizedBox(height: 6),
      Text(
        'Fill in the loan details to send a request.',
        style: text12(
          fontWeight: FontWeight.w400,
        ).copyWith(color: const Color(0xFF7A7670)),
      ),

      const SizedBox(height: 24),

      // Amount
      const _SheetLabel('Amount Needed (₹)'),
      const SizedBox(height: 8),
      _SheetTextField(
        controller: amountCtrl,
        hint: '0.00',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        prefix: '₹',
      ),

      const SizedBox(height: 20),

      // Repayment date
      const _SheetLabel('Repayment Date'),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: onPickDate,
        child: AbsorbPointer(
          child: _SheetTextField(
            controller: dateCtrl,
            hint: 'Select date',
            suffix: const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: Color(0xFF9E9A94),
            ),
          ),
        ),
      ),
      const SizedBox(height: 20),

      const _SheetLabel('Reason'),
      const SizedBox(height: 8),
      _SheetTextField(
        controller: reasonCtr,
        hint: 'reason',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),

      const SizedBox(height: 24),

      Text(
        'Repayment Mode',
        style: text14(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      const SizedBox(height: 12),

      ..._sheetRepaymentModes.map(
        (mode) => _SheetRepaymentOptionCard(
          mode: mode,
          selectedRepaymentMode: selectedRepaymentMode,
        ),
      ),

      const SizedBox(height: 12),

      Text(
        'How will you get money?',
        style: text14(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      const SizedBox(height: 12),

      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _sheetPaymentMethods.map((method) {
            return Obx(() {
              final paymentMethod = method['type'] as PaymentMethod;
              final isSelected = selectedPayment.value == paymentMethod;

              return GestureDetector(
                onTap: () => selectedPayment.value = paymentMethod,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.button : AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.button : AppColors.grey200,
                      width: isSelected ? 1.8 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        method['icon'] as IconData,
                        size: 18,
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        method['title'].toString(),
                        style: text13(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
          }).toList(),
        ),
      ),

      const SizedBox(height: 16),

      Obx(
        () => _buildSheetPaymentFields(
          selectedPayment: selectedPayment,
          upiCtrl: upiCtrl,
          accNumberCtrl: accNumberCtrl,
          ifscCtrl: ifscCtrl,
          holderCtrl: holderCtrl,
        ),
      ),

      const SizedBox(height: 28),

      _PrimaryButton(label: 'Send Loan Request', onTap: onSend),
      const SizedBox(height: 4),
    ],
  );
}

final List<Map<String, dynamic>> _sheetRepaymentModes = [
  {
    'title': 'AutoPay',
    'type': 'auto-debit',
    'subtitle': 'Auto debit on due date',
    'desc': 'Automatic deduction + reminders & calling support',
    'icon': Icons.autorenew_rounded,
  },
  {
    'title': 'Micro Debit',
    'type': 'micro-debit',
    'subtitle': 'Daily micro-debits',
    'desc': 'Daily small debits + reminders & support',
    'icon': Icons.calendar_today_rounded,
  },
  {
    'title': 'Smart Protect',
    'type': 'smart-protect',
    'subtitle': 'Autodebit + Failsafe',
    'desc': 'Autodebit + microdebit backup + recovery workflow',
    'icon': Icons.security_rounded,
  },
  {
    'title': 'Manual Support',
    'type': 'manual',
    'subtitle': 'Manual repayment',
    'desc': 'Manual payment with reminders & calling assistance',
    'icon': Icons.support_agent_rounded,
  },
];

final List<Map<String, dynamic>> _sheetPaymentMethods = [
  {
    'title': 'UPI',
    'type': PaymentMethod.upi,
    'icon': Icons.account_balance_wallet_rounded,
  },
  {
    'title': 'Bank Transfer',
    'type': PaymentMethod.bank,
    'icon': Icons.account_balance_rounded,
  },
];

Widget _buildSheetPaymentFields({
  required Rxn<PaymentMethod> selectedPayment,
  required TextEditingController upiCtrl,
  required TextEditingController accNumberCtrl,
  required TextEditingController ifscCtrl,
  required TextEditingController holderCtrl,
}) {
  if (selectedPayment.value == PaymentMethod.upi) {
    return Column(
      key: const ValueKey('UPI'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SheetLabel('Your UPI ID'),
        const SizedBox(height: 8),
        _SheetTextField(
          controller: upiCtrl,
          hint: 'e.g. name@upi',
          suffix: const Icon(
            Icons.account_balance_wallet_outlined,
            size: 20,
            color: Color(0xFF9E9A94),
          ),
        ),
      ],
    );
  }

  return Column(
    key: const ValueKey('Bank'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SheetLabel('Account Holder Name'),
      const SizedBox(height: 8),
      _SheetTextField(controller: holderCtrl, hint: 'Enter full name'),
      const SizedBox(height: 14),
      const _SheetLabel('Account Number'),
      const SizedBox(height: 8),
      _SheetTextField(
        controller: accNumberCtrl,
        hint: 'Enter account number',
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 14),
      const _SheetLabel('IFSC Code'),
      const SizedBox(height: 8),
      _SheetTextField(
        controller: ifscCtrl,
        hint: 'e.g. SBIN0001234',
        suffix: const Icon(
          Icons.account_balance_outlined,
          size: 20,
          color: Color(0xFF9E9A94),
        ),
      ),
    ],
  );
}

class _SheetRepaymentOptionCard extends StatelessWidget {
  final Map<String, dynamic> mode;
  final RxString selectedRepaymentMode;

  const _SheetRepaymentOptionCard({
    required this.mode,
    required this.selectedRepaymentMode,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = selectedRepaymentMode.value == mode['type'];

      return GestureDetector(
        onTap: () => selectedRepaymentMode.value = mode['type'].toString(),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.button.withOpacity(0.08)
                : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.button : AppColors.grey200,
              width: isSelected ? 1.8 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.button : AppColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  mode['icon'] as IconData,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode['title'].toString(),
                      style: text16(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      mode['subtitle'].toString(),
                      style: text13(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mode['desc'].toString(),
                      style: text12(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.button,
                  size: 26,
                ),
            ],
          ),
        ),
      );
    });
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFFD3D1C7),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class _SheetLabel extends StatelessWidget {
  final String text;
  const _SheetLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Color(0xFF4A4845),
        letterSpacing: 0.7,
      ),
    );
  }
}

class _SheetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final String? prefix;
  final Widget? suffix;

  const _SheetTextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E1DB)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          if (prefix != null) ...[
            Text(
              prefix!,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A4845),
              ),
            ),
            const SizedBox(width: 6),
            Container(width: 1, height: 20, color: const Color(0xFFE4E1DB)),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Color(0xFFBEB9B2),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A1A)),
            ),
          ),
          ?suffix,
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

// ── Delete single message confirmation ────────────────────────────────────────
void _confirmDeleteMessage(
  BuildContext context,
  ChatController controller,
  ChatMessage msg,
) {
  if (msg.id == null || msg.id!.isEmpty) {
    // Optimistic message not yet ack'd — just remove locally
    controller.messages.remove(msg);
    return;
  }

  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD3D1C7),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFE53935),
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Delete Message?',
            style: text16(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'This message will be permanently deleted.',
            style: text13(color: const Color(0xFF7A7670)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              // Cancel
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2EFE9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Cancel',
                      style: text14(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Delete
              Expanded(
                child: Obx(() {
                  final loading =
                      controller.msgRes.value?.status == Status.loading;
                  return GestureDetector(
                    onTap: loading
                        ? null
                        : () async {
                            await controller.msgDelete(msg.id!);
                            if (controller.msgRes.value?.status ==
                                Status.completed) {
                              controller.messages.remove(msg);
                              Get.back();
                              AppSnackbar.show(
                                title: 'Deleted',
                                message: 'Message deleted',
                                type: SnackBarType.success,
                              );
                            } else {
                              AppSnackbar.show(
                                title: 'Error',
                                message: 'Could not delete message',
                                type: SnackBarType.error,
                              );
                            }
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 50,
                      decoration: BoxDecoration(
                        color: loading
                            ? const Color(0xFFE53935).withOpacity(0.5)
                            : const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Delete',
                              style: text14(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

// ── Clear all chat confirmation ───────────────────────────────────────────────
void _confirmClearAllChat(BuildContext context, ChatController controller) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD3D1C7),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Color(0xFFFFEBEE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.delete_sweep_outlined,
              color: Color(0xFFE53935),
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Clear Entire Chat?',
            style: text16(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'All messages will be permanently deleted.\nThis cannot be undone.',
            style: text13(color: const Color(0xFF7A7670)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2EFE9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Cancel',
                      style: text14(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() {
                  final loading =
                      controller.clearAllChatRes.value?.status ==
                      Status.loading;
                  return GestureDetector(
                    onTap: loading
                        ? null
                        : () async {
                            await controller.clearAllChat(
                              controller.otherUserId,
                            );
                            if (controller.clearAllChatRes.value?.status ==
                                Status.completed) {
                              controller.messages.clear();
                              Get.back();
                              AppSnackbar.show(
                                title: 'Cleared',
                                message: 'Chat cleared successfully',
                                type: SnackBarType.success,
                              );
                            } else {
                              AppSnackbar.show(
                                title: 'Error',
                                message: 'Could not clear chat',
                                type: SnackBarType.error,
                              );
                            }
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 50,
                      decoration: BoxDecoration(
                        color: loading
                            ? const Color(0xFFE53935).withOpacity(0.5)
                            : const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Clear All',
                              style: text14(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
