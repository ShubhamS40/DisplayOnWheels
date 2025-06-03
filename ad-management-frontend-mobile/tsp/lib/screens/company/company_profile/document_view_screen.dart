import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../providers/company_profile_provider.dart';

class DocumentViewScreen extends StatelessWidget {
  const DocumentViewScreen({Key? key}) : super(key: key);

  static const Color primaryOrange = Color(0xFFFF5722);
  static const Color textColor = Color(0xFF2C3E50);

  @override
  Widget build(BuildContext context) {
    final companyProvider = Provider.of<CompanyProfileProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final documentDetails = companyProvider.companyProfile?.documentDetails;

    // Debug print to check document details structure
    if (documentDetails != null) {
      print('Document URLs available: ${documentDetails.documentUrls != null}');
      print(
          'Registration Doc URL: ${documentDetails.documentUrls.businessRegistrationUrl}');
      print('ID Card URL: ${documentDetails.documentUrls.idCardUrl}');
      print(
          'GST Number URL: ${documentDetails.documentUrls.gstRegistrationUrl}');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Company Documents',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : textColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: documentDetails == null
          ? const Center(child: Text('No document details available'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Information Card
                  _buildInfoCard(
                    context: context,
                    title: 'Document Status',
                    isDarkMode: isDarkMode,
                    children: [
                      _buildStatusItem(
                          context: context,
                          icon: Icons.business,
                          title: 'Business Registration',
                          status: documentDetails
                              .verificationStatus.businessRegistration),
                      const SizedBox(height: 12),
                      _buildStatusItem(
                        context: context,
                        icon: Icons.person,
                        title: 'ID Card',
                        status: documentDetails.verificationStatus.idCardStatus,
                      ),
                      const SizedBox(height: 12),
                      _buildStatusItem(
                        context: context,
                        icon: Icons.account_balance,
                        title: 'GST Registration',
                        status:
                            documentDetails.verificationStatus.gstRegistration,
                      ),
                      const SizedBox(height: 12),
                      _buildStatusItem(
                        context: context,
                        icon: Icons.verified,
                        title: 'Overall Status',
                        status: documentDetails.verificationStatus.overall,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Document Images
                  _buildInfoCard(
                    context: context,
                    title: 'Document Images',
                    isDarkMode: isDarkMode,
                    children: [
                      _buildDocumentItem(
                        context: context,
                        title: 'Business Registration',
                        url: documentDetails
                            .documentUrls.businessRegistrationUrl,
                      ),
                      _buildDocumentItem(
                        context: context,
                        title: 'ID Card',
                        url: documentDetails.documentUrls.idCardUrl,
                      ),
                      _buildDocumentItem(
                        context: context,
                        title: 'GST Registration',
                        url: documentDetails.documentUrls.gstRegistrationUrl,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Company Info
                  _buildInfoCard(
                    context: context,
                    title: 'Company Information',
                    isDarkMode: isDarkMode,
                    children: [
                      _buildInfoItem(
                        title: 'Company Name',
                        value: documentDetails.companyInfo.name,
                        icon: Icons.business,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoItem(
                        title: 'Business Type',
                        value: documentDetails.companyInfo.type,
                        icon: Icons.category,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoItem(
                        title: 'Address',
                        value: documentDetails.companyInfo.address,
                        icon: Icons.location_on,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoItem(
                        title: 'City & State',
                        value:
                            '${documentDetails.companyInfo.city}, ${documentDetails.companyInfo.state}',
                        icon: Icons.location_city,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoItem(
                        title: 'Zip Code',
                        value: documentDetails.companyInfo.zipCode,
                        icon: Icons.pin_drop,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoItem(
                        title: 'Registration Number',
                        value: documentDetails.companyInfo.registrationNumber,
                        icon: Icons.numbers,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoItem(
                        title: 'Tax ID/GST Number',
                        value: documentDetails.companyInfo.taxId,
                        icon: Icons.receipt_long,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required String title,
    required bool isDarkMode,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : textColor,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String status,
  }) {
    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'verified':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Row(
      children: [
        Icon(icon, size: 20, color: primaryOrange),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon, size: 16, color: statusColor),
              const SizedBox(width: 4),
              Text(
                status,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentItem({
    required BuildContext context,
    required String title,
    required String url,
  }) {
    // Calculate responsive height based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final imageHeight = screenWidth * 0.5; // 50% of screen width for height
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: imageHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[200],
          ),
          child: url.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: GestureDetector(
                    onTap: () {
                      _showFullScreenImage(context, url, title);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.contain, // Changed from cover to contain
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(color: primaryOrange),
                        ),
                        errorWidget: (context, url, error) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            Text(
                              'Failed to load image',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : const Center(
                  child: Text('No image available'),
                ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInfoItem({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: primaryOrange),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              Text(
                value.isEmpty ? 'Not provided' : value,
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

  void _showFullScreenImage(
      BuildContext context, String imageUrl, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: Colors.black,
          ),
          body: Container(
            color: Colors.black,
            child: Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: primaryOrange),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.error, color: Colors.red, size: 48),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
