import 'package:flutter/material.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/components/theme_constants.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/campaign_preview_screen.dart';

class PreviewButton extends StatelessWidget {
  final Map<String, dynamic> adDetails;
  final bool isFormValid;

  const PreviewButton({
    Key? key,
    required this.adDetails,
    this.isFormValid = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      width: double.infinity,
      child: ElevatedButton(
        style: AdCampaignTheme.blackButtonStyle,
        onPressed: isFormValid 
            ? () => _navigateToPreview(context)
            : null,
        child: const Text(
          "Preview Ad",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void _navigateToPreview(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CampaignPreviewScreen(campaignDetails: adDetails),
      ),
    );
  }
}
