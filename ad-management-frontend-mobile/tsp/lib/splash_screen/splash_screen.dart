import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tsp/screens/auth/role_selection.dart';
import 'package:tsp/screens/driver/driver_document/documentUpload.dart';
import 'package:video_player/video_player.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsp/screens/driver/driver_main_screen.dart';
import 'package:tsp/screens/company/company_main_screen/company_main_screen.dart';
import 'package:tsp/screens/admin/admin_dashboard/admin_dashboard_screen.dart';
import 'package:http/http.dart' as http;
import 'package:tsp/screens/driver/driver_document/documentVerification_Stage.dart';
import 'package:tsp/screens/company/company_document/company_verification_stage.dart';
import 'package:tsp/screens/company/company_document/company_upload_documents.dart';

// We'll use a different approach to handle JS functionality

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  // Fallback timer to ensure navigation happens even if video fails
  Timer? _fallbackTimer;
  bool _hasNavigated = false; // Flag to prevent multiple navigations

  @override
  void initState() {
    super.initState();

    // Debug platform information
    if (kIsWeb) {
      developer.log('Running on Web platform');
      // Web-specific logging without using dart:js
      developer.log('Web platform detected - optimizing for web playback');
    } else {
      developer.log('Running on mobile platform');
    }

    // Set a fallback timer to ensure we navigate even if video fails
    // Use longer timeout for web platform
    int fallbackSeconds = kIsWeb ? 12 : 5;
    developer.log('Setting fallback timer for $fallbackSeconds seconds');
    _fallbackTimer = Timer(Duration(seconds: fallbackSeconds), () {
      developer.log('Fallback timer triggered - navigating to role selection');
      _navigateToRoleSelection();
    });

    // Initialize video controller with error handling
    developer.log('Initializing video controller for assets/splash_screen.mp4');
    _videoController = VideoPlayerController.asset('assets/splash_screen.mp4');

    // Add additional web-specific logging
    if (kIsWeb) {
      developer.log('Using web-specific video configuration');
      // For web, we'll set additional properties on the video controller
      _videoController.setVolume(0); // Ensure video is muted on web
      developer.log('Set video to autoplay and muted for web platform');
    }

    _videoController.initialize().then((_) {
      if (!mounted) return;

      developer.log('Video initialized successfully');
      // Cancel fallback timer if video initializes successfully
      _fallbackTimer?.cancel();

      setState(() {
        _isVideoInitialized = true;
      });

      // Set video to loop in case the listener doesn't trigger properly
      _videoController.setLooping(false);

      // Start playing the video with error handling
      try {
        _videoController.play().then((_) {
          developer.log('Video play command succeeded');
        }).catchError((error) {
          developer.log('Video play command failed: $error');
          // If play fails, we'll rely on the fallback timer
        });
      } catch (e) {
        developer.log('Exception when trying to play video: $e');
      }

      developer.log(
          'Video started playing with duration: ${_videoController.value.duration.inSeconds} seconds');

      // For web, add additional logging
      if (kIsWeb) {
        developer.log('Video initialized on web platform');
        developer.log(
            'Video properties: isPlaying=${_videoController.value.isPlaying}, '
            'isLooping=${_videoController.value.isLooping}, '
            'volume=${_videoController.value.volume}');
      }

      // Navigate to role selection screen when video completes
      _videoController.addListener(_videoListener);
    }).catchError((error) {
      developer.log('Error initializing video: $error', error: error);
      // If video fails to initialize, we'll rely on the fallback timer
    });
  }

  // Method to handle navigation to role selection screen
  void _navigateToRoleSelection() async {
    // Prevent multiple navigations
    if (!mounted || _hasNavigated) return;

    _hasNavigated = true;
    developer.log('Checking for existing login session');

    // Cancel fallback timer
    _fallbackTimer?.cancel();

    // Check for existing login tokens
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final driverId = prefs.getString('driverId');
    final companyId = prefs.getString('companyId');
    final adminId = prefs.getString('adminId');
    final userType = prefs.getString('userType');

    if (token != null && driverId != null) {
      // Driver is logged in, check document verification status
      developer.log('Found existing driver session, checking document status');
      await _checkDriverDocumentStatus(driverId, token);
    } else if (token != null && companyId != null) {
      // Company is logged in, check document verification status
      developer.log('Found existing company session, checking document status');
      await _checkCompanyDocumentStatus(companyId, token);
    } else if (token != null && adminId != null && userType == 'admin') {
      // Admin is logged in
      developer
          .log('Found existing admin session, redirecting to admin dashboard');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
      );
    } else {
      // No existing session, go to role selection
      developer.log('No existing session found, navigating to role selection');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
      );
    }
  }

  // Check driver document verification status
  Future<void> _checkDriverDocumentStatus(String driverId, String token) async {
    try {
      // First check if the driver has submitted documents
      final docsSubmittedResponse = await http.get(
        Uri.parse(
            'http://3.110.135.112:5000/api/driver/has-submitted-documents/$driverId'),
        headers: {"Content-Type": "application/json"},
      );

      final docsSubmittedData = json.decode(docsSubmittedResponse.body);
      final bool hasSubmittedDocs = docsSubmittedData['hasSubmitted'] ?? false;

      // If documents have not been submitted, route to document upload screen
      if (!hasSubmittedDocs) {
        developer.log(
            'Driver has not submitted documents, redirecting to document upload screen');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => DriverVerificationScreen(driverId: driverId),
          ),
        );
        return;
      }

      // If documents have been submitted, check verification status
      final docStatusResponse = await http.get(
        Uri.parse(
            'http://3.110.135.112:5000/api/driver/document-status/$driverId'),
        headers: {"Content-Type": "application/json"},
      );

      if (docStatusResponse.statusCode == 200) {
        final docStatusData = json.decode(docStatusResponse.body);
        final documents = docStatusData['documents'];

        // Check if all documents are approved
        final bool allApproved = documents['photoStatus'] == 'APPROVED' &&
            documents['idCardStatus'] == 'APPROVED' &&
            documents['drivingLicenseStatus'] == 'APPROVED' &&
            documents['vehicleImageStatus'] == 'APPROVED' &&
            documents['bankProofStatus'] == 'APPROVED';

        if (allApproved) {
          // All documents approved - navigate directly to driver dashboard
          developer.log(
              'All driver documents approved, redirecting to driver main screen');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => DriverMainScreen()),
          );
        } else {
          // Documents pending or rejected - show document status screen
          developer.log(
              'Some driver documents pending or rejected, redirecting to document status screen');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => DocumentStatusScreen()),
          );
        }
      } else {
        // Error getting document status, default to document status screen
        developer.log(
            'Error getting driver document status, redirecting to document status screen');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => DocumentStatusScreen()),
        );
      }
    } catch (e) {
      // If any errors, navigate to document status screen as fallback
      developer.log('Error checking driver document status: $e');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => DocumentStatusScreen()),
      );
    }
  }

  // Check company document verification status
  Future<void> _checkCompanyDocumentStatus(
      String companyId, String token) async {
    try {
      // First check if the company has submitted documents
      final docsSubmittedResponse = await http.get(
        Uri.parse(
            'http://3.110.135.112:5000/api/company-docs/has-submitted-documents/$companyId'),
        headers: {"Content-Type": "application/json"},
      );

      final docsSubmittedData = json.decode(docsSubmittedResponse.body);
      final bool hasSubmittedDocs = docsSubmittedData['hasSubmitted'] ?? false;

      // If documents have not been submitted, route to document upload screen
      if (!hasSubmittedDocs) {
        developer.log(
            'Company has not submitted documents, redirecting to document upload screen');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                CompanyDocumentUploadScreen(companyId: companyId),
          ),
        );
        return;
      }

      // If documents have been submitted, check verification status
      final docStatusResponse = await http.get(
        Uri.parse(
            'http://3.110.135.112:5000/api/company-docs/document-status/$companyId'),
        headers: {"Content-Type": "application/json"},
      );

      if (docStatusResponse.statusCode == 200) {
        final docStatusData = json.decode(docStatusResponse.body);
        final documents = docStatusData['documents'];

        // Check if all documents are approved
        final bool allApproved =
            documents['companyRegistrationStatus'] == 'APPROVED' &&
                documents['idCardStatus'] == 'APPROVED' &&
                documents['gstNumberStatus'] == 'APPROVED';

        if (allApproved) {
          // All documents approved - navigate directly to company dashboard
          developer.log(
              'All company documents approved, redirecting to company main screen');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const CompanyMainScreen()),
          );
        } else {
          // Documents pending or rejected - show document status screen
          developer.log(
              'Some company documents pending or rejected, redirecting to document status screen');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => CompanyDocumentStatusScreen()),
          );
        }
      } else {
        // Error getting document status, default to document status screen
        developer.log(
            'Error getting company document status, redirecting to document status screen');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => CompanyDocumentStatusScreen()),
        );
      }
    } catch (e) {
      // If any errors, navigate to document status screen as fallback
      developer.log('Error checking company document status: $e');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => CompanyDocumentStatusScreen(),
        ),
      );
    }
  }

  // Method to handle skip button press
  void _handleSkipButtonPress() {
    developer.log('Skip button pressed');
    _navigateToRoleSelection();
  }

  // Method to handle force play button press
  void _handleForcePlayButtonPress() {
    developer.log('Force play button pressed');
    try {
      _videoController.play().then((_) {
        developer.log('Manual play succeeded');
      }).catchError((error) {
        developer.log('Manual play failed: $error');
      });
    } catch (e) {
      developer.log('Exception during manual play: $e');
    }
  }

  void _videoListener() {
    // Check if video position is at or near the end
    if (_videoController.value.position >=
        _videoController.value.duration - const Duration(milliseconds: 300)) {
      if (mounted && !_videoController.value.isPlaying) {
        developer.log('Video completed - navigating to role selection');
        _navigateToRoleSelection();
      }
    }

    // For web, add more detailed logging
    if (kIsWeb && _videoController.value.position.inSeconds % 1 == 0) {
      developer.log(
          'Video position: ${_videoController.value.position.inSeconds}s / '
          '${_videoController.value.duration.inSeconds}s');

      // Log video state using Flutter's VideoPlayerValue
      developer
          .log('Video state: isPlaying=${_videoController.value.isPlaying}, '
              'isBuffering=${_videoController.value.isBuffering}, '
              'isLooping=${_videoController.value.isLooping}');
    }
  }

  @override
  void dispose() {
    // Clean up resources
    _videoController.dispose();
    _fallbackTimer?.cancel();
    developer.log('Disposed splash screen resources');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.black, // Black background for better video visibility
      body: Stack(
        children: [
          // Full screen video player when initialized
          if (_isVideoInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover, // Cover the entire screen as requested
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            ),

          // Loading indicator when not initialized
          if (!_isVideoInitialized)
            Container(
              color: const Color(
                  0xFFE89C08), // Keep original background color for loading
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/logo/dow.png',
                      width: 200,
                      height: 200,
                    ),
                    const SizedBox(height: 20),
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 20),
                    const Text(
                      'Loading splash screen...',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

          // Web-specific controls - only show on web platform
        ],
      ),
    );
  }
}

// No changes needed in this file since we've already initialized providers in main.dart
// The initializeProviders function in main.dart will handle loading IDs from SharedPreferences
// and updating the providers at app startup.
