import 'package:flutter/material.dart';

class CampaignDetailsCard extends StatelessWidget {
  final Map<String, dynamic> campaign;
  final bool isDarkMode;

  const CampaignDetailsCard({
    Key? key,
    required this.campaign,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final iconColor = const Color(0xFFFF5722);
    
    // Determine approval status style
    IconData statusIcon;
    Color statusColor;
    String statusText;
    
    final status = campaign['approvalStatus'] ?? 'PENDING';
    switch (status) {
      case 'APPROVED':
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        statusText = 'Approved';
        break;
      case 'PENDING':
        statusIcon = Icons.pending;
        statusColor = Colors.orange;
        statusText = 'Pending Approval';
        break;
      case 'REJECTED':
        statusIcon = Icons.cancel;
        statusColor = Colors.red;
        statusText = 'Rejected';
        break;
      default:
        statusIcon = Icons.help;
        statusColor = Colors.grey;
        statusText = 'Unknown Status';
    }
    
    // Handle null dates
    String dateRangeText = 'Not set';
    if (campaign['startDate'] != null && campaign['endDate'] != null) {
      dateRangeText = '${campaign['startDate']} - ${campaign['endDate']}';
    }
    
    // Calculate remaining days
    String validityText = 'Validity unknown';
    if (campaign['validity'] != null) {
      final days = campaign['validity'];
      validityText = '$days days remaining';
    }
    
    return Card(
      elevation: 3,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Approval Status
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Campaign Name
            Row(
              children: [
                Icon(Icons.campaign, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Campaign Name',
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Text(
                campaign['name'] ?? 'Unnamed Campaign',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Campaign Plan
            if (campaign['planName'] != null && campaign['planName'].toString().isNotEmpty) ...[              
              Row(
                children: [
                  Icon(Icons.stars, color: iconColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Plan',
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: Text(
                  campaign['planName'] ?? 'Standard Plan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
            
            // Start & End Date
            Row(
              children: [
                Icon(Icons.date_range, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Start & End Date',
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Text(
                dateRangeText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            
            // Validity Days
            if (campaign['validity'] != null) ...[              
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: Text(
                  validityText,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Number of Cars
            Row(
              children: [
                Icon(Icons.directions_car, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'No. of Cars Running the Ad',
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Text(
                (campaign['carsCount'] ?? 0).toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
