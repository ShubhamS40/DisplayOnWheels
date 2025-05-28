import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:developer' as developer;

// Import components
import 'components/map_component.dart';
import 'components/status_bar_component.dart';
import 'components/control_panel_component.dart';
import 'components/bluetooth_panel_component.dart';

// Import services
import 'services/location_service.dart';
import 'services/bluetooth_service.dart';

class DriverLiveLocation extends StatefulWidget {
  const DriverLiveLocation({Key? key}) : super(key: key);

  @override
  State<DriverLiveLocation> createState() => _DriverLiveLocationState();
}

class _DriverLiveLocationState extends State<DriverLiveLocation>
    with SingleTickerProviderStateMixin {
  // Map controller
  late MapController _mapController;
  bool _mapInitialized = false;
  bool _mapReady = false;
  bool _isMapLoading = true;

  // Services
  late LocationService _locationService;
  late BluetoothService _bluetoothService;

  // Animation controller for sliding panels
  late AnimationController _animationController;
  bool _showBluetoothPanel = false;

  // Theme colors
  final Color primaryColor = const Color(0xFFFF9800);
  final Color primaryDarkColor = const Color(0xFFE65100);
  final Color secondaryColor = const Color(0xFF2196F3);
  final Color successColor = const Color(0xFF4CAF50);
  final Color errorColor = const Color(0xFFF44336);
  final Color surfaceColor = const Color(0xFFF5F5F5);
  final Color cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    
    developer.log('Initializing driver live location screen', name: 'DriverLiveLocation');
    
    // Create a new controller - must be done before any usage
    _mapController = MapController();
    
    // Initialize services
    _locationService = LocationService(showSnackBar: _showSnackBar);
    _bluetoothService = BluetoothService(showSnackBar: _showSnackBar);

    // Initialize location service first
    _initializeServices();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Set timer to update timestamps and refresh UI
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          // Just trigger a rebuild to update location data on screen
          if (_locationService.currentLocation != null) {
            developer.log(
              'Timer update - Location: ${_locationService.currentLocation?.latitude}, ${_locationService.currentLocation?.longitude}',
              name: 'DriverLiveLocation'
            );
          }
          if (_locationService.isSharing) {
            _locationService.updateTimestamp();
          }
        });
      }
    });
  }

  Future<void> _initializeServices() async {
    setState(() {
      _isMapLoading = true;
    });
    
    try {
      await _locationService.initialize();
      await _bluetoothService.initialize();
      
      if (_locationService.currentLocation != null) {
        developer.log(
          'Services initialized. Location: ${_locationService.currentLocation?.latitude}, ${_locationService.currentLocation?.longitude}',
          name: 'DriverLiveLocation'
        );
      } else {
        developer.log('Services initialized but no location data available yet', name: 'DriverLiveLocation');
      }
    } catch (e) {
      developer.log('Error initializing services: $e', name: 'DriverLiveLocation');
      _showSnackBar('Error initializing location services. Please restart the app.');
    } finally {
      if (mounted) {
        setState(() {
          _isMapLoading = false;
        });
      }
    }
  }

  // No longer needed with OpenStreetMap

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(10),
        backgroundColor: Colors.black.withOpacity(0.8),
      ),
    );
  }

  void _toggleLocationSharing() {
    setState(() {
      _locationService.toggleLocationSharing(_mapController);
    });
  }

  void _goToMyLocation() async {
    // Check if map is fully ready
    if (!_mapReady) {
      _showSnackBar('Map is not ready yet. Please wait a moment and try again.');
      developer.log('Map not ready when trying to go to current location', name: 'DriverLiveLocation');
      return;
    }
    
    setState(() {
      _isMapLoading = true; // Show loading indicator
    });
    
    try {
      // First, let's display the current location data regardless of map state
      if (_locationService.currentLocation != null) {
        final lat = _locationService.currentLocation!.latitude;
        final lng = _locationService.currentLocation!.longitude;
        
        if (lat != null && lng != null) {
          _showSnackBar('Your coordinates: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}');
          developer.log('Current location: $lat, $lng', name: 'DriverLiveLocation');
        } else {
          _showSnackBar('Location data incomplete. Please check location permissions.');
        }
      } else {
        _showSnackBar('No location data available. Please check location permissions.');
      }
      
      // Then try to move map to that location
      await _locationService.goToCurrentLocation(_mapController);
    } catch (e) {
      developer.log("Error in _goToMyLocation: $e", name: 'DriverLiveLocation');
      _showSnackBar('Could not navigate to your location. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isMapLoading = false; // Hide loading indicator
        });
      }
    }
  }

  void _toggleBluetoothPanel() {
    setState(() {
      _showBluetoothPanel = !_showBluetoothPanel;
    });

    if (_showBluetoothPanel) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _showBluetoothWarningDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: errorColor),
              SizedBox(width: 8),
              Text('Bluetooth Warning'),
            ],
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Text(
            'Your advertisement board is not connected. Please connect to continue sharing location.',
            style: GoogleFonts.poppins(
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _toggleBluetoothPanel();
              },
              child: Text(
                'OPEN BLUETOOTH SETTINGS',
                style: GoogleFonts.poppins(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'CANCEL',
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map Layer
          MapComponent(
            isMapLoading: _isMapLoading,
            mapController: _mapController,
            currentLocation: _locationService.currentLocation != null
                ? LocationData(
                    latitude: _locationService.currentLocation?.latitude,
                    longitude: _locationService.currentLocation?.longitude)
                : null,
            primaryColor: primaryColor,
            onRetry: () {
              setState(() {
                _isMapLoading = true;
                _mapReady = false;
                _mapInitialized = false;
              });
              _initializeServices();
            },
            onMapCreated: (controller) {
              developer.log("Map created with controller", name: 'DriverLiveLocation');
              setState(() {
                _mapInitialized = true;
              });
            },
            onMapReady: () {
              // This will be called when the map is fully rendered and ready
              developer.log("Map is fully ready and rendered", name: 'DriverLiveLocation');
              setState(() {
                _mapReady = true;
                _isMapLoading = false;
              });
              
              // Show current location in a snackbar even if map navigation fails
              if (_locationService.currentLocation != null) {
                final lat = _locationService.currentLocation!.latitude;
                final lng = _locationService.currentLocation!.longitude;
                if (lat != null && lng != null) {
                  _showSnackBar('Your coordinates: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}');
                }
              }
              
              // Now it's safe to navigate to current location
              if (_locationService.currentLocation != null) {
                try {
                  // Wait a moment to ensure map is fully rendered
                  Future.delayed(Duration(milliseconds: 500), () {
                    if (mounted) {
                      _locationService.goToCurrentLocation(_mapController);
                    }
                  });
                } catch (e) {
                  developer.log("Error navigating to location: $e", name: 'DriverLiveLocation');
                  _showSnackBar("Could not go to your location. Please try again later.");
                }
              }
            },
          ),

          // Status Bar
          StatusBarComponent(
            isSharing: _locationService.isSharing,
            successColor: successColor,
            onBackPressed: () => Navigator.of(context).pop(),
            onToggleSharing: (value) => _toggleLocationSharing(),
          ),

          // Control Panel
          ControlPanelComponent(
            isSharing: _locationService.isSharing,
            sharingStatus: _locationService.sharingStatus,
            lastUpdated: _locationService.lastUpdated,
            cardColor: cardColor,
            successColor: successColor,
            errorColor: errorColor,
            secondaryColor: secondaryColor,
            onToggleLocationSharing: _toggleLocationSharing,
            onGoToMyLocation: _goToMyLocation,
            onShowBluetoothPanel: _toggleBluetoothPanel,
            isBluetoothOn: _bluetoothService.isBluetoothOn,
            isTargetDeviceConnected: _bluetoothService.isTargetDeviceConnected,
            storedInRedis: _locationService.storedInRedis,
            storedInDatabase: _locationService.storedInDatabase,
            nextDatabaseUpdateIn: _locationService.nextDatabaseUpdateIn,
          ),

          // Bluetooth Panel
          BluetoothPanelComponent(
            showBluetoothPanel: _showBluetoothPanel,
            animation: _animationController,
            isBluetoothOn: _bluetoothService.isBluetoothOn,
            isScanning: _bluetoothService.isScanning,
            connectedDevices: _bluetoothService.connectedDevices,
            onToggleBluetooth: () {
              setState(() {
                _bluetoothService.toggleBluetooth().then((_) {
                  setState(() {});
                });
              });
            },
            onScanForDevices: () {
              setState(() {
                _bluetoothService.scanForDevices().then((_) {
                  setState(() {});
                });
              });
            },
            primaryColor: primaryColor,
            successColor: successColor,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _bluetoothService.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
