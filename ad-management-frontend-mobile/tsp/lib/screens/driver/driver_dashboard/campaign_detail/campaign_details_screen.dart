import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsp/provider/providers.dart';
import 'package:tsp/services/campaign/campaign_service.dart';
import 'package:tsp/utils/constants.dart';

// Component imports
import 'package:tsp/screens/driver/driver_dashboard/campaign_detail/components/campaign_header.dart';
import 'package:tsp/screens/driver/driver_dashboard/campaign_detail/components/campaign_details_section.dart';
import 'package:tsp/screens/driver/driver_dashboard/campaign_detail/components/advertisement_proof_section.dart';
import 'package:tsp/screens/driver/driver_dashboard/campaign_detail/components/campaign_detail_item.dart';
import 'package:tsp/screens/driver/driver_dashboard/campaign_detail/components/guideline_item.dart';
import 'package:tsp/screens/driver/driver_dashboard/campaign_detail/components/current_location_view.dart';

class CampaignDetailsScreen extends ConsumerStatefulWidget {
  final String campaignId;

  const CampaignDetailsScreen({
    Key? key,
    required this.campaignId,
  }) : super(key: key);

  @override
  ConsumerState<CampaignDetailsScreen> createState() =>
      _CampaignDetailsScreenState();
}

class _CampaignDetailsScreenState extends ConsumerState<CampaignDetailsScreen> {
  bool isLoading = true;
  Map<String, dynamic>? campaignData;
  String errorMessage = '';

