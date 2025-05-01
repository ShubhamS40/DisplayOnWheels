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
                campaign['name'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
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
                '${campaign['startDate']} - ${campaign['endDate']}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Current State
            Row(
              children: [
                Icon(Icons.location_on, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Current State',
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
                campaign['state'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            
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
                campaign['carsCount'].toString(),
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
