import 'package:flutter/material.dart';
import 'detail_row.dart';

class PricingSummary extends StatelessWidget {
  final Map<String, dynamic> campaignDetails;
  final bool isDarkMode;
  final Color orangeColor;

  const PricingSummary({
    Key? key,
    required this.campaignDetails,
    required this.isDarkMode,
    required this.orangeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DetailRow(
          label: 'Plan Price',
          value: 'Rs. ${(campaignDetails['planPrice'] ?? 0) * (campaignDetails['carCount'] ?? 0)}/-',
          isDarkMode: isDarkMode,
        ),
        DetailRow(
          label: 'Per Vehicle',
          value: 'Rs. ${campaignDetails['planPrice'] ?? 0}/-',
          isDarkMode: isDarkMode,
        ),
        DetailRow(
          label: 'Number of Vehicles',
          value: '${campaignDetails['carCount'] ?? 0}',
          isDarkMode: isDarkMode,
        ),
        
        // Show design fee if needed
        if (campaignDetails['needsPosterDesign'] == true) ...[
          const Divider(),
          DetailRow(
            label: 'Poster Design Fee',
            value: 'Rs. ${(campaignDetails['posterDesignPrice'] ?? 0).toInt()}/-',
            isDarkMode: isDarkMode,
          ),
          DetailRow(
            label: 'Design Size',
            value: campaignDetails['posterSize'] ?? 'A3',
            isDarkMode: isDarkMode,
          ),
        ],
        
        const Divider(),
        DetailRow(
          label: 'Total Amount',
          value: 'Rs. ${((campaignDetails['planPrice'] ?? 0) * (campaignDetails['carCount'] ?? 0) + 
             (campaignDetails['needsPosterDesign'] == true ? (campaignDetails['posterDesignPrice'] ?? 0) : 0)).toInt()}/-',
          isDarkMode: isDarkMode,
          valueColor: orangeColor,
          valueBold: true,
          valueFontSize: 18,
        ),
      ],
    );
  }
}
