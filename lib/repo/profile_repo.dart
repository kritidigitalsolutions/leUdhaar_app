import 'dart:io';

import 'package:dio/dio.dart';
import 'package:leudaar_app/data/api_response.dart';
import 'package:leudaar_app/data/network/network_api_service.dart';
import 'package:leudaar_app/models/response_model/profile_models/chat_list_res_model.dart';
import 'package:leudaar_app/models/response_model/profile_models/dashboard_res_model.dart';
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

  // dashboard

  Future<ApiResponse<DashboardResModel>> getDashboard() async {
    try {
      final token = AuthStorage.getToken();

      _api.setToken(token ?? '');

      final res = await _api.getApi(AppUrls.dashboard);

      return ApiResponse.completed(DashboardResModel.fromJson(res));
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // my chat list

  Future<ApiResponse<ChatListResModel>> getChatList() async {
    try {
      final token = AuthStorage.getToken();

      _api.setToken(token ?? '');

      final res = await _api.getApi(AppUrls.chatList);

      return ApiResponse.completed(ChatListResModel.fromJson(res));
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // // my chat history clear

  Future<ApiResponse<Map<String, dynamic>>> clearAllChats(String userId) async {
    try {
      final token = AuthStorage.getToken();
      _api.setToken(token ?? '');
      final res = await _api.deleteApi("${AppUrls.chats}/$userId", {});
      return ApiResponse.completed(res);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // // my chat history clear

  Future<ApiResponse<Map<String, dynamic>>> deleteChatMsg(String msgId) async {
    try {
      final token = AuthStorage.getToken();
      _api.setToken(token ?? '');
      final res = await _api.deleteApi("${AppUrls.message}/$msgId", {});
      return ApiResponse.completed(res);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
