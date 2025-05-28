import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProcessSection extends StatelessWidget {
  static const Color textColor = Color(0xFF2C3E50);
  static const Color primaryOrange = Color(0xFFFF6B00);

  const ProcessSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How It Works',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 20),
        _buildProcessStep(
          1, 
          'Sign Up & Profile Setup', 
          'Create your account and complete your driver profile with vehicle details.'
        ),
        const SizedBox(height: 24),
        _buildProcessStep(
          2, 
          'Vehicle Verification', 
          'Our team verifies your vehicle and approves your profile.'
        ),
        const SizedBox(height: 24),
        _buildProcessStep(
          3, 
          'Advertisement Assignment', 
          'Get assigned to advertising campaigns that match your driving routes.'
        ),
        const SizedBox(height: 24),
        _buildProcessStep(
          4, 
          'Drive & Earn', 
          'Complete your regular driving while displaying ads and earn money.'
        ),
      ],
    );
  }

  Widget _buildProcessStep(int step, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: primaryOrange,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: primaryOrange.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
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
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
