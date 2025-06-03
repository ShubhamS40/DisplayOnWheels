import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverLocationData {
  final String driverId;
  final String campaignDriverId;
  final String campaignId;
  final String campaignTitle;
  final String name;
  final String phone;
  final String email;
  final String vehicleNumber;
  final String vehicleType;
  final bool isActive;
  final bool isAssigned;
  final double latitude;
  final double longitude;
  final String timestamp;
  final String lastUpdateAgo;

  DriverLocationData({
    required this.driverId,
    required this.campaignDriverId,
    required this.campaignId,
    required this.campaignTitle,
    required this.name,
    required this.phone,
    required this.email,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.isActive,
    required this.isAssigned,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.lastUpdateAgo,
  });

  factory DriverLocationData.fromJson(Map<String, dynamic> json) {
    return DriverLocationData(
      driverId: json['driverId'] as String,
      campaignDriverId: json['campaignDriverId'] as String,
      campaignId: json['campaignId'] as String,
      campaignTitle: json['campaignTitle'] as String? ?? 'Unknown Campaign',
      name: json['name'] as String? ?? 'Unknown Driver',
      phone: json['phone'] as String? ?? 'N/A',
      email: json['email'] as String? ?? 'N/A',
      vehicleNumber: json['vehicleNumber'] as String? ?? 'N/A',
      vehicleType: json['vehicleType'] as String? ?? 'Unknown',
      isActive: json['isActive'] as bool? ?? false,
      isAssigned: json['isAssigned'] as bool? ?? true,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      lastUpdateAgo: json['lastUpdateAgo'] as String? ?? 'Unknown',
    );
  }
}

class CompanyDriversMapScreen extends StatefulWidget {
  const CompanyDriversMapScreen({Key? key}) : super(key: key);

  @override
  State<CompanyDriversMapScreen> createState() => _CompanyDriversMapScreenState();
}

class _CompanyDriversMapScreenState extends State<CompanyDriversMapScreen> {
  final MapController _mapController = MapController();
  List<DriverLocationData> _driverLocations = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  Timer? _refreshTimer;
  DriverLocationData? _selectedDriver;
  String? _companyId;

  // Metadata from API response
  int _totalDrivers = 0;
  int _activeDrivers = 0;
  String _lastUpdateTime = '';

