import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/routes/app_routes.dart';
import 'package:leudaar_app/utils/custom_button.dart';
import 'package:leudaar_app/utils/service/helper_methods.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/view_model/after_login/profile_controller/profile_controller.dart';
import 'package:leudaar_app/views/after_login/profile/policy/policy_page.dart';
import 'package:leudaar_app/views/custom_widget/custom_logout_widget.dart';
import 'package:leudaar_app/views/custom_widget/custom_widget.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverAppBar Header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            floating: false,
            backgroundColor: AppColors.primary,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
                child: Column(
                  children: [
                    // Back Button
                    Align(alignment: Alignment.topLeft, child: backButton()),

                    // Avatar
                    Obx(() {
                      return Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: const Color(0xFF1E2937),

                            backgroundImage:
                                controller.selectedImage.value != null
                                ? FileImage(controller.selectedImage.value!)
                                : (controller.user.value?.profileImage !=
                                          null &&
                                      controller
                                          .user
                                          .value!
                                          .profileImage!
                                          .isNotEmpty)
                                ? NetworkImage(
                                        "http://192.168.1.17:5005${controller.user.value!.profileImage!}",
                                      )
                                      as ImageProvider
                                : null,

                            child:
                                (controller.selectedImage.value == null &&
                                    (controller.user.value?.profileImage ==
                                            null ||
                                        controller
                                            .user
                                            .value!
                                            .profileImage!
                                            .isEmpty))
                                ? Text(
                                    getInitials(
                                      controller.user.value?.fullName,
                                    ),
                                    style: text30(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white,
                                    ),
                                  )
                                : null,
                          ),
                          // 📷 Camera button
                          GestureDetector(
                            onTap: () {
                              Get.bottomSheet(
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: const BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(25),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Choose Option",
                                        style: text18(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _actionBox(
                                            icon: Icons.camera_alt,
                                            label: "Camera",
                                            color: const Color(0xFF3B82F6),
                                            onTap: () {
                                              controller.pickImageFromCamera();
                                              Get.back();
                                            },
                                          ),
                                          _actionBox(
                                            icon: Icons.photo_library,
                                            label: "Gallery",
                                            color: const Color(0xFF22C55E),
                                            onTap: () {
                                              controller.pickImageFromGallery();
                                              Get.back();
                                            },
                                          ),
                                          _actionBox(
                                            icon: Icons.delete,
                                            label: "Remove",
                                            color: const Color(0xFFEF4444),
                                            onTap: () {
                                              controller.removeImage();
                                              Get.back();
                                            },
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: const CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.button,
                              child: Icon(
                                Icons.camera_alt_outlined,
                                size: 18,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),

                    const SizedBox(height: 16),

                    Obx(
                      () => Text(
                        controller.user.value?.fullName ?? "No Name",
                        style: text16(
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Obx(
                      () => Text(
                        "+91 ${controller.user.value?.phone ?? ""}",
                        style: text13(color: AppColors.white70),
                      ),
                    ),
                    const SizedBox(height: 15),

                    OutlinedButton(
                      onPressed: () {
                        Get.toNamed(AppRoutes.editProfile);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Edit your Profile",
                        style: text13(
                          fontWeight: FontWeight.w500,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Menu Items
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // ① Activity ─────────────────────────────────────
                    _sectionLabel('Activity'),
                    _menuCard([
                      _menuItem(
                        Icons.chat_bubble_outline_rounded,
                        'My Chats',

                        () => Get.toNamed(AppRoutes.myChatListScreen),
                      ),
                      _menuItem(
                        Icons.grid_view_rounded,
                        'Dashboard',

                        () => Get.toNamed(AppRoutes.dashboard),
                      ),
                      _menuItem(
                        Icons.request_page_outlined,
                        'Requests',

                        () => Get.toNamed(AppRoutes.requestScreen),
                      ),
                    ]),

                    // ② Finance ──────────────────────────────────────
                    _sectionLabel('Finance'),
                    _menuCard([
                      _menuItem(
                        Icons.account_balance_wallet_outlined,
                        'My Wallet',

                        () => Get.toNamed(AppRoutes.myWallet),
                      ),
                      _menuItem(
                        Icons.description_outlined,
                        'Agreements',

                        () => Get.toNamed(AppRoutes.agreements),
                      ),
                      _menuItem(
                        Icons.credit_card_outlined,
                        'Micro Debit Recovery',

                        () => Get.toNamed(AppRoutes.microDebit),
                      ),
                      _menuItem(
                        Icons.bolt_outlined,
                        'Auto Debit Recovery',

                        () => Get.toNamed(AppRoutes.autoDebit),
                      ),
                    ]),

                    // ③ Policies & Support ───────────────────────────
                    _sectionLabel('Policies & Support'),
                    _menuCard([
                      _menuItem(
                        Icons.gavel_rounded,
                        'Terms & Conditions',

                        () => Get.to(() => PolicyPage(type: PolicyType.terms)),
                      ),
                      _menuItem(
                        Icons.privacy_tip_outlined,
                        'Privacy Policy',

                        () =>
                            Get.to(() => PolicyPage(type: PolicyType.privacy)),
                      ),
                      _menuItem(
                        Icons.help_outline_rounded,
                        'Help & Support',

                        () {},
                      ),
                      _menuItem(Icons.info_outline_rounded, 'About App', () {}),
                    ]),

                    const SizedBox(height: 32),

                    // Logout Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: AppButton(
                        height: 50,
                        title: 'Log Out',
                        onTap: () => showLogoutBottomSheet(Get.context!),
                      ),
                    ),

                    // Version footer
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'Leudaar v1.0.0',
                          style: text12(color: AppColors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _actionBox({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: text13(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Text(
        label.toUpperCase(),
        style: text11(
          color: AppColors.grey,
          fontWeight: FontWeight.w700,
        ).copyWith(letterSpacing: 0.8),
      ),
    );
  }

  // ── Menu card wrapper (rounded white card per section) ──
  Widget _menuCard(List<Widget> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          return Column(
            children: [
              items[i],
              if (i != items.length - 1)
                Divider(
                  height: 1,
                  indent: 60, // indent past icon
                  color: AppColors.grey200,
                ),
            ],
          );
        }),
      ),
    );
  }

  // ── Menu item — now takes a color for icon bg ───────────
  Widget _menuItem(
    IconData icon,
    String title,
    // NEW param
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: text14(
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.grey,
        size: 20,
      ),
      onTap: onTap,
    );
  }
}
