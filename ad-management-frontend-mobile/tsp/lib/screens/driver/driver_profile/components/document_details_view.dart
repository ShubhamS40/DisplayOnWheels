import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:tsp/models/driver_profile_model.dart';
import '../../../../provider/providers.dart';
import '../../../../providers/driver_profile_provider.dart';

class DocumentDetailsView extends ConsumerWidget {
  static const Color primaryOrange = Color(0xFFFF5722);
  static const Color textColor = Color(0xFF2C3E50);

  const DocumentDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access the app-level provider
    final profileProvider =
        provider.Provider.of<DriverProfileProvider>(context);
    final documentDetails = profileProvider.documentDetails;

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
          'Document Details',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryOrange,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: profileProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryOrange))
          : profileProvider.error != null
              ? Center(child: Text('Error: ${profileProvider.error}'))
              : documentDetails == null
                  ? const Center(child: Text('No document details found'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildVerificationStatusCard(
                              documentDetails.verificationStatus),
                          const SizedBox(height: 24),
                          _buildDocumentsGrid(context, documentDetails),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildVerificationStatusCard(VerificationStatus status) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status.overall) {
      case 'APPROVED':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'All documents are verified';
        break;
      case 'REJECTED':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = status.adminMessage ?? 'Some documents were rejected';
        break;
      default:
        statusColor = Colors.amber;
        statusIcon = Icons.pending;
        statusText = 'Verification pending';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 36,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verification Status',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsGrid(BuildContext context, DocumentDetails documents) {
    final docList = [
      {
        'title': 'Profile Photo',
        'image': documents.photos.profilePhoto,
        'status': documents.verificationStatus.profilePhoto,
      },
      {
        'title': 'ID Card',
        'image': documents.photos.idCard,
        'status': documents.verificationStatus.idCard,
      },
      {
        'title': 'Driving License',
        'image': documents.photos.drivingLicense,
        'status': documents.verificationStatus.drivingLicense,
      },
      {
        'title': 'Vehicle Image',
        'image': documents.photos.vehicleImage,
        'status': documents.verificationStatus.vehicleImage,
      },
      {
        'title': 'Bank Proof',
        'image': documents.photos.bankProof,
        'status': documents.verificationStatus.bankProof,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Documents',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: docList.length,
          itemBuilder: (context, index) {
            final doc = docList[index];
            return _buildDocumentCard(
              context,
              title: doc['title'] as String,
              imageUrl: doc['image'] as String,
              status: doc['status'] as String,
            );
          },
        ),
      ],
    );
  }

  Widget _buildDocumentCard(
    BuildContext context, {
    required String title,
    required String imageUrl,
    required String status,
  }) {
    Color statusColor;
    String statusText;

    switch (status) {
      case 'APPROVED':
        statusColor = Colors.green;
        statusText = 'Approved';
        break;
      case 'REJECTED':
        statusColor = Colors.red;
        statusText = 'Rejected';
        break;
      default:
        statusColor = Colors.amber;
        statusText = 'Pending';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenImage(imageUrl: imageUrl),
          ),
        );
      },
      child: Container(
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
            // Document image
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Loading indicator as base layer
                      Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child:
                              CircularProgressIndicator(color: primaryOrange),
                        ),
                      ),
                      // Actual image
                      Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading image from: $imageUrl - $error');
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported,
                                    color: Colors.red,
                                    size: 36,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Image not available',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: primaryOrange,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Document info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: statusColor.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      statusText,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
