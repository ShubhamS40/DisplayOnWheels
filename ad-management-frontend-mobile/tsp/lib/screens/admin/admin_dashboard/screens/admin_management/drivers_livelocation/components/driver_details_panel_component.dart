import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../model/driver_location_data.dart';

class DriverDetailsPanelComponent extends StatelessWidget {
  final DriverLocationData driver;
  final MapController mapController;
  final VoidCallback onClose;
  final Color primaryColor;

  const DriverDetailsPanelComponent({
    Key? key,
    required this.driver,
    required this.mapController,
    required this.onClose,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: primaryColor.withOpacity(0.2),
                backgroundImage: driver.profileImage != null &&
                        driver.profileImage!.isNotEmpty
                    ? NetworkImage(driver.profileImage!)
                    : null,
                child:
                    driver.profileImage == null || driver.profileImage!.isEmpty
                        ? Icon(Icons.person, color: primaryColor)
                        : null,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    if (driver.vehicleNumber != null)
                      Text(
                        driver.vehicleNumber!,
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: onClose,
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDriverInfoItem(
                  'Status',
                  driver.isActive ? 'Active' : 'Inactive',
                  icon: Icons.circle,
                  color: driver.isActive ? Colors.green : Colors.orange,
                ),
              ),
              Expanded(
                child: _buildDriverInfoItem(
                  'Last Update',
                  driver.lastUpdateAgo,
                  icon: Icons.update,
                ),
              ),
              if (driver.vehicleType != null)
                Expanded(
                  child: _buildDriverInfoItem(
                    'Vehicle Type',
                    driver.vehicleType!,
                    icon: Icons.time_to_leave,
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    mapController.move(
                      LatLng(driver.latitude, driver.longitude),
                      15.0,
                    );
                  },
                  icon: Icon(Icons.center_focus_strong, size: 16),
                  label: Text('Center on Map'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Implement call driver functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Calling ${driver.name}...')),
                    );
                  },
                  icon: Icon(Icons.phone, size: 16),
                  label: Text('Call Driver'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfoItem(String label, String value,
      {IconData? icon, Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: color ?? Colors.grey[600],
              ),
              SizedBox(width: 4),
            ],
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
