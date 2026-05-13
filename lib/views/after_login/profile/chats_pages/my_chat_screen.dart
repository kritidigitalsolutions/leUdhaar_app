import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/view_model/after_login/chat_controller/chat_controller.dart';

class ChatDetailScreen extends StatelessWidget {
  ChatDetailScreen({super.key});

  final controller = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ── AppBar ─────────────────────────────────────
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
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary,
              child: Text(
                "AK",
                style: text12(
                  fontWeight: FontWeight.w700,
                ).copyWith(color: AppColors.white),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Amit Kumar",
                  style: text14(
                    fontWeight: FontWeight.w600,
                  ).copyWith(color: AppColors.primary),
                ),
                Text(
                  "Active 2 mins ago",
                  style: text11(
                    fontWeight: FontWeight.w400,
                  ).copyWith(color: AppColors.success),
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
              if (value == "delete") {
                Get.snackbar("Deleted", "Chat deleted successfully");
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "delete",
                child: Text(
                  "Delete Chat",
                  style: text14(color: const Color(0xFF1A1A1A)),
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

      // ── Body ───────────────────────────────────────
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                itemCount: controller.messages.length,
                itemBuilder: (_, index) {
                  final msg = controller.messages[index];

                  // Date separator
                  bool showDate =
                      index == 0 ||
                      !_isSameDay(
                        controller.messages[index - 1].time,
                        msg.time,
                      );

                  return Column(
                    children: [
                      if (showDate) _DateSeparator(msg.time),
                      _buildMessage(msg),
                    ],
                  );
                },
              ),
            ),
          ),

          // ── Input bar ────────────────────────────
          SafeArea(child: _ChatInputBar(controller: controller)),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildMessage(ChatMessage msg) {
    // Special: Udhaar card
    if (msg.type == MessageType.udhaar) {
      return _UdhaarCardBubble(msg: msg);
    }

    // Waiting pill
    if (msg.type == MessageType.status) {
      return _WaitingPill(text: msg.text ?? "");
    }

    return Align(
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
            ),
            child: _MessageContent(msg: msg),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
            child: Text(
              DateFormat('hh:mm a').format(msg.time),
              style: text10(
                fontWeight: FontWeight.w400,
              ).copyWith(color: const Color(0xFF9E9A94)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Date separator ────────────────────────────────────────────────────────────

class _DateSeparator extends StatelessWidget {
  final DateTime date;
  const _DateSeparator(this.date);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          DateFormat('MMMM d, y').format(date),
          style: text11(
            fontWeight: FontWeight.w400,
          ).copyWith(color: const Color(0xFF9E9A94)),
        ),
      ),
    );
  }
}

// ── Message content ───────────────────────────────────────────────────────────

class _MessageContent extends StatelessWidget {
  final ChatMessage msg;
  const _MessageContent({required this.msg});

