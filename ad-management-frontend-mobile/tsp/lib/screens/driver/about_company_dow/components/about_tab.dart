import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'info_card.dart';
import 'timeline_section.dart';

class AboutTab extends StatelessWidget {
  static const Color textColor = Color(0xFF2C3E50);
  static const Color primaryOrange = Color(0xFFFF6B00);

  const AboutTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About DisplayonWheels',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'DisplayonWheels is a revolutionary mobile advertising platform that transforms vehicles into moving billboards, creating impactful advertising opportunities for businesses of all sizes.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          InfoCard(
            title: 'Our Mission',
            subtitle: 'Transforming Advertising',
            description: 'To revolutionize outdoor advertising by leveraging existing traffic flows and providing affordable, measurable advertising opportunities for businesses while creating additional income for drivers.',
            icon: Icons.rocket_launch,
          ),
          const SizedBox(height: 24),
          const TimelineSection(),
        ],
      ),
    );
  }
}
