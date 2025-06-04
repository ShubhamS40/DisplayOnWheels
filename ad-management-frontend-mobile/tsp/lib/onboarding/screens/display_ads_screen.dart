import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DisplayAdsScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const DisplayAdsScreen({
    Key? key,
    required this.onNext,
    required this.onSkip,
  }) : super(key: key);

  @override// line 273 in CampaignConfirmationDialog._submitCampaign
  debugPrint('Sending campaign data: ${jsonEncode(campaignDetails)}');
  State<DisplayAdsScreen> createState() => _DisplayAdsScreenState();
}

class _DisplayAdsScreenState extends State<DisplayAdsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideUpAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideUpAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double imageSize = screenSize.width * 0.8;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            // Title
            FadeTransition(
              opacity: _fadeInAnimation,
              child: const Text(
                'Display Ads',
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
                  'Advertise your business with our mobile display ads',
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
            // Main image
            Expanded(
              flex: 5,
              child: FadeTransition(
                opacity: _fadeInAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: SvgPicture.asset(
                    'assets/images/onboarding/svg/display_ads.svg',
                    width: imageSize,
                    height: imageSize * 0.7,
                  ),
                ),
              ),
            ),
            // Features section
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    // Highlight box
                    FadeTransition(
                      opacity: _fadeInAnimation,
                      child: Transform.translate(
                        offset: Offset(0, _slideUpAnimation.value),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 24,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'For Companies',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    // Feature list
                    ..._buildFeatureItems(),
                  ],
                ),
              ),
            ),
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.only(bottom: 30, left: 30, right: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip button
                  FadeTransition(
                    opacity: _fadeInAnimation,
                    child: TextButton(
                      onPressed: widget.onSkip,
                      child: const Text(
                        'SKIP',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  // Next button
                  FadeTransition(
                    opacity: _fadeInAnimation,
                    child: _buildNextButton(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFeatureItems() {
    final features = [
      {'icon': Icons.visibility, 'text': 'Increase brand visibility'},
      {'icon': Icons.location_on, 'text': 'Location-based targeting'},
      {'icon': Icons.bar_chart, 'text': 'Real-time analytics'},
    ];

    return features.asMap().entries.map((entry) {
      final index = entry.key;
      final feature = entry.value;
      
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.4 + (index * 0.1),
            1.0,
            curve: Curves.easeOut,
          ),
        ),
        child: Transform.translate(
          offset: Offset(
            0,
            30 * (1 - CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                0.4 + (index * 0.1),
                1.0,
                curve: Curves.easeOut,
              ),
            ).value),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
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
          ),
        ),
      );
    }).toList();
  }

  Widget _buildNextButton() {
    return GestureDetector(
      onTap: widget.onNext,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
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
              'NEXT',
              style: TextStyle(
                color: Color(0xFF0D47A1),
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.arrow_forward,
              color: Color(0xFF0D47A1),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
