import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;

class MergedCompanyOnboardingScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const MergedCompanyOnboardingScreen({
    Key? key,
    this.onComplete,
  }) : super(key: key);

  @override
  State<MergedCompanyOnboardingScreen> createState() => _MergedCompanyOnboardingScreenState();
}

class _MergedCompanyOnboardingScreenState extends State<MergedCompanyOnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _carController;
  
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideUpAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _carAnimation;

  @override
  void initState() {
    super.initState();

    // Main fade and slide animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideUpAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Pulse animation for map marker
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Car movement animation
    _carController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _carAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0.0),
      end: const Offset(0.5, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _carController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations
    _fadeController.forward();
    _pulseController.repeat();
    _carController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _carController.dispose();
    super.dispose();
  }

  void _completeOnboarding() {
    // Call the original onComplete callback if provided
    if (widget.onComplete != null) {
      widget.onComplete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double imageSize = screenSize.width * 0.8;

    return Scaffold(
      backgroundColor: const Color(0xFFEA9E23), // Background color as requested
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Logo
              Image.asset(
                'assets/logo/dow.png',
                height: 100, // Increased from 60 to 100
              ),
              const SizedBox(height: 20),
              // Title
              FadeTransition(
                opacity: _fadeInAnimation,
                child: const Text(
                  'Display On Wheels',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              // Subtitle
              FadeTransition(
                opacity: _fadeInAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Advertise your business with mobile display ads and track them in real-time',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              // Display Ads Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FadeTransition(
                  opacity: _fadeInAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        // Display Ads Illustration
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Image.network(
                            'https://img.freepik.com/free-vector/mobile-marketing-concept-illustration_114360-1497.jpg',
                            height: 180,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Display Ads Features
                        ..._buildDisplayAdsFeatures(),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Live Tracking Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FadeTransition(
                  opacity: _fadeInAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        // Live Tracking Illustration with Animations
                        SizedBox(
                          height: 180,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Map background
                              Image.network(
                                'https://img.freepik.com/free-vector/city-map-with-global-positioning-system-navigation-location-route-planning-app-illustration_1284-53080.jpg',
                                height: 180,
                                fit: BoxFit.cover,
                              ),
                              
                              // Pulsing location marker
                              Positioned(
                                top: 60,
                                right: 100,
                                child: AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Outer pulse
                                        Container(
                                          width: 40 * (1 + _pulseController.value * 0.5),
                                          height: 40 * (1 + _pulseController.value * 0.5),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.3 * (1 - _pulseController.value)),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        // Inner pulse
                                        Container(
                                          width: 25 * (1 + _pulseController.value * 0.3),
                                          height: 25 * (1 + _pulseController.value * 0.3),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.5 * (1 - _pulseController.value)),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        // Center dot
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: const BoxDecoration(
                                            color: Colors.blue,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              
                              // Moving car
                              Positioned(
                                bottom: 40,
                                child: SlideTransition(
                                  position: _carAnimation,
                                  child: Transform.rotate(
                                    angle: 0.1, // Slight tilt
                                    child: const Icon(
                                      Icons.directions_car,
                                      color: Colors.black,
                                      size: 36,
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Live tracking indicator
                              Positioned(
                                top: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.fiber_manual_record,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Live Tracking',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Live Tracking Features
                        ..._buildTrackingFeatures(),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Get Started Button
              FadeTransition(
                opacity: _fadeInAnimation,
                child: GestureDetector(
                  onTap: _completeOnboarding,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'GET STARTED',
                          style: TextStyle(
                            color: Color(0xFFEA9E23),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 1.0,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(
                          Icons.arrow_forward,
                          color: Color(0xFFEA9E23),
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDisplayAdsFeatures() {
    final features = [
      {'icon': Icons.visibility, 'text': 'Increase brand visibility'},
      {'icon': Icons.location_on, 'text': 'Location-based targeting'},
      {'icon': Icons.bar_chart, 'text': 'Real-time analytics'},
    ];

    return features.map((feature) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                feature['icon'] as IconData,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                feature['text'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildTrackingFeatures() {
    final features = [
      {'icon': Icons.location_on, 'text': 'Real-time location tracking'},
      {'icon': Icons.speed, 'text': 'Speed and distance monitoring'},
      {'icon': Icons.notifications_active, 'text': 'Instant alerts and notifications'},
    ];

    return features.map((feature) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                feature['icon'] as IconData,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                feature['text'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}