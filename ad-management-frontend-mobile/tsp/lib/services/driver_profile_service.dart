import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/driver_profile_model.dart';

class DriverProfileService {
  final String baseUrl = 'http://3.110.135.112:5000/api';
  
  // Get driver profile data
  Future<DriverProfileModel> getDriverProfile(String driverId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/driver-profile/driver-details/$driverId'),
        headers: {
          'Content-Type': 'application/json',
          // Add auth token if required
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          return DriverProfileModel.fromJson(responseData['data']);
        } else {
          throw Exception(responseData['message'] ?? 'Failed to load driver profile');
        }
      } else {
        throw Exception('Failed to load driver profile. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching driver profile: $e');
    }
  }
}
