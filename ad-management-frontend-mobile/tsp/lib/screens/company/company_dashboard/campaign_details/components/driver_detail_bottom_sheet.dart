import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'campaign_image_viewer.dart';

class DriverDetailBottomSheet extends StatefulWidget {
  final Map<String, dynamic> driver;

  const DriverDetailBottomSheet({
    Key? key,
    required this.driver,
  }) : super(key: key);

  @override
  State<DriverDetailBottomSheet> createState() =>
      _DriverDetailBottomSheetState();
}

class _DriverDetailBottomSheetState extends State<DriverDetailBottomSheet> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _setupMarkers();
  }

  void _setupMarkers() {
    if (widget.driver['location'] != null) {
      setState(() {
        _markers = {
          Marker(
            markerId: MarkerId(widget.driver['id']),
            position: widget.driver['location'],
            infoWindow: InfoWindow(
              title: widget.driver['name'],
              snippet: 'Vehicle: ${widget.driver['vehicleNumber']}',
            ),
          ),
        };
      });
    }
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
                        child: widget.driver['location'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: widget.driver['location'],
                                    zoom: 14,
                                  ),
                                  markers: _markers,
                                  onMapCreated: (controller) {
                                    _mapController = controller;
                                  },
                                  myLocationEnabled: false,
                                  zoomControlsEnabled: false,
                                  mapToolbarEnabled: false,
                                ),
                              )
                            : Center(
                                child: Text(
                                  'Location not available',
                                  style: TextStyle(color: textColor),
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Ad Proof Images
                    _infoCard(
                      title: 'Ad Proof Uploads',
                      icon: Icons.photo_library,
                      iconColor: accentColor,
                      backgroundColor: Colors.orange,
                      content: widget.driver['uploadedImages'] != null &&
                              (widget.driver['uploadedImages'] as List)
                                  .isNotEmpty
                          ? GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount:
                                  (widget.driver['uploadedImages'] as List)
                                      .length,
                              itemBuilder: (context, index) {
                                final imageUrl =
                                    widget.driver['uploadedImages'][index];
                                return GestureDetector(
                                  onTap: () => _viewImage(imageUrl),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: NetworkImage(imageUrl),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                        margin: const EdgeInsets.all(4),
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.7),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Icon(
                                          Icons.fullscreen,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                  'No images uploaded yet',
                                  style: TextStyle(color: textColor),
                                ),
                              ),
                            ),
                    ),

                    const SizedBox(height: 20),
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
