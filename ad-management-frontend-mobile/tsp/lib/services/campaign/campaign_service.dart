import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:tsp/utils/constants.dart';
import 'package:dio/dio.dart' as dio;
import 'package:intl/intl.dart';

// Import the constants from the constants file
import 'package:tsp/utils/constants.dart' as app_constants;

// Campaign service-specific constants
class CampaignServiceConfig {
  // Alternative production endpoint if main one fails
  static const String fallbackBaseUrl = 'https://tsp-api.herokuapp.com';

  // Primary API endpoint
  static const String primaryBaseUrl = 'https://tsp-api-prod.com';

  // Use this to debug CORS issues
  static bool enableDetailedNetworkLogs = true;
}

class CampaignService {
  static final CampaignService _instance = CampaignService._internal();
  factory CampaignService() => _instance;
  CampaignService._internal();

  // Fetch company campaigns from dashboard API
  Future<Map<String, dynamic>> fetchCompanyCampaigns() async {
    try {
      // Get auth info
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final companyId = prefs.getString('companyId');

      if (token == null || companyId == null) {
        debugPrint('Authentication or Company ID not found');
        return {
          'success': false,
          'message': 'Authentication or Company ID not found',
          'campaigns': []
        };
      }

      // Fetch campaigns from the API
      final apiUrl =
          '${Constants.baseUrl}/api/company-dashboard/company/$companyId/campaigns';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);

        // Process campaigns by status
        final List<Map<String, dynamic>> activeCampaigns = [];
        final List<Map<String, dynamic>> pendingCampaigns = [];
        final List<Map<String, dynamic>> completedCampaigns = [];

        final now = DateTime.now();

        for (var campaign in responseData) {
          // Convert campaign to consistent format with required fields
          final Map<String, dynamic> formattedCampaign = {
            'id': campaign['id'] ?? '',
            'name': campaign['name'] ?? '',
            'description': campaign['description'] ?? '',
            'startDate': campaign['startDate'],
            'endDate': campaign['endDate'],
            'posterUrl': _normalizePosterUrl(campaign['posterUrl'] ?? ''),
            'approvalStatus': campaign['approvalStatus'] ?? 'PENDING',
            'carsCount': campaign['carsCount'] ?? 0,
            'state': 'N/A', // Default
            'validity': 0, // Will be calculated
            'planName': campaign['planName'] ?? '',
          };

          // Calculate remaining days if dates are available
          if (campaign['startDate'] != null && campaign['endDate'] != null) {
            try {
              // Try to parse dates if they're not null
              DateTime? startDate;
              DateTime? endDate;

              if (campaign['startDate'] is String) {
                startDate = DateTime.tryParse(campaign['startDate']);
              }

              if (campaign['endDate'] is String) {
                endDate = DateTime.tryParse(campaign['endDate']);
              }

              if (startDate != null && endDate != null) {
                // Calculate validity in days
                final difference = endDate.difference(now).inDays;
                formattedCampaign['validity'] = difference > 0 ? difference : 0;

                // Format dates for display
                final dateFormat = DateFormat('dd/MM/yyyy');
                formattedCampaign['startDate'] = dateFormat.format(startDate);
                formattedCampaign['endDate'] = dateFormat.format(endDate);
              }
            } catch (e) {
              debugPrint('Error parsing dates: $e');
            }
          }

          // Add campaign to appropriate list based on status
          if (formattedCampaign['approvalStatus'] == 'APPROVED') {
            activeCampaigns.add(formattedCampaign);
          } else if (formattedCampaign['approvalStatus'] == 'PENDING') {
            pendingCampaigns.add(formattedCampaign);
          } else {
            completedCampaigns.add(formattedCampaign);
          }
        }

        return {
          'success': true,
          'message': 'Campaigns fetched successfully',
          'activeCampaigns': activeCampaigns,
          'pendingCampaigns': pendingCampaigns,
          'completedCampaigns': completedCampaigns,
        };
      } else {
        // Handle error response
        String errorMsg = 'Failed to fetch campaigns';

        try {
          final responseData = jsonDecode(response.body);
          if (responseData is Map) {
            errorMsg =
                responseData['message'] ?? responseData['error'] ?? errorMsg;
          }
        } catch (e) {
          errorMsg = 'Server error: HTTP ${response.statusCode}';
        }

        debugPrint('Failed to fetch campaigns: $errorMsg');
        return {
          'success': false,
          'message': errorMsg,
          'activeCampaigns': [],
          'pendingCampaigns': [],
          'completedCampaigns': [],
        };
      }
    } catch (e) {
      // Provide detailed error diagnostics
      debugPrint('Error fetching campaigns: $e');
      return {
        'success': false,
        'message': 'Error: $e',
        'activeCampaigns': [],
        'pendingCampaigns': [],
        'completedCampaigns': [],
      };
    }
  }

  // Create campaign using HTTP directly to match Postman exactly
  Future<Map<String, dynamic>> launchCampaign({
    required Map<String, dynamic> campaignData,
    String? paymentId,
    Function(double)? onProgressUpdate,
  }) async {
    try {
      // Get auth info
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final companyId = prefs.getString('companyId');

      if (token == null || companyId == null) {
        debugPrint('Authentication or Company ID not found');
        return {
          'success': false,
          'message': 'Authentication or Company ID not found'
        };
      }

      // Handle planId with better fallback logic
      // Always ensure we have a valid plan ID (minimum 1)
      final dynamic rawPlanId = campaignData['planId'];
      final int planId;

      if (rawPlanId != null) {
        // Convert to int if it's a string
        if (rawPlanId is String) {
          planId = int.tryParse(rawPlanId) ?? 4;
        } else {
          planId = rawPlanId as int;
        }
      } else {
        // Use fallback logic
        planId = _extractPlanId(campaignData['selectedPlan']) ?? 4;
      }

      // Always default to plan ID 4 if plan is not valid
      final validPlanId = (planId < 1 || planId > 10) ? 4 : planId;
      debugPrint('Using plan ID: $validPlanId');

      // Calculate total with null safety
      final carCount = campaignData['carCount'] ?? 0;
      final planPrice = campaignData['planPrice'] ?? 0;
      final designNeeded = campaignData['needsPosterDesign'] == true;
      final designPrice =
          designNeeded ? (campaignData['posterDesignPrice'] ?? 5000) : 0;
      final totalAmount = ((planPrice * carCount) + designPrice).toInt();
      debugPrint('Total amount calculated: $totalAmount');

      // IMPORTANT: Use the exact URL that works in Postman
      final apiUrl =
          '${Constants.baseUrl}/api/company-launch/create-add-campaign';

      // Try direct HTTP approach first since that's what works in Postman
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Add authorization header like Postman
      if (token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add all fields exactly as they appear in Postman
      request.fields['companyId'] = companyId;
      request.fields['planId'] = validPlanId.toString();
      request.fields['title'] = campaignData['adTitle'] ?? 'Campaign';
      request.fields['description'] = campaignData['adDescription'] ??
          campaignData['adTitle'] ??
          'Campaign';
      request.fields['targetLocation'] = campaignData['targetLocation'] ?? '';
      request.fields['vehicleCount'] = carCount.toString();
      request.fields['vehicleType'] = campaignData['vehicleType'] ?? 'Standard';
      request.fields['totalAmount'] = totalAmount.toString();
      request.fields['posterSize'] = campaignData['posterSize'] ?? 'A3';
      request.fields['posterDesignPrice'] = designPrice.toString();
      request.fields['posterDesignNeeded'] = designNeeded ? 'true' : 'false';

      // Log the fields for debugging
      debugPrint('Request fields:');
      request.fields.forEach((key, value) {
        debugPrint('  $key: $value');
      });

      // Handle poster file upload
      if (campaignData['needsPosterDesign'] != true) {
        if (kIsWeb && campaignData['posterBytes'] != null) {
          // Web implementation
          final bytes = campaignData['posterBytes'] as Uint8List;
          final fileName = campaignData['posterFileName'] ?? 'poster.png';
          final extension = fileName.split('.').last.toLowerCase();

          debugPrint('Adding web poster file: $fileName');
          request.files.add(
            http.MultipartFile.fromBytes(
              'posterFile',
              bytes,
              filename: fileName,
              contentType: MediaType('image', extension),
            ),
          );
        } else if (!kIsWeb && campaignData['posterFile'] != null) {
          // Mobile implementation
          final File file = campaignData['posterFile'];
          final String fileName = path.basename(file.path);
          final String extension =
              path.extension(file.path).replaceAll('.', '');

          debugPrint('Adding mobile poster file: $fileName');
          request.files.add(
            await http.MultipartFile.fromPath(
              'posterFile',
              file.path,
              contentType: MediaType('image', extension),
            ),
          );
        }
      }

      // Log the files for debugging
      debugPrint('Request files:');
      for (var file in request.files) {
        debugPrint('  ${file.field}: ${file.filename}');
      }

      // Send the request and track progress
      final streamedResponse = await request.send();

      // Convert to a regular response
      final response = await http.Response.fromStream(streamedResponse);

      // Parse the response
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      // Handling success
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData is Map && responseData.containsKey('posterUrl')) {
          responseData['posterUrl'] = _normalizePosterUrl(responseData['posterUrl'] ?? '');
        }
        debugPrint('Campaign created successfully: $responseData');
        return {
          'success': true,
          'message': 'Campaign created successfully',
          'data': responseData
        };
      } else {
        // Handle error response
        String errorMsg = 'Failed to create campaign';

        try {
          final responseData = jsonDecode(response.body);
          if (responseData is Map) {
            errorMsg =
                responseData['message'] ?? responseData['error'] ?? errorMsg;
          }
        } catch (e) {
          errorMsg = 'Server error: HTTP ${response.statusCode}';
        }

        debugPrint('Failed to create campaign: $errorMsg');
        return {'success': false, 'message': errorMsg};
      }
    } catch (e) {
      // Provide detailed error diagnostics
      debugPrint('Error creating campaign: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<String?> _uploadPosterFile({
    File? file,
    Uint8List? bytes,
    required String token,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${app_constants.Constants.baseUrl}/api/uploads/poster'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      if (file != null) {
        var fileExtension = path.extension(file.path).replaceAll('.', '');
        request.files.add(await http.MultipartFile.fromPath(
          'poster',
          file.path,
          contentType: MediaType('image', fileExtension),
        ));
      } else if (bytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'poster',
          bytes,
          filename: 'poster.jpg',
          contentType: MediaType('image', 'jpeg'),
        ));
      } else {
        return null;
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(responseData);
        return data['fileUrl'];
      } else {
        debugPrint(
            'File upload failed (${response.statusCode}): $responseData');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    }
  }

  // Helper method to normalize poster URLs by removing localhost prefix
  String _normalizePosterUrl(String url) {
    // Remove the localhost prefix if present
    if (url.contains('http://localhost:5000/uploads/posters/')) {
      // Extract just the filename part
      final filename = url.split('/').last;
      // If we have a valid S3 URL in the system, use that format
      if (filename.isNotEmpty) {
        return 'https://displayonwheel.s3.ap-south-1.amazonaws.com/campaigns/posters/$filename';
      }
    }
    return url;
  }

  int? _extractPlanId(String? planName) {
    if (planName == null) return 4; // Default to plan ID 4 if null
    switch (planName.toLowerCase()) {
      case 'basic':
        return 1;
      case 'standard':
        return 2;
      case 'premium':
        return 3;
      default:
        return 4; // Default to plan ID 4 for unknown plan names
    }
  }

  Future<List<dynamic>> getCompanyCampaigns() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final companyId = prefs.getString('companyId');

      if (token == null || companyId == null) {
        debugPrint('Token or Company ID missing');
        return [];
      }

      final response = await http.get(
        Uri.parse(
            '${app_constants.Constants.baseUrl}/api/company-dashboard/company/$companyId/campaigns'),
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
}
