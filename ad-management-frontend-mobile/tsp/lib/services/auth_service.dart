import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../screens/auth/role_selection.dart';

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

  // Logout method to clear token and other stored data
  Future<void> logout(BuildContext context) async {
    try {
      // Clear stored tokens and user data
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove("token");

      // Optional: Call logout endpoint if your API has one
      // try {
      //   final token = prefs.getString("token");
      //   if (token != null) {
      //     await _dio.post("/auth/logout",
      //       options: Options(headers: {"Authorization": "Bearer $token"}));
      //   }
      // } catch (e) {
      //   print("Error logging out from API: $e");
      //   // Continue with local logout even if API call fails
      // }

      // Clear any other stored user data
      await prefs.remove("user_id");
      await prefs.remove("user_role");
      await prefs.remove("user_data");

      // Navigate to role selection screen and clear navigation stack
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
          (route) => false, // This removes all previous routes
        );
      }
    } catch (e) {
      print("Error during logout: $e");
      // Show error message if logout fails
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logout failed. Please try again.')),
        );
      }
    }
  }
}
