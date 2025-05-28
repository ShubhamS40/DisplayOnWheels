import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../model/driver_detail_model.dart';

class BasicInfoSection extends StatelessWidget {
  final BasicDetails basicDetails;
  
  const BasicInfoSection({
    Key? key,
    required this.basicDetails,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Format the dates for better readability
    String formattedCreatedAt = 'N/A';
    try {
      final DateTime createdDate = DateTime.parse(basicDetails.createdAt);
      formattedCreatedAt = DateFormat('MMM d, yyyy').format(createdDate);
    } catch (e) {
      // Keep the default value if date parsing fails
    }
    
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
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFFFF5722).withOpacity(0.1),
                  backgroundImage: NetworkImage(
                    basicDetails.email.isNotEmpty
                        ? 'https://ui-avatars.com/api/?name=${basicDetails.fullName}&background=FF5722&color=fff&size=128'
                        : 'https://ui-avatars.com/api/?name=?&background=FF5722&color=fff&size=128',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        basicDetails.fullName,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: basicDetails.isAvailable
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  basicDetails.isAvailable
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  size: 12,
                                  color: basicDetails.isAvailable
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  basicDetails.isAvailable ? 'Available' : 'Unavailable',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: basicDetails.isAvailable
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: basicDetails.isEmailVerified
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  basicDetails.isEmailVerified
                                      ? Icons.verified
                                      : Icons.warning,
                                  size: 12,
                                  color: basicDetails.isEmailVerified
                                      ? Colors.blue
                                      : Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  basicDetails.isEmailVerified
                                      ? 'Email Verified'
                                      : 'Email Not Verified',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: basicDetails.isEmailVerified
                                        ? Colors.blue
                                        : Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            const Divider(),
            
            // Driver basic information
            _buildInfoItem(
              icon: Icons.email,
              title: 'Email',
              value: basicDetails.email,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              icon: Icons.phone,
              title: 'Phone',
              value: basicDetails.contactNumber,
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              icon: Icons.account_balance_wallet,
              title: 'Wallet Balance',
              value: '₹${basicDetails.walletBalance.toStringAsFixed(2)}',
              color: Colors.amber,
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              icon: Icons.calendar_today,
              title: 'Account Created',
              value: formattedCreatedAt,
              color: Colors.purple,
            ),
            
            // Location info if available
            if (basicDetails.currentLocation != null) ...[
              const SizedBox(height: 12),
              _buildInfoItem(
                icon: Icons.location_on,
                title: 'Current Location',
                value: 'Lat: ${basicDetails.currentLocation!.lat.toStringAsFixed(6)}, Lng: ${basicDetails.currentLocation!.lng.toStringAsFixed(6)}',
                color: Colors.red,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
