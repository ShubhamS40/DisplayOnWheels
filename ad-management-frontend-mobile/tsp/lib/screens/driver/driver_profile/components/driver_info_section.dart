import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../providers/driver_profile_provider.dart';
import 'info_item.dart';

class DriverInfoSection extends StatelessWidget {
  static const Color primaryOrange = Color(0xFFFF5722); // Using brand orange color
  static const Color textColor = Color(0xFF2C3E50);

  const DriverInfoSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<DriverProfileProvider>(context);
    final basicDetails = profileProvider.basicDetails;
    final vehicleDetails = profileProvider.vehicleDetails;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Driver Information',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          InfoItem(
            icon: Icons.phone,
            label: 'Phone',
            value: basicDetails?.contactNumber ?? 'Loading...',
            color: Colors.blue,
            showAction: true,
            actionIcon: Icons.edit,
          ),
          const Divider(height: 24),
          InfoItem(
            icon: Icons.email,
            label: 'Email',
            value: basicDetails?.email ?? 'Loading...',
            color: Colors.green,
            showAction: true,
            actionIcon: Icons.edit,
          ),
          const Divider(height: 24),
          InfoItem(
            icon: Icons.directions_car,
            label: 'Vehicle Type',
            value: vehicleDetails?.vehicleType ?? 'Loading...',
            color: primaryOrange,
          ),
          const Divider(height: 24),
          InfoItem(
            icon: Icons.confirmation_number,
            label: 'Vehicle Number',
            value: vehicleDetails?.vehicleNumber ?? 'Loading...',
            color: primaryOrange,
          ),
          const Divider(height: 24),
          InfoItem(
            icon: Icons.account_balance_wallet,
            label: 'Wallet Balance',
            value: '₹${basicDetails?.walletBalance.toStringAsFixed(2) ?? '0.00'}',
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}
