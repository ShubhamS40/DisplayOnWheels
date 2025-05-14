import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsp/utils/constants.dart';

class AdminCampaignService {
  static final AdminCampaignService _instance =
      AdminCampaignService._internal();
  factory AdminCampaignService() => _instance;
  AdminCampaignService._internal();

  // Get all campaigns for admin
  Future<List<dynamic>> getAllCampaigns() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? 'asd';
      String adminId = prefs.getString('adminId') ?? '1'; // Default to '1'

      if (token == null) {
        debugPrint('Token missing');
        return [];
      }

      // Just print for debugging
      debugPrint('Using adminId: $adminId');

      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/api/company-launch'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        debugPrint('Failed to fetch campaigns (${response.statusCode})');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching campaigns: $e');
      return [];
    }
  }

  // Approve a campaign
  Future<Map<String, dynamic>> approveCampaign(String campaignId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final adminId = prefs.getString('adminId');

      if (token == null || adminId == null) {
        return {'success': false, 'message': 'Admin authentication required'};
      }

      final response = await http.post(
        Uri.parse(
            '${Constants.baseUrl}/api/company-launch/$campaignId/approve'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'adminID': adminId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Campaign approved successfully',
          'data': data['data']
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to approve campaign'
        };
      }
    } catch (e) {
      debugPrint('Error approving campaign: $e');
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  // Reject a campaign
  Future<Map<String, dynamic>> rejectCampaign(
      String campaignId, String reason) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final adminId = prefs.getString('adminId');

      if (token == null || adminId == null) {
        return {'success': false, 'message': 'Admin authentication required'};
      }

      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/api/company-launch/$campaignId/reject'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'adminID': adminId, 'rejectionReason': reason}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Campaign rejected successfully',
          'data': data['data']
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to reject campaign'
        };
      }
    } catch (e) {
      debugPrint('Error rejecting campaign: $e');
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  // Update campaign details (start/end dates)
  Future<Map<String, dynamic>> updateCampaignDetails(
      String campaignId, Map<String, dynamic> data) async {
    // Ensure dates have proper ISO 8601 format with Z suffix
    if (data.containsKey('startDate') && data['startDate'] != null) {
      // Parse the date string if it's not already a DateTime
      final startDate = data['startDate'] is DateTime
          ? data['startDate'] as DateTime
          : DateTime.parse(data['startDate'].toString());

      // Format to ensure proper ISO 8601 format with Z suffix
      data['startDate ,enddate'] = startDate.toUtc().toIso8601String();
    }

    if (data.containsKey('endDate') && data['endDate'] != null) {
      // Parse the date string if it's not already a DateTime
      final endDate = data['endDate'] is DateTime
          ? data['endDate'] as DateTime
          : DateTime.parse(data['endDate'].toString());

      // Format to ensure proper ISO 8601 format with Z suffix
      data['endDate'] = endDate.toUtc().toIso8601String();
    }

    debugPrint('Formatted data for update: $data');
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final adminId = prefs.getString('adminId');

      if (token == null || adminId == null) {
        return {'success': false, 'message': 'Admin authentication required'};
      }

      final response = await http.put(
        Uri.parse('${Constants.baseUrl}/api/company-launch/$campaignId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      debugPrint(
          'Update campaign response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          return {
            'success': true,
            'message': 'Campaign updated successfully',
            'data': responseData['data']
          };
        } catch (e) {
          debugPrint('Error parsing success response: $e');
          return {
            'success': true,
            'message': 'Campaign updated successfully',
            'data': {'updated': true}
          };
        }
      } else {
        try {
          // Check if response body is valid JSON before parsing
          if (response.body.startsWith('<!DOCTYPE')) {
            debugPrint('Received HTML response instead of JSON');
            return {
              'success': false,
              'message': 'Server error: Received HTML response'
            };
          }

          final responseData = jsonDecode(response.body);
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to update campaign'
          };
        } catch (e) {
          debugPrint('Error parsing error response: $e');
          return {
            'success': false,
            'message': 'Failed to update campaign: ${response.statusCode}'
          };
        }
      }
    } catch (e) {
      debugPrint('Error updating campaign: $e');
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  // Assign drivers to campaign
  Future<Map<String, dynamic>> assignDriversToCampaign(
      String campaignId, List<String> driverIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final adminId = prefs.getString('adminId');

      if (token == null || adminId == null) {
        return {'success': false, 'message': 'Admin authentication required'};
      }

      // Ensure the adminId is a number as shown in the API
      final adminIdValue = int.tryParse(adminId) ?? 1;

      // Use the validated payment endpoint as shown in Postman
      final response = await http.post(
        Uri.parse(
            '${Constants.baseUrl}/api/company-validate-payment/campaign/$campaignId/assign-drivers'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body:
            jsonEncode({'driverIds': driverIds, 'assignedById': adminIdValue}),
      );

      debugPrint(
          'Driver assignment request: ${Uri.parse('${Constants.baseUrl}/api/company-validate-payment/campaign/$campaignId/assign-drivers')}');
      debugPrint('Driver assignment body: ${jsonEncode({
            'driverIds': driverIds,
            'assignedById': adminIdValue
          })}');

      debugPrint(
          'Assign drivers response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          return {
            'success': true,
            'message': data['message'] ?? 'Drivers assigned successfully',
            'data': data['assignedDrivers']
          };
        } catch (e) {
          debugPrint('Error parsing success response: $e');
          return {
            'success': true,
            'message': 'Drivers assigned successfully',
            'data': []
          };
        }
      } else {
        try {
          // Check if response body is valid JSON before parsing
          if (response.body.startsWith('<!DOCTYPE')) {
            debugPrint('Received HTML response instead of JSON');
            return {
              'success': false,
              'message': 'Server error: Received HTML response'
            };
          }

          final data = jsonDecode(response.body);
          return {
            'success': false,
            'message': data['message'] ?? 'Failed to assign drivers'
          };
        } catch (e) {
          debugPrint('Error parsing error response: $e');
          return {
            'success': false,
            'message': 'Failed to assign drivers: ${response.statusCode}'
          };
        }
      }
    } catch (e) {
      debugPrint('Error assigning drivers: $e');
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  // Get available drivers for assignment
  // Delete a campaign
  Future<Map<String, dynamic>> deleteCampaign(String campaignId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final adminId = prefs.getString('adminId');

      if (token == null || adminId == null) {
        return {'success': false, 'message': 'Admin authentication required'};
      }

      final response = await http.delete(
        Uri.parse('${Constants.baseUrl}/api/company-launch/$campaignId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Delete campaign response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'Campaign deleted successfully',
        };
      } else {
        String errorMessage = 'Failed to delete campaign';
        try {
          final data = jsonDecode(response.body);
          errorMessage = data['message'] ?? errorMessage;
        } catch (e) {
          // If JSON parsing fails, use the status code
          errorMessage = 'Server error: ${response.statusCode}';
        }
        
        return {
          'success': false,
          'message': errorMessage
        };
      }
    } catch (e) {
      debugPrint('Error deleting campaign: $e');
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  Future<List<dynamic>> getAvailableDrivers() async {
    try {
      // Get auth info
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final adminId = prefs.getString('adminId');

      if (token == null || adminId == null) {
        debugPrint('Authentication details missing');
        return [];
      }

      // IMPORTANT: Use the exact URL that matches backend
      final apiUrl =
          '${Constants.baseUrl}/api/admin/driver-campaign-management/available-drivers';
      debugPrint('Fetching available drivers from: $apiUrl');

      // Send the request with proper headers
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // Log the response for debugging
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body length: ${response.body.length}');

      // Parse the response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final drivers = data['data'] ?? [];
        debugPrint('Fetched ${drivers.length} available drivers');

        // Log sample driver data for debugging
        if (drivers.isNotEmpty) {
          debugPrint('Sample driver data: ${drivers[0]}');
        }

        return drivers;
      } else {
        // Handle error response
        String errorMsg = 'Failed to fetch drivers';

        try {
          final responseData = jsonDecode(response.body);
          if (responseData is Map) {
            errorMsg =
                responseData['message'] ?? responseData['error'] ?? errorMsg;
          }
        } catch (e) {
          errorMsg = 'Server error: HTTP ${response.statusCode}';
        }

        debugPrint('Failed to fetch drivers: $errorMsg');
        return [];
      }
    } catch (e) {
      // Provide detailed error diagnostics
      debugPrint('Error fetching drivers: $e');
      return [];
    }
  }
}
