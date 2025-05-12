import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/components/ad_title_input.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/components/car_input_fields.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/components/location_selector.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/components/plan_selector_button.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/components/poster_design_info.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/components/poster_upload_section.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/components/preview_button.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/components/theme_constants.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/components/vehicle_type_selector.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/poster_design_request_screen.dart';

class AdCampaignScreen extends StatefulWidget {
  const AdCampaignScreen({Key? key}) : super(key: key);

  @override
  State<AdCampaignScreen> createState() => _AdCampaignScreenState();
}

class _AdCampaignScreenState extends State<AdCampaignScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _adTitleController = TextEditingController();
  final TextEditingController _carCountController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String _selectedVehicleType = '';
  String _selectedPlan = '';
  int _selectedPlanPrice = 0;
  Map<String, dynamic>? _selectedPlanDetails; // Store essential plan info
  String _planDuration = ''; // Store plan duration information
  int _carCount = 0;
  int _totalPlanPrice = 0;
  File? _posterFile;
  Uint8List? _webPosterBytes;

  // Design request data will be set when returning from PosterDesignRequestScreen
  String _posterSize = 'A3';
  double _posterDesignPrice = 0.0;
  String _posterTitle = '';
  String _posterNotes = '';
  String _designIdeas = '';
  bool _needsDesignRequest = false;

  bool get _isFormValid =>
      _adTitleController.text.isNotEmpty &&
      _selectedVehicleType.isNotEmpty &&
      _selectedPlan.isNotEmpty &&
      _carCount > 0 &&
      _locationController.text.isNotEmpty &&
      (_needsDesignRequest || _posterFile != null || _webPosterBytes != null);

  // Method to open design request screen
  void _openDesignRequestScreen() async {
    // Navigate to design request screen and wait for result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PosterDesignRequestScreen(),
      ),
    );

    // If result is not null, update state with design request data
    if (result != null && mounted) {
      setState(() {
        _needsDesignRequest = true;
        _posterSize = result['posterSize'] ?? 'A3';
        _posterDesignPrice = result['posterPrice'] ?? 5000.0;
        _posterTitle = result['posterTitle'] ?? '';
        _posterNotes = result['posterNotes'] ?? '';
        _designIdeas = result['designIdeas'] ?? '';

        // Clear any selected poster file
        _posterFile = null;
        _webPosterBytes = null;
      });
    }
  }

  Future<void> _pickPosterImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        setState(() {
          _needsDesignRequest =
              false; // Disable design request if user uploads image

          if (kIsWeb) {
            // For web platform
            pickedFile.readAsBytes().then((bytes) {
              setState(() {
                _webPosterBytes = bytes;
              });
            });
          } else {
            // For mobile platforms
            _posterFile = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  void dispose() {
    _adTitleController.dispose();
    _carCountController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Launch a New Ad Campaign'),
        backgroundColor: AdCampaignTheme.primaryOrange,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ad Title Input
              AdTitleInput(
                controller: _adTitleController,
                onChanged: (value) {
                  setState(() {});
                },
              ),

              // Vehicle Type Selector
              VehicleTypeSelector(
                onSelected: (vehicleType) {
                  setState(() {
                    _selectedVehicleType = vehicleType;
                  });
                },
              ),

              // Plan Selector Button
              PlanSelectorButton(
                selectedPlan: _selectedPlan,
                onPlanSelected: (planName, price, planDetails) {
                  setState(() {
                    _selectedPlan = planName;
                    _selectedPlanPrice = price;
                    _selectedPlanDetails = planDetails;
                    
                    // Store plan duration if available
                    if (planDetails != null && planDetails.containsKey('durationDays')) {
                      _planDuration = '${planDetails['durationDays']} days';
                    }
                    
                    // Update total price based on car count
                    _totalPlanPrice = _selectedPlanPrice * _carCount;
                  });
                },
              ),

              // Car Input Fields
              CarInputFields(
                carCountController: _carCountController,
                selectedPlanPrice: _selectedPlanPrice,
                onChanged: (value) {
                  setState(() {
                    _carCount = int.tryParse(value) ?? 0;
                    // Update total plan price based on car count
                    _totalPlanPrice = _selectedPlanPrice * _carCount;
                  });
                },
                onCarCountChanged: (count) {
                  setState(() {
                    _carCount = count;
                    _totalPlanPrice = _selectedPlanPrice * _carCount;
                  });
                },
              ),

              // Location Selector
              LocationSelector(
                controller: _locationController,
                onLocationSelected: (location) {
                  setState(() {});
                },
              ),

              // Additional Ad Information
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Additional Ad Information',
                  style: AdCampaignTheme.headingStyle,
                ),
              ),

              // Advertisement Poster Section
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AdCampaignTheme.secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Advertisement Poster',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AdCampaignTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Poster Options as separate buttons (no tabs)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: !_needsDesignRequest
                                ? AdCampaignTheme.primaryButtonStyle
                                : AdCampaignTheme.secondaryButtonStyle,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Upload My Own Poster'),
                            onPressed: _pickPosterImage,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: _needsDesignRequest
                                ? AdCampaignTheme.primaryButtonStyle
                                : AdCampaignTheme.secondaryButtonStyle,
                            icon: const Icon(Icons.design_services),
                            label: const Text('Request Design'),
                            onPressed: _openDesignRequestScreen,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Show upload preview if a file is selected
                    if (_posterFile != null || _webPosterBytes != null) ...[
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: AdCampaignTheme.borderColor),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _webPosterBytes != null
                              ? Image.memory(_webPosterBytes!,
                                  fit: BoxFit.cover)
                              : Image.file(_posterFile!, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Poster selected successfully',
                        style: TextStyle(
                          color: Colors.green,
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                        ),
                      ),
                    ],

                    // Show design request summary if design was requested
                    if (_needsDesignRequest) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AdCampaignTheme.primaryOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AdCampaignTheme.primaryOrange
                                  .withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.design_services,
                                    color: AdCampaignTheme.primaryOrange),
                                const SizedBox(width: 8),
                                const Text(
                                  'Design Request Summary',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AdCampaignTheme.primaryOrange,
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: _openDesignRequestScreen,
                                  child: const Text('Edit'),
                                ),
                              ],
                            ),
                            const Divider(),
                            _buildDesignInfoRow('Poster Size', _posterSize),
                            _buildDesignInfoRow(
                                'Poster Title',
                                _posterTitle.isEmpty
                                    ? 'Not specified'
                                    : _posterTitle),
                            _buildDesignInfoRow(
                                'Price', 'Rs. ${_posterDesignPrice.toInt()}/-'),
                            if (_posterNotes.isNotEmpty)
                              _buildDesignInfoRow('Notes Length',
                                  '${_posterNotes.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length} words'),
                          ],
                        ),
                      ),
                    ],

                    if (!_needsDesignRequest &&
                        _posterFile == null &&
                        _webPosterBytes == null) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Please upload a poster or request our designers to create one for you.',
                        style: TextStyle(
                          color: AdCampaignTheme.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Summary Card
              if (_selectedPlan.isNotEmpty || _needsDesignRequest)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AdCampaignTheme.secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AdCampaignTheme.primaryOrange.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Campaign Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AdCampaignTheme.primaryOrange,
                        ),
                      ),
                      const Divider(height: 24),
                      if (_selectedPlan.isNotEmpty) ...[
                        _buildSummaryRow('Ad Plan', _selectedPlan),
                        _buildSummaryRow('Plan Duration', _planDuration),
                        _buildSummaryRow('Plan Price (Per Vehicle)',
                            'Rs. $_selectedPlanPrice/-'),
                        _buildSummaryRow('Vehicles', _carCount.toString()),
                        _buildSummaryRow('Subtotal', 'Rs. $_totalPlanPrice/-'),
                      ],
                      if (_needsDesignRequest) ...[
                        const Divider(height: 24),
                        _buildSummaryRow('Poster Design', 'Size $_posterSize'),
                        _buildSummaryRow('Design Fee',
                            'Rs. ${_posterDesignPrice.toInt()}/-'),
                      ],
                      const Divider(height: 24),
                      _buildSummaryRow(
                        'Total',
                        'Rs. ${(_totalPlanPrice + (_needsDesignRequest ? _posterDesignPrice : 0)).toInt()}/-',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),

              // Preview Button
              PreviewButton(
                isFormValid: _isFormValid,
                adDetails: {
                  'adTitle': _adTitleController.text,
                  'vehicleType': _selectedVehicleType,
                  'selectedPlan': _selectedPlan,
                  'planPrice': _selectedPlanPrice,
                  'carCount': _carCount,
                  'totalPlanPrice': _totalPlanPrice,
                  'targetLocation': _locationController.text,
                  'needsPosterDesign': _needsDesignRequest,
                  'posterTitle': _posterTitle,
                  'posterNotes': _posterNotes,
                  'designIdeas': _designIdeas,
                  'posterSize': _posterSize,
                  'posterDesignPrice': _posterDesignPrice,
                  'posterFile': _posterFile,
                  'posterBytes': _webPosterBytes,
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: AdCampaignTheme.textPrimary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal
                  ? AdCampaignTheme.primaryOrange
                  : AdCampaignTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesignInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
