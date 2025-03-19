import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class BluetoothPage extends StatefulWidget {
  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  static const platform = MethodChannel("bluetooth_channel");
  List<Map<String, String>> connectedDevices = [];
  bool isTargetDeviceConnected = false;
  bool isAdvertisementOn = false;
  Timer? _refreshTimer; // Store the timer to cancel it later

  @override
  void initState() {
    super.initState();
    requestBluetoothPermission();
  }

  /// Starts auto-refresh every 5 seconds
  void startAutoRefresh() {
    _refreshTimer?.cancel(); // Ensure no duplicate timers
    _refreshTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      getConnectedDevices();
    });
  }

  /// Request Bluetooth permissions
  Future<void> requestBluetoothPermission() async {
    if (await Permission.bluetoothConnect.request().isGranted &&
        await Permission.bluetoothScan.request().isGranted) {
      getConnectedDevices();
      startAutoRefresh();
    }
  }

  /// Get connected Bluetooth devices from native code
  Future<void> getConnectedDevices() async {
    print("Fetching connected devices...");
    try {
      final List<dynamic> result =
          await platform.invokeMethod("getConnectedBluetoothDevices");
      setState(() {
        connectedDevices =
            result.map((device) => Map<String, String>.from(device)).toList();

        // Check for target device
        isTargetDeviceConnected = connectedDevices.any((device) =>
            (device["address"] ?? "").toLowerCase() == "19:2b:20:a4:ef:43");
      });
    } on PlatformException catch (e) {
      print("Error: ${e.message}");
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // Stop the timer when widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Connected Devices",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildBoardStatusCard(), // Board Status Card
          const SizedBox(height: 20),
          Expanded(
            child: connectedDevices.isEmpty
                ? const Center(
                    child: Text(
                      "No connected devices",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: connectedDevices.length,
                    itemBuilder: (context, index) => Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading:
                            const Icon(Icons.bluetooth, color: Colors.blue),
                        title: Text(
                          connectedDevices[index]["name"] ?? "Unknown Device",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle:
                            Text(connectedDevices[index]["address"] ?? ""),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// Widget to display the Board Status in a nice-looking UI card
  Widget _buildBoardStatusCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isTargetDeviceConnected
                  ? [Colors.greenAccent, Colors.green]
                  : [Colors.redAccent, Colors.red],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                isTargetDeviceConnected ? Icons.check_circle : Icons.cancel,
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(width: 16),
              Text(
                isTargetDeviceConnected ? "Board is ON" : "Board is OFF",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
