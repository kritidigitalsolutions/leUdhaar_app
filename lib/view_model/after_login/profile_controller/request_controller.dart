import 'package:get/get.dart';
import 'package:leudaar_app/data/api_response.dart';
import 'package:leudaar_app/models/response_model/leudhaar_res/request_money_res_model.dart';
import 'package:leudaar_app/repo/leUdhaar_repo.dart';

class RequestController extends GetxController {
  final LeudhaarRepo _repo = LeudhaarRepo();
  var requestMoneyRes = ApiResponse<RequestMoneyResModel>.loading().obs;

  Future<void> fetchHelpData() async {
    requestMoneyRes.value = ApiResponse.loading();
    requestMoneyRes.value = await _repo.getRequestMoney();
  }
}
