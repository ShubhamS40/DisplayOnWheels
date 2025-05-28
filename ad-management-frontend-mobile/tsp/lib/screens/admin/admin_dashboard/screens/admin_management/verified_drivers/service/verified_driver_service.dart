import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../../utils/constants.dart';
import '../model/verified_driver_model.dart';

class VerifiedDriverService {
  final String baseUrl = Constants.baseUrl;

  Future<VerifiedDriversResponse> getVerifiedDrivers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/view-all-drivers/verified-drivers'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Constants.apiTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return VerifiedDriversResponse.fromJson(data);
      } else {
        throw Exception('Failed to load verified drivers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching verified drivers: $e');
    }
  }
}
