import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/models/response_model/leudhaar_res/contact_checked_res_model.dart';

import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/routes/app_routes.dart';
import 'package:leudaar_app/utils/service/helper_methods.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/view_model/after_login/leUdhaar_controller/chat_controller.dart';

// ═════════════════════════════════════════════════════════════════════════════
// SCREEN
// ═════════════════════════════════════════════════════════════════════════════

class ChatSearchScreen extends StatelessWidget {
  ChatSearchScreen({super.key});

  final ChatSearchController controller = Get.put(ChatSearchController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          // ── Top search bar (primary bg) ────────────────────────────────────
          _TopSearchBar(controller: controller),

          // ── White body ─────────────────────────────────────────────────────
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(color: AppColors.white),
              child: Obx(() {
                // Full-screen loader while fetching / checking
                if (controller.isLoading.value || controller.isChecking.value) {
                  return _LoadingBody(isChecking: controller.isChecking.value);
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  children: [
                    // ── Recent searches ──────────────────────────────────────
                    if (controller.searchController.text.isEmpty &&
                        controller.recentSearches.isNotEmpty) ...[
                      _SectionTitle(
                        label: 'Recent searches',
                        icon: Icons.history_rounded,
                        iconColor: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 10),
                      ...controller.recentSearches.map(
                        (name) => _RecentSearchTile(
                          name: name,
                          onTap: () => controller.searchController.text = name,
                          onRemove: () =>
                              controller.recentSearches.remove(name),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFFEEEAE3), height: 1),
                      const SizedBox(height: 24),
                    ],

                    // ── Registered contacts ──────────────────────────────────
                    _SectionTitle(
                      label:
                          "On Le'Udhaar  •  ${controller.filteredRegistered.length}",
                      icon: Icons.verified_rounded,
                      iconColor: const Color(0xFF27AE60),
                    ),
                    const SizedBox(height: 12),

                    if (controller.filteredRegistered.isEmpty)
                      _EmptyState(
                        icon: Icons.person_search_rounded,
                        message: controller.searchController.text.isEmpty
                            ? 'None of your contacts are on Le\'Udhaar yet'
                            : 'No registered contacts match your search',
                      )
                    else
                      ...controller.filteredRegistered.map(
                        (c) => _RegisteredTile(
                          contact: c,
                          localContact: controller.getLocalContact(c),
                          onTap: () {
                            final name =
                                c.user?.fullName ??
                                controller.getLocalContact(c)?.displayName ??
                                c.inputPhone ??
                                'Unknown';
                            controller.addToRecentSearch(name);
                            final Map<String, dynamic> otherUser = {
                              "id": c.user?.id ?? '',
                              "name": c.user?.fullName ?? '',
                              "phone": c.user?.phone ?? '',
                              "image": c.user?.profileImage ?? '',
                            };
                            Get.toNamed(
                              AppRoutes.myChatPage,
                              arguments: otherUser,
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 28),
                    const Divider(color: Color(0xFFEEEAE3), height: 1),
                    const SizedBox(height: 28),

                    // ── Unregistered contacts ────────────────────────────────
                    _SectionTitle(
                      label:
                          "Invite to Le'Udhaar  •  ${controller.filteredUnregistered.length}",
                      icon: Icons.person_add_alt_1_rounded,
                      iconColor: AppColors.primary,
                    ),
                    const SizedBox(height: 12),

                    if (controller.filteredUnregistered.isEmpty)
                      _EmptyState(
                        icon: Icons.group_add_rounded,
                        message: controller.searchController.text.isEmpty
                            ? 'All your contacts are already on Le\'Udhaar!'
                            : 'No contacts match your search',
                      )
                    else
                      ...controller.filteredUnregistered.map(
                        (c) => _unregisteredTile(c),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

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
              onTap: () => shareViaWhatsApp(name, lc.actions?.inviteLink),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success,
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
            onTap: () => shareInvite(name, lc.actions?.inviteLink),
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
}

// ═════════════════════════════════════════════════════════════════════════════
// TOP SEARCH BAR
// ═════════════════════════════════════════════════════════════════════════════

class _TopSearchBar extends StatelessWidget {
  final ChatSearchController controller;
  const _TopSearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Row(
          children: [
            // Back button
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.white,
                  size: 16,
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Search field
            Expanded(
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: AppColors.white70,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: controller.searchController,
                        style: text15(color: AppColors.white),
                        decoration: InputDecoration(
                          hintText: 'Search by name or number…',
                          hintStyle: text15(
                            color: AppColors.white.withOpacity(0.55),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    // Clear button
                    controller.searchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () => controller.searchController.clear(),
                            child: const Icon(
                              Icons.close_rounded,
                              color: AppColors.white70,
                              size: 18,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// LOADING BODY
// ═════════════════════════════════════════════════════════════════════════════

class _LoadingBody extends StatelessWidget {
  final bool isChecking;
  const _LoadingBody({required this.isChecking});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.primary,
              backgroundColor: AppColors.primary.withOpacity(0.1),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isChecking ? 'Checking who\'s on Le\'Udhaar…' : 'Loading contacts…',
            style: text13(
              fontWeight: FontWeight.w500,
            ).copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SECTION TITLE
// ═════════════════════════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;

  const _SectionTitle({
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 6),
        Text(
          label,
          style: text13(
            fontWeight: FontWeight.w700,
          ).copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// RECENT SEARCH TILE
// ═════════════════════════════════════════════════════════════════════════════

class _RecentSearchTile extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _RecentSearchTile({
    required this.name,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFF2EFE9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.history_rounded,
          size: 18,
          color: Color(0xFF9E9A94),
        ),
      ),
      title: Text(
        name,
        style: text14(
          fontWeight: FontWeight.w500,
        ).copyWith(color: AppColors.textPrimary),
      ),
      trailing: GestureDetector(
        onTap: onRemove,
        child: const Icon(
          Icons.close_rounded,
          size: 18,
          color: Color(0xFFBEB9B2),
        ),
      ),
      onTap: onTap,
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// REGISTERED CONTACT TILE
// ═════════════════════════════════════════════════════════════════════════════

class _RegisteredTile extends StatelessWidget {
  final LeUdhaarContact contact;
  final Contact? localContact;
  final VoidCallback onTap;

  const _RegisteredTile({
    required this.contact,
    required this.localContact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayName =
        contact.user?.fullName ??
        localContact?.displayName ??
        contact.inputPhone ??
        'Unknown';

    final phone = contact.normalizedPhone ?? contact.inputPhone ?? '';

    final initials = _initials(displayName);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF0EDE7), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Avatar ────────────────────────────────────────────────────
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    initials,
                    style: text14(
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
                // Verified badge
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFF27AE60),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 9,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 12),

            // ── Name & phone ──────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: text14(
                      fontWeight: FontWeight.w600,
                    ).copyWith(color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_rounded,
                        size: 11,
                        color: Color(0xFF9E9A94),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatPhone(phone),
                        style: text12(
                          fontWeight: FontWeight.w400,
                        ).copyWith(color: const Color(0xFF9E9A94)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Status badge + arrow ──────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.circle,
                        size: 6,
                        color: Color(0xFF27AE60),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Active',
                        style: text10(
                          fontWeight: FontWeight.w600,
                        ).copyWith(color: const Color(0xFF27AE60)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Send Udhaar →',
                  style: text10(
                    fontWeight: FontWeight.w500,
                  ).copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// EMPTY STATE
// ═════════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5F1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: const Color(0xFFD3D1C7)),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: text12(
              fontWeight: FontWeight.w400,
            ).copyWith(color: const Color(0xFFBEB9B2)),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// HELPERS
// ═════════════════════════════════════════════════════════════════════════════

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || name.isEmpty) return '?';
  if (parts.length == 1) return parts[0][0].toUpperCase();
  return (parts[0][0] + parts[1][0]).toUpperCase();
}

String _formatPhone(String phone) {
  final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length == 10) {
    return '${digits.substring(0, 5)} ${digits.substring(5)}';
  }
  if (digits.length == 12 && digits.startsWith('91')) {
    final local = digits.substring(2);
    return '+91 ${local.substring(0, 5)} ${local.substring(5)}';
  }
  return phone;
}
