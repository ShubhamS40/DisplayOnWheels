import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import '../../../../provider/providers.dart';
import '../../../../providers/driver_profile_provider.dart';

class EditProfileView extends ConsumerWidget {
  static const Color primaryOrange = Color(0xFFFF5722);
  static const Color textColor = Color(0xFF2C3E50);

  const EditProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access the app-level provider
    final profileProvider =
        provider.Provider.of<DriverProfileProvider>(context);
    final basicDetails = profileProvider.basicDetails;

    // Fetch driver profile data when screen initializes
    if (!profileProvider.isLoading && profileProvider.driverProfile == null) {
      // Get driver ID from Riverpod provider
      final driverId = ref.read(driverIdProvider);
      if (driverId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          profileProvider.fetchDriverProfile(driverId);
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile Details',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryOrange,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit profile form
              // This would be implemented in a future update
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit functionality coming soon')),
              );
            },
          ),
        ],
      ),
      body: profileProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryOrange))
          : profileProvider.error != null
              ? Center(child: Text('Error: ${profileProvider.error}'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (basicDetails != null) ...[
                        // Profile image section
                        if (profileProvider.documentDetails != null &&
                            profileProvider.documentDetails!.photos.profilePhoto
                                .isNotEmpty)
                          _buildProfileImageSection(
                              context,
                              profileProvider
                                  .documentDetails!.photos.profilePhoto),

                        const SizedBox(height: 24),

                        // Basic info section
                        _buildInfoCard(
                          context,
                          'Personal Information',
                          [
                            _buildInfoRow('Full Name', basicDetails.fullName),
                            _buildInfoRow('Email', basicDetails.email),
                            _buildInfoRow('Phone', basicDetails.contactNumber),
                            _buildInfoRow('Email Verified',
                                basicDetails.isEmailVerified ? 'Yes' : 'No'),
                            _buildInfoRow(
                                'Availability',
                                basicDetails.isAvailable
                                    ? 'Available'
                                    : 'Unavailable'),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Account info section
                        _buildInfoCard(
                          context,
                          'Account Information',
                          [
                            _buildInfoRow('Wallet Balance',
                                '₹${basicDetails.walletBalance.toStringAsFixed(2)}'),
                            _buildInfoRow('Member Since',
                                _formatDate(basicDetails.createdAt)),
                            _buildInfoRow('Last Updated',
                                _formatDate(basicDetails.updatedAt)),
                          ],
                        ),
                      ] else
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text('No profile details found'),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildProfileImageSection(BuildContext context, String imageUrl) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenImage(imageUrl: imageUrl),
                ),
              );
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryOrange,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 60,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: primaryOrange,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
