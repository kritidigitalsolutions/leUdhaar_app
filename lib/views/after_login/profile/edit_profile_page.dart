import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/utils/custom_textfields.dart';
import 'package:leudaar_app/utils/service/helper_methods.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/view_model/after_login/profile_controller/profile_controller.dart';
import 'package:leudaar_app/views/custom_widget/custom_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final controller = Get.put(EditProfileController());
  final ProfileController profileCtr = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Obx(() => _buildHeader()),
          Expanded(
            child: Obx(
              () => controller.isSaved.value
                  ? _buildSuccessView()
                  : _buildFormView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.only(top: 50, bottom: 24, left: 16, right: 16),
      child: Column(
        children: [
          Row(
            children: [
              backButton(),
              const SizedBox(width: 12),
              Text(
                'Edit profile',
                style: text18(
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ],
          ),

          if (!controller.isSaved.value) ...[
            const SizedBox(height: 20),

            Obx(() {
              return Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: const Color(0xFF1E2937),

                    backgroundImage: profileCtr.selectedImage.value != null
                        ? FileImage(profileCtr.selectedImage.value!)
                        : (profileCtr.user.value?.profileImage != null &&
                              profileCtr.user.value!.profileImage!.isNotEmpty)
                        ? NetworkImage(
                                "http://192.168.1.17:5005${profileCtr.user.value!.profileImage!}",
                              )
                              as ImageProvider
                        : null,

                    child:
                        (profileCtr.selectedImage.value == null &&
                            (profileCtr.user.value?.profileImage == null ||
                                profileCtr.user.value!.profileImage!.isEmpty))
                        ? Text(
                            getInitials(profileCtr.user.value?.fullName),
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
                                style: text18(fontWeight: FontWeight.w600),
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
                                      profileCtr.pickImageFromCamera();
                                      Get.back();
                                    },
                                  ),
                                  _actionBox(
                                    icon: Icons.photo_library,
                                    label: "Gallery",
                                    color: const Color(0xFF22C55E),
                                    onTap: () {
                                      profileCtr.pickImageFromGallery();
                                      Get.back();
                                    },
                                  ),
                                  _actionBox(
                                    icon: Icons.delete,
                                    label: "Remove",
                                    color: const Color(0xFFEF4444),
                                    onTap: () {
                                      profileCtr.removeImage();
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
            const SizedBox(height: 6),
            Text(
              'Change photo',
              style: text12(
                color: AppColors.button,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          _buildLabel('Full name'),
          AppTextField(
            controller: controller.fullNameController,
            hintText: "ex. Rahul Sharma",
          ),

          // _buildTextField(controller.fullNameController, 'Rahul Sharma'),
          const SizedBox(height: 16),
          _buildLabel('Mobile number'),
          AbsorbPointer(
            child: NumberTextField(
              controller: controller.mobileController,
              hintText: "ex. +91 98765 43210",
            ),
          ),

          //_buildTextField(controller.upiController, 'rahul@upi'),
          const SizedBox(height: 16),
          _buildLabel('City'),
          AppTextField(
            controller: controller.cityController,
            hintText: "ex. Agra, UP",
          ),

          // _buildTextField(controller.cityController, 'Meerut, UP'),
          const SizedBox(height: 32),

          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => controller.isLoading.value
                    ? null
                    : controller.saveChanges(profileCtr.selectedImage.value),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.button,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: controller.isLoading.value
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                          color: AppColors.white,
                        ),
                      )
                    : Text(
                        'Save Changes',
                        style: text16(
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 32),

          Container(
            height: 90,
            width: 90,
            decoration: const BoxDecoration(
              color: Color(0xFFECF8ED),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.success,
              size: 48,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Profile updated',
            style: text20(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Your changes have been saved\nsuccessfully.',
            textAlign: TextAlign.center,
            style: text13(color: AppColors.textSecondary),
          ),

          const SizedBox(height: 28),

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.grey200),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Column(
              children: [
                _summaryRow('Name', controller.fullNameController.text),
                Divider(height: 1, color: AppColors.grey200),

                Divider(height: 1, color: AppColors.grey200),
                _summaryRow('City', controller.cityController.text),
              ],
            ),
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: controller.backToProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.button,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Back to profile',
                style: text16(
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

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: text14(color: AppColors.textSecondary)),
          Text(
            value,
            style: text14(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: text13(
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
