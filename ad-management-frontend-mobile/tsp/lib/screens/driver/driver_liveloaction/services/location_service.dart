import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  final Location _location = Location();
  LocationData? _currentLocation;
  bool _isSharing = false;
  String _sharingStatus = "Not sharing";
  String _lastUpdated = "";
  final Function(String) showSnackBar;
  Timer? _locationUpdateTimer;
  String? _driverId;
  final String _apiEndpoint = "http://localhost:5000/api/driver-location/update-location";
  
  // Storage status information
  bool? _storedInRedis;
  bool? _storedInDatabase;
  double? _nextDatabaseUpdateIn;
  
  LocationService({required this.showSnackBar});

  bool get isSharing => _isSharing;
  String get sharingStatus => _sharingStatus;
  String get lastUpdated => _lastUpdated;
  LocationData? get currentLocation => _currentLocation;
  
  // Storage status getters
  bool? get storedInRedis => _storedInRedis;
  bool? get storedInDatabase => _storedInDatabase;
  double? get nextDatabaseUpdateIn => _nextDatabaseUpdateIn;

  // Initialize location service
  Future<void> initialize() async {
    try {
      // Load driver ID from shared preferences
      await _loadDriverId();
      
      // Set high accuracy and update interval
      await _location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 1000, // Update every 1 second
        distanceFilter: 0, // No minimum distance to trigger update
      );
      
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        developer.log('Location services not enabled, requesting...', name: 'LocationService');
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          developer.log('User denied location services', name: 'LocationService');
          showSnackBar('Location services are required for live tracking');
          return;
        }
      }

      var permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        developer.log('Location permission denied, requesting...', name: 'LocationService');
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          developer.log('User denied location permission', name: 'LocationService');
          showSnackBar('Location permission is required for live tracking');
          return;
        }
      }

      _currentLocation = await _location.getLocation();
      developer.log(
        'Initial location: ${_currentLocation?.latitude}, ${_currentLocation?.longitude}',
        name: 'LocationService'
      );
      
      // Set up a listener for location changes
      _location.onLocationChanged.listen(_handleLocationChange);
      
      showSnackBar('Location initialized successfully');
    } catch (e) {
      developer.log('Error initializing location: $e', name: 'LocationService');
      showSnackBar('Error getting location: $e');
    }
  }

  // Load driver ID from shared preferences
  Future<void> _loadDriverId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _driverId = prefs.getString('driverId');
      developer.log('Loaded driver ID: $_driverId', name: 'LocationService');
      
      if (_driverId == null) {
        showSnackBar('Driver ID not found. Please login again.');
      }
    } catch (e) {
      developer.log('Error loading driver ID: $e', name: 'LocationService');
    }
  }
  
  // Private method to handle location changes
  void _handleLocationChange(LocationData locationData) {
    if (locationData.latitude != null && locationData.longitude != null) {
      _currentLocation = locationData;
      developer.log(
        'Location updated: ${_currentLocation?.latitude}, ${_currentLocation?.longitude}',
        name: 'LocationService'
      );
      updateTimestamp();
    }
  }
  
  // Send location update to server
  Future<void> _sendLocationToServer() async {
    if (_currentLocation?.latitude == null || _currentLocation?.longitude == null) {
      developer.log('Cannot send location update: No valid location data', name: 'LocationService');
      return;
    }
    
    if (_driverId == null) {
      // Try to load driver ID again
      await _loadDriverId();
      if (_driverId == null) {
        developer.log('Cannot send location update: No driver ID', name: 'LocationService');
        return;
      }
    }
    
    try {
      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'driverId': _driverId,
          'lat': _currentLocation!.latitude,
          'lng': _currentLocation!.longitude,
        }),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          // Extract storage details from response
          final details = responseData['details'];
          _storedInRedis = details != null ? details['storedInRedis'] ?? false : false;
          _storedInDatabase = details != null ? details['storedInDatabase'] ?? false : false;
          _nextDatabaseUpdateIn = details != null ? details['nextDatabaseUpdateIn'] ?? 0.0 : 0.0;
          
          developer.log(
            'Location sent to server successfully: ${_currentLocation!.latitude}, ${_currentLocation!.longitude}\n'
            'Redis: $_storedInRedis, Database: $_storedInDatabase, Next DB update in: ${_nextDatabaseUpdateIn}s',
            name: 'LocationService'
          );
          
          // Update timestamp when database is updated
          if (_storedInDatabase == true) {
            updateTimestamp();
          }
        } else {
          developer.log('Server returned error: ${responseData['message']}', name: 'LocationService');
        }
      } else {
        developer.log('Failed to send location to server. Status code: ${response.statusCode}', name: 'LocationService');
      }
    } catch (e) {
      developer.log('Error sending location to server: $e', name: 'LocationService');
    }
  }

  // Start sharing location
  void startLocationSharing(MapController mapController) {
    _isSharing = true;
    _sharingStatus = "Sharing";
    _lastUpdated = "Started just now";
    developer.log('Starting location sharing', name: 'LocationService');
    
    // Ensure we have the latest location data
    _location.getLocation().then((locationData) {
      _currentLocation = locationData;
      
      if (locationData.latitude != null && locationData.longitude != null) {
        developer.log(
          'Starting with location: ${locationData.latitude}, ${locationData.longitude}',
          name: 'LocationService'
        );
        
        // Send initial location update
        _sendLocationToServer();
        
        // Start timer to continuously send location updates every 1 second
        _locationUpdateTimer?.cancel();
        _locationUpdateTimer = Timer.periodic(Duration(seconds: 1), (timer) {
          if (_isSharing) {
            _sendLocationToServer();
          } else {
            timer.cancel();
          }
        });
        
      } else {
        developer.log('No valid location data available for sharing', name: 'LocationService');
      }
    });
  }

  // Stop sharing location
  void stopLocationSharing() {
    _isSharing = false;
    _sharingStatus = "Not sharing";
    _lastUpdated = "";
    // Cancel the timer to stop sending location updates
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
    developer.log('Stopped location sharing and updates to server', name: 'LocationService');
  }
  
  // Go to current location
  Future<void> goToCurrentLocation(MapController mapController) async {
    // Get fresh location data first
    try {
      developer.log("Requesting current location data...", name: 'LocationService');
      _currentLocation = await _location.getLocation();
      developer.log(
        "Current location received - Latitude: ${_currentLocation?.latitude}, Longitude: ${_currentLocation?.longitude}",
        name: 'LocationService'
      );
      
      if (_currentLocation != null &&
          _currentLocation!.latitude != null &&
          _currentLocation!.longitude != null) {
        try {
          // Create LatLng object for OpenStreetMap
          final newCenter = LatLng(
            _currentLocation!.latitude!,
            _currentLocation!.longitude!
          );
          
          // Display coordinates to the user
          showSnackBar("Your location: ${_currentLocation!.latitude!.toStringAsFixed(6)}, ${_currentLocation!.longitude!.toStringAsFixed(6)}");
          
          try {
            // Move map to current location with animation
            mapController.move(newCenter, 18.0); // Using fixed zoom level 18 for detailed view
          } catch (e) {
            developer.log("Error with map camera: $e", name: 'LocationService');
            // Try again with a delay - map might need time to initialize fully
            await Future.delayed(Duration(milliseconds: 500));
            try {
              mapController.move(newCenter, 15.0);
            } catch (e2) {
              developer.log("Second attempt to move map failed: $e2", name: 'LocationService');
              showSnackBar("Map not ready yet. Please try again in a moment.");
              return;
            }
          }
        } catch (e) {
          developer.log("Error navigating to current location: $e", name: 'LocationService');
          showSnackBar("Couldn't navigate to current location");
        }
      } else {
        if (_currentLocation == null) {
          showSnackBar("Location data is unavailable");
          developer.log("Location data is null", name: 'LocationService');
        } else {
          showSnackBar("Invalid location coordinates");
          developer.log(
            "Invalid location coordinates: ${_currentLocation?.latitude}, ${_currentLocation?.longitude}", 
            name: 'LocationService'
          );
        }
      }
    } catch (e) {
      developer.log("Error getting fresh location: $e", name: 'LocationService');
      showSnackBar("Couldn't get your location. Please check location permissions.");
    }
  }
  
  // Update timestamp for location sharing
  void updateTimestamp() {
    if (_isSharing) {
      final now = DateTime.now();
      _lastUpdated = "Last updated: ${now.hour}:${now.minute.toString().padLeft(2, '0')}";
      
      // Display coordinates when timestamp is updated
      if (_currentLocation?.latitude != null && _currentLocation?.longitude != null) {
        developer.log(
          "Current location: ${_currentLocation!.latitude!.toStringAsFixed(6)}, ${_currentLocation!.longitude!.toStringAsFixed(6)}",
          name: 'LocationService'
        );
      }
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
