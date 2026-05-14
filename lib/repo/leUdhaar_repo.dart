import 'package:leudaar_app/data/api_response.dart';
import 'package:leudaar_app/data/network/network_api_service.dart';
import 'package:leudaar_app/models/request_model/leUdhaar_request/leudhaarReq_modles.dart';
import 'package:leudaar_app/models/response_model/leudhaar_res/contact_checked_res_model.dart';
import 'package:leudaar_app/models/response_model/leudhaar_res/request_money_res_model.dart';
import 'package:leudaar_app/res/app_urls.dart';
import 'package:leudaar_app/utils/service/local_storage/auth_storage.dart';

class LeudhaarRepo {
  final _api = NetworkApiService();

  // ======================== contact checker ========================================

  Future<ApiResponse<ContactCheckedResModel>> checkContact(
    List<String> contacts,
  ) async {
    try {
      final token = AuthStorage.getToken();
      _api.setToken(token ?? '');
      final res = await _api.postApi(AppUrls.contactChecker, {
        "phones": contacts,
      });

      return ApiResponse.completed(ContactCheckedResModel.fromJson(res));
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // ======================== money request ========================================

  Future<ApiResponse<Map<String, dynamic>>> requestMoney(
    RequestMoneyReqModel model,
  ) async {
    try {
      final token = AuthStorage.getToken();
      _api.setToken(token ?? '');
      final res = await _api.postApi(AppUrls.requestMoney, model.toJson());

      return ApiResponse.completed(res);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // ======================== money request get ========================================

  Future<ApiResponse<RequestMoneyResModel>> getRequestMoney() async {
    try {
      final token = AuthStorage.getToken();
      _api.setToken(token ?? '');
      final res = await _api.getApi(AppUrls.requestMoney);

      return ApiResponse.completed(RequestMoneyResModel.fromJson(res));
    } catch (e) {
      print(e.toString());
      return ApiResponse.error(e.toString());
    }
  }
}
