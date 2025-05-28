import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'contact_header.dart';
import 'contact_options.dart';
import 'contact_form.dart';
import 'social_media_links.dart';
import 'map_section.dart';

class ContactTab extends StatelessWidget {
  static const Color textColor = Color(0xFF2C3E50);

  const ContactTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Us',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Have questions or want to join our platform? Reach out to us through any of the channels below.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          const ContactHeader(),
          const SizedBox(height: 24),
          const ContactOptions(),
          const SizedBox(height: 32),
          const ContactForm(),
          const SizedBox(height: 32),
          const SocialMediaLinks(),
          const SizedBox(height: 32),
          const MapSection(),
        ],
      ),
    );
  }
}
