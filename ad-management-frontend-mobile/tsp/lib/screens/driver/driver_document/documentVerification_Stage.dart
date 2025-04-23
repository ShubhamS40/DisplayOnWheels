import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tsp/screens/driver/driver_dashboard.dart';
import 'package:tsp/screens/driver/driver_document/documentUpload.dart';
import 'package:tsp/screens/driver/driver_document/document_reupload.dart';
import 'package:tsp/screens/driver/driver_main_screen.dart';
import 'package:tsp/screens/driver/driver_upload_status_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocumentStatusScreen extends StatefulWidget {
  const DocumentStatusScreen({Key? key}) : super(key: key);

  @override
  _DocumentStatusScreenState createState() => _DocumentStatusScreenState();
}

class _DocumentStatusScreenState extends State<DocumentStatusScreen> {
  bool _isLoading = true;
  String _error = '';
  Map<String, dynamic>? _documentData;
  String _driverId = '';

  @override
  void initState() {
    super.initState();
    _loadDriverId();
  }

  Future<void> _loadDriverId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final driverId = prefs.getString('driverId');
      if (driverId != null) {
        setState(() {
          _driverId = driverId;
        });
        _fetchDocumentStatus();
      } else {
        setState(() {
          _error = 'Driver ID not found. Please login again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading driver data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchDocumentStatus() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:5000/api/driver/document-status/$_driverId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _documentData = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load document status: ${response.body}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Verification Status'),
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error, style: TextStyle(color: Colors.red)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchDocumentStatus,
              child: Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_documentData == null) {
      return Center(
        child: Text('No document data available'),
      );
    }

    final documents = _documentData!['documents'];
    final bool allApproved = _isAllDocumentsApproved(documents);
    final bool anyRejected = _hasRejectedDocuments(documents);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusHeader(allApproved, anyRejected),
          const SizedBox(height: 24),
          _buildDocumentsList(documents),
          const SizedBox(height: 16),
          if (anyRejected) _buildReUploadButton(),
        ],
      ),
    );
  }

  bool _isAllDocumentsApproved(Map<String, dynamic> documents) {
    return documents['photoStatus'] == 'APPROVED' &&
        documents['idCardStatus'] == 'APPROVED' &&
        documents['drivingLicenseStatus'] == 'APPROVED' &&
        documents['vehicleImageStatus'] == 'APPROVED' &&
        documents['bankProofStatus'] == 'APPROVED';
  }

  bool _hasRejectedDocuments(Map<String, dynamic> documents) {
    return documents['photoStatus'] == 'REJECTED' ||
        documents['idCardStatus'] == 'REJECTED' ||
        documents['drivingLicenseStatus'] == 'REJECTED' ||
        documents['vehicleImageStatus'] == 'REJECTED' ||
        documents['bankProofStatus'] == 'REJECTED';
  }

  Widget _buildStatusHeader(bool allApproved, bool anyRejected) {
    IconData headerIcon;
    Color headerColor;
    String headerTitle;
    String headerMessage;

    if (allApproved) {
      headerIcon = Icons.check_circle;
      headerColor = Colors.green;
      headerTitle = 'All Documents Verified';
      headerMessage = 'Your documents have been verified successfully.';
    } else if (anyRejected) {
      headerIcon = Icons.error;
      headerColor = Colors.red;
      headerTitle = 'Document Verification Failed';
      headerMessage =
          'Some documents have been rejected. Please re-upload them.';
    } else {
      headerIcon = Icons.pending;
      headerColor = Colors.orange;
      headerTitle = 'Verification Pending';
      headerMessage = 'Your documents are being reviewed by our team.';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: headerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: headerColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            headerIcon,
            color: headerColor,
            size: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headerTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: headerColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  headerMessage,
                  style: TextStyle(
                    color: headerColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList(Map<String, dynamic> documents) {
    final Map<String, String> documentNames = {
      'photo': 'Your Photo',
      'idCard': 'ID Card',
      'drivingLicense': 'Driving License',
      'vehicleImage': 'Vehicle Image',
      'bankProof': 'Bank Proof',
    };

    final Map<String, String> documentStatuses = {
      'photoStatus': documents['photoStatus'],
      'idCardStatus': documents['idCardStatus'],
      'drivingLicenseStatus': documents['drivingLicenseStatus'],
      'vehicleImageStatus': documents['vehicleImageStatus'],
      'bankProofStatus': documents['bankProofStatus'],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Document Status',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...documentStatuses.entries.map((entry) {
          final docKey = entry.key.replaceAll('Status', '');
          return _buildDocumentItem(
            documentNames[docKey] ?? 'Unknown Document',
            entry.value,
            documents['adminMessage'],
          );
        }).toList(),
        if (documents['adminMessage'] != null &&
            documents['adminMessage'].isNotEmpty)
          _buildAdminMessageCard(documents['adminMessage']),
      ],
    );
  }

  Widget _buildDocumentItem(
      String documentName, String status, String? adminMessage) {
    IconData statusIcon;
    Color statusColor;
    String statusText;

    switch (status) {
      case 'APPROVED':
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        statusText = 'Approved';
        break;
      case 'REJECTED':
        statusIcon = Icons.cancel;
        statusColor = Colors.red;
        statusText = 'Rejected';
        break;
      default:
        statusIcon = Icons.pending;
        statusColor = Colors.orange;
        statusText = 'Pending';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: status == 'REJECTED'
            ? Border.all(color: Colors.red.withOpacity(0.3))
            : null,
      ),
      child: Row(
        children: [
          Icon(
            statusIcon,
            color: statusColor,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  documentName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (status == 'REJECTED' &&
                    adminMessage != null &&
                    adminMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Please re-upload this document',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (status == 'REJECTED')
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                icon: Icon(Icons.upload_file, color: Colors.red),
                onPressed: () => _navigateToReUploadDocument(documentName),
                tooltip: 'Re-upload document',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAdminMessageCard(String adminMessage) {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.red),
              SizedBox(width: 8),
              Text(
                'Message from Admin',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            adminMessage,
            style: TextStyle(
              color: Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToReUploadDocument(String documentType) {
    String docTypeKey = '';
    String displayName = '';

    // Map document display name to the key used in the API
    if (documentType == 'Your Photo') {
      docTypeKey = 'photo';
      displayName = 'Photo';
    } else if (documentType == 'ID Card') {
      docTypeKey = 'idCard';
      displayName = 'ID Card';
    } else if (documentType == 'Driving License') {
      docTypeKey = 'drivingLicense';
      displayName = 'Driving License';
    } else if (documentType == 'Vehicle Image') {
      docTypeKey = 'vehicleImage';
      displayName = 'Vehicle Image';
    } else if (documentType == 'Bank Proof') {
      docTypeKey = 'bankProof';
      displayName = 'Bank Proof';
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentReuploadScreen(
          driverId: _driverId,
          documentType: docTypeKey,
          documentName: displayName,
        ),
      ),
    ).then((_) => _fetchDocumentStatus()); // Refresh after returning
  }

  Widget _buildReUploadButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: Icon(Icons.upload_file, color: Colors.white),
          label: Text(
            'Re-upload Rejected Documents',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DriverVerificationScreen(driverId: _driverId),
              ),
            ).then((_) => _fetchDocumentStatus());
          },
        ),
      ),
    );
  }
}
