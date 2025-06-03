import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;

class OnboardingPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final Widget? button;
  final bool isWelcomeScreen;
  final Color? gradientStartColor;
  final Color? gradientEndColor;

  const OnboardingPage({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.button,
    this.isWelcomeScreen = false,
    this.gradientStartColor,
    this.gradientEndColor,
  }) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.03,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
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
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFE89C08), // Orange background as requested
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: widget.isWelcomeScreen
              ? _buildWelcomeScreen(context)
              : _buildRegularOnboardingPage(context),
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildImage(context),
                  ),
                ),
                const SizedBox(height: 32),
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          colors: [
                            const Color(0xFFFF5722),
                            const Color(0xFFE89C08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds);
                      },
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.button != null)
          FadeTransition(
            opacity: _fadeAnimation,
            child: widget.button!,
          ),
        const SizedBox(height: 16), // Reduced spacing
      ],
    );
  }

  Widget _buildRegularOnboardingPage(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        SizedBox(height: size.height * 0.02), // Reduced top padding
        SizedBox(
          height: size.height * 0.25, // Further reduced height
          child: Center(
            child: Transform.rotate(
              angle: math.sin(_animationController.value * math.pi * 2) *
                  _rotateAnimation.value,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildImage(context),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16), // Reduced spacing
        // Title
        SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 24, // Smaller font size
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 10), // Reduced spacing
        // Subtitle
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.3),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic),
            ),
          ),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: const Interval(0.4, 0.9, curve: Curves.easeIn),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20), // Reduced horizontal padding
              child: Text(
                widget.subtitle,
                style: const TextStyle(
                  fontSize: 14, // Smaller font size
                  color: Colors.white,
                  height: 1.3, // Reduced line height
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        Expanded(child: Container()), // Push button to bottom
        // Button
        if (widget.button != null)
          Padding(
            padding: EdgeInsets.only(bottom: size.height * 0.05),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
                ),
              ),
              child: widget.button!,
            ),
          ),
      ],
    );
  }

  Widget _buildImage(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Use 30% of screen height for image to ensure everything fits
    final double availableHeight = size.height * 0.5;
    final double maxWidth = size.width * 0.7;

    if (widget.imagePath.startsWith('data:image/svg+xml;base64,')) {
      // Handle base64 encoded SVG
      return SvgPicture.string(
        widget.imagePath.substring(widget.imagePath.indexOf(',') + 1),
        height: availableHeight,
        width: maxWidth,
        fit: BoxFit.contain,
      );
    } else if (widget.imagePath.endsWith('.svg')) {
      return SvgPicture.asset(
        widget.imagePath,
        height: availableHeight,
        width: maxWidth,
        fit: BoxFit.contain,
      );
    } else {
      return Image.asset(
        widget.imagePath,
        height: availableHeight,
        width: maxWidth,
        fit: BoxFit.contain,
      );
    }
  }
}
