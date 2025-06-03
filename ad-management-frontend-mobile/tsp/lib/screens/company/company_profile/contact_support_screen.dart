import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({Key? key}) : super(key: key);

  static const Color primaryOrange = Color(0xFFFF5722);
  static const Color textColor = Color(0xFF2C3E50);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contact Support',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : textColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: primaryOrange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.support_agent,
                      size: 40,
                      color: primaryOrange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'DisplayOnWheels Support',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We\'re here to help',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Contact Information
            _buildCard(
              context: context,
              title: 'Contact Information',
              isDarkMode: isDarkMode,
              children: [
                _buildContactItem(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  subtitle: 'support@displayonwheels.com',
                  onTap: () => _launchUrl('mailto:support@displayonwheels.com'),
                ),
                const Divider(),
                _buildContactItem(
                  icon: Icons.phone_outlined,
                  title: 'Phone',
                  subtitle: '+91 1234567890',
                  onTap: () => _launchUrl('tel:+911234567890'),
                ),
                const Divider(),
                _buildContactItem(
                  icon: Icons.language_outlined,
                  title: 'Website',
                  subtitle: 'www.displayonwheels.com',
                  onTap: () => _launchUrl('https://www.displayonwheels.com'),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Office Hours
            _buildCard(
              context: context,
              title: 'Office Hours',
              isDarkMode: isDarkMode,
              children: [
                _buildInfoItem(
                  icon: Icons.access_time,
                  title: 'Monday - Friday',
                  subtitle: '9:00 AM - 6:00 PM IST',
                ),
                const Divider(),
                _buildInfoItem(
                  icon: Icons.weekend_outlined,
                  title: 'Saturday',
                  subtitle: '10:00 AM - 2:00 PM IST',
                ),
                const Divider(),
                _buildInfoItem(
                  icon: Icons.event_busy,
                  title: 'Sunday',
                  subtitle: 'Closed',
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // FAQs
            _buildCard(
              context: context,
              title: 'Frequently Asked Questions',
              isDarkMode: isDarkMode,
              children: [
                _buildFaqItem(
                  context: context,
                  question: 'How do I start a new ad campaign?',
                  answer: 'You can start a new ad campaign by going to the Campaigns tab and clicking on the "Create New Campaign" button. Follow the steps to set up your campaign details, target audience, budget, and ad creative.',
                ),
                const Divider(),
                _buildFaqItem(
                  context: context,
                  question: 'How are the ad charges calculated?',
                  answer: 'Ad charges are calculated based on the number of vehicles, campaign duration, and the type of ad display chosen. The system will provide you with a detailed breakdown of costs before you confirm your campaign.',
                ),
                const Divider(),
                _buildFaqItem(
                  context: context,
                  question: 'What documents are required for verification?',
                  answer: 'For company verification, you need to provide business registration documents, GST registration certificate, and PAN card. These documents help us verify your business identity and ensure compliance with regulations.',
                ),
                const Divider(),
                _buildFaqItem(
                  context: context,
                  question: 'How can I track my campaign performance?',
                  answer: 'You can track your campaign performance in real-time through the Analytics tab. It provides metrics such as impressions, reach, engagement, and conversion rates to help you measure the effectiveness of your campaigns.',
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Submit a Ticket
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Submit a Support Ticket',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Need more help? Submit a support ticket and our team will get back to you within 24 hours.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement ticket submission form
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Support ticket submission coming soon'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Submit a Ticket',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required bool isDarkMode,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : textColor,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Function() onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: primaryOrange, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: primaryOrange, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem({
    required BuildContext context,
    required String question,
    required String answer,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        childrenPadding: const EdgeInsets.only(bottom: 12),
        title: Text(
          question,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Text(
            answer,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
