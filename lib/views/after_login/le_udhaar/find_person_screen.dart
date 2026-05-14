import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/models/response_model/leudhaar_res/contact_checked_res_model.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/routes/app_routes.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/view_model/after_login/leUdhaar_controller/chat_controller.dart';
import 'package:leudaar_app/views/custom_widget/custom_widget.dart';
import 'package:share_plus/share_plus.dart';

class FindPersonScreen extends StatefulWidget {
  const FindPersonScreen({super.key});

  @override
  State<FindPersonScreen> createState() => _FindPersonScreenState();
}

class _FindPersonScreenState extends State<FindPersonScreen> {
  final ChatSearchController controller = Get.put(ChatSearchController());

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────
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
                      'Find a person',
                      style: text18(
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      'Search by name or number',
                      style: text12(color: AppColors.white54),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: Obx(() {
              // ── Full screen loading ─────────────────────────────────
              if (controller.isLoading.value) {
                return _fullLoadingState();
              }

              return Column(
                children: [
                  // ── Search Bar ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: TextField(
                      controller: controller.searchController,
                      style: text14(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search name or number',
                        hintStyle: text14(color: AppColors.hintText),
                        filled: true,
                        fillColor: AppColors.white,
                        suffixIcon: controller.searchController.text.isNotEmpty
                            ? GestureDetector(
                                onTap: controller.searchController.clear,
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
                              )
                            : const Icon(
                                Icons.search_rounded,
                                color: AppColors.textSecondary,
                              ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.grey300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.grey300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.button,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── API checking banner ───────────────────────────────
                  if (controller.isChecking.value)
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Checking who\'s on Le\'Udhaar...',
                            style: text12(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 8),

                  // ── Lists ─────────────────────────────────────────────
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
                      children: [
                        // Recent searches chips
                        if (controller.searchController.text.isEmpty &&
                            controller.recentSearches.isNotEmpty) ...[
                          _sectionHeader(
                            label: 'Recent Searches',
                            icon: Icons.history_rounded,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: controller.recentSearches
                                .map(
                                  (name) => GestureDetector(
                                    onTap: () =>
                                        controller.searchController.text = name,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: AppColors.grey200,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.history_rounded,
                                            size: 14,
                                            color: AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            name,
                                            style: text13(
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // ── On Le'Udhaar ──────────────────────────────
                        _sectionHeader(
                          label:
                              'On Le\'Udhaar  •  ${controller.filteredRegistered.length}',
                          icon: Icons.verified_rounded,
                          iconColor: const Color(0xFF27AE60),
                        ),
                        const SizedBox(height: 10),
                        if (controller.filteredRegistered.isEmpty)
                          _emptyChip('No registered contacts found')
                        else
                          ...controller.filteredRegistered.map(
                            (c) => _registeredTile(c),
                          ),

                        const SizedBox(height: 20),

                        // ── Invite to Le'Udhaar ───────────────────────
                        _sectionHeader(
                          label:
                              'Invite to Le\'Udhaar  •  ${controller.filteredUnregistered.length}',
                          icon: Icons.person_add_alt_1_rounded,
                          iconColor: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 10),
                        if (controller.filteredUnregistered.isEmpty)
                          _emptyChip('No other contacts')
                        else
                          ...controller.filteredUnregistered.map(
                            (c) => _unregisteredTile(c),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Registered tile (on Le'Udhaar) ───────────────────────────────────
  Widget _registeredTile(LeUdhaarContact lc) {
    final Contact? local = controller.getLocalContact(lc);
    final String name =
        lc.user?.fullName ?? local?.displayName ?? lc.inputPhone ?? '';
    final String phone = lc.user?.phone ?? lc.normalizedPhone ?? '';
    final String initials = _initials(name);
    final bool hasPhoto = local?.photo != null;
    final bool canRequest = lc.actions?.canSendMoneyRequest == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.button.withOpacity(0.35),
          width: 1.4,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary,
                backgroundImage: hasPhoto
                    ? MemoryImage(local!.photo!.thumbnail!)
                    : null,
                child: hasPhoto
                    ? null
                    : Text(
                        initials,
                        style: text13(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Name & phone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: text14(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(phone, style: text12(color: AppColors.textSecondary)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF27AE60).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Le\'Udhaar',
                        style: text12(
                          color: const Color(0xFF27AE60),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Request button
          if (canRequest)
            GestureDetector(
              onTap: () {
                controller.addToRecentSearch(name);
                Get.toNamed(
                  AppRoutes.requestMoneyScreen,
                  arguments: {
                    'initials': initials,
                    'name': name,
                    'number': phone,
                    'userId': lc.user?.id,
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.button,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Request',
                  style: text12(
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Unregistered tile (not on Le'Udhaar) ─────────────────────────────
  Widget _unregisteredTile(LeUdhaarContact lc) {
    final Contact? local = controller.getLocalContact(lc);
    final String name = local?.displayName ?? lc.inputPhone ?? '';
    final String phone = lc.normalizedPhone ?? lc.inputPhone ?? '';
    final String initials = _initials(name);
    final bool hasPhoto = local?.photo != null;
    final bool canWhatsapp = lc.actions?.canSendWhatsapp == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.grey300,
            backgroundImage: hasPhoto
                ? MemoryImage(local!.photo!.thumbnail!)
                : null,
            child: hasPhoto
                ? null
                : Text(
                    initials,
                    style: text13(
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
          ),
          const SizedBox(width: 12),

          // Name & phone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: text14(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(phone, style: text12(color: AppColors.textSecondary)),
              ],
            ),
          ),

          // WhatsApp invite
          if (canWhatsapp) ...[
            GestureDetector(
              onTap: () => _shareViaWhatsApp(name, lc.actions?.inviteLink),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'WhatsApp',
                  style: text12(
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],

          // General share / Invite
          GestureDetector(
            onTap: () => _shareInvite(name, lc.actions?.inviteLink),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.button,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Invite',
                style: text12(
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────
  Widget _fullLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Fetching your contacts...',
            style: text14(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader({
    required String label,
    required IconData icon,
    Color? iconColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor ?? AppColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: text13(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _emptyChip(String msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(msg, style: text13(color: AppColors.textSecondary)),
    );
  }

  void _shareViaWhatsApp(String name, dynamic inviteLink) {
    final link =
        inviteLink?.toString() ?? 'https://leudaar.app/refer?user=your_user_id';
    final message =
        "Hey $name 👋\n\nJoin me on Le'Udhaar — stress-free lending & borrowing!\n\n$link";
    SharePlus.instance.share(
      ShareParams(text: message, subject: "Join me on Le'Udhaar"),
    );
  }

  void _shareInvite(String name, dynamic inviteLink) {
    final link =
        inviteLink?.toString() ?? 'https://leudaar.app/refer?user=your_user_id';
    final message =
        "Hey $name 👋\n\nI've invited you to join Le'Udhaar — a stress-free & automated platform for lending, borrowing, and repayments.\n\nJoin now:\n$link";
    SharePlus.instance.share(
      ShareParams(text: message, subject: "Join me on Le'Udhaar"),
    );
  }
}
