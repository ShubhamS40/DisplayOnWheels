import 'package:flutter/material.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/campaign_preview/components/campaign_header.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/campaign_preview/components/design_request_summary.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/campaign_preview/components/detail_row.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/campaign_preview/components/campaign_confirmation_dialog.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/campaign_preview/components/poster_preview.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/campaign_preview/components/pricing_summary.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/campaign_preview/components/section_card.dart';

class CampaignPreviewScreen extends StatelessWidget {
  final Map<String, dynamic> campaignDetails;

  const CampaignPreviewScreen({
    Key? key,
    required this.campaignDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final orangeColor = const Color(0xFFFF5722); // Primary orange color
    
    // Calculate total amount
    final totalAmount = ((campaignDetails['planPrice'] ?? 0) * (campaignDetails['carCount'] ?? 0) + 
                      (campaignDetails['needsPosterDesign'] == true ? (campaignDetails['posterDesignPrice'] ?? 0) : 0)).toInt();
    
    // Check if there's a poster
    final hasPoster = campaignDetails['posterFile'] != null || campaignDetails['posterBytes'] != null;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text('Campaign Preview'),
        elevation: 0,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Edit Campaign',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campaign Header
            CampaignHeader(
              campaignDetails: campaignDetails,
              onViewPoster: () => _showPosterPreview(context, isDarkMode, orangeColor),
              hasPoster: hasPoster,
              orangeColor: orangeColor,
            ),
            
            // Campaign Details Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: SectionCard(
                title: 'Campaign Details',
                icon: Icons.campaign,
                isDarkMode: isDarkMode,
                orangeColor: orangeColor,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DetailRow(
                      label: 'Campaign Title', 
                      value: campaignDetails['adTitle'] ?? 'Not specified',
                      isDarkMode: isDarkMode,
                    ),
                    DetailRow(
                      label: 'Vehicle Type', 
                      value: campaignDetails['vehicleType'] ?? 'Not specified',
                      isDarkMode: isDarkMode,
                    ),
                    DetailRow(
                      label: 'Plan', 
                      value: campaignDetails['selectedPlan'] ?? 'Not specified',
                      isDarkMode: isDarkMode,
                    ),
                    DetailRow(
                      label: 'Number of Vehicles', 
                      value: '${campaignDetails['carCount'] ?? 0}',
                      isDarkMode: isDarkMode,
                    ),
                    DetailRow(
                      label: 'Target Location', 
                      value: campaignDetails['targetLocation'] ?? 'Not specified',
                      isDarkMode: isDarkMode,
                    ),
                  ],
                ),
              ),
            ),
            
            // Poster Section - Show either uploaded poster or design request info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: SectionCard(
                title: 'Advertisement Poster',
                icon: Icons.image,
                isDarkMode: isDarkMode,
                orangeColor: orangeColor,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Use a conditional approach to render the correct content
                    Builder(builder: (context) {
                      // Show poster design request info if requested
                      if (campaignDetails['needsPosterDesign'] == true) {
                        return DesignRequestSummary(
                          campaignDetails: campaignDetails, 
                          isDarkMode: isDarkMode, 
                          orangeColor: orangeColor
                        );
                      } 
                      // Show uploaded poster preview if available
                      else if (hasPoster) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Poster preview
                            GestureDetector(
                              onTap: () => _showPosterPreview(context, isDarkMode, orangeColor),
                              child: Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: isDarkMode ? Colors.grey[900] : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: PosterPreview(
                                  fileInput: campaignDetails['posterFile'],
                                  bytesInput: campaignDetails['posterBytes'],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Poster info
                            DetailRow(
                              label: 'Poster Size', 
                              value: campaignDetails['posterSize'] ?? 'A3',
                              isDarkMode: isDarkMode,
                            ),
                          ],
                        );
                      } else {
                        return const SizedBox.shrink(); // Empty widget if no poster
                      }
                    }),
                  ],
                ),
              ),
            ),
            
            // Pricing Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: SectionCard(
                title: 'Pricing Summary',
                icon: Icons.attach_money,
                isDarkMode: isDarkMode,
                orangeColor: orangeColor,
                content: PricingSummary(
                  campaignDetails: campaignDetails,
                  isDarkMode: isDarkMode,
                  orangeColor: orangeColor,
                ),
              ),
            ),
            
            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: orangeColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // Show confirmation dialog
                  showDialog(
                    context: context,
                    builder: (context) => CampaignConfirmationDialog(
                      campaignDetails: campaignDetails,
                      isDarkMode: isDarkMode,
                      orangeColor: orangeColor,
                      totalAmount: totalAmount,
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Submit Campaign',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.check_circle_outline),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPosterPreview(BuildContext context, bool isDarkMode, Color orangeColor) {
    showDialog(
      context: context,
      builder: (context) => PosterPreviewDialog(
        campaignDetails: campaignDetails,
        isDarkMode: isDarkMode,
        orangeColor: orangeColor,
      ),
    );
  }
}
