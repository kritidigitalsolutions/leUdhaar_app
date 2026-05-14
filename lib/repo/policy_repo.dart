import 'package:leudaar_app/data/api_response.dart';
import 'package:leudaar_app/data/network/network_api_service.dart';
import 'package:leudaar_app/models/response_model/policy_models/policy_res_model.dart';
import 'package:leudaar_app/res/app_urls.dart';

class PolicyRepo {
  final NetworkApiService _api = NetworkApiService();

  // help & support

  Future<ApiResponse<PolicyResModel>> getPolicy(String type) async {
    try {
      final res = await _api.getApi("${AppUrls.policy}/$type");

      return ApiResponse.completed(PolicyResModel.fromJson(res));
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // help & support

  Future<ApiResponse<HelpSupportResModel>> getHelpData() async {
    try {
      final res = await _api.getApi(AppUrls.helpSupport);

      return ApiResponse.completed(HelpSupportResModel.fromJson(res));
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // aboutus

  Future<ApiResponse<AboutUsResModel>> getAboutUs() async {
    try {
      final res = await _api.getApi(AppUrls.aboutUs);

      return ApiResponse.completed(AboutUsResModel.fromJson(res));
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
