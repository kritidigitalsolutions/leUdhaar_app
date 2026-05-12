import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

// ===========================================================
// profile page
// ===================================================

class ProfileController extends GetxController {
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
  final fullNameController = TextEditingController(text: 'Rahul Sharma');
  final mobileController = TextEditingController(text: '+91 98765 43210');
  final upiController = TextEditingController(text: 'rahul@upi');
  final cityController = TextEditingController(text: 'Meerut, UP');

  RxBool isSaved = false.obs;

  void saveChanges() {
    isSaved.value = true;
  }

  void backToProfile() {
    Get.back();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    mobileController.dispose();
    upiController.dispose();
    cityController.dispose();
    super.onClose();
  }
}
