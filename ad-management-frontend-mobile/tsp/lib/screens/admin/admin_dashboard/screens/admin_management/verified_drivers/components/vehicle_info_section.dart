import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/driver_detail_model.dart';

class VehicleInfoSection extends StatelessWidget {
  final VehicleDetails vehicleDetails;
  
  const VehicleInfoSection({
    Key? key,
    required this.vehicleDetails,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.directions_car,
                  color: const Color(0xFFFF5722),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Vehicle Information',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildVehicleDetailItem(
                    title: 'Vehicle Type',
                    value: vehicleDetails.vehicleType,
                    icon: Icons.commute,
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildVehicleDetailItem(
                    title: 'Vehicle Number',
                    value: vehicleDetails.vehicleNumber,
                    icon: Icons.confirmation_number,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildVehicleDetailItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
