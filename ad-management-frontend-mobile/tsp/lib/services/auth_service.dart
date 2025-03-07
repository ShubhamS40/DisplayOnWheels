import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: "https://your-api-url.com"));

  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio
          .post("/auth/login", data: {"email": email, "password": password});
      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("token", response.data["token"]);
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }
}
