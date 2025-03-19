import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  List<BluetoothDevice> devices = [];
  bool isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanSubscription;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.location.request();
  }

  Future<void> _startScan() async {
    // ब्लूटूथ चालू है यह सुनिश्चित करें
    if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
      print('Bluetooth is off');
      return;
    }

    setState(() {
      devices.clear();
      isScanning = true;
    });

    // स्कैन रिजल्ट्स के लिए लिसनर
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!devices.contains(result.device)) {
          setState(() {
            devices.add(result.device);
          });
          // डिवाइस की जानकारी प्रिंट करें
          print('Found device: ${result.device.remoteId} - '
              'Name: ${result.advertisementData.advName}');
        }
      }
    }, onError: (e) => print(e));

    // स्कैनिंग रुकने पर सब्सक्रिप्शन कैंसल करें
    FlutterBluePlus.cancelWhenScanComplete(_scanSubscription);

    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
      );
      await FlutterBluePlus.isScanning.where((val) => val == false).first;
    } catch (e) {
      print('Scan error: $e');
    } finally {
      setState(() => isScanning = false);
    }
  }

  void _stopScan() {
    FlutterBluePlus.stopScan();
    setState(() => isScanning = false);
  }

  @override
  void dispose() {
    _scanSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: isScanning ? _stopScan : _startScan,
          child: Text(isScanning ? 'स्कैन रोकें' : 'स्कैन शुरू करें'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return ListTile(
                title: Text(
                    device.advName.isEmpty ? 'अज्ञात डिवाइस' : device.advName),
                subtitle: Text(device.remoteId.toString()),
              );
            },
          ),
        ),
      ],
    );
  }
}
