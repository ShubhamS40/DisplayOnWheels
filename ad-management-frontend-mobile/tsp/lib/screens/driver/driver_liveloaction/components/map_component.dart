import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:developer' as developer;

// Location data model to avoid location package dependency in component
class LocationData {
  final double? latitude;
  final double? longitude;

  LocationData({this.latitude, this.longitude});
}

class MapComponent extends StatefulWidget {
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
  State<MapComponent> createState() => _MapComponentState();
}

class _MapComponentState extends State<MapComponent> {

  @override
  Widget build(BuildContext context) {
    // Debug the current location data
    developer.log(
      'Building map component with location: ${widget.currentLocation?.latitude}, ${widget.currentLocation?.longitude}',
      name: 'MapComponent',
    );

    if (widget.isMapLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(widget.primaryColor),
            ),
            SizedBox(height: 16),
            Text(
              "Initializing map...",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      );
    }

    // Default position (India)
    final defaultPosition = LatLng(28.6139, 77.2090);
    final currentPosition =
        widget.currentLocation?.latitude != null && widget.currentLocation?.longitude != null
            ? LatLng(widget.currentLocation!.latitude!, widget.currentLocation!.longitude!)
            : defaultPosition;

    try {
      return ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: FlutterMap(
          mapController: widget.mapController,
          options: MapOptions(
            initialCenter: currentPosition,
            initialZoom: 15.0,
            minZoom: 5.0,
            maxZoom: 18.0,
            interactionOptions:
                const InteractionOptions(flags: InteractiveFlag.all),
            onMapReady: () async {
              // This ensures the map is fully initialized before any operations
              developer.log('Map is ready and fully initialized', name: 'MapComponent');
              
              // Add a small delay to ensure map is fully rendered
              await Future.delayed(const Duration(milliseconds: 500));
              
              // Call onMapCreated first if it's provided
              widget.onMapCreated(widget.mapController);
              
              // Then call onMapReady if provided
              if (widget.onMapReady != null) {
                widget.onMapReady!();
              }
            },
          ),
          children: [
            // Base map layer
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.tsp.app',
              // Add error handling for tile loading
              errorImage: NetworkImage('https://tile.openstreetmap.org/0/0/0.png'),
            ),
            // Current location marker
            if (widget.currentLocation?.latitude != null &&
                widget.currentLocation?.longitude != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(
                      widget.currentLocation!.latitude!,
                      widget.currentLocation!.longitude!,
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
                                color: widget.primaryColor.withOpacity(0.2),
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
                                color: widget.primaryColor.withOpacity(0.4),
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
                                color: widget.primaryColor,
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
      developer.log("Error creating OpenStreetMap: $e", name: 'MapComponent');
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
            if (widget.currentLocation != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                  "Current Location: ${widget.currentLocation!.latitude}, ${widget.currentLocation!.longitude}",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: widget.onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.primaryColor,
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
