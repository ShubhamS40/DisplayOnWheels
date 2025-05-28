import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/verified_company_model.dart';
import '../../../../../../../utils/constants.dart';

class VerifiedCompanyService {
  Future<VerifiedCompanyResponse> getVerifiedCompanies() async {
    try {
      // Get token from shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Fetching verified companies from the API
      final response = await http.get(
        Uri.parse(
            'http://localhost:5000/api/admin/view-all-companies/company-list'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return VerifiedCompanyResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
            'Failed to load verified companies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching verified companies: $e');
    }
  }
}
