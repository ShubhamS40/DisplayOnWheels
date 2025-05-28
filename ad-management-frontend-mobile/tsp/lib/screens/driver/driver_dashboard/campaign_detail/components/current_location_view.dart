import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';

class CurrentLocationView extends StatefulWidget {
  final Map<String, dynamic>? locationData;
  final double height;

  const CurrentLocationView({
    Key? key,
    this.locationData,
    this.height = 240,
  }) : super(key: key);

  @override
  State<CurrentLocationView> createState() => _CurrentLocationViewState();
}

class _CurrentLocationViewState extends State<CurrentLocationView> {
  MapController? _mapController;
  bool _mapReady = false;

  @override
  Widget build(BuildContext context) {
    // Check if location data is valid
    if (widget.locationData == null ||
        widget.locationData!['lat'] == null ||
        widget.locationData!['lng'] == null) {
      return _buildErrorContainer('Location data not available');
    }

    // Safely parse lat and lng with fallback values
    double lat;
    double lng;

    try {
      lat = double.parse(widget.locationData!['lat'].toString());
      lng = double.parse(widget.locationData!['lng'].toString());
    } catch (e) {
      debugPrint('Error parsing location data: $e');
      return _buildErrorContainer('Invalid location coordinates');
    }

    // Now build the map with valid coordinates
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(lat, lng),
          initialZoom: 15.0,
          onMapReady: () {
            setState(() {
              _mapReady = true;
              if (_mapController == null) {
                _mapController = MapController();
              }
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.tsp.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 40.0,
                height: 40.0,
                point: LatLng(lat, lng),
                child: const Column(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Color(0xFFFF5722),
                      size: 30,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContainer(String message) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
