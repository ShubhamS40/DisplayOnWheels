import 'dart:async';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart' as permission;

class BluetoothService {
  static const MethodChannel platform = MethodChannel("bluetooth_channel");
  
  List<Map<String, String>> connectedDevices = [];
  bool isTargetDeviceConnected = false;
  bool isBluetoothOn = false;
  bool isScanning = false;
  Timer? _refreshTimer;
  
  final Function(String) showSnackBar;
  
  BluetoothService({required this.showSnackBar});
  
  // Initialize Bluetooth service
  Future<void> initialize() async {
    await requestPermissions();
  }
  
  // Request Bluetooth permissions
  Future<void> requestPermissions() async {
    if (await permission.Permission.bluetoothConnect.request().isGranted &&
        await permission.Permission.bluetoothScan.request().isGranted) {
      await checkBluetoothStatus();
      await getConnectedDevices();
      startAutoRefresh();
    }
  }
  
  // Check Bluetooth status
  Future<void> checkBluetoothStatus() async {
    try {
      final bool result = await platform.invokeMethod("isBluetoothEnabled");
      isBluetoothOn = result;
    } on PlatformException catch (e) {
      print("Error checking Bluetooth status: ${e.message}");
    }
  }
  
  // Toggle Bluetooth on/off
  Future<void> toggleBluetooth() async {
    try {
      if (isBluetoothOn) {
        await platform.invokeMethod("disableBluetooth");
      } else {
        await platform.invokeMethod("enableBluetooth");
      }
      await checkBluetoothStatus();
    } on PlatformException catch (e) {
      print("Error toggling Bluetooth: ${e.message}");
    }
  }
  
  // Start auto-refresh for Bluetooth devices
  void startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      await getConnectedDevices();
    });
  }
  
  // Stop auto-refresh
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
  }
  
  // Get connected Bluetooth devices
  Future<void> getConnectedDevices() async {
    if (!isBluetoothOn) return;

    try {
      final List<dynamic> result =
          await platform.invokeMethod("getConnectedBluetoothDevices");

      connectedDevices =
          result.map((device) => Map<String, String>.from(device)).toList();

      // Check for target device
      isTargetDeviceConnected = connectedDevices.any((device) =>
          (device["address"] ?? "").toLowerCase() == "19:2b:20:a4:ef:43");

    } on PlatformException catch (e) {
      print("Error getting connected devices: ${e.message}");
    }
  }
  
  // Scan for Bluetooth devices
  Future<void> scanForDevices() async {
    if (!isBluetoothOn) {
      showSnackBar('Please turn on Bluetooth first');
      return;
    }

    isScanning = true;

    try {
      await platform.invokeMethod("startDiscovery");

      // Scan for 10 seconds
      await Future.delayed(const Duration(seconds: 10));
      await platform.invokeMethod("stopDiscovery");
      await getConnectedDevices();
    } on PlatformException catch (e) {
      print("Error scanning for devices: ${e.message}");
    } finally {
      isScanning = false;
    }
  }
  
  // Dispose resources
  void dispose() {
    stopAutoRefresh();
  }
}
