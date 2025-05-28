import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class OpenStreetMapView extends StatefulWidget {
  final List<Map<String, dynamic>> drivers;
  final bool fullScreen;

  const OpenStreetMapView({
    Key? key,
    required this.drivers,
    this.fullScreen = false,
  }) : super(key: key);

  @override
  State<OpenStreetMapView> createState() => _OpenStreetMapViewState();
}

class _OpenStreetMapViewState extends State<OpenStreetMapView> {
  MapController? _mapController;
  List<Marker> _markers = [];
  bool _isLoading = true;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    // Initialize the map controller right away
    _mapController = MapController();
    _setupMarkers();
  }

  void _setupMarkers() {
    if (widget.drivers.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final List<Marker> markers = [];
    final List<LatLng> positions = [];

    for (final driver in widget.drivers) {
      if (driver.containsKey('currentLocation') &&
          driver['currentLocation'] != null &&
          driver['currentLocation']['lat'] != null &&
          driver['currentLocation']['lng'] != null) {
        final double lat =
            double.parse(driver['currentLocation']['lat'].toString());
        final double lng =
            double.parse(driver['currentLocation']['lng'].toString());
        final LatLng position = LatLng(lat, lng);
        positions.add(position);

        markers.add(
          Marker(
            width: 40.0,
            height: 40.0,
            point: position,
            child: GestureDetector(
              onTap: () {
                _showDriverInfo(driver);
              },
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFFFF5722),
                        child: Icon(
                          Icons.directions_car,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  if (widget.fullScreen)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        driver['name'] ?? 'Driver',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }
    }

    setState(() {
      _markers = markers;
      _isLoading = false;
    });

    // Center the map if we have positions
    if (positions.isNotEmpty) {
      _centerMap(positions);
    }
  }

  void _centerMap(List<LatLng> positions) {
    if (_mapController == null || !_mapReady) {
      // Map not ready yet, will center later in onMapCreated
      return;
    }
    
    if (positions.length == 1) {
      // If only one position, center on it with a closer zoom
      _mapController!.move(positions[0], 15.0);
      return;
    }

    // Calculate bounds
    double minLat = 90.0, maxLat = -90.0;
    double minLng = 180.0, maxLng = -180.0;

    for (final LatLng pos in positions) {
      if (pos.latitude < minLat) minLat = pos.latitude;
      if (pos.latitude > maxLat) maxLat = pos.latitude;
      if (pos.longitude < minLng) minLng = pos.longitude;
      if (pos.longitude > maxLng) maxLng = pos.longitude;
    }

    // Add padding
    final paddingDegrees = 0.02; // ~2km padding
    minLat -= paddingDegrees;
    maxLat += paddingDegrees;
    minLng -= paddingDegrees;
    maxLng += paddingDegrees;

    // Calculate center and appropriate zoom level
    final center = LatLng(
      (minLat + maxLat) / 2,
      (minLng + maxLng) / 2,
    );

    // Calculate zoom level (simplified approach)
    final latDiff = (maxLat - minLat).abs();
    final lngDiff = (maxLng - minLng).abs();
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

    // Convert difference to zoom level (rough approximation)
    double zoom = 12.0;
    if (maxDiff > 0.5)
      zoom = 8.0;
    else if (maxDiff > 0.2)
      zoom = 10.0;
    else if (maxDiff > 0.1)
      zoom = 11.0;
    else if (maxDiff > 0.05)
      zoom = 12.0;
    else if (maxDiff > 0.02)
      zoom = 13.0;
    else if (maxDiff > 0.01)
      zoom = 14.0;
    else
      zoom = 15.0;

    // Move the map
    if (_mapController != null) {
      _mapController!.move(center, zoom);
    }
  }

  void _showDriverInfo(Map<String, dynamic> driver) {
    final verified = driver['advertisementProofVerified'] ?? false;
    final hasProof = driver['AddProofPhoto'] != null &&
        driver['AddProofPhoto'].toString().isNotEmpty;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFFF5722).withOpacity(0.1),
              child: const Icon(
                Icons.person,
                color: Color(0xFFFF5722),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driver['name'] ?? 'Driver',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    driver['vehicleNumber'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow(
              icon: Icons.phone,
              title: 'Phone',
              value: driver['phone'] ?? 'N/A',
            ),
            _infoRow(
              icon: Icons.access_time,
              title: 'Assigned',
              value: _formatDateTime(driver['assignedAt']),
            ),
            _infoRow(
              icon: Icons.photo,
              title: 'Ad Proof',
              value: hasProof
                  ? (verified ? 'Verified ✓' : 'Pending Verification')
                  : 'Not Uploaded',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (hasProof)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _viewAdProof(driver['AddProofPhoto']);
              },
              child: const Text(
                'View Ad Proof',
                style: TextStyle(color: Color(0xFFFF5722)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: const Color(0xFFFF5722),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
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

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) {
      return 'N/A';
    }

    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateTimeStr;
    }
  }

  void _viewAdProof(String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Ad Proof'),
              backgroundColor: const Color(0xFFFF5722),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: Image.network(
                  url,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: const Color(0xFFFF5722),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.broken_image,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFF5722),
            ),
          )
        : Column(
            children: [
              if (_markers.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No location data available',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              else
                Expanded(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: const LatLng(28.6139, 77.2090), // Default to Delhi
                      initialZoom: 11.0,
                      onMapReady: () {
                        setState(() {
                          _mapReady = true;
                        });
                        // Initialize controller if needed
                        if (_mapController == null) {
                          _mapController = MapController();
                        }
                        // Center map on markers once map is ready
                        if (_markers.isNotEmpty) {
                          final positions = _markers.map((marker) => marker.point).toList();
                          _centerMap(positions);
                        }
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: _markers,
                      ),
                    ],
                  ),
                ),
            ],
          );
  }
}
