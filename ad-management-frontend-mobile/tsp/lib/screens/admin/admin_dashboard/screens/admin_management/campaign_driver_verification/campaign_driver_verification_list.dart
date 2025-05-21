import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:tsp/utils/theme_constants.dart';
import 'package:intl/intl.dart';

import 'campaign_driver_verification_detail.dart';

class CampaignDriverVerificationList extends StatefulWidget {
  const CampaignDriverVerificationList({Key? key}) : super(key: key);

  @override
  _CampaignDriverVerificationListState createState() =>
      _CampaignDriverVerificationListState();
}

class _CampaignDriverVerificationListState
    extends State<CampaignDriverVerificationList> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _pendingProofs = [];

  @override
  void initState() {
    super.initState();
    _fetchPendingProofs();
  }

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:5000',
    connectTimeout: Duration(seconds: 5),
    receiveTimeout: Duration(seconds: 3),
  ));

  Future<void> _fetchPendingProofs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _dio.get(
        '/api/admin/campaign-driver-verification/proofs/pending',
      );

      if (response.statusCode == 200) {
        final jsonResponse = response.data;
        if (jsonResponse['success'] == true) {
          setState(() {
            _pendingProofs = jsonResponse['data'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Failed to load data';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Server error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM, yyyy').format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Ad Proof Verification'),
        backgroundColor: ThemeConstants.primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPendingProofs,
        color: ThemeConstants.primaryColor,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red),
                        SizedBox(height: 16),
                        Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchPendingProofs,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeConstants.primaryColor,
                          ),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _pendingProofs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 64,
                              color: ThemeConstants.primaryColor,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No pending verifications',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'All ad proofs have been verified',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _pendingProofs.length,
                        itemBuilder: (context, index) {
                          final item = _pendingProofs[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CampaignDriverVerificationDetail(
                                      campaignDriverId: item['id'],
                                      proofData: item,
                                    ),
                                  ),
                                ).then((_) => _fetchPendingProofs());
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: Colors.grey[300],
                                            image: item[
                                                        'driverUploadAdvertisemntProofPhotoUrl'] !=
                                                    null
                                                ? DecorationImage(
                                                    image: NetworkImage(
                                                      item[
                                                          'driverUploadAdvertisemntProofPhotoUrl'],
                                                    ),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null,
                                          ),
                                          child: item[
                                                      'driverUploadAdvertisemntProofPhotoUrl'] ==
                                                  null
                                              ? const Icon(Icons.image_not_supported)
                                              : null,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['campaign']['title'] ??
                                                    'Unnamed Campaign',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Company: ${item['campaign']['company']['businessName'] ?? 'N/A'}',
                                                style: TextStyle(
                                                  color: isDarkMode
                                                      ? Colors.white70
                                                      : Colors.black54,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Driver: ${item['driver']['fullName'] ?? 'Unknown'} (${item['driver']['vehicleNumber'] ?? 'No Vehicle'})',
                                                style: TextStyle(
                                                  color: isDarkMode
                                                      ? Colors.white70
                                                      : Colors.black54,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Uploaded on: ${_formatDate(item['assignedAt'] ?? '')}',
                                                style: TextStyle(
                                                  color: isDarkMode
                                                      ? Colors.white60
                                                      : Colors.black45,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: ThemeConstants.primaryColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Pending Verification',
                                        style: TextStyle(
                                          color: ThemeConstants.primaryColor,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}