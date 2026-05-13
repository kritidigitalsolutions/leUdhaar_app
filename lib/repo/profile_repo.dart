import 'dart:io';

import 'package:dio/dio.dart';
import 'package:leudaar_app/data/api_response.dart';
import 'package:leudaar_app/data/network/network_api_service.dart';
import 'package:leudaar_app/res/app_urls.dart';
import 'package:leudaar_app/utils/service/local_storage/auth_storage.dart';

class ProfileRepo {
  final NetworkApiService _api = NetworkApiService();

  Future<ApiResponse<dynamic>> updateProfile({
    required String fullName,
    required String phone,
    required String city,
    File? image,
  }) async {
    try {
      final formData = FormData.fromMap({
        "fullName": fullName,
        "phone": phone,
        "city": city,
        if (image != null)
          "profileImage": await MultipartFile.fromFile(
            image.path,
            filename: image.path.split("/").last,
          ),
      });

      // ✅ PRINT NORMAL FIELDS
      print("FULL NAME: $fullName");
      print("PHONE: $phone");
      print("CITY: $city");

      // ✅ PRINT IMAGE
      print("IMAGE PATH: ${image?.path}");

      final token = AuthStorage.getToken();

      _api.setToken(token ?? '');

      final res = await _api.pacthApi(AppUrls.editProfile, formData);

      return ApiResponse.completed(res);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
