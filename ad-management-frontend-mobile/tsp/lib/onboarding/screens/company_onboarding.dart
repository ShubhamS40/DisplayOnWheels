import 'package:flutter/material.dart';
import 'package:tsp/screens/company/company_auth/company_login.dart';
import 'display_ads_screen.dart';
import 'tracking_screen.dart';

class CompanyOnboardingScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const CompanyOnboardingScreen({
    Key? key,
    this.onComplete,
  }) : super(key: key);

  @override
  State<CompanyOnboardingScreen> createState() => _CompanyOnboardingScreenState();
}

class _CompanyOnboardingScreenState extends State<CompanyOnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _indicatorController;
  late AnimationController _backgroundController;

  late Animation<Color?> _backgroundStartAnimation;
  late Animation<Color?> _backgroundEndAnimation;

  int _currentPage = 0;
  // Color theme based on the app's orange and blue theme
  final List<Color> _startGradientColors = [
    const Color(0xFF0D47A1), // Display Ads Screen - Blue
    const Color(0xFF2962FF), // Tracking Screen - Light Blue
  ];

  final List<Color> _endGradientColors = [
    const Color(0xFF1565C0), // Display Ads Screen - Medium blue
    const Color(0xFF448AFF), // Tracking Screen - Lighter blue
  ];

  @override
  void initState() {
    super.initState();

    _indicatorController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _updateGradientAnimation(0, 0);
  }

  void _updateGradientAnimation(int from, int to) {
    _backgroundStartAnimation = ColorTween(
      begin: _startGradientColors[from],
      end: _startGradientColors[to],
    ).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: Curves.easeInOut,
      ),
    );

    _backgroundEndAnimation = ColorTween(
      begin: _endGradientColors[from],
      end: _endGradientColors[to],
    ).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: Curves.easeInOut,
      ),
    );

    _backgroundController.reset();
    _backgroundController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _indicatorController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 1) { // We have 2 pages (index 0-1)
      final int nextPage = _currentPage + 1;
      _updateGradientAnimation(_currentPage, nextPage);

      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipToEnd() {
    _completeOnboarding();
  }

  void _completeOnboarding() {
    // Call the original onComplete callback if provided
    if (widget.onComplete != null) {
      widget.onComplete!();
    }

    // Navigate to company login screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => CompanyLogin()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _backgroundStartAnimation.value ??
                      _startGradientColors[_currentPage],
                  _backgroundEndAnimation.value ??
                      _endGradientColors[_currentPage],
                ],
              ),
            ),
            child: Stack(
              children: [
                PageView(
                  controller: _pageController,
                  physics: const ClampingScrollPhysics(),
                  onPageChanged: (index) {
                    if (!_backgroundController.isAnimating) {
                      _updateGradientAnimation(_currentPage, index);
                    }

                    setState(() {
                      _currentPage = index;
                    });

                    _indicatorController.reset();
                    _indicatorController.forward();
                  },
                  children: [
                    DisplayAdsScreen(onNext: _nextPage, onSkip: _skipToEnd),
                    TrackingScreen(onNext: _nextPage, onSkip: _skipToEnd),
                  ],
                ),
                // Custom page indicator
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < 2; i++) _buildPageIndicator(i),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageIndicator(int index) {
    bool isCurrentPage = _currentPage == index;

    return AnimatedBuilder(
      animation: _indicatorController,
      builder: (context, child) {
        double size = isCurrentPage
            ? 10.0 + (_indicatorController.value * 5.0)
            : index < _currentPage
                ? 10.0
                : 8.0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          height: size,
          width: isCurrentPage ? size * 2.5 : size,
          decoration: BoxDecoration(
            color: isCurrentPage
                ? const Color(0xFFE89C08)
                : index < _currentPage
                    ? const Color(0xFFE89C08).withOpacity(0.7)
                    : const Color(0xFFE89C08).withOpacity(0.3),
            borderRadius: BorderRadius.circular(isCurrentPage ? 12 : size / 2),
            boxShadow: isCurrentPage
                ? [
                    BoxShadow(
                      color: const Color(0xFFE89C08).withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        );
      },
    );
  }
}
