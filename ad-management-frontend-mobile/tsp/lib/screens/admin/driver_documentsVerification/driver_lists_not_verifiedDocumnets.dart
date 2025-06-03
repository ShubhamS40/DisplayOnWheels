import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tsp/screens/admin/driver_documentsVerification/driver_verification_detail.dart';
import 'package:intl/intl.dart';

// Reuse the same API config as in document_verification_driver.dart
class ApiConfig {
  // Change this to your server's IP or hostname when testing
  static String baseUrl = 'http://3.110.135.112:5000';

  // Admin API endpoints
  static String get pendingDriversUrl =>
      '$baseUrl/api/admin/pending-drivers-documents';
  static String driverDocumentsUrl(String driverId) =>
      '$baseUrl/api/admin/driver-documents/$driverId';
  static String verifyDriverUrl(String driverId) =>
      '$baseUrl/api/admin/driver-documents/$driverId/verify';
}

class Driver {
  final String id;
  final String fullName;
  final String email;
  final String contactNumber;
  final String vehicleNumber;
  final String vehicleType;
  final String verificationStatus;
  final DateTime? uploadedAt;

  Driver({
    required this.id,
    required this.fullName,
    required this.email,
    required this.contactNumber,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.verificationStatus,
    this.uploadedAt,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['driver']['id'],
      fullName: json['driver']['fullName'],
      email: json['driver']['email'],
      contactNumber: json['driver']['contactNumber'],
      vehicleNumber: json['driver']['vehicleNumber'],
      vehicleType: json['driver']['vehicleType'],
      verificationStatus: json['verificationStatus'],
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.parse(json['uploadedAt'])
          : DateTime.now().subtract(Duration(
              days: (10 * (json['driver']['id'].hashCode % 10))
                  .abs())), // Temporary dummy data
    );
  }
}

class PendingDriverVerificationList extends StatefulWidget {
  @override
  _PendingDriverVerificationListState createState() =>
      _PendingDriverVerificationListState();
}

class _PendingDriverVerificationListState
    extends State<PendingDriverVerificationList> {
  bool _isLoading = true;
  List<Driver> _allDrivers = [];
  List<Driver> _filteredDrivers = [];
  String _error = '';
  String _searchQuery = '';
  String _statusFilter = 'All';

  final List<String> _statusOptions = [
    'All',
    'PENDING',
    'APPROVED',
    'REJECTED'
  ];

  @override
  void initState() {
    super.initState();
    _fetchPendingDrivers();
  }

  Future<void> _fetchPendingDrivers() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.pendingDriversUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _allDrivers = (data['drivers'] as List)
              .map((driver) => Driver.fromJson(driver))
              .toList();
          _applyFilters();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load pending drivers: ${response.body}';
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

  void _applyFilters() {
    setState(() {
      _filteredDrivers = _allDrivers.where((driver) {
        // Apply status filter
        if (_statusFilter != 'All' &&
            driver.verificationStatus != _statusFilter) {
          return false;
        }

        // Apply search query
        if (_searchQuery.isNotEmpty) {
          return driver.fullName
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              driver.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              driver.contactNumber.contains(_searchQuery) ||
              driver.vehicleNumber
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
        }

        return true;
      }).toList();
    });
  }

  String _getTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
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
        title: Text('Driver Verification'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchPendingDrivers,
          ),
        ],
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
            Text('Error: $_error', style: TextStyle(color: Colors.red)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchPendingDrivers,
              child: Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildSearchAndFilterBar(),
        Expanded(
          child: _filteredDrivers.isEmpty
              ? Center(
                  child: Text(
                    'No drivers found matching your criteria',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchPendingDrivers,
                  child: ListView.builder(
                    itemCount: _filteredDrivers.length,
                    itemBuilder: (context, index) {
                      return _buildDriverCard(_filteredDrivers[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by name, email, or vehicle number',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _applyFilters();
              });
            },
          ),
          SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _statusOptions.map((status) {
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: _statusFilter == status,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _statusFilter = status;
                          _applyFilters();
                        });
                      }
                    },
                    backgroundColor: Colors.white,
                    selectedColor:
                        Theme.of(context).primaryColor.withOpacity(0.2),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(Driver driver) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToDriverDetails(driver),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      driver.fullName.isNotEmpty
                          ? driver.fullName[0].toUpperCase()
                          : '?',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver.fullName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(driver.email),
                        Text(driver.contactNumber),
                      ],
                    ),
                  ),
                  _getStatusChip(driver.verificationStatus),
                ],
              ),
              Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.directions_car, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    '${driver.vehicleType} (${driver.vehicleNumber})',
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                  Spacer(),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 16, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        'Uploaded ${_getTimeAgo(driver.uploadedAt)}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getStatusChip(String status) {
    Color color;
    IconData icon;

    switch (status) {
      case 'PENDING':
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case 'REJECTED':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case 'APPROVED':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
    }

    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 16),
      label: Text(
        status,
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }

  void _navigateToDriverDetails(Driver driver) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DriverVerification(driverId: driver.id),
      ),
    ).then((_) => _fetchPendingDrivers()); // Refresh after returning
  }
}
