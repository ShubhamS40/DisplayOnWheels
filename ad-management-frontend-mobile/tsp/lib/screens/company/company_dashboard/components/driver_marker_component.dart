import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'driver_location_data.dart';

class DriverMarkerComponent {
  static Marker buildDriverMarker(DriverLocationData driver, Function(DriverLocationData) onTap) {
    final markerColor = driver.isActive ? Colors.green : Colors.orange;
    
    return Marker(
      point: LatLng(driver.latitude, driver.longitude),
      width: 50.0,
      height: 50.0,
      child: GestureDetector(
        onTap: () => onTap(driver),
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
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Outer circle (pulse effect)
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: markerColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Middle circle
                  Center(
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: markerColor.withOpacity(0.4),
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
                        color: markerColor,
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
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                driver.name.split(' ')[0], // First name only for brevity
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