  @override
  Widget build(BuildContext context) {
    if (msg.type == MessageType.text) {
      return Text(
        msg.text ?? "",
        style: text14(
          color: msg.isMe ? const Color(0xFFF7F5F1) : AppColors.textPrimary,
        ).copyWith(height: 1.5),
      );
    }

    if (msg.type == MessageType.image) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(msg.imagePath!),
          height: 180,
          width: 180,
          fit: BoxFit.cover,
        ),
      );
    }

    if (msg.type == MessageType.file) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.insert_drive_file_outlined,
            size: 20,
            color: msg.isMe ? Colors.white70 : const Color(0xFF4A4845),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              msg.fileName ?? "",
              style: text13(
                color: msg.isMe
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

// ── Udhaar card bubble ────────────────────────────────────────────────────────

class _UdhaarCardBubble extends StatelessWidget {
  final ChatMessage msg;
  const _UdhaarCardBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 2),
            padding: const EdgeInsets.all(14),
            width: Get.width * 0.65,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label row
                Row(
                  children: [
                    const Icon(
                      Icons.currency_rupee_rounded,
                      size: 14,
                      color: Color(0xFF9E9A94),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Udhaar Requested",
                      style: text11(
                        fontWeight: FontWeight.w500,
                      ).copyWith(color: const Color(0xFF9E9A94)),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Amount
                Text(
                  "₹${NumberFormat('#,##,###').format(msg.udhaarAmount ?? 0)}",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 10),

                // Due date
                _UdhaarRow(
                  icon: Icons.calendar_today_outlined,
                  text: "Due: ${msg.udhaarDueDate ?? ''}",
                ),
                const SizedBox(height: 4),

                // Protection
                _UdhaarRow(
                  icon: Icons.verified_user_outlined,
                  text: msg.udhaarProtection ?? "",
                ),

                const SizedBox(height: 10),

                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAC775).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "Pending Acceptance",
                        style: text10(
                          fontWeight: FontWeight.w600,
                        ).copyWith(color: const Color(0xFFFAC775)),
                      ),
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
        ],
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

// ── Waiting pill ──────────────────────────────────────────────────────────────

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
            Text(
              text,
              style: text11(
                fontWeight: FontWeight.w500,
              ).copyWith(color: const Color(0xFF5A5651)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Chat input bar ────────────────────────────────────────────────────────────

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
          // ── Rupee button → opens bottom sheet ──
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
                "₹",
                style: text16(
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ).copyWith(height: 1),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // ── Message input ───────────────────────
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F5F1),
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                controller: controller.messageController,
                style: text14().copyWith(color: const Color(0xFF1A1A1A)),
                decoration: const InputDecoration(
                  hintText: "Message...",
                  hintStyle: TextStyle(color: Color(0xFFBEB9B2), fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          const SizedBox(width: 6),

          // ── Attachment ──────────────────────────
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.attach_file_rounded,
              color: Color(0xFF9E9A94),
              size: 20,
            ),
            color: Colors.white,
            onSelected: (value) {
              if (value == "image") controller.sendImage();
              if (value == "file") controller.sendFile();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: "image", child: Text("Send Image")),
              PopupMenuItem(value: "file", child: Text("Send File")),
            ],
          ),

          // ── Send button ─────────────────────────
          GestureDetector(
            onTap: controller.sendText,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.send_rounded,
                color: AppColors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Udhaar bottom sheet ───────────────────────────────────────────────────────

void _showUdhaarSheet(BuildContext context, ChatController controller) {
  final amountCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final selectedProtection = 'basic'.obs;
  DateTime? pickedDate;

  Get.bottomSheet(
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD3D1C7),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Request Udhaar",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 24),

            // Amount
            const _SheetLabel("Amount Needed (₹)"),
            const SizedBox(height: 8),
            _SheetTextField(
              controller: amountCtrl,
              hint: "0.00",
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              prefix: "₹",
            ),

            const SizedBox(height: 20),

            // Repayment date
            const _SheetLabel("Repayment Date"),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 7)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                  builder: (ctx, child) => Theme(
                    data: ThemeData.light().copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF1A1A1A),
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (date != null) {
                  pickedDate = date;
                  dateCtrl.text = DateFormat('yyyy-MM-dd').format(date);
                }
              },
              child: AbsorbPointer(
                child: _SheetTextField(
                  controller: dateCtrl,
                  hint: "Select date",
                  suffix: const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: Color(0xFF9E9A94),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Protection options
            Text(
              "Offer Protection to Lender",
              style: text13(
                fontWeight: FontWeight.w600,
              ).copyWith(color: const Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 4),
            Text(
              "Build trust by offering automated recovery methods.",
              style: text12(
                fontWeight: FontWeight.w400,
              ).copyWith(color: const Color(0xFF7A7670)),
            ),

            const SizedBox(height: 12),

            Obx(
              () => Column(
                children: [
                  _ProtectionOption(
                    value: "basic",
                    groupValue: selectedProtection.value,
                    title: "Le'Udhaar Basic",
                    subtitle:
                        "Auto-debit, calling reminders & optional micro-debits.",
                    icon: Icons.verified_user_outlined,
                    onChanged: (v) => selectedProtection.value = v!,
                  ),
                  const SizedBox(height: 10),
                  _ProtectionOption(
                    value: "legal",
                    groupValue: selectedProtection.value,
                    title: "Le'Legally Enforcement",
                    subtitle:
                        "AI MoU drafting, E-sign, Auto-debit & Micro-debits.",
                    icon: Icons.balance_outlined,
                    onChanged: (v) => selectedProtection.value = v!,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Send button
            GestureDetector(
              onTap: () {
                final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
                if (amount <= 0 || pickedDate == null) {
                  Get.snackbar(
                    "Missing info",
                    "Please enter amount and select a date",
                    backgroundColor: Colors.white,
                    colorText: const Color(0xFF1A1A1A),
                  );
                  return;
                }
                final protectionLabel = selectedProtection.value == 'basic'
                    ? "Basic Le Udhaar (Auto-Debit, Reminders & Micro-debits) Offered"
                    : "Le'Legally Enforcement (AI MoU, E-sign & Micro-debits) Offered";

                controller.sendUdhaarRequest(
                  amount: amount,
                  dueDate: DateFormat('yyyy-MM-dd').format(pickedDate!),
                  protection: protectionLabel,
                );
                Get.back();
              },
              child: Container(
                height: 54,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Send Loan Request",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Bottom sheet sub-widgets ──────────────────────────────────────────────────

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

class _ProtectionOption extends StatelessWidget {
  final String value;
  final String groupValue;
  final String title;
  final String subtitle;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const _ProtectionOption({
    required this.value,
    required this.groupValue,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF1A1A1A).withOpacity(0.04)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF1A1A1A) : const Color(0xFFE4E1DB),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected
                  ? const Color(0xFF1A1A1A)
                  : const Color(0xFF9E9A94),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: text13(
                      fontWeight: FontWeight.w600,
                    ).copyWith(color: const Color(0xFF1A1A1A)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: text11(
                      fontWeight: FontWeight.w400,
                    ).copyWith(color: const Color(0xFF7A7670)),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: const Color(0xFF1A1A1A),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}
