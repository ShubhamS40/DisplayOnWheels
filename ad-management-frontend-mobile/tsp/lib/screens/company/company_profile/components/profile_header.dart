import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../providers/company_profile_provider.dart';

class CompanyProfileHeader extends StatelessWidget {
  static const Color primaryOrange = Color(0xFFFF5722); // Using brand color
  static const Color textColor = Color(0xFF2C3E50);

  const CompanyProfileHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<CompanyProfileProvider>(context);
    final basicDetails = profileProvider.basicDetails;
    return Stack(
      children: [
        // Background decoration
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 180,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  primaryOrange,
                  Color(0xFFFF8534),
                ],
              ),
            ),
          ),
        ),
        
        // Profile content
        Positioned(
          top: 100,
          left: 0,
          right: 0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 60),
                Text(
                  basicDetails?.businessName ?? 'Loading...',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Company ID: ${_formatCompanyId(basicDetails?.id)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  basicDetails?.email ?? 'Loading...',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatusChip(
                      profileProvider.isVerified ? 'Verified' : 'Unverified', 
                      profileProvider.isVerified ? Colors.green : Colors.amber
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(
                      basicDetails?.businessType ?? 'Business',
                      primaryOrange,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        
        // Company logo
        Positioned(
          top: 50,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: basicDetails?.logoUrl != null && basicDetails!.logoUrl!.isNotEmpty
                    ? NetworkImage(basicDetails.logoUrl!)
                    : null,
                child: basicDetails?.logoUrl == null || (basicDetails!.logoUrl?.isEmpty ?? true)
                    ? const Icon(Icons.business, size: 50, color: Colors.grey)
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to safely format company ID
  String _formatCompanyId(String? id) {
    if (id == null || id.isEmpty) {
      return 'Loading...';
    }
    return id.length >= 8 ? id.substring(0, 8) : id;
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