  // Photo upload related variables
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  Uint8List? _selectedImageBytes; // For web compatibility
  bool _isUploading = false;
  String? _uploadedPhotoUrl;
  String? _uploadErrorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCampaignDetails();
  }

  Future<void> _fetchCampaignDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final driverId = prefs.getString('driverId');

      if (token == null || driverId == null) {
        setState(() {
          isLoading = false;
          errorMessage = 'Authentication failed. Please login again.';
        });
        return;
      }

      // Using the provided API endpoint
      final response = await http.get(
        Uri.parse(
            '${Constants.baseUrl}/api/driver-dashboard/campaigns-details/${ref.read(driverIdProvider) ?? ''}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // Log the API call for debugging
      debugPrint(
          'API call: ${Constants.baseUrl}/api/driver-dashboard/campaigns-details/${ref.read(driverIdProvider) ?? ''}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Log the response for debugging
        debugPrint('API response: $responseData');

        // The API might return data directly or in a nested format
        // Handle both possibilities
        if (responseData is Map) {
          if (responseData.containsKey('status') &&
              responseData['status'] == 'success') {
            // Format: {status: success, data: [...]}
            if (responseData['data'] is List &&
                responseData['data'].isNotEmpty) {
              // Find the campaign with matching ID
              Map<dynamic, dynamic>? matchingCampaign;

              for (var campaign in responseData['data']) {
                if (campaign['id'] == widget.campaignId) {
                  matchingCampaign = campaign;
                  break;
                }
              }

              // If no exact match found, use the first one
              // Convert to Map<String, dynamic> to fix type error
              final Map<String, dynamic> typedCampaign = {};
              final rawCampaign = matchingCampaign ?? responseData['data'][0];

              // Convert each key to String type
              rawCampaign.forEach((key, value) {
                typedCampaign[key.toString()] = value;
              });

              setState(() {
                isLoading = false;
                campaignData = typedCampaign;
              });
            } else {
              setState(() {
                isLoading = false;
                errorMessage = 'No campaign data found';
              });
            }
          } else if (responseData.containsKey('id') ||
              responseData.containsKey('campaignId')) {
            // Format: Direct campaign data
            final Map<String, dynamic> typedCampaign = {};
            responseData.forEach((key, value) {
              typedCampaign[key.toString()] = value;
            });

            setState(() {
              isLoading = false;
              campaignData = typedCampaign;
            });
          } else {
            setState(() {
              isLoading = false;
              errorMessage = 'Invalid response format';
            });
          }
        } else {
          setState(() {
            isLoading = false;
            errorMessage = 'Invalid response data type';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load campaign details';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $e';
      });
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  // Get campaign poster URL with proper error handling
  String _getPosterUrl() {
    if (campaignData == null) return '';

    // Try different possible paths to find the poster URL
    final campaign = campaignData!['campaign'] ?? campaignData;
    if (campaign is! Map) return '';

    // Option 1: Direct posterFile field
    String? posterUrl = campaign['posterFile']?.toString();

    // Option 2: nested in campaign.posterFile
    if (posterUrl == null || posterUrl.isEmpty) {
      final nestedCampaign = campaign['campaign'];
      if (nestedCampaign is Map) {
        posterUrl = nestedCampaign['posterFile']?.toString();
      }
    }

    return posterUrl ?? '';
  }

  // Helper function to safely get values from nested maps
  String _getValue(String path) {
    if (campaignData == null) return 'N/A';

    try {
      final parts = path.split('.');
      dynamic current = campaignData;

      for (final part in parts) {
        if (current is! Map) return 'N/A';
        current = current[part];
        if (current == null) return 'N/A';
      }

      return current.toString();
    } catch (e) {
      return 'N/A';
    }
  }

  // Get formatted location
  String _formatLocation(String? city, String? state) {
    if (city == null && state == null) return 'N/A';
    if (city == null) return state!;
    if (state == null) return city;
    return '$city, $state';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Campaign Details',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF5722)),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error Loading Campaign',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                              errorMessage = '';
                            });
                            _fetchCampaignDetails();
                          },
                          icon: const Icon(Icons.refresh),
                          label: Text(
                            'Try Again',
                            style: GoogleFonts.poppins(),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5722),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Campaign Header Component
                      CampaignHeader(
                        title: _getValue('campaign.title'),
                        companyName: _getValue('campaign.company.businessName'),
                        status: _getValue('status'),
                        posterUrl: _getPosterUrl(),
                        getStatusColor: _getStatusColor,
                      ),
                      const SizedBox(height: 20),

                      // Campaign Details Component
                      CampaignDetailsSection(
                        startDate: _formatDate(_getValue('campaign.startDate')),
                        endDate: _formatDate(_getValue('campaign.endDate')),
                        budget: '\$${_getValue('campaign.budget')}',
                        location: _formatLocation(
                          _getValue('campaign.city'),
                          _getValue('campaign.state'),
                        ),
                        buildDetailItem: _buildDetailItem,
                      ),
                      const SizedBox(height: 20),

                      // Current Location Section
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: const Color(0xFFFF5722),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Current Location',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Use our new component with proper null handling
                              CurrentLocationView(
                                locationData: campaignData != null ? 
                                    _getValue('currentLocation') != null ? 
                                        Map<String, dynamic>.from({"lat": _getValue('currentLocation.lat'), "lng": _getValue('currentLocation.lng')}) : 
                                        null : 
                                    null,
                                height: 200,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Advertisement Proof Section Component
                      AdvertisementProofSection(
                        selectedImage: _selectedImage,
                        selectedImageBytes: _selectedImageBytes,
                        isUploading: _isUploading,
                        uploadErrorMessage: _uploadErrorMessage,
                        uploadedPhotoUrl: _uploadedPhotoUrl,
                        getImage: _getImage,
                        resetImage: _resetImage,
                        uploadImage: _uploadImage,
                        buildGuidelineItem: _buildGuidelineItem,
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return CampaignDetailItem(
      label: label,
      value: value,
      icon: icon,
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
      case 'APPROVED':
        return Colors.green;
      case 'PENDING':
      case 'PROCESSING':
        return const Color(0xFFE89C08);
      case 'REJECTED':
      case 'CANCELLED':
        return Colors.red;
      case 'COMPLETED':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildGuidelineItem(String number, String text, IconData icon) {
    return GuidelineItem(
      number: number,
      text: text,
      icon: icon,
    );
  }

  // Get image from camera or gallery
  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (pickedFile != null) {
        // For web compatibility
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _selectedImageBytes = bytes;
            _selectedImage = null; // File is not used on web
            _uploadErrorMessage = null;
          });
        } else {
          setState(() {
            _selectedImage = File(pickedFile.path);
            _selectedImageBytes = null;
            _uploadErrorMessage = null;
          });
        }
      }
    } catch (e) {
      setState(() {
        _uploadErrorMessage = 'Error picking image: $e';
      });
    }
  }

  // Reset image
  void _resetImage() {
    setState(() {
      _selectedImage = null;
      _selectedImageBytes = null;
      _uploadErrorMessage = null;
    });
  }

  // Upload image to server
  Future<void> _uploadImage() async {
    if (_selectedImage == null && _selectedImageBytes == null) {
      setState(() {
        _uploadErrorMessage = 'Please select an image first';
      });
      return;
    }

    // Get campaignDriverId from the campaign data
    String? campaignDriverId;
    if (campaignData != null) {
      // Based on the Postman screenshot, we need to directly get the 'id' field from the nested data
      if (campaignData!.containsKey('data') && campaignData!['data'] is List) {
        final dataList = campaignData!['data'] as List;
        if (dataList.isNotEmpty && dataList[0] is Map) {
          final firstItem = dataList[0] as Map;
          campaignDriverId = firstItem['id']?.toString();
          debugPrint('Using ID from data list: $campaignDriverId');
        }
      } else {
        // Fallback to direct fields
        campaignDriverId = _getValue('id');
        debugPrint('Using direct ID: $campaignDriverId');

        // If not found, try other possible locations
        if (campaignDriverId == null || campaignDriverId.isEmpty) {
          campaignDriverId = _getValue('campaignDriverId');
          debugPrint('Using campaignDriverId: $campaignDriverId');
        }
      }
    }

    if (campaignDriverId == null || campaignDriverId.isEmpty) {
      setState(() {
        _uploadErrorMessage = 'Campaign ID not found';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadErrorMessage = null;
    });

    try {
      // Use the campaign service to upload the photo
      final result = await CampaignService().uploadAdvertisementProofPhoto(
        campaignDriverId: campaignDriverId,
        photoFile: _selectedImage,
        photoBytes: _selectedImageBytes,
      );

      setState(() {
        _isUploading = false;
      });

      if (result['success']) {
        // Success
        setState(() {
          _uploadedPhotoUrl =
              result['photoUrl'] ?? result['data']['photoUrl'] ?? '';
          _selectedImage = null;
          _uploadErrorMessage = null;
        });

        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result['message'] ?? 'Proof photo uploaded successfully!',
                    style: GoogleFonts.poppins(),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        // Error
        setState(() {
          _uploadErrorMessage = result['message'];
        });
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadErrorMessage = 'Error uploading image: $e';
      });
    }
  }
}
