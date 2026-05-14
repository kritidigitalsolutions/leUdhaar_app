import 'package:get/get.dart';
import 'package:leudaar_app/view_model/after_login/profile_controller/profile_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
