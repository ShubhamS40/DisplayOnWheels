import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tsp/screens/admin/driver_documentsVerification/driver_detail_card.dart';
import 'package:tsp/screens/admin/driver_documentsVerification/driver_documents_card.dart';
import 'driver_bank_detail_card.dart';

class DriverVerification extends StatefulWidget {
  final String driverId;
  const DriverVerification({Key? key, required this.driverId})
      : super(key: key);

  @override
  State<DriverVerification> createState() => _DriverVerificationState();
}

class _DriverVerificationState extends State<DriverVerification> {
  Map<String, dynamic>? driverData;
  String adminMessage = "";
  final Map<String, String> docStatus = {};

  @override
  void initState() {
    super.initState();
    fetchDriverDocuments();
  }

  Future<void> fetchDriverDocuments() async {
    final response = await http.get(Uri.parse(
        'http://3.110.135.112:5000/api/admin/driver-documents/${widget.driverId}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        driverData = data['driverDocuments'];
        docStatus['photoStatus'] = driverData!['photoStatus'];
        docStatus['idCardStatus'] = driverData!['idCardStatus'];
        docStatus['drivingLicenseStatus'] = driverData!['drivingLicenseStatus'];
        docStatus['vehicleImageStatus'] = driverData!['vehicleImageStatus'];
        docStatus['bankProofStatus'] = driverData!['bankProofStatus'];
        adminMessage = driverData!['adminMessage'] ?? '';
      });
    } else {
      print('Failed to fetch driver documents');
    }
  }

  void updateStatus(String key, String status, [String? reason]) {
    setState(() {
      docStatus[key] = status;
      if (status == 'REJECTED' && reason != null) {
        adminMessage = reason;
      }
    });
  }

  Future<void> submitVerification() async {
    final body = {
      'photoStatus': docStatus['photoStatus'],
      'idCardStatus': docStatus['idCardStatus'],
      'drivingLicenseStatus': docStatus['drivingLicenseStatus'],
      'vehicleImageStatus': docStatus['vehicleImageStatus'],
      'bankProofStatus': docStatus['bankProofStatus'],
      'adminMessage': adminMessage,
    };

    final response = await http.put(
      Uri.parse(
          'http://3.110.135.112:5000/api/admin/driver-documents/${widget.driverId}/verify'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document status updated')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update status')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (driverData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final driver = driverData!['driver'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Verification'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DriverDetailCard(driver: driver),
            const SizedBox(height: 16),
            DriverBankDetailCard(
              bankName: driverData!['bankName'],
              branchName: driverData!['branchName'],
              ifscCode: driverData!['ifscCode'],
              accountNumber: driverData!['accountNumber'],
            ),
            const SizedBox(height: 16),
            _buildDocCard("Photo", "photoStatus", driverData!['photoUrl']),
            _buildDocCard("ID Card", "idCardStatus", driverData!['idCardUrl']),
            _buildDocCard("Driving License", "drivingLicenseStatus",
                driverData!['drivingLicenseUrl']),
            _buildDocCard("Vehicle Image", "vehicleImageStatus",
                driverData!['vehicleImageUrl']),
            _buildDocCard("Bank Proof", "bankProofStatus",
                "https://displayonwheel.s3.ap-south-1.amazonaws.com/Driver_Documents/Drivers_Photo/2e786544-264f-45af-b062-259a8b10fa03_scaled_logo.jpg"),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Submit Verification',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocCard(String title, String statusKey, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DriverDocumentCard(
        documentType: title,
        documentUrl: url,
        status: docStatus[statusKey]!,
        onStatusChanged: (status, reason) =>
            updateStatus(statusKey, status, reason),
      ),
    );
  }
}
