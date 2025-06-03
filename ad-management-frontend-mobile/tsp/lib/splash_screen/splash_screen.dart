import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tsp/screens/auth/role_selection.dart';
import 'package:video_player/video_player.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show kIsWeb;

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
  void _navigateToRoleSelection() {
    // Prevent multiple navigations
    if (!mounted || _hasNavigated) return;

    _hasNavigated = true;
    developer.log('Navigating to role selection screen');

    // Cancel fallback timer
    _fallbackTimer?.cancel();

    // Navigate to role selection screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
    );
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
