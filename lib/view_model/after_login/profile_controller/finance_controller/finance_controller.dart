import 'package:get/get.dart';
import 'package:leudaar_app/data/api_response.dart';
import 'package:leudaar_app/models/response_model/profile_models/dashboard_res_model.dart';
import 'package:leudaar_app/repo/profile_repo.dart';

class DashboardController extends GetxController {
  final _repo = ProfileRepo();

  final dashBoardRes = ApiResponse<DashboardResModel>.loading().obs;

  Future<void> dashboardData() async {
    dashBoardRes.value = ApiResponse.loading();
    dashBoardRes.value = await _repo.getDashboard();
  }
}
