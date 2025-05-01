import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tsp/screens/company/company_dashboard/company_dashboard_screen.dart';

class CampaignPreviewScreen extends StatelessWidget {
  final Map<String, dynamic> campaignDetails;

  const CampaignPreviewScreen({
    Key? key,
    required this.campaignDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final orangeColor = const Color(0xFFFF5722); // Primary orange color
    
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text('Campaign Preview'),
        elevation: 0,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Edit Campaign',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campaign Header with Image Preview
            Container(
              width: double.infinity,
              height: screenSize.height * 0.25,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    orangeColor,
                    orangeColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                children: [
                  // Background pattern
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.1,
                      child: GridPattern(color: Colors.white),
                    ),
                  ),
                  
                  // Campaign title and info
                  Positioned(
                    left: 20,
                    bottom: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          campaignDetails['adTitle'] ?? 'New Campaign',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            campaignDetails['selectedPlan'] ?? 'No Plan Selected',
                            style: TextStyle(
                              color: orangeColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Poster preview indicator
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          if (campaignDetails['posterFile'] != null || 
                              campaignDetails['posterBytes'] != null) {
                            _showPosterPreview(context);
                          }
                        },
                        child: Row(
                          children: const [
                            Icon(
                              Icons.image,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'View Poster',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Campaign Details Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campaign Summary
                  _buildSectionCard(
                    context: context,
                    title: 'Campaign Summary',
                    icon: Icons.campaign,
                    content: Column(
                      children: [
                        _buildDetailRow(
                          'Campaign Title:',
                          campaignDetails['adTitle'] ?? 'N/A',
                          isDarkMode: isDarkMode,
                        ),
                        _buildDetailRow(
                          'Vehicle Type:',
                          campaignDetails['vehicleType'] ?? 'N/A',
                          isDarkMode: isDarkMode,
                        ),
                        _buildDetailRow(
                          'Number of Vehicles:',
                          '${campaignDetails['carCount'] ?? 0}',
                          isDarkMode: isDarkMode,
                        ),
                        _buildDetailRow(
                          'Target Location:',
                          campaignDetails['targetLocation'] ?? 'N/A',
                          isDarkMode: isDarkMode,
                        ),
                      ],
                    ),
                    isDarkMode: isDarkMode,
                    orangeColor: orangeColor,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Plan Details
                  _buildSectionCard(
                    context: context,
                    title: 'Plan Details',
                    icon: Icons.access_time,
                    content: Column(
                      children: [
                        _buildDetailRow(
                          'Selected Plan:',
                          campaignDetails['selectedPlan'] ?? 'N/A',
                          valueColor: orangeColor,
                          valueBold: true,
                          isDarkMode: isDarkMode,
                        ),
                        _buildDetailRow(
                          'Price per Vehicle:',
                          'Rs ${campaignDetails['planPrice'] ?? 0}',
                          isDarkMode: isDarkMode,
                        ),
                        _buildDetailRow(
                          'Total Cost:',
                          'Rs ${(campaignDetails['planPrice'] ?? 0) * (campaignDetails['carCount'] ?? 0)}',
                          valueColor: orangeColor,
                          valueBold: true,
                          isDarkMode: isDarkMode,
                        ),
                      ],
                    ),
                    isDarkMode: isDarkMode,
                    orangeColor: orangeColor,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Poster Details
                  _buildSectionCard(
                    context: context,
                    title: 'Poster Information',
                    icon: Icons.image,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          'Poster Title:',
                          campaignDetails['posterTitle'] ?? 'N/A',
                          isDarkMode: isDarkMode,
                        ),
                        _buildDetailRow(
                          'Poster Size:',
                          campaignDetails['posterSize'] ?? 'A3',
                          isDarkMode: isDarkMode,
                        ),
                        if (campaignDetails['posterNotes'] != null && 
                            campaignDetails['posterNotes'].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Notes:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isDarkMode ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Text(
                                    campaignDetails['posterNotes'].toString(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // Poster thumbnail
                        if (campaignDetails['posterFile'] != null || 
                            campaignDetails['posterBytes'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: GestureDetector(
                              onTap: () => _showPosterPreview(context),
                              child: Container(
                                width: double.infinity,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: isDarkMode ? Colors.grey[900] : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: _buildPosterPreview(
                                    campaignDetails['posterFile'],
                                    campaignDetails['posterBytes'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    isDarkMode: isDarkMode,
                    orangeColor: orangeColor,
                  ),
                ],
              ),
            ),
            
            // Bottom action area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Cost summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          'Plan Cost:',
                          'Rs ${campaignDetails['planPrice'] ?? 0}',
                          isDarkMode: isDarkMode,
                        ),
                        _buildDetailRow(
                          'Number of Vehicles:',
                          '${campaignDetails['carCount'] ?? 0}',
                          isDarkMode: isDarkMode,
                        ),
                        const Divider(),
                        _buildDetailRow(
                          'Total Campaign Cost:',
                          'Rs ${(campaignDetails['planPrice'] ?? 0) * (campaignDetails['carCount'] ?? 0)}',
                          valueColor: orangeColor,
                          valueBold: true,
                          valueFontSize: 18,
                          isDarkMode: isDarkMode,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Launch Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orangeColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // Show a success dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
                            title: Text(
                              'Campaign Created!',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            content: Text(
                              'Your ad campaign has been successfully created. '
                              'Our team will review it and get back to you soon.',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  // Navigate back to dashboard
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (context) => const CompanyDashboardScreen()),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: orangeColor,
                                ),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text(
                        'LAUNCH CAMPAIGN',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget content,
    required bool isDarkMode,
    required Color orangeColor,
  }) {
    return Container(
      width: double.infinity,
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
          // Section header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: orangeColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(
                  color: orangeColor.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: orangeColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: orangeColor,
                  ),
                ),
              ],
            ),
          ),
          
          // Section content
          Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? valueColor,
    bool valueBold = false,
    double? valueFontSize,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: valueBold ? FontWeight.bold : FontWeight.w500,
                fontSize: valueFontSize ?? 14,
                color: valueColor ?? (isDarkMode ? Colors.white : Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosterPreview(File? file, Uint8List? bytes, {BoxFit fit = BoxFit.contain}) {
    if (file != null) {
      return Image.file(
        file,
        fit: fit,
      );
    } else if (bytes != null) {
      return Image.memory(
        bytes,
        fit: fit,
      );
    } else {
      return const Center(
        child: Icon(
          Icons.image_not_supported,
          color: Colors.grey,
          size: 40,
        ),
      );
    }
  }

  void _showPosterPreview(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final orangeColor = const Color(0xFFFF5722);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    campaignDetails['posterTitle'] ?? 'Campaign Poster',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            
            // Poster preview
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: _buildPosterPreview(
                  campaignDetails['posterFile'],
                  campaignDetails['posterBytes'],
                ),
              ),
            ),
            
            // Footer with poster size and download button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Size: ${campaignDetails['posterSize'] ?? 'A3'}',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white54 : Colors.black54,
                    ),
                  ),
                  TextButton.icon(
                    icon: Icon(
                      Icons.download,
                      color: orangeColor,
                    ),
                    label: Text(
                      'Save',
                      style: TextStyle(
                        color: orangeColor,
                      ),
                    ),
                    onPressed: () {
                      // Download functionality would go here
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Poster saved to gallery'),
                          backgroundColor: isDarkMode ? Colors.grey[800] : null,
                        ),
                      );
                    },
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

class GridPattern extends StatelessWidget {
  final Color color;
  
  const GridPattern({
    Key? key,
    required this.color,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GridPainter(color: color),
    );
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  
  GridPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;
    
    const spacing = 20.0;
    
    // Draw vertical lines
    for (double i = 0; i <= size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }
    
    // Draw horizontal lines
    for (double i = 0; i <= size.height; i += spacing) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
