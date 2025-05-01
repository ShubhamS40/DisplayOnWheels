import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tsp/screens/company/company_document/company_upload_documents.dart';
import 'package:tsp/screens/company/company_document/company_reupload_document.dart';
import 'package:tsp/screens/company/company_recharge_plan/ad_recharge_plan_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:tsp/screens/driver/driver_dashboard.dart';

class CompanyDocumentStatusScreen extends StatefulWidget {
  const CompanyDocumentStatusScreen({Key? key}) : super(key: key);

  @override
  _CompanyDocumentStatusScreenState createState() =>
      _CompanyDocumentStatusScreenState();
}

class _CompanyDocumentStatusScreenState
    extends State<CompanyDocumentStatusScreen> {
  bool _isLoading = true;
  String _error = '';
  Map<String, dynamic>? _documentData;
  String _companyId = '';
  bool _skipToHome = false;

  // API Config class for consistent URLs
  static String get baseUrl => kIsWeb
      ? 'http://localhost:5000' // For web browser testing
      : 'http://10.0.2.2:5000'; // For emulator testing

  @override
  void initState() {
    super.initState();
    _loadCompanyId();
  }

  Future<void> _loadCompanyId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');
      if (companyId != null) {
        setState(() {
          _companyId = companyId;
        });
        _fetchDocumentStatus();
      } else {
        setState(() {
          _error = 'Company ID not found. Please login again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading company data: $e';
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
        Uri.parse('$baseUrl/api/company-docs/document-status/$_companyId'),
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

    // Make sure 'documents' exists in the response
    final documents = _documentData!['documents'] ?? {};

    // Check if it's a valid map before proceeding
    if (documents is! Map<String, dynamic>) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Invalid document data format',
                style: TextStyle(color: Colors.red)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchDocumentStatus,
              child: Text('Try Again'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompanyDocumentUploadScreen(),
                  ),
                );
              },
              child: Text('Upload Documents'),
            ),
          ],
        ),
      );
    }

    // Make sure we have the document status keys we need
    final Map<String, dynamic> documentStatuses = {
      'companyRegistrationStatus':
          documents['companyRegistrationStatus'] ?? 'PENDING',
      'idCardStatus': documents['idCardStatus'] ?? 'PENDING',
      'gstNumberStatus': documents['gstNumberStatus'] ?? 'PENDING',
      'adminMessage': documents['adminMessage'] ?? '',
    };

    final bool allApproved = _isAllDocumentsApproved(documentStatuses);
    final bool anyRejected = _hasRejectedDocuments(documentStatuses);

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
          if (allApproved) _buildContinueButton(),
        ],
      ),
    );
  }

  bool _isAllDocumentsApproved(Map<String, dynamic> documents) {
    final regStatus =
        documents['companyRegistrationStatus'] as String? ?? 'PENDING';
    final idStatus = documents['idCardStatus'] as String? ?? 'PENDING';
    final gstStatus = documents['gstNumberStatus'] as String? ?? 'PENDING';

    return regStatus == 'APPROVED' &&
        idStatus == 'APPROVED' &&
        gstStatus == 'APPROVED';
  }

  bool _hasRejectedDocuments(Map<String, dynamic> documents) {
    final regStatus =
        documents['companyRegistrationStatus'] as String? ?? 'PENDING';
    final idStatus = documents['idCardStatus'] as String? ?? 'PENDING';
    final gstStatus = documents['gstNumberStatus'] as String? ?? 'PENDING';

    return regStatus == 'REJECTED' ||
        idStatus == 'REJECTED' ||
        gstStatus == 'REJECTED';
  }

  Widget _buildStatusHeader(bool allApproved, bool anyRejected) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (allApproved) {
      statusText = 'All documents approved!';
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (anyRejected) {
      statusText = 'Some documents were rejected';
      statusColor = Colors.red;
      statusIcon = Icons.error;
    } else {
      statusText = 'Documents under review';
      statusColor = Colors.orange;
      statusIcon = Icons.pending;
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: statusColor, width: 1.0),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 30),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                if (!allApproved)
                  Text(
                    anyRejected
                        ? 'Please re-upload the rejected documents'
                        : 'Your documents are being reviewed by our team',
                    style: TextStyle(
                      fontSize: 14,
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
      'companyRegistrationStatus': 'Company Registration',
      'idCardStatus': 'ID Card',
      'gstNumberStatus': 'GST Number',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Documents Status',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        ...documentNames.entries.map((entry) {
          // Extract status with null safety
          final status = documents[entry.key] as String? ?? 'PENDING';
          final String docType = entry.key.replaceAll('Status', '');
          final String docUrl = documents['${docType}Url'] as String? ?? '';
          return _buildDocumentStatusCard(
              entry.value, status, docUrl, documents['adminMessage']);
        }).toList(),
        if (documents['adminMessage'] != null &&
            documents['adminMessage'].toString().isNotEmpty)
          _buildAdminMessageCard(documents['adminMessage']),
      ],
    );
  }

  Widget _buildDocumentStatusCard(String documentName, String status,
      String documentUrl, String? adminMessage) {
    IconData statusIcon;
    Color statusColor;
    String statusText;

    // Get document type for re-upload
    String documentTypeKey = _getDocumentTypeKey(documentName);

    // Ensure status is not null
    final docStatus = status.isNotEmpty ? status : 'PENDING';

    switch (docStatus) {
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
      case 'PENDING':
      default:
        statusIcon = Icons.hourglass_empty;
        statusColor = Colors.orange;
        statusText = 'Pending';
        break;
    }

    // Check if this document is mentioned in the admin message
    bool isDocumentInAdminMessage = false;
    if (adminMessage != null && adminMessage.isNotEmpty) {
      // Look for specific document keywords in admin message
      String lowercaseMessage = adminMessage.toLowerCase();
      String lowercaseName = documentName.toLowerCase();
      
      // Check if document name appears in admin message
      isDocumentInAdminMessage = lowercaseMessage.contains(lowercaseName) ||
          _isDocumentMatchingMessage(documentName, lowercaseMessage);
    }

    // Document needs attention if rejected OR mentioned in admin message
    bool needsAttention = docStatus == 'REJECTED' || isDocumentInAdminMessage;

    return GestureDetector(
      onTap: needsAttention ? () => _navigateToReuploadDocument(documentTypeKey, documentName) : null,
      child: Container(
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
          border: needsAttention
              ? Border.all(color: Colors.red.withOpacity(0.3), width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              statusIcon,
              color: statusColor,
              size: 28,
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
                  if (needsAttention)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Action required: re-upload document',
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
            // Show re-upload button for rejected or attention-needed documents
            if (needsAttention)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: IconButton(
                  icon: Icon(Icons.upload_file, color: Colors.red),
                  onPressed: () => _navigateToReuploadDocument(documentTypeKey, documentName),
                  tooltip: 'Re-upload document',
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper to check if document is mentioned in admin message
  bool _isDocumentMatchingMessage(String documentName, String message) {
    switch (documentName.toLowerCase()) {
      case 'company registration':
        return message.contains('company') || 
               message.contains('registration') || 
               message.contains('certificate');
      case 'id card':
        return message.contains('id') || 
               message.contains('card') || 
               message.contains('identity');
      case 'gst number':
        return message.contains('gst') || 
               message.contains('tax') || 
               message.contains('number');
      default:
        return false;
    }
  }

  // Get document type key for API
  String _getDocumentTypeKey(String documentName) {
    switch (documentName.toLowerCase()) {
      case 'company registration':
        return 'companyRegDoc';
      case 'id card':
        return 'idCard';
      case 'gst number':
        return 'gstNumber';
      default:
        return documentName.replaceAll(' ', '').toLowerCase();
    }
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
            style: TextStyle(color: Colors.red.shade800),
          ),
        ],
      ),
    );
  }

  Widget _buildReUploadButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CompanyDocumentUploadScreen(),
            ),
          );
        },
        icon: Icon(Icons.upload_file),
        label: Text('Reupload Documents'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Column(
      children: [
        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              // Navigate to ad campaign screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => RechargePlanScreen(),
                ),
              );
            },
            icon: Icon(Icons.campaign),
            label: Text('Launch Ad Campaign'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: TextStyle(fontSize: 16),
            ),
          ),
        ),
        SizedBox(height: 20),
        _buildSkipOption(),
      ],
    );
  }

  Widget _buildSkipOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Skip to dashboard: '),
        Switch(
          value: _skipToHome,
          onChanged: (value) {
            setState(() {
              _skipToHome = value;
              if (value) {
                _navigateToDashboard();
              }
            });
          },
          activeColor: Colors.blue,
        ),
      ],
    );
  }

  void _navigateToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DriverDashboard(),
      ),
    );
  }

  void _navigateToUploadDocument() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompanyDocumentUploadScreen(),
      ),
    );
  }
  
  void _navigateToReuploadDocument(String documentType, String documentName) {
    // Map the document type to the correct type expected by the backend
    String mappedDocType;
    
    if (documentType.toLowerCase().contains('company')) {
      mappedDocType = 'companyRegDoc';
    } else if (documentType.toLowerCase().contains('id')) {
      mappedDocType = 'idCard';
    } else if (documentType.toLowerCase().contains('gst')) {
      mappedDocType = 'gstNumber';  // Changed from 'gstDoc' to 'gstNumber' to match API expectations
    } else {
      // Default fallback
      mappedDocType = documentType;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompanyDocumentReuploadScreen(
          companyId: _companyId,
          documentType: mappedDocType, // Pass the mapped document type
          documentName: documentName,
        ),
      ),
    );
  }
}
