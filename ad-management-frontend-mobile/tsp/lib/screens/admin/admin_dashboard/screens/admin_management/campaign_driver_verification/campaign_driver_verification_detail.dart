import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:tsp/utils/theme_constants.dart';
import 'package:intl/intl.dart';

class CampaignDriverVerificationDetail extends StatefulWidget {
  final String campaignDriverId;
  final Map<String, dynamic> proofData;

  const CampaignDriverVerificationDetail({
    Key? key,
    required this.campaignDriverId,
    required this.proofData,
  }) : super(key: key);

  @override
  _CampaignDriverVerificationDetailState createState() =>
      _CampaignDriverVerificationDetailState();
}

class _CampaignDriverVerificationDetailState
    extends State<CampaignDriverVerificationDetail> {
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  final TextEditingController _rejectionReasonController =
      TextEditingController();

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  Future<void> _approveProof() async {
    _showConfirmationDialog(
      title: 'Approve Ad Proof',
      message: 'Are you sure you want to approve this advertisement proof?',
      confirmAction: () async {
        await _submitAction(true);
      },
    );
  }

  Future<void> _rejectProof() async {
    _showRejectionDialog();
  }

  void _showRejectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Ad Proof'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejecting this proof:'),
            const SizedBox(height: 16),
            TextField(
              controller: _rejectionReasonController,
              decoration: InputDecoration(
                hintText: 'Enter rejection reason',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              if (_rejectionReasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a rejection reason'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              _submitAction(false);
            },
            child: const Text('REJECT'),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog({
    required String title,
    required String message,
    required Function confirmAction,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              confirmAction();
            },
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    );
  }

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:5000',
    connectTimeout: Duration(seconds: 5),
    receiveTimeout: Duration(seconds: 3),
  ));

  Future<void> _submitAction(bool isApproved) async {
    if (mounted) {
      setState(() {
        _isSubmitting = true;
        _errorMessage = null;
      });
    }

    try {
      final endpoint = isApproved
          ? '/api/admin/campaign-driver-verification/proofs/approve'
          : '/api/admin/campaign-driver-verification/proofs/reject';

      final Map<String, dynamic> bodyData = {
        'campaignDriverId': widget.campaignDriverId,
        'adminId': 1, // This should be replaced with actual admin ID
      };

      if (!isApproved) {
        bodyData['message'] = _rejectionReasonController.text.trim();
      }

      final response = await _dio.post(
        endpoint,
        data: bodyData,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = response.data;
        if (jsonResponse['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isApproved
                      ? 'Ad proof approved successfully'
                      : 'Ad proof rejected successfully',
                ),
                backgroundColor: isApproved ? Colors.green : Colors.amber,
              ),
            );
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            setState(() {
              _errorMessage = 'Failed to update proof';
              _isSubmitting = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Server error: ${response.statusCode}';
            _isSubmitting = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Network error: $e';
          _isSubmitting = false;
        });
      }
    }
  }

  void _showFullScreenImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Ad Proof'),
            backgroundColor: ThemeConstants.primaryColor,
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4,
              child: Image.network(
                imageUrl,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: ThemeConstants.primaryColor,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 64,
                      color: Colors.red,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final data = widget.proofData;

    return Scaffold(
      appBar: AppBar(
        title: Text('Ad Proof Details'),
        backgroundColor: ThemeConstants.primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ad Proof Image
                  Text(
                    'Advertisement Proof Image',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      if (data['driverUploadAdvertisemntProofPhotoUrl'] !=
                          null) {
                        _showFullScreenImage(
                            data['driverUploadAdvertisemntProofPhotoUrl']);
                      }
                    },
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[300],
                      ),
                      child: data['driverUploadAdvertisemntProofPhotoUrl'] !=
                              null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                data['driverUploadAdvertisemntProofPhotoUrl'],
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                      color: ThemeConstants.primaryColor,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 64,
                                      color: Colors.red,
                                    ),
                                  );
                                },
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 64,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Campaign Details
                  _buildInfoCard(
                    title: 'Campaign Information',
                    isDarkMode: isDarkMode,
                    children: [
                      _buildInfoRow(
                        'Campaign Title',
                        data['campaign']['title'] ?? 'N/A',
                        isDarkMode,
                      ),
                      _buildInfoRow(
                        'Company',
                        data['campaign']['company']['businessName'] ?? 'N/A',
                        isDarkMode,
                      ),
                      _buildInfoRow(
                        'Assigned Date',
                        _formatDate(data['assignedAt'] ?? ''),
                        isDarkMode,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Driver Details
                  _buildInfoCard(
                    title: 'Driver Information',
                    isDarkMode: isDarkMode,
                    children: [
                      _buildInfoRow(
                        'Driver Name',
                        data['driver']['fullName'] ?? 'N/A',
                        isDarkMode,
                      ),
                      _buildInfoRow(
                        'Vehicle Number',
                        data['driver']['vehicleNumber'] ?? 'N/A',
                        isDarkMode,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _rejectProof,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isSubmitting &&
                                  _rejectionReasonController.text.isNotEmpty
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Reject',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _approveProof,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isSubmitting &&
                                  _rejectionReasonController.text.isEmpty
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Approve',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),

                  // Error Message
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard({
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
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ThemeConstants.primaryColor,
            ),
          ),
          const Divider(),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
