import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverLocationMap extends StatefulWidget {
  final List<Map<String, dynamic>> drivers;

  const DriverLocationMap({
    Key? key,
    required this.drivers,
  }) : super(key: key);

  @override
  State<DriverLocationMap> createState() => _DriverLocationMapState();
}

class _DriverLocationMapState extends State<DriverLocationMap> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  LatLngBounds? _bounds;

  @override
  void initState() {
    super.initState();
    _setupMarkersAndBounds();
  }

  void _setupMarkersAndBounds() {
    if (widget.drivers.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Create markers from drivers
    final Set<Marker> markers = {};
    final List<LatLng> positions = [];

    for (final driver in widget.drivers) {
      if (driver['location'] != null) {
        final LatLng position = driver['location'];
        positions.add(position);
        
        markers.add(
          Marker(
            markerId: MarkerId(driver['id']),
            position: position,
            infoWindow: InfoWindow(
              title: driver['name'],
              snippet: '${driver['vehicleNumber']} • ${driver['lastActive']}',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          ),
        );
      }
    }

    // Calculate bounds for camera position
    if (positions.isNotEmpty) {
      double minLat = positions.first.latitude;
      double maxLat = positions.first.latitude;
      double minLng = positions.first.longitude;
      double maxLng = positions.first.longitude;

      for (final position in positions) {
        if (position.latitude < minLat) minLat = position.latitude;
        if (position.latitude > maxLat) maxLat = position.latitude;
        if (position.longitude < minLng) minLng = position.longitude;
        if (position.longitude > maxLng) maxLng = position.longitude;
      }

      _bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );
    }

    setState(() {
      _markers = markers;
      _isLoading = false;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    
    if (_bounds != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          _bounds!,
          50.0, // padding
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final accentColor = const Color(0xFFFF5722);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Driver Locations',
          style: TextStyle(color: textColor),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: accentColor))
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(28.6139, 77.2090), // Default to Delhi
                    zoom: 10,
                  ),
                  markers: _markers,
                  onMapCreated: _onMapCreated,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapToolbarEnabled: true,
                  zoomControlsEnabled: true,
                ),
                
                // Map info panel
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.location_on,
                                color: accentColor,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Driver Locations',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_markers.length} drivers currently active',
                          style: TextStyle(
                            fontSize: 12,
                            color: textColor.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap on a marker to view driver details',
                          style: TextStyle(
                            fontSize: 12,
                            color: textColor.withOpacity(0.7),
                          ),
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
