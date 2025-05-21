import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
    
    // Create a new controller
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

    // Set timer to update timestamps
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_locationService.isSharing && mounted) {
        setState(() {
          _locationService.updateTimestamp();
        });
      }
    });
  }

  Future<void> _initializeServices() async {
    await _locationService.initialize();
    await _bluetoothService.initialize();
    setState(() {
      _isMapLoading = false;
    });
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
      print('Map not ready when trying to go to current location');
      return;
    }
    
    setState(() {
      _isMapLoading = true; // Show loading indicator
    });
    
    try {
      print('Attempting to navigate to current location: ${_locationService.currentLocation?.latitude}, ${_locationService.currentLocation?.longitude}');
      await _locationService.goToCurrentLocation(_mapController);
    } catch (e) {
      print("Error in _goToMyLocation: $e");
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
              });
              _initializeServices();
            },
            onMapCreated: (controller) {
              print("Map created with controller");
              setState(() {
                _mapInitialized = true;
                _isMapLoading = false;
              });
            },
            onMapReady: () {
              // This will be called when the map is fully rendered and ready
              setState(() {
                _mapReady = true;
              });
              
              print("Map is fully ready and rendered. Navigating to location...");
              
              // Now it's safe to navigate to current location
              if (_locationService.currentLocation != null) {
                try {
                  _locationService.goToCurrentLocation(_mapController);
                } catch (e) {
                  print("Error navigating to location: $e");
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
