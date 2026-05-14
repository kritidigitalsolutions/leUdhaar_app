import 'package:get/get.dart';
import 'package:leudaar_app/data/api_response.dart';
import 'package:leudaar_app/models/response_model/policy_models/policy_res_model.dart';
import 'package:leudaar_app/repo/policy_repo.dart';

class PolicyController extends GetxController {
  // PolicyController(this.type);

  // final PolicyType type;
  final PolicyRepo _repo = PolicyRepo();

  // ============== terms and privacy ===================

  final policyResponse = ApiResponse<PolicyResModel>.loading().obs;

  Future<void> fetchPolicy(String type) async {
    policyResponse.value = ApiResponse.loading();
    policyResponse.value = await _repo.getPolicy(type);
  }

  // =================Help and support ========================

  final helpSupResponse = ApiResponse<HelpSupportResModel>.loading().obs;

  Future<void> fetchHelpData() async {
    helpSupResponse.value = ApiResponse.loading();
    helpSupResponse.value = await _repo.getHelpData();
  }

  // =================Help and support ========================

  final aboutUsRes = ApiResponse<AboutUsResModel>.loading().obs;

  Future<void> fetchAboutUs() async {
    aboutUsRes.value =
        ApiResponse.loading(); // ← was wrongly using helpSupResponse
    aboutUsRes.value = await _repo.getAboutUs();
  }
}
