import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  final Location _location = Location();
  LocationData? _currentLocation;
  bool _isSharing = false;
  String _sharingStatus = "Not sharing";
  String _lastUpdated = "";
  final Function(String) showSnackBar;
  
  LocationService({required this.showSnackBar});

  bool get isSharing => _isSharing;
  String get sharingStatus => _sharingStatus;
  String get lastUpdated => _lastUpdated;
  LocationData? get currentLocation => _currentLocation;

  // Initialize location service
  Future<void> initialize() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      var permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      _currentLocation = await _location.getLocation();
    } catch (e) {
      showSnackBar('Error getting location: $e');
    }
  }

  // Start sharing location
  void startLocationSharing(MapController mapController) {
    _isSharing = true;
    _sharingStatus = "Sharing";
    _lastUpdated = "Started just now";
    
    try {
      _location.onLocationChanged.listen((LocationData currentLocation) {
        if (mapController != null &&
            _isSharing &&
            currentLocation.latitude != null &&
            currentLocation.longitude != null) {
          try {
            // Create LatLng object for OpenStreetMap
            final newCenter = LatLng(
              currentLocation.latitude!,
              currentLocation.longitude!
            );
            
            // Check if the map controller's camera is initialized
            try {
              // Move map to current location with animation
              final currentZoom = mapController.camera.zoom; // Get current zoom level
              mapController.move(newCenter, currentZoom); // Keep current zoom level
            } catch (e) {
              // If camera isn't ready, use a default zoom level
              print("Camera not ready, using default zoom: $e");
              mapController.move(newCenter, 15.0); // Use default zoom level
            }
          } catch (e) {
            print("Exception updating map position: $e");
          }
        }
      });
    } catch (e) {
      print("Error starting location sharing: $e");
      showSnackBar("Couldn't start location sharing");
    }
  }

  // Stop sharing location
  void stopLocationSharing() {
    _isSharing = false;
    _sharingStatus = "Not sharing";
    _lastUpdated = "";
    // Add any additional logic to stop sharing location
  }
  
  // Go to current location
  Future<void> goToCurrentLocation(MapController mapController) async {
    // Get fresh location data first
    try {
      print("Requesting current location data...");
      _currentLocation = await _location.getLocation();
      print("Current location received - Latitude: ${_currentLocation?.latitude}, Longitude: ${_currentLocation?.longitude}");
      
      if (_currentLocation != null &&
          _currentLocation!.latitude != null &&
          _currentLocation!.longitude != null) {
        try {
          // Create LatLng object for OpenStreetMap
          final newCenter = LatLng(
            _currentLocation!.latitude!,
            _currentLocation!.longitude!
          );
          
          // Make sure the map camera is initialized
          try {
            // Move map to current location with animation
            mapController.move(newCenter, 18.0); // Using fixed zoom level 18 for detailed view
            showSnackBar("Moved to your current location");
          } catch (e) {
            print("Error with map camera: $e");
            // Try again with a delay - map might need time to initialize fully
            await Future.delayed(Duration(milliseconds: 500));
            mapController.move(newCenter, 15.0);
            showSnackBar("Moved to your current location");
          }
        } catch (e) {
          print("Error navigating to current location: $e");
          showSnackBar("Couldn't navigate to current location");
        }
      } else {
        if (_currentLocation == null) {
          showSnackBar("Location data is unavailable");
          print("Location data is null");
        } else if (mapController == null) {
          showSnackBar("Map is not ready yet");
          print("Map controller is null");
        } else {
          showSnackBar("Invalid location coordinates");
          print("Invalid location coordinates: ${_currentLocation?.latitude}, ${_currentLocation?.longitude}");
        }
      }
    } catch (e) {
      print("Error getting fresh location: $e");
      showSnackBar("Couldn't get your location. Please check location permissions.");
    }
  }
  
  // Update timestamp for location sharing
  void updateTimestamp() {
    if (_isSharing) {
      _lastUpdated = "Last updated: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}";
    }
  }
  
  // Toggle location sharing
  void toggleLocationSharing(MapController mapController) {
    if (_isSharing) {
      stopLocationSharing();
    } else {
      startLocationSharing(mapController);
    }
  }
}
