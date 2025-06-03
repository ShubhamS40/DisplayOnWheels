import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

// Import components
import 'components/stats_panel_component.dart';
import 'components/driver_details_panel_component.dart';
import 'components/driver_marker_component.dart';
import 'model/driver_location_data.dart';

class AdminDriversMapScreen extends StatefulWidget {
  const AdminDriversMapScreen({Key? key}) : super(key: key);

  @override
  State<AdminDriversMapScreen> createState() => _AdminDriversMapScreenState();
}

class _AdminDriversMapScreenState extends State<AdminDriversMapScreen> {
  final MapController _mapController = MapController();
  List<DriverLocationData> _driverLocations = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  Timer? _refreshTimer;
  DriverLocationData? _selectedDriver;

  @override
  void initState() {
    super.initState();
    _fetchDriverLocations();

    // Set up periodic refresh every 5 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
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

  // Metadata from API response
  int _totalDrivers = 0;
  int _activeDrivers = 0;
  String _lastUpdateTime = '';

  Future<void> _fetchDriverLocations() async {
    setState(() {
      _hasError = false;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'http://3.110.135.112:5000/api/admin/drivers-locations/all-drivers-locations'),
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
              markers: _driverLocations
                  .map((driver) => DriverMarkerComponent.buildDriverMarker(
                      driver, _showDriverDetails))
                  .toList(),
            ),
          ],
        ),

        // Statistics panel
        Positioned(
          top: 16,
          right: 16,
          child: StatsPanelComponent(
            totalDrivers: _totalDrivers,
            activeDrivers: _activeDrivers,
            lastUpdated: _lastUpdateTime.isNotEmpty
                ? 'Updated ${_formatTimestamp(_lastUpdateTime)}'
                : 'Just now',
          ),
        ),

        // Driver details panel when a driver is selected
        if (_selectedDriver != null)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: DriverDetailsPanelComponent(
              driver: _selectedDriver!,
              mapController: _mapController,
              onClose: _closeDriverDetails,
              primaryColor: const Color(0xFFFF5722),
            ),
          ),
      ],
    );
  }

  // All component methods have been moved to separate files
}
