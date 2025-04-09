import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as permission;
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class DriverLiveLocation extends StatefulWidget {
  const DriverLiveLocation({Key? key}) : super(key: key);

  @override
  State<DriverLiveLocation> createState() => _DriverLiveLocationState();
}

class _DriverLiveLocationState extends State<DriverLiveLocation>
    with SingleTickerProviderStateMixin {
  // Map controller
  GoogleMapController? _mapController;
  Location _location = Location();
  bool _isSharing = false;
  LocationData? _currentLocation;
  bool _isMapLoading = true;

  // Bluetooth functionality
  static const platform = MethodChannel("bluetooth_channel");
  List<Map<String, String>> connectedDevices = [];
  bool isTargetDeviceConnected = false;
  bool isBluetoothOn = false;
  bool isScanning = false;
  Timer? _refreshTimer;

  // Animation controller for sliding panels
  late AnimationController _animationController;
  bool _showBluetoothPanel = false;

  // Map style
  final CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(28.6139, 77.2090), // Default to New Delhi
    zoom: 14.0,
  );

  // Map styling
  String _mapStyle = '';

  // Location sharing info
  String _sharingStatus = "Not sharing";
  String _lastUpdated = "";

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
    _initializeLocation();
    requestBluetoothPermission();
    _loadMapStyle();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Set timer to update timestamps
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isSharing && mounted) {
        setState(() {
          _lastUpdated =
              "Last updated: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}";
        });
      }
    });
  }

  Future<void> _loadMapStyle() async {
    try {
      String style = await rootBundle.loadString('assets/map_style.json');
      setState(() {
        _mapStyle = style;
      });
    } catch (e) {
      // If style file isn't available, use default style
      print("Error loading map style: $e");
    }
  }

  /// Location methods
  Future<void> _initializeLocation() async {
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
      setState(() {
        _isMapLoading = false;
      });

      if (_currentLocation != null && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isMapLoading = false;
      });

      _showSnackBar('Error getting location: $e');
    }
  }

  void _showSnackBar(String message) {
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
    if (!isTargetDeviceConnected && !_isSharing) {
      _showBluetoothWarningDialog();
      return;
    }

    setState(() {
      _isSharing = !_isSharing;
      _sharingStatus = _isSharing ? "Sharing" : "Not sharing";
      _lastUpdated = _isSharing ? "Started just now" : "";
    });

    if (_isSharing) {
      _startLocationSharing();
    } else {
      _stopLocationSharing();
    }
  }

  void _startLocationSharing() {
    try {
      _location.onLocationChanged.listen((LocationData currentLocation) {
        if (_mapController != null &&
            _isSharing &&
            currentLocation != null &&
            currentLocation.latitude != null &&
            currentLocation.longitude != null) {
          try {
            _mapController!
                .animateCamera(
              CameraUpdate.newLatLng(
                LatLng(currentLocation.latitude!, currentLocation.longitude!),
              ),
            )
                .catchError((e) {
              print("Error updating camera position: $e");
            });
          } catch (e) {
            print("Exception updating camera position: $e");
          }
        }
      });
    } catch (e) {
      print("Error starting location sharing: $e");
      _showSnackBar("Couldn't start location sharing");
    }
  }

  void _stopLocationSharing() {
    // Implement stop sharing logic
    // e.g., stop sending location updates to your backend
  }

  /// Bluetooth methods
  Future<void> requestBluetoothPermission() async {
    if (await permission.Permission.bluetoothConnect.request().isGranted &&
        await permission.Permission.bluetoothScan.request().isGranted) {
      _checkBluetoothStatus();
      getConnectedDevices();
      startAutoRefresh();
    }
  }

  Future<void> _checkBluetoothStatus() async {
    try {
      final bool result = await platform.invokeMethod("isBluetoothEnabled");
      setState(() {
        isBluetoothOn = result;
      });
    } on PlatformException catch (e) {
      print("Error checking Bluetooth status: ${e.message}");
    }
  }

  Future<void> _toggleBluetooth() async {
    try {
      if (isBluetoothOn) {
        await platform.invokeMethod("disableBluetooth");
      } else {
        await platform.invokeMethod("enableBluetooth");
      }
      await _checkBluetoothStatus();
    } on PlatformException catch (e) {
      print("Error toggling Bluetooth: ${e.message}");
    }
  }

  void startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (mounted) {
        getConnectedDevices();
      }
    });
  }

  Future<void> getConnectedDevices() async {
    if (!isBluetoothOn) return;

    try {
      final List<dynamic> result =
          await platform.invokeMethod("getConnectedBluetoothDevices");

      if (mounted) {
        setState(() {
          connectedDevices =
              result.map((device) => Map<String, String>.from(device)).toList();

          // Check for target device
          isTargetDeviceConnected = connectedDevices.any((device) =>
              (device["address"] ?? "").toLowerCase() == "19:2b:20:a4:ef:43");
        });
      }
    } on PlatformException catch (e) {
      print("Error: ${e.message}");
    }
  }

  Future<void> _scanForDevices() async {
    if (!isBluetoothOn) {
      _showSnackBar('Please turn on Bluetooth first');
      return;
    }

    setState(() {
      isScanning = true;
    });

    try {
      await platform.invokeMethod("startDiscovery");

      // Scan for 10 seconds
      await Future.delayed(const Duration(seconds: 10));
      await platform.invokeMethod("stopDiscovery");
      await getConnectedDevices();
    } on PlatformException catch (e) {
      print("Error scanning for devices: ${e.message}");
    } finally {
      if (mounted) {
        setState(() {
          isScanning = false;
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
          _buildMapLayer(),

          // Status Bar
          _buildStatusBar(),

          // Control Panel
          _buildControlPanel(),

          // Bluetooth Panel
          _buildBluetoothPanel(),
        ],
      ),
    );
  }

  Widget _buildMapLayer() {
    if (_isMapLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
        ),
      );
    }

    // Handle potential map initialization errors with try-catch
    try {
      return GoogleMap(
        initialCameraPosition: _initialPosition,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        compassEnabled: false,
        buildingsEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          try {
            setState(() {
              _mapController = controller;
            });

            if (_mapStyle.isNotEmpty) {
              try {
                controller.setMapStyle(_mapStyle).catchError((e) {
                  print("Error setting map style: $e");
                });
              } catch (e) {
                print("Exception setting map style: $e");
              }
            }

            if (_currentLocation != null &&
                _currentLocation!.latitude != null &&
                _currentLocation!.longitude != null) {
              try {
                controller
                    .animateCamera(
                  CameraUpdate.newLatLng(
                    LatLng(
                      _currentLocation!.latitude!,
                      _currentLocation!.longitude!,
                    ),
                  ),
                )
                    .catchError((e) {
                  print("Error animating camera: $e");
                });
              } catch (e) {
                print("Exception animating camera: $e");
              }
            }
          } catch (e) {
            print("Error in onMapCreated callback: $e");
          }
        },
      );
    } catch (e) {
      print("Error creating Google Map: $e");
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
              onPressed: () {
                setState(() {
                  _isMapLoading = true;
                });
                _initializeLocation();
              },
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

  Widget _buildStatusBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 20,
      right: 20,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black54),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Text(
                'Live Location',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: 8),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isSharing ? successColor : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _isSharing ? 'Sharing' : 'Not Sharing',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _isSharing ? Colors.white : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Positioned(
      bottom: 30,
      left: 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusInfoCard(),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Controls',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    _buildActionButton(
                      icon: _isSharing ? Icons.stop_circle : Icons.play_circle,
                      label: _isSharing ? 'Stop Sharing' : 'Start Sharing',
                      color: _isSharing ? errorColor : successColor,
                      onTap: _toggleLocationSharing,
                    ),
                    SizedBox(width: 12),
                    _buildActionButton(
                      icon: Icons.my_location,
                      label: 'My Location',
                      color: secondaryColor,
                      onTap: () {
                        if (_currentLocation != null &&
                            _currentLocation!.latitude != null &&
                            _currentLocation!.longitude != null &&
                            _mapController != null) {
                          try {
                            _mapController!
                                .animateCamera(
                              CameraUpdate.newLatLng(
                                LatLng(
                                  _currentLocation!.latitude!,
                                  _currentLocation!.longitude!,
                                ),
                              ),
                            )
                                .catchError((e) {
                              print("Error moving to current location: $e");
                              _showSnackBar("Couldn't move to your location");
                            });
                          } catch (e) {
                            print("Exception moving to current location: $e");
                            _showSnackBar("Couldn't access map");
                          }
                        } else {
                          _showSnackBar("Location not available");
                        }
                      },
                    ),
                    SizedBox(width: 12),
                    _buildActionButton(
                      icon: Icons.bluetooth,
                      label: 'Bluetooth',
                      color: primaryColor,
                      onTap: _toggleBluetoothPanel,
                      badge: isTargetDeviceConnected,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool badge = false,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, color: color, size: 28),
                  if (badge)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: successColor,
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
              SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusInfoCard() {
    return AnimatedOpacity(
      opacity: isTargetDeviceConnected ? 1.0 : 0.7,
      duration: Duration(milliseconds: 300),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isTargetDeviceConnected ? successColor : Colors.grey.shade600,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isTargetDeviceConnected ? successColor : Colors.grey)
                  .withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isTargetDeviceConnected
                    ? Icons.check_circle_outline
                    : Icons.error_outline,
                color: Colors.white,
                size: 30,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isTargetDeviceConnected ? 'Board is ON' : 'Board is OFF',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    isTargetDeviceConnected
                        ? 'Your advertisement board is connected'
                        : 'Your advertisement board is not connected',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBluetoothPanel() {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      bottom: _showBluetoothPanel ? 0 : -400,
      left: 0,
      right: 0,
      height: 400,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Panel header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bluetooth Settings',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: _toggleBluetoothPanel,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bluetooth toggle
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isBluetoothOn
                          ? primaryColor.withOpacity(0.1)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isBluetoothOn
                            ? primaryColor.withOpacity(0.3)
                            : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.bluetooth,
                              color: isBluetoothOn
                                  ? primaryColor
                                  : Colors.grey.shade400,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Bluetooth',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: isBluetoothOn
                                    ? Colors.black87
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: isBluetoothOn,
                          onChanged: (value) => _toggleBluetooth(),
                          activeColor: primaryColor,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Scan button
                  if (isBluetoothOn)
                    ElevatedButton.icon(
                      onPressed: isScanning ? null : _scanForDevices,
                      icon: isScanning
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(Icons.search, size: 20),
                      label: Text(
                        isScanning ? 'Scanning...' : 'Scan for Devices',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: Size(double.infinity, 48),
                      ),
                    ),
                  SizedBox(height: 16),

                  // Connected devices title
                  Text(
                    'Connected Devices',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12),

                  // Connected devices list
                  if (connectedDevices.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.bluetooth_disabled,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'No devices connected',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      constraints: BoxConstraints(maxHeight: 150),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: connectedDevices.length,
                        itemBuilder: (context, index) {
                          return _buildDeviceItem(connectedDevices[index]);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceItem(Map<String, String> device) {
    final String address = device["address"] ?? "";
    final bool isTargetDevice = address.toLowerCase() == "19:2b:20:a4:ef:43";

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isTargetDevice
            ? successColor.withOpacity(0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isTargetDevice
              ? successColor.withOpacity(0.5)
              : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.bluetooth,
            color: isTargetDevice ? successColor : Colors.blue,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device["name"] ?? "Unknown Device",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  address,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (isTargetDevice)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: successColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Ad Board',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _refreshTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }
}
