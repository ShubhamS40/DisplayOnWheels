import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'feature_card.dart';
import 'process_section.dart';

class FeaturesTab extends StatelessWidget {
  static const Color textColor = Color(0xFF2C3E50);
  static const Color primaryOrange = Color(0xFFFF5722);

  const FeaturesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Features',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'DisplayonWheels offers a comprehensive suite of features designed to maximize advertising impact and driver earnings.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          _buildFeatureGrid(),
          const SizedBox(height: 32),
          const ProcessSection(),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 0.85,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: const [
        FeatureCard(
          title: 'GPS Tracking',
          icon: Icons.location_on,
          description: 'Real-time location tracking to optimize ad visibility',
        ),
        FeatureCard(
          title: 'Proof of Display',
          icon: Icons.camera_alt,
          description: 'Easily upload photos as proof of advertisement display',
        ),
        FeatureCard(
          title: 'Earnings Reports',
          icon: Icons.bar_chart,
          description: 'Detailed reports of your earnings and performance',
        ),
        FeatureCard(
          title: 'Route Optimization',
          icon: Icons.route,
          description: 'Suggestions for optimal routes to maximize visibility',
        ),
      ],
    );
  }
}
