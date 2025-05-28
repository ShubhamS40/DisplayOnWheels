import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SocialMediaLinks extends StatelessWidget {
  static const Color primaryOrange = Color(0xFFFF5722);
  static const Color textColor = Color(0xFF2C3E50);

  const SocialMediaLinks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Follow Us',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSocialButton(Icons.facebook, 'Facebook'),
            _buildSocialButton(Icons.camera_alt, 'Instagram'),
            _buildSocialButton(Icons.message, 'Twitter'),
            _buildSocialButton(Icons.work, 'LinkedIn'),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primaryOrange.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: primaryOrange,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
