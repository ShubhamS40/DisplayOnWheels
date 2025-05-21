import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Location data model to avoid location package dependency in component
class LocationData {
  final double? latitude;
  final double? longitude;

  LocationData({this.latitude, this.longitude});
}

class MapComponent extends StatelessWidget {
  final bool isMapLoading;
  final MapController mapController;
  final LocationData? currentLocation;
  final Color primaryColor;
  final VoidCallback onRetry;
  final Function(MapController) onMapCreated;
  final VoidCallback? onMapReady;

  const MapComponent({
    Key? key,
    required this.isMapLoading,
    required this.mapController,
    required this.currentLocation,
    required this.primaryColor,
    required this.onRetry,
    required this.onMapCreated,
    this.onMapReady,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isMapLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
        ),
      );
    }

    // Default position (India)
    final defaultPosition = LatLng(28.6139, 77.2090);
    final currentPosition =
        currentLocation?.latitude != null && currentLocation?.longitude != null
            ? LatLng(currentLocation!.latitude!, currentLocation!.longitude!)
            : defaultPosition;

    try {
      return ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: currentPosition,
            initialZoom: 15.0,
            minZoom: 5.0,
            maxZoom: 18.0,
            interactionOptions:
                const InteractionOptions(flags: InteractiveFlag.all),
            onMapReady: () {
              // This ensures the map is fully initialized before any operations
              print("Map is ready and fully initialized");
              if (onMapReady != null) {
                onMapReady!();
              }
            },
          ),
          children: [
            // Base map layer
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.tsp.app',
            ),
            // Current location marker
            if (currentLocation?.latitude != null &&
                currentLocation?.longitude != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(
                      currentLocation!.latitude!,
                      currentLocation!.longitude!,
                    ),
                    width: 40.0,
                    height: 40.0,
                    child: Container(
                      child: Stack(
                        children: [
                          // Outer circle (pulse effect)
                          Center(
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          // Middle circle
                          Center(
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          // Inner circle (solid)
                          Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      );
    } catch (e) {
      print("Error creating OpenStreetMap: $e");
      // Fallback UI when map creation fails
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.map_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              "Could not load map",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Retry",
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        ),
      );
    }
  }
}
