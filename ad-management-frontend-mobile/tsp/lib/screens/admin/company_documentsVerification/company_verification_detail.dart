import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tsp/screens/admin/company_documentsVerification/company_detail_card.dart';
import 'package:tsp/screens/admin/company_documentsVerification/company_documents_card.dart';

class CompanyVerificationDetailScreen extends StatefulWidget {
  final String companyId;
  const CompanyVerificationDetailScreen({Key? key, required this.companyId})
      : super(key: key);

  @override
  State<CompanyVerificationDetailScreen> createState() => _CompanyVerificationDetailScreenState();
}

class _CompanyVerificationDetailScreenState extends State<CompanyVerificationDetailScreen> {
  Map<String, dynamic>? companyData;
  String adminMessage = "";
  final Map<String, String> docStatus = {};
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchCompanyDocuments();
  }

  Future<void> fetchCompanyDocuments() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse(
          'http://localhost:5000/api/admin/company-documents/${widget.companyId}'));
      
      print("API URL: http://localhost:5000/api/admin/company-documents/${widget.companyId}");
      print("Fetch company documents response: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        setState(() {
          companyData = data['companyDocuments'];
          
          // Use consistent document status field names that match the API
          docStatus['companyRegistrationStatus'] = companyData!['companyRegistrationStatus'] ?? 'PENDING';
          docStatus['idCardStatus'] = companyData!['idCardStatus'] ?? 'PENDING';
          docStatus['gstNumberStatus'] = companyData!['gstNumberStatus'] ?? 'PENDING';
          
          // Only set admin message if it exists in the response
          if (companyData!.containsKey('adminMessage') && companyData!['adminMessage'] != null) {
            adminMessage = companyData!['adminMessage'];
          }
          
          isLoading = false;
        });
        
        // Log document statuses for debugging
        print("Document statuses after fetch:");
        print("companyRegistrationStatus: ${docStatus['companyRegistrationStatus']}");
        print("idCardStatus: ${docStatus['idCardStatus']}");
        print("gstNumberStatus: ${docStatus['gstNumberStatus']}");
      } else {
        setState(() {
          errorMessage = 'Failed to fetch company documents: ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
      print('Failed to fetch company documents: $e');
    }
  }

  void updateStatus(String key, String status, [String? reason]) {
    // Log before update
    print("updateStatus called: $key changing from ${docStatus[key]} to $status");
    
    setState(() {
      docStatus[key] = status;
      // Only set admin message if this is a rejection with a reason
      if (status == 'REJECTED' && reason != null && reason.isNotEmpty) {
        adminMessage = reason;
        print("Setting admin message to: $reason");
      }
    });
    
    // Log after update to verify state change
    print("Status after update: $key = ${docStatus[key]}");
    print("Current docStatus: $docStatus");
  }

  Future<void> submitVerification() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Create a copy of the docStatus map to avoid any reference issues
      final statusToSubmit = Map<String, String>.from(docStatus);
      
      // Only include admin message if we're rejecting documents
      final bool anyRejected = statusToSubmit.values.any((status) => status == 'REJECTED');
      final String messageToSend = anyRejected ? adminMessage : '';
      
      final requestBody = {
        'companyRegistrationStatus': statusToSubmit['companyRegistrationStatus'],
        'idCardStatus': statusToSubmit['idCardStatus'],
        'gstNumberStatus': statusToSubmit['gstNumberStatus'],
        'adminMessage': messageToSend,
      };
      
      print("Submitting verification with data: $requestBody");
      
      final apiUrl = 'http://localhost:5000/api/admin/company-documents/${widget.companyId}/verify';
      print("API URL: $apiUrl");
      
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print("Verification API response: ${response.statusCode}");
      print("Response body: ${response.body}");
      
      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        // Successfully updated, now refresh the data to show updated statuses
        await fetchCompanyDocuments();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Company documents verification submitted successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        
        // Wait briefly to show the updated status before navigating back
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pop(context, true); // Pass true to indicate successful update
        }
      } else {
        setState(() {
          errorMessage = 'Failed to submit verification: ${response.body}';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit verification: ${response.statusCode}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $e';
      });
      print('Failed to submit verification: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Document Verification'),
        elevation: 0,
      ),
      body: _buildBody(),
      bottomNavigationBar: companyData != null
          ? BottomAppBar(
              color: Colors.blue,
              child: SizedBox(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.cancel, color: Colors.white),
                      label: const Text('Cancel', style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const VerticalDivider(
                      color: Colors.white54,
                      thickness: 1,
                      width: 1,
                      indent: 10,
                      endIndent: 10,
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: const Text('Submit', style: TextStyle(color: Colors.white)),
                      onPressed: submitVerification,
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchCompanyDocuments,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (companyData == null) {
      return const Center(
        child: Text('No company data available'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company Information Card
          CompanyDetailCard(companyData: companyData!),
          const SizedBox(height: 16),

          // Documents Section
          CompanyDocumentsCard(
            companyData: companyData!,
            docStatus: docStatus,
            onStatusUpdate: updateStatus,
          ),
          const SizedBox(height: 16),

          // Admin Message / Rejection Reason
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Admin Message',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Enter rejection reason or notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onChanged: (value) {
                      adminMessage = value;
                    },
                    controller: TextEditingController(text: adminMessage),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
