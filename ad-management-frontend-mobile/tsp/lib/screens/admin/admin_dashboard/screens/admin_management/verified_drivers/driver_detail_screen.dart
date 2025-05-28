import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'model/driver_detail_model.dart';
import 'service/driver_detail_service.dart';
import 'components/basic_info_section.dart';
import 'components/vehicle_info_section.dart';
import 'components/document_section.dart';
import 'components/bank_details_section.dart';
import 'components/campaign_section.dart';
import 'components/location_map_card.dart';

class DriverDetailScreen extends StatefulWidget {
  final String driverId;
  
  const DriverDetailScreen({
    Key? key,
    required this.driverId,
  }) : super(key: key);

  @override
  State<DriverDetailScreen> createState() => _DriverDetailScreenState();
}

class _DriverDetailScreenState extends State<DriverDetailScreen> {
  final DriverDetailService _detailService = DriverDetailService();
  bool _isLoading = true;
  String? _errorMessage;
  DriverDetailData? _driverDetails;
  
  @override
  void initState() {
    super.initState();
    _fetchDriverDetails();
  }
  
  Future<void> _fetchDriverDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final response = await _detailService.getDriverDetails(widget.driverId);
      setState(() {
        _driverDetails = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Driver Details',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFFFF5722),
        elevation: 0,
        actions: [
          if (_driverDetails != null)
            IconButton(
              icon: const Icon(Icons.call),
              onPressed: () => _makePhoneCall(_driverDetails!.basicDetails.contactNumber),
              tooltip: 'Call Driver',
            ),
          if (_driverDetails != null)
            IconButton(
              icon: const Icon(Icons.email),
              onPressed: () => _sendEmail(_driverDetails!.basicDetails.email),
              tooltip: 'Email Driver',
            ),
        ],
      ),
      body: _buildContent(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF5722),
        onPressed: () {
          // Action to take, such as enabling/disabling the driver
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Admin action coming soon'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: const Icon(Icons.admin_panel_settings),
        tooltip: 'Admin Actions',
      ),
    );
  }
  
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF5722),
        ),
      );
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading driver details',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchDriverDetails,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5722),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    if (_driverDetails == null) {
      return const Center(
        child: Text('No driver details available'),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _fetchDriverDetails,
      color: const Color(0xFFFF5722),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BasicInfoSection(basicDetails: _driverDetails!.basicDetails),
            const SizedBox(height: 16),
            // Add Location Map Card to show driver's location on OpenStreetMap
            if (_driverDetails!.basicDetails.currentLocation != null)
              LocationMapCard(
                location: _driverDetails!.basicDetails.currentLocation!,
                driverName: _driverDetails!.basicDetails.fullName,
              ),
            const SizedBox(height: 16),
            VehicleInfoSection(vehicleDetails: _driverDetails!.vehicleDetails),
            const SizedBox(height: 16),
            DocumentSection(documentDetails: _driverDetails!.documentDetails),
            const SizedBox(height: 16),
            BankDetailsSection(bankDetails: _driverDetails!.documentDetails.bank),
            const SizedBox(height: 16),
            CampaignSection(campaigns: _driverDetails!.assignedCampaigns),
          ],
        ),
      ),
    );
  }
  
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch phone call to $phoneNumber'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _sendEmail(String emailAddress) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: emailAddress,
      query: 'subject=Regarding Your Driver Account&body=Hello,',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch email to $emailAddress'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
