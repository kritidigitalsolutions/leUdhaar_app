import 'package:hive/hive.dart';
import 'package:leudaar_app/models/response_model/auth_models/verify_res_model.dart';

class AuthStorage {
  static final Box _box = Hive.box('authBox');

  static Future<void> saveToken(String token) async {
    await _box.put('token', token);
  }

  static String? getToken() {
    return _box.get('token');
  }

  static Future<void> saveUser(User user) async {
    await _box.put('user', user.toJson());
  }

  static User? getUser() {
    final data = _box.get('user');

    if (data == null) return null;

    return User.fromJson(Map<String, dynamic>.from(data));
  }

  static Future<void> clear() async {
    await _box.clear();
  }

  static bool isLoggedIn() {
    return getToken() != null;
  }
}
