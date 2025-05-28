import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../../utils/constants.dart';
import '../model/driver_detail_model.dart';

class DriverDetailService {
  final String baseUrl = Constants.baseUrl;

  Future<DriverDetailResponse> getDriverDetails(String driverId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/brief-detail/driver/$driverId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Constants.apiTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return DriverDetailResponse.fromJson(data);
      } else {
        throw Exception('Failed to load driver details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching driver details: $e');
    }
  }
}
