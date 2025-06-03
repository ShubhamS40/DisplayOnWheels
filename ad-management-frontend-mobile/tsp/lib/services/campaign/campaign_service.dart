import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:tsp/utils/constants.dart';
import 'package:dio/dio.dart' as dio;
import 'package:intl/intl.dart';
// Import the constants from the constants file
import 'package:tsp/utils/constants.dart' as app_constants;

// Import the rechargePlanIdProvider
import 'package:tsp/screens/company/company_launch_ad_campain/components/plan_selector_button.dart';

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
    WidgetRef? ref,
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

      // Get planId from StateProvider if ref is provided, otherwise use default
      int planId = 6; // Default fallback
      
      if (ref != null) {
        final planIdString = ref.read(rechargePlanIdProvider);
        if (planIdString != null && planIdString.isNotEmpty) {
          planId = int.tryParse(planIdString) ?? 6;
          debugPrint('Using plan ID from provider: $planId');
        } else {
          debugPrint('Plan ID not found in provider, using default: $planId');
        }
      } else {
        debugPrint('WidgetRef not provided, using default plan ID: $planId');
      }

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
      request.fields['planId'] = planId.toString(); // Hardcoded to 6
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
          responseData['posterUrl'] =
              _normalizePosterUrl(responseData['posterUrl'] ?? '');
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
    // Always return 6 regardless of the plan name
    return 6;
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

  /// Uploads an advertisement proof photo for a driver campaign
  ///
  /// [campaignDriverId] - The ID of the campaign driver assignment
  /// [photoFile] - The photo file to upload (for mobile platforms)
  /// [photoBytes] - The photo bytes to upload (for web platform)
  /// [onProgress] - Optional callback for upload progress
  Future<Map<String, dynamic>> uploadAdvertisementProofPhoto({
    required String campaignDriverId,
    File? photoFile,
    Uint8List? photoBytes,
    Function(double)? onProgress,
  }) async {
    try {
      // Get authentication token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final driverId = prefs.getString('driverId');

      if (token == null || driverId == null) {
        debugPrint('Authentication failed: Token or Driver ID missing');
        return {
          'success': false,
          'message': 'Authentication failed. Please login again.'
        };
      }

      // Create multipart request
      final uri = Uri.parse(
          '${Constants.baseUrl}/api/driver-campaign/upload-advertisement-proof-photo/$campaignDriverId');
      print("Shubham SIngh ${campaignDriverId}");
      debugPrint('Uploading photo to: $uri');

      var request = http.MultipartRequest('POST', uri);

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add photo to the request based on platform
      if (photoFile != null) {
        // For mobile platforms, use File
        final fileExtension =
            path.extension(photoFile.path).replaceAll('.', '');
        request.files.add(await http.MultipartFile.fromPath(
          'photo', // Field name must match the API expectation
          photoFile.path,
          contentType: MediaType('image', fileExtension),
        ));
      } else if (photoBytes != null) {
        // For web platform, use bytes
        request.files.add(http.MultipartFile.fromBytes(
          'photo',
          photoBytes,
          filename: 'photo.jpg',
          contentType: MediaType('image', 'jpeg'),
        ));
      } else {
        return {'success': false, 'message': 'No photo provided'};
      }

      // Send the request and get the response
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Proof photo uploaded successfully',
          'photoUrl': responseData['photoUrl'] ?? '',
          'data': responseData
        };
      } else {
        // Parse error response
        String errorMessage = 'Failed to upload photo';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage =
              errorData['message'] ?? errorData['error'] ?? errorMessage;
        } catch (e) {
          errorMessage = 'Server error: HTTP ${response.statusCode}';
        }

        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      debugPrint('Error uploading advertisement proof photo: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
