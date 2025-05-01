import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tsp/screens/admin/company_documentsVerification/company_verification_detail.dart';
import 'package:intl/intl.dart';

// API Config class for company document verification
class CompanyApiConfig {
  // Change this to your server's IP or hostname when testing
  static String baseUrl = 'http://localhost:5000';

  // Admin API endpoints for company documents
  static String get pendingCompaniesUrl =>
      '$baseUrl/api/admin/pending-company-documents';
  static String companyDocumentsUrl(String companyId) =>
      '$baseUrl/api/admin/company-documents/$companyId';
  static String verifyCompanyUrl(String companyId) =>
      '$baseUrl/api/admin/company-documents/$companyId/verify';
}

class Company {
  final String id;
  final String businessName;
  final String email;
  final String contactNumber;
  final String businessType;
  final String verificationStatus;
  final DateTime? uploadedAt;

  Company({
    required this.id,
    required this.businessName,
    required this.email,
    required this.contactNumber,
    required this.businessType,
    required this.verificationStatus,
    this.uploadedAt,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['company']['id'],
      businessName: json['company']['businessName'],
      email: json['company']['email'],
      contactNumber: json['company']['contactNumber'],
      businessType: json['company']['businessType'],
      verificationStatus: json['verificationStatus'],
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.parse(json['uploadedAt'])
          : null,
    );
  }
}

class PendingCompanyVerificationList extends StatefulWidget {
  const PendingCompanyVerificationList({Key? key}) : super(key: key);

  @override
  State<PendingCompanyVerificationList> createState() =>
      _PendingCompanyVerificationListState();
}

class _PendingCompanyVerificationListState
    extends State<PendingCompanyVerificationList> {
  List<Company> companies = [];
  List<Company> filteredCompanies = [];
  bool isLoading = true;
  String errorMessage = '';
  String searchQuery = '';
  String statusFilter = 'All';
  final orangeColor = const Color(0xFFFF5722); // Primary app orange color

  @override
  void initState() {
    super.initState();
    _fetchPendingCompanies();
  }

  Future<void> _fetchPendingCompanies() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse(CompanyApiConfig.pendingCompaniesUrl),
        headers: {'Content-Type': 'application/json'},
      );

      print("Fetching pending companies from: ${CompanyApiConfig.pendingCompaniesUrl}");
      print("Response status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Companies data: ${data['companies'].length} items");
        
        List<Company> fetchedCompanies = [];

        for (var item in data['companies']) {
          fetchedCompanies.add(Company.fromJson(item));
          print("Processed company: ${item['company']['businessName']} - Status: ${item['verificationStatus']}");
        }
        
        setState(() {
          companies = fetchedCompanies;
          filteredCompanies = fetchedCompanies;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load pending companies. Please try again.';
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching companies: $e");
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      filteredCompanies = companies.where((company) {
        final matchesSearch = 
          company.businessName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          company.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
          company.contactNumber.contains(searchQuery);

        final matchesStatus = statusFilter == 'All' ||
            company.verificationStatus.toUpperCase() == statusFilter;

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  String _getTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('MMM d, yyyy').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Document Verification'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPendingCompanies,
        child: _buildBody(),
      ),
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
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchPendingCompanies,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (companies.isEmpty) {
      return const Center(
        child: Text(
          'No pending company documents to verify.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return Column(
      children: [
        _buildSearchAndFilterBar(),
        Expanded(
          child: filteredCompanies.isEmpty
              ? const Center(
                  child: Text(
                    'No companies match your filters.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filteredCompanies.length,
                  itemBuilder: (context, index) {
                    return _buildCompanyCard(filteredCompanies[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterBar() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey[850] : Colors.white;
    
    return Container(
      padding: const EdgeInsets.all(8),
      color: backgroundColor,
      child: Column(
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by name, email or phone',
              prefixIcon: Icon(Icons.search, color: orangeColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: orangeColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: orangeColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (value) {
              searchQuery = value;
              _applyFilters();
            },
          ),
          const SizedBox(height: 8),
          // Filter row
          Row(
            children: [
              const Text('Status: ', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              _buildFilterChip('All', 'All'),
              const SizedBox(width: 8),
              _buildFilterChip('Pending', 'PENDING'),
              const SizedBox(width: 8),
              _buildFilterChip('Rejected', 'REJECTED'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = statusFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: orangeColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? orangeColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            statusFilter = value;
            _applyFilters();
          });
        }
      },
    );
  }

  Widget _buildCompanyCard(Company company) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Text(
              company.businessName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            _getStatusChip(company.verificationStatus),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Company info row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Business type
                      Row(
                        children: [
                          const Icon(Icons.business, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Type: ${company.businessType}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Email
                      Row(
                        children: [
                          const Icon(Icons.email, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            company.email,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Phone
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            company.contactNumber,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Upload time
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Uploaded: ${_getTimeAgo(company.uploadedAt)}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => _navigateToCompanyDetails(company),
                child: const Text('View Documents'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getStatusChip(String status) {
    Color chipColor;
    String statusText;

    switch (status.toUpperCase()) {
      case 'APPROVED':
        chipColor = Colors.green;
        statusText = 'Approved';
        break;
      case 'REJECTED':
        chipColor = Colors.red;
        statusText = 'Rejected';
        break;
      case 'PENDING':
      default:
        chipColor = orangeColor;
        statusText = 'Pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        border: Border.all(color: chipColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(color: chipColor, fontSize: 12),
      ),
    );
  }

  void _navigateToCompanyDetails(Company company) async {
    // Wait for the result of the verification screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompanyVerificationDetailScreen(companyId: company.id),
      ),
    );

    // If we got back with a true result (verification was done) or no specific result,
    // refresh the companies list to show updated statuses
    if (result == true || result == null) {
      // Show loading indicator during refresh
      setState(() {
        isLoading = true;
      });
      
      // Slight delay to ensure backend has updated
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Refresh the list
      await _fetchPendingCompanies();
      
      // Re-apply any filters that were active
      _applyFilters();
    }
  }
}
