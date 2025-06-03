import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/company_profile_model.dart';
import '../utils/constants.dart';

class CompanyProfileService {
  final String baseUrl = Constants.baseUrl;

  Future<CompanyProfileModel> getCompanyProfile(String companyId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Use the API endpoint provided by the user
      final response = await http.get(
        Uri.parse('$baseUrl/api/company-profile/company-details/$companyId'),
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
        final Map<String, dynamic> data = json.decode(response.body);
        print('API Response: $data');
        return CompanyProfileModel.fromJson(data['data']);
      } else {
        // Log the error for debugging purposes
        print('API Error: Failed to load company profile. Status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load company profile. Please try again.');
      }
    } catch (e) {
      // Log the error for debugging
      print('Error fetching company profile: $e');
      throw Exception('Error fetching company profile: $e');
    }
  }

  // Mock data for development and testing
  CompanyProfileModel _getMockCompanyProfile() {
    // Create mock DocumentDetails
    final documentDetails = DocumentDetails(
      documentUrls: DocumentUrls(
        businessRegistrationUrl: 'https://example.com/docs/registration.pdf',
        idCardUrl: 'https://example.com/docs/idcard.jpg',
        gstRegistrationUrl: 'https://example.com/docs/gst.pdf',
        panCardUrl: 'https://example.com/docs/pancard.jpg',
      ),
      companyInfo: CompanyInfo(
        name: 'Acme Corporation',
        type: 'Private Limited',
        address: '123 Main St, Mumbai',
        city: 'Mumbai',
        state: 'Maharashtra',
        country: 'India',
        zipCode: '400001',
        registrationNumber: 'REG123456789',
        taxId: 'GST123456789',
      ),
      verificationStatus: VerificationStatus(
        businessRegistration: 'Approved',
        idCardStatus: 'Pending',
        gstRegistration: 'Approved',
        panCard: 'Approved',
        overall: 'Approved',
        adminMessage: 'Your documents have been verified.',
      ),
    );

    // Create mock CompanyBasicDetails
    final basicDetails = CompanyBasicDetails(
      id: 'COMP123456',
      businessName: 'TSP Advertising',
      email: 'info@tspadvertising.com',
      contactNumber: '+91 9876543210',
      walletBalance: 25000.0,
      isEmailVerified: true,
      createdAt: '10/01/2023',
      updatedAt: '10/01/2023',
    );

    // Create mock campaigns
    final campaigns = [
      CampaignData(
        id: 'CAM001',
        title: 'Summer Promotion',
        status: 'Active',
        startDate: '2023-05-01',
        endDate: '2023-06-30',
        approvalStatus: 'Approved',
        totalAmount: 5000.0,
        vehicleCount: 8,
        posterDesignNeeded: false,
      ),
      CampaignData(
        id: 'CAM002',
        title: 'Festival Offer',
        status: 'Active',
        startDate: '2023-04-15',
        endDate: '2023-05-15',
        approvalStatus: 'Approved',
        totalAmount: 7500.0,
        vehicleCount: 10,
        posterDesignNeeded: false,
      ),
      CampaignData(
        id: 'CAM003',
        title: 'New Year Special',
        status: 'Completed',
        startDate: '2023-01-01',
        endDate: '2023-01-31',
        approvalStatus: 'Completed',
        totalAmount: 12500.0,
        vehicleCount: 15,
        posterDesignNeeded: false,
      ),
    ];

    // Create mock statistics data
    final statistics = StatisticsData(
      totalCampaigns: 12,
      activeCampaigns: 3,
      completedCampaigns: 9,
      totalSpent: 75000.0,
    );

    // Return complete CompanyProfileModel
    return CompanyProfileModel(
      basicDetails: basicDetails,
      documentDetails: documentDetails,
      campaigns: campaigns,
      statistics: statistics,
    );
  }

  Future<void> updateCompanyProfile(
      String companyId, Map<String, dynamic> updatedData) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http
          .put(
            Uri.parse('$baseUrl/api/company/profile/$companyId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(updatedData),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw Exception('Connection timeout. Please try again.'),
          );

      if (response.statusCode != 200) {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ??
            'Failed to update company profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating company profile: $e');
      throw Exception('Error updating company profile: $e');
    }
  }
}
