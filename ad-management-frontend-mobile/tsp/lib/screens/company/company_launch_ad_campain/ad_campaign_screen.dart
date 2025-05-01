import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/components/ad_title_input.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/components/car_input_fields.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/components/location_selector.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/components/plan_selector_button.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/components/poster_design_info.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/components/poster_upload_section.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/components/preview_button.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/components/theme_constants.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/components/vehicle_type_selector.dart';

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
  final TextEditingController _posterTitleController = TextEditingController();
  final TextEditingController _posterNotesController = TextEditingController();
  
  String _selectedVehicleType = '';
  String _selectedPlan = '';
  int _selectedPlanPrice = 0;
  int _carCount = 0;
  String _selectedPosterSize = 'A3';
  File? _posterFile;
  Uint8List? _webPosterBytes;
  
  bool get _isFormValid => 
    _adTitleController.text.isNotEmpty && 
    _selectedVehicleType.isNotEmpty && 
    _selectedPlan.isNotEmpty && 
    _carCount > 0 && 
    _locationController.text.isNotEmpty;

  @override
  void dispose() {
    _adTitleController.dispose();
    _carCountController.dispose();
    _locationController.dispose();
    _posterTitleController.dispose();
    _posterNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Launch a New Ad Campaign'),
        backgroundColor: Colors.white,
        foregroundColor: AdCampaignTheme.textPrimary,
        elevation: 0,
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
                onPlanSelected: (planName, price) {
                  setState(() {
                    _selectedPlan = planName;
                    _selectedPlanPrice = price;
                  });
                },
              ),
              
              // Car Input Fields
              CarInputFields(
                carCountController: _carCountController,
                selectedPlanPrice: _selectedPlanPrice,
                onCarCountChanged: (count) {
                  setState(() {
                    _carCount = count;
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
              
              // Poster Upload Section
              PosterUploadSection(
                onPosterSelected: (file) {
                  setState(() {
                    _posterFile = file;
                  });
                },
                onWebPosterSelected: (bytes) {
                  setState(() {
                    _webPosterBytes = bytes;
                  });
                },
              ),
              
              // Poster Design Info
              PosterDesignInfo(
                titleController: _posterTitleController,
                notesController: _posterNotesController,
                onPosterSizeSelected: (size) {
                  setState(() {
                    _selectedPosterSize = size;
                  });
                },
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
                  'targetLocation': _locationController.text,
                  'posterTitle': _posterTitleController.text,
                  'posterNotes': _posterNotesController.text,
                  'posterSize': _selectedPosterSize,
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
}
