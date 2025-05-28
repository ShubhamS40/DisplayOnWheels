import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimelineSection extends StatelessWidget {
  static const Color primaryOrange = Color(0xFFFF6B00);
  static const Color textColor = Color(0xFF2C3E50);

  const TimelineSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Journey',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 24),
          _buildTimelineItem(
            '2021',
            'Company Founded',
            'DisplayonWheels was established with a vision to revolutionize outdoor advertising.',
            true,
          ),
          _buildTimelineConnector(true),
          _buildTimelineItem(
            '2022',
            'First 100 Drivers',
            'Reached our first milestone of 100 drivers registered on the platform.',
            true,
          ),
          _buildTimelineConnector(true),
          _buildTimelineItem(
            '2023',
            'Mobile App Launch',
            'Launched our mobile application for both Android and iOS platforms.',
            true,
          ),
          _buildTimelineConnector(true),
          _buildTimelineItem(
            '2024',
            'Going National',
            'Expanded our services to multiple cities across the country.',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
      String year, String title, String description, bool isCompleted) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: isCompleted ? primaryOrange : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                year,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isCompleted ? textColor : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color:
                      isCompleted ? Colors.grey.shade700 : Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineConnector(bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: Container(
        width: 2,
        height: 30,
        color: isCompleted ? primaryOrange : Colors.grey.shade400,
      ),
    );
  }
}
