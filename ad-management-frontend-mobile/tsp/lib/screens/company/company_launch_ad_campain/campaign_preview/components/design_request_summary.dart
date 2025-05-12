import 'package:flutter/material.dart';
import 'detail_row.dart';

class DesignRequestSummary extends StatelessWidget {
  final Map<String, dynamic> campaignDetails;
  final bool isDarkMode;
  final Color orangeColor;

  const DesignRequestSummary({
    Key? key,
    required this.campaignDetails,
    required this.isDarkMode,
    required this.orangeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: orangeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: orangeColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.design_services, color: orangeColor),
              const SizedBox(width: 8),
              Text(
                'Custom Design Request',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: orangeColor,
                ),
              ),
            ],
          ),
          const Divider(),
          // Poster details
          DetailRow(
            label: 'Poster Size',
            value: campaignDetails['posterSize'] ?? 'A3',
            isDarkMode: isDarkMode,
          ),
          if ((campaignDetails['posterTitle'] ?? '').isNotEmpty)
            DetailRow(
              label: 'Poster Title',
              value: campaignDetails['posterTitle'] ?? '',
              isDarkMode: isDarkMode,
            ),
          if ((campaignDetails['posterNotes'] ?? '').isNotEmpty) ...[
            DetailRow(
              label: 'Notes Length',
              value: '${(campaignDetails['posterNotes'] ?? '').split(RegExp(r'\\s+')).where((word) => word.isNotEmpty).length} words',
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 8),
            Text(
              'Notes Preview:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                ((campaignDetails['posterNotes'] ?? '') as String).length > 100
                    ? ((campaignDetails['posterNotes'] ?? '') as String).substring(0, 100) + '...'
                    : (campaignDetails['posterNotes'] ?? ''),
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          DetailRow(
            label: 'Design Fee',
            value: 'Rs. ${(campaignDetails['posterDesignPrice'] ?? 0).toInt()}/-',
            isDarkMode: isDarkMode,
            valueColor: orangeColor,
            valueBold: true,
          ),
        ],
      ),
    );
  }
}
