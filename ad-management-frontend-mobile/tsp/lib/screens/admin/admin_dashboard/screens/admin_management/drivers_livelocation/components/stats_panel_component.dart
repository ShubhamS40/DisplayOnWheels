import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatsPanelComponent extends StatelessWidget {
  final int totalDrivers;
  final int activeDrivers;
  final String lastUpdated;

  const StatsPanelComponent({
    Key? key,
    required this.totalDrivers,
    required this.activeDrivers,
    required this.lastUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.black.withOpacity(0.8)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Driver Stats',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          _buildStatRow('Total Drivers', totalDrivers.toString(), Icons.person),
          _buildStatRow(
            'Active Drivers', 
            activeDrivers.toString(), 
            Icons.directions_car,
            color: Colors.green
          ),
          _buildStatRow(
            'Inactive Drivers',
            (totalDrivers - activeDrivers).toString(),
            Icons.car_crash,
            color: Colors.orange
          ),
          _buildStatRow(
            'Last Updated', 
            lastUpdated, 
            Icons.update,
            showDivider: false
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon,
      {Color? color, bool showDivider = true}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: color ?? Colors.grey[600],
            ),
            SizedBox(width: 8),
            Text(
              '$label: ',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color ?? Colors.grey[800],
              ),
            ),
          ],
        ),
        if (showDivider) Divider(height: 8, thickness: 0.5),
      ],
    );
  }
}
