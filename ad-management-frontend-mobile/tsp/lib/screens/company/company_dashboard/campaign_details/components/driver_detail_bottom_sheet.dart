import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'campaign_image_viewer.dart';

class DriverDetailBottomSheet extends StatefulWidget {
  final Map<String, dynamic> driver;
  final String? adProofPhotoUrl;
  final bool isAdProofVerified;

  const DriverDetailBottomSheet({
    Key? key,
    required this.driver,
    this.adProofPhotoUrl,
    this.isAdProofVerified = false,
  }) : super(key: key);

  @override
  State<DriverDetailBottomSheet> createState() =>
      _DriverDetailBottomSheetState();
}

class _DriverDetailBottomSheetState extends State<DriverDetailBottomSheet> {
  MapController? _mapController;
  List<Marker> _markers = [];
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    // Initialize map controller for OpenStreetMap
    _mapController = MapController();
    _setupMarkers();
  }

  void _setupMarkers() {
    List<Marker> markers = [];
    LatLng? position;
    
    // Check if we have currentLocation data in the new API format
    if (widget.driver['currentLocation'] != null &&
        widget.driver['currentLocation']['lat'] != null &&
        widget.driver['currentLocation']['lng'] != null) {
      
      // Get lat and lng from the currentLocation object
      final double lat = double.parse(widget.driver['currentLocation']['lat'].toString());
      final double lng = double.parse(widget.driver['currentLocation']['lng'].toString());
      position = LatLng(lat, lng);
      
      markers.add(
        Marker(
          width: 40.0,
          height: 40.0,
          point: position,
          child: _buildMarkerWidget(widget.driver['name']),
        ),
      );
    } 
    // Fallback to the old format if needed
    else if (widget.driver['location'] != null) {
      try {
        // Convert from Google LatLng to OpenStreetMap LatLng if needed
        final oldPosition = widget.driver['location'];
        position = LatLng(oldPosition.latitude, oldPosition.longitude);
        
        markers.add(
          Marker(
            width: 40.0,
            height: 40.0,
            point: position,
            child: _buildMarkerWidget(widget.driver['name']),
          ),
        );
      } catch (e) {
        debugPrint('Error converting location data: $e');
      }
    }
    
    setState(() {
      _markers = markers;
    });
  }
  
  Widget _buildMarkerWidget(String name) {
    return Column(
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
              child: const Icon(
                Icons.directions_car,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _viewImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CampaignImageViewer(
          imageUrl: imageUrl,
          title: 'Ad Proof',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final accentColor = const Color(0xFFFF5722);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Driver Details
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Driver Info Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: accentColor,
                          child: Text(
                            widget.driver['name'].substring(0, 1),
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.driver['name'],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                widget.driver['vehicleNumber'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textColor.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      widget.driver['status'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Driver Contact
                    _infoCard(
                      title: 'Contact Information',
                      icon: Icons.phone,
                      iconColor: accentColor,
                      backgroundColor: Colors.orange,
                      content: Column(
                        children: [
                          _infoRow(
                            icon: Icons.phone,
                            label: 'Phone Number',
                            value: widget.driver['phone'] ?? 'Not available',
                            iconColor: accentColor,
                            textColor: textColor,
                          ),
                          const SizedBox(height: 8),
                          _infoRow(
                            icon: Icons.access_time,
                            label: 'Last Active',
                            value: widget.driver['lastActive'] ?? 'Unknown',
                            iconColor: accentColor,
                            textColor: textColor,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Current Location
                    _infoCard(
                      title: 'Current Location',
                      icon: Icons.location_on,
                      iconColor: accentColor,
                      backgroundColor: Colors.orange,
                      content: SizedBox(
                        height: 200,
                        child: _hasValidLocation(widget.driver)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: FlutterMap(
                                  mapController: _mapController,
                                  options: MapOptions(
                                    initialCenter: _getLatLng(widget.driver),
                                    initialZoom: 14.0,
                                    onMapReady: () {
                                      setState(() {
                                        _mapReady = true;
                                      });
                                    },
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      subdomains: const ['a', 'b', 'c'],
                                    ),
                                    MarkerLayer(
                                      markers: _markers,
                                    ),
                                  ],
                                ),
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.location_off,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Location data not available',
                                      style: TextStyle(color: textColor),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Ad Proof Photo
                    _infoCard(
                      title: 'Ad Proof Photo',
                      icon: Icons.photo,
                      iconColor: accentColor,
                      backgroundColor: Colors.orange,
                      content: widget.adProofPhotoUrl != null
                          ? Column(
                              children: [
                                GestureDetector(
                                  onTap: () =>
                                      _viewImage(widget.adProofPhotoUrl!),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          widget.adProofPhotoUrl!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 200,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            height: 200,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.broken_image,
                                                  color: Colors.grey,
                                                  size: 48,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Failed to load image',
                                                  style: TextStyle(
                                                      color: Colors.grey[600]),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.6),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.fullscreen,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to view full size image',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textColor.withOpacity(0.6),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                          : Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.no_photography,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No ad proof uploaded yet',
                                      style: TextStyle(color: textColor),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              // Bottom Action
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Close'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required Widget content,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? Colors.black : Colors.grey[100];
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  // Helper method to check if driver has valid location data
  bool _hasValidLocation(Map<String, dynamic> driver) {
    // First check new format
    if (driver['currentLocation'] != null &&
        driver['currentLocation']['lat'] != null &&
        driver['currentLocation']['lng'] != null) {
      return true;
    }
    // Fallback to old format
    return driver['location'] != null;
  }

  // Helper method to get LatLng from driver data
  LatLng _getLatLng(Map<String, dynamic> driver) {
    // First try new format
    if (driver['currentLocation'] != null &&
        driver['currentLocation']['lat'] != null &&
        driver['currentLocation']['lng'] != null) {
      try {
        final double lat = double.parse(driver['currentLocation']['lat'].toString());
        final double lng = double.parse(driver['currentLocation']['lng'].toString());
        return LatLng(lat, lng);
      } catch (e) {
        debugPrint('Error parsing location data: $e');
      }
    }
    
    // Fallback to old format
    if (driver['location'] != null) {
      return driver['location'];
    }
    
    // Default fallback to Delhi
    return const LatLng(28.6139, 77.2090);
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    required Color textColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: textColor.withOpacity(0.7),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
