import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/driver_profile_model.dart';
import '../utils/constants.dart';

class DriverProfileService {
  final String baseUrl = Constants.baseUrl;

  // Get driver profile data
  Future<DriverProfileModel> getDriverProfile(String driverId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/driver-profile/driver-details/$driverId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () =>
            throw Exception('Connection timeout. Please try again.'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          return DriverProfileModel.fromJson(responseData['data']);
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to load driver profile');
        }
      } else {
        // Log the error for debugging purposes
        print(
            'API Error: Failed to load driver profile. Status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load driver profile. Please try again.');
      }
    } catch (e) {
      // Log the error for debugging
      print('Error fetching driver profile: $e');
      throw Exception('Error fetching driver profile: $e');
    }
  }
}
