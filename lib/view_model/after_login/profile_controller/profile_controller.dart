import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leudaar_app/data/api_response.dart';
import 'package:leudaar_app/models/response_model/auth_models/verify_res_model.dart';
import 'package:leudaar_app/repo/profile_repo.dart';
import 'package:leudaar_app/utils/custom_snackbar.dart';
import 'package:leudaar_app/utils/service/local_storage/auth_storage.dart';

// ===========================================================
// profile page
// ===================================================

class ProfileController extends GetxController {
  Rx<User?> user = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  void loadUser() {
    user.value = AuthStorage.getUser();
    print(AuthStorage.getToken());
    print("USER DATA: ${user.value?.fullName}");
  }

  void refreshUser() {
    user.value = AuthStorage.getUser();

    user.refresh(); // important
  }

  final ImagePicker _picker = ImagePicker();

  // selected image
  Rx<File?> selectedImage = Rx<File?>(null);

  // loading state
  RxBool isLoading = false.obs;

  // 📸 Pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      print("Gallery Error: $e");
    }
  }

  // 📷 Pick image from camera
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      print("Camera Error: $e");
    }
  }

  // ❌ Remove image
  void removeImage() {
    selectedImage.value = null;
  }
}

// ========================================================
// edit profile =======
//========================================

class EditProfileController extends GetxController {
  final profileCtr = Get.find<ProfileController>();

  final ProfileRepo _repo = ProfileRepo();

  final fullNameController = TextEditingController();
  final mobileController = TextEditingController();
  final cityController = TextEditingController();

  Rx<File?> selectedImage = Rx<File?>(null);
  RxBool isLoading = false.obs;
  RxBool isSaved = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  void loadUserData() {
    final user = AuthStorage.getUser();

    if (user != null) {
      fullNameController.text = user.fullName ?? "";
      mobileController.text = user.phone ?? "";
      cityController.text = ""; // add if available in API
    }
  }

  Future<void> saveChanges(File? image) async {
    isLoading.value = true;

    final res = await _repo.updateProfile(
      fullName: fullNameController.text.trim(),
      phone: mobileController.text.trim(),
      city: cityController.text.trim(),
      image: image,
    );

    isLoading.value = false;

    if (res.status == Status.completed) {
      final data = res.data;

      if (data["success"] == true) {
        final oldUser = AuthStorage.getUser();

        final updatedUser = User(
          id: oldUser?.id,
          fullName: data["data"]["fullName"] ?? oldUser?.fullName,
          phone: data["data"]["phone"] ?? oldUser?.phone,
          profileImage: data["data"]["profileImage"] ?? oldUser?.profileImage,
          walletBalance: oldUser?.walletBalance,
          totalLent: oldUser?.totalLent,
          totalBorrowed: oldUser?.totalBorrowed,
          totalRecovered: oldUser?.totalRecovered,
          pendingAmount: oldUser?.pendingAmount,
          overdueAmount: oldUser?.overdueAmount,
          accountStatus: oldUser?.accountStatus,
          kycStatus: oldUser?.kycStatus,
          lastLoginAt: oldUser?.lastLoginAt,
          createdAt: oldUser?.createdAt,
          updatedAt: oldUser?.updatedAt,
        );

        await AuthStorage.saveUser(updatedUser);

        isSaved.value = true;
        profileCtr.refreshUser();

        AppSnackbar.show(
          title: "Success",
          message: "Profile updated successfully",
          type: SnackBarType.success,
        );
      } else {
        AppSnackbar.show(
          title: "Error",
          message: data["message"] ?? "Update failed",
          type: SnackBarType.error,
        );
      }
    } else {
      AppSnackbar.show(
        title: "Error",
        message: "Something went wrong",
        type: SnackBarType.error,
      );
    }
  }

  void backToProfile() {
    Get.back();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    mobileController.dispose();
    cityController.dispose();
    super.onClose();
  }
}
