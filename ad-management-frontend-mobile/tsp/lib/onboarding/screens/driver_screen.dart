import 'package:flutter/material.dart';
import '../widgets/onboarding_page.dart';

class DriverScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const DriverScreen({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      title: "FOR DRIVERS",
      subtitle:
          "Turn your daily commute into extra income by displaying ads on your vehicle and sharing proof photos.",
      imagePath: "assets/logo/Car.png",
      button: Column(
        children: [
          // Earnings callout
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.attach_money,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Earn Extra Income",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          decoration: TextDecoration.none, // no underline
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Get paid for ads on your vehicle",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          height: 1.2,
                          decoration: TextDecoration.none, // no underline
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // How it works
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                _buildStepItem("1", "Accept ad campaigns"),
                const SizedBox(height: 6),
                _buildStepItem("2", "Display ads on vehicle"),
                const SizedBox(height: 6),
                _buildStepItem("3", "Upload photos & location"),
                const SizedBox(height: 6),
                _buildStepItem("4", "Get paid to your account"),
              ],
            ),
          ),

          // Get Started button with animation
          GestureDetector(
            onTapDown: (_) => _controller.forward(),
            onTapUp: (_) => _controller.reverse(),
            onTapCancel: () => _controller.reverse(),
            onTap: widget.onComplete,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "GET STARTED",
                              style: TextStyle(
                                color: Color(0xFFE89C08),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                decoration: TextDecoration.none, // no underline
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Color(0xFFE89C08),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String number, String text) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: const Color(0xFFE89C08),
                fontWeight: FontWeight.bold,
                fontSize: 12,
                decoration: TextDecoration.none, // no underline
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            letterSpacing: 0.2,
            decoration: TextDecoration.none, // no underline
          ),
        ),
      ],
    );
  }
}