  @override
  void initState() {
    super.initState();
    _getCompanyId().then((_) => _fetchDriverLocations());

    // Set up periodic refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _fetchDriverLocations();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _getCompanyId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _companyId = prefs.getString('companyId');
    });
  }

  Future<void> _fetchDriverLocations() async {
    if (_companyId == null) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Company ID not found. Please login again.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _hasError = false;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'http://3.110.135.112:5000/api/company/compaign-assign-drivers/$_companyId/drivers-locations'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final List<dynamic> driversData = data['drivers'];

          // Extract metadata if available
          if (data.containsKey('metadata')) {
            final metadata = data['metadata'];
            _totalDrivers = metadata['totalDrivers'] ?? 0;
            _activeDrivers = metadata['activeDrivers'] ?? 0;
            _lastUpdateTime =
                metadata['timestamp'] ?? DateTime.now().toIso8601String();
          } else {
            // If metadata not found, count active drivers
            int activeCount = 0;
            for (var driver in driversData) {
              if (driver['isActive'] == true) activeCount++;
            }
            _totalDrivers = driversData.length;
            _activeDrivers = activeCount;
            _lastUpdateTime = DateTime.now().toIso8601String();
          }

          setState(() {
            _driverLocations = driversData
                .map((driver) => DriverLocationData.fromJson(driver))
                .toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _hasError = true;
            _errorMessage =
                data['message'] ?? 'Failed to fetch driver locations';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Server error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Network error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _centerMapToAllDrivers() {
    if (_driverLocations.isEmpty) return;

    if (_driverLocations.length == 1) {
      _mapController.move(
        LatLng(_driverLocations[0].latitude, _driverLocations[0].longitude),
        14.0,
      );
      return;
    }

    // Calculate bounds to include all drivers
    double minLat = 90.0;
    double maxLat = -90.0;
    double minLng = 180.0;
    double maxLng = -180.0;

    for (var driver in _driverLocations) {
      minLat = (driver.latitude < minLat) ? driver.latitude : minLat;
      maxLat = (driver.latitude > maxLat) ? driver.latitude : maxLat;
      minLng = (driver.longitude < minLng) ? driver.longitude : minLng;
      maxLng = (driver.longitude > maxLng) ? driver.longitude : maxLng;
    }

    // Add some padding
    final latPadding = (maxLat - minLat) * 0.1;
    final lngPadding = (maxLng - minLng) * 0.1;

    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;

    final zoom = _calculateZoomLevel(
      minLat - latPadding,
      maxLat + latPadding,
      minLng - lngPadding,
      maxLng + lngPadding,
    );

    _mapController.move(LatLng(centerLat, centerLng), zoom);
  }

  double _calculateZoomLevel(
      double minLat, double maxLat, double minLng, double maxLng) {
    // Simple algorithm to calculate appropriate zoom level
    final latRange = maxLat - minLat;
    final lngRange = maxLng - minLng;
    final maxRange = latRange > lngRange ? latRange : lngRange;

    // Rough mapping of distance to zoom levels
    if (maxRange > 10) return 5;
    if (maxRange > 5) return 7;
    if (maxRange > 1) return 9;
    if (maxRange > 0.5) return 11;
    if (maxRange > 0.1) return 13;
    if (maxRange > 0.05) return 14;
    if (maxRange > 0.01) return 15;
    return 16;
  }

  void _showDriverDetails(DriverLocationData driver) {
    setState(() {
      _selectedDriver = driver;
    });
  }

  void _closeDriverDetails() {
    setState(() {
      _selectedDriver = null;
    });
  }

  String _formatTimestamp(String timestamp) {
    try {
      final DateTime dateTime = DateTime.parse(timestamp);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(dateTime);

      if (difference.inSeconds < 60) {
        return 'just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} min ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hr ago';
      } else {
        return '${difference.inDays} days ago';
      }
    } catch (e) {
      return 'recently';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Live Driver Tracking',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchDriverLocations,
            tooltip: 'Refresh locations',
          ),
          IconButton(
            icon: Icon(Icons.fit_screen),
            onPressed: _centerMapToAllDrivers,
            tooltip: 'View all drivers',
          ),
        ],
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: false,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: const Color(0xFFFF5722),
              ),
            )
          : _hasError
              ? _buildErrorWidget()
              : _driverLocations.isEmpty
                  ? _buildEmptyWidget()
                  : _buildMapWidget(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          SizedBox(height: 16),
          Text(
            'Error Loading Driver Locations',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchDriverLocations,
            icon: Icon(Icons.refresh),
            label: Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5722),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No Driver Locations Available',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'There are currently no drivers sharing their location.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchDriverLocations,
            icon: Icon(Icons.refresh),
            label: Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5722),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapWidget() {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _driverLocations.isNotEmpty
                ? LatLng(
                    _driverLocations[0].latitude, _driverLocations[0].longitude)
                : LatLng(28.6139, 77.2090), // Default to India if no drivers
            initialZoom: 12.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
            onMapReady: _centerMapToAllDrivers,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.tsp.app',
            ),
            MarkerLayer(
              markers: _driverLocations.map((driver) {
                return Marker(
                  point: LatLng(driver.latitude, driver.longitude),
                  width: 50,
                  height: 50,
                  child: GestureDetector(
                    onTap: () => _showDriverDetails(driver),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: driver.isActive
                                ? Colors.green
                                : Colors.orange,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.directions_car,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          child: Text(
                            driver.vehicleNumber,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),

        // Statistics panel
        Positioned(
          top: 16,
          right: 16,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              width: 180,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Driver Statistics',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Drivers:',
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        '$_totalDrivers',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Active Drivers:',
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        '$_activeDrivers',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Updated ${_formatTimestamp(_lastUpdateTime)}',
                    style: TextStyle(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Driver details panel when a driver is selected
        if (_selectedDriver != null)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFFFF5722),
                          foregroundColor: Colors.white,
                          child: Icon(Icons.person),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedDriver!.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Vehicle: ${_selectedDriver!.vehicleType} (${_selectedDriver!.vehicleNumber})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: _closeDriverDetails,
                        ),
                      ],
                    ),
                    Divider(),
                    Text(
                      'Campaign: ${_selectedDriver!.campaignTitle}',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Status: ${_selectedDriver!.isActive ? "Active" : "Inactive"}',
                          style: TextStyle(
                            color: _selectedDriver!.isActive
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Updated: ${_formatTimestamp(_selectedDriver!.timestamp)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            // Center map on this driver
                            _mapController.move(
                              LatLng(_selectedDriver!.latitude,
                                  _selectedDriver!.longitude),
                              15.0,
                            );
                          },
                          icon: Icon(Icons.my_location, size: 16),
                          label: Text('Center'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5722),
                            foregroundColor: Colors.white,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            // Show detailed info
                            _showDriverDetailsDialog(_selectedDriver!);
                          },
                          icon: Icon(Icons.info_outline, size: 16),
                          label: Text('Details'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showDriverDetailsDialog(DriverLocationData driver) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgColor,
        title: Row(
          children: [
            Icon(
              Icons.person,
              color: const Color(0xFFFF5722),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                driver.name,
                style: TextStyle(
                  fontSize: 18,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailItem('Vehicle Type', driver.vehicleType),
              _buildDetailItem('Vehicle Number', driver.vehicleNumber),
              _buildDetailItem('Campaign', driver.campaignTitle),
              _buildDetailItem('Phone', driver.phone),
              _buildDetailItem('Email', driver.email),
              _buildDetailItem('Status', driver.isActive ? 'Active' : 'Inactive'),
              _buildDetailItem('Last Updated', _formatTimestamp(driver.timestamp)),
              Divider(),
              Text(
                'Location:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Latitude: ${driver.latitude}',
                style: TextStyle(color: textColor),
              ),
              Text(
                'Longitude: ${driver.longitude}',
                style: TextStyle(color: textColor),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: const Color(0xFFFF5722)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];
    final valueColor = isDarkMode ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
