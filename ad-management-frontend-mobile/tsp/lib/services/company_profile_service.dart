import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/company_profile_model.dart';
import '../utils/constants.dart';

class CompanyProfileService {
  final String baseUrl = Constants.baseUrl;

  Future<CompanyProfileModel> getCompanyProfile(String companyId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/company/profile/$companyId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return CompanyProfileModel.fromJson(data);
    } else {
      // For now, return mock data for development
      return _getMockCompanyProfile();
      // Uncomment below line for production
      // throw Exception('Failed to load company profile: ${response.statusCode}');
    }
  }

  // Mock data for development and testing
  CompanyProfileModel _getMockCompanyProfile() {
    return CompanyProfileModel(
      basicDetails: CompanyBasicDetails(
        id: 'COMP123456',
        companyName: 'TSP Advertising',
        email: 'info@tspadvertising.com',
        contactNumber: '+91 9876543210',
        address: '123 Business Park, Mumbai, Maharashtra, India',
        registrationNumber: 'REG123456789',
        logoUrl: '',
        walletBalance: 25000.0,
        isVerified: true,
        accountCreated: '10/01/2023',
      ),
      campaigns: [
        CampaignData(
          id: 'CAM001',
          title: 'Summer Promotion',
          status: 'Active',
          startDate: '2023-05-01',
          endDate: '2023-06-30',
          assignedDrivers: 8,
          budget: 5000.0,
          posterUrl: '',
        ),
        CampaignData(
          id: 'CAM002',
          title: 'Festival Offer',
          status: 'Active',
          startDate: '2023-04-15',
          endDate: '2023-05-15',
          assignedDrivers: 10,
          budget: 7500.0,
          posterUrl: '',
        ),
        CampaignData(
          id: 'CAM003',
          title: 'New Year Special',
          status: 'Completed',
          startDate: '2023-01-01',
          endDate: '2023-01-31',
          assignedDrivers: 15,
          budget: 12500.0,
          posterUrl: '',
        ),
      ],
      accountDetails: AccountDetails(
        planType: 'Premium',
        planExpiryDate: '2023-12-31',
        planAmount: 10000.0,
        autoRenewal: true,
      ),
      statistics: StatisticsData(
        totalCampaigns: 12,
        activeCampaigns: 3,
        completedCampaigns: 9,
        totalSpent: 75000.0,
      ),
    );
  }

  Future<void> updateCompanyProfile(
      String companyId, Map<String, dynamic> updatedData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/api/company/profile/$companyId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(updatedData),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to update company profile: ${response.statusCode}');
    }
  }
}
