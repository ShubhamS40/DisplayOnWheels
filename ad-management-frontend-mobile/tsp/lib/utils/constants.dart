import 'package:flutter/foundation.dart';

class Constants {
  // API Base URL - Use localhost for development and actual API for production
  static String get baseUrl => kIsWeb
      ? 'http://3.110.135.112:5000' // Web development URL
      : 'http://3.110.135.112:5000'; // Mobile development URL
  
  // Production URL - uncomment when deploying to production
  // static const String baseUrl = 'https://tsp-api-prod.com';
  
  // API Endpoints
  static const String uploadPosterEndpoint = '/api/uploads/poster';
  static const String campaignEndpoint = '/api/campaigns';
  static const String companyDocumentsEndpoint = '/api/company-docs';
  static const String driverDocumentsEndpoint = '/api/driver-docs';
  
  // Campaign API endpoints
  static const List<String> campaignCreateEndpoints = [
    '/api/company-launch/create-ad-campaign',
    '/api/company/campaigns/create',
    '/api/campaigns'
  ];
  
  // UI Colors
  static const int primaryColorValue = 0xFFFF5722; // Orange
  
  // Timeout values
  static const Duration apiTimeout = Duration(seconds: 60);
  static const Duration uploadTimeout = Duration(minutes: 2);
}
