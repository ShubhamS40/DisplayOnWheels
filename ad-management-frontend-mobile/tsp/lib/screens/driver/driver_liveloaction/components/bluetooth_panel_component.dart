import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BluetoothPanelComponent extends StatelessWidget {
  final bool showBluetoothPanel;
  final Animation<double> animation;
  final bool isBluetoothOn;
  final bool isScanning;
  final List<Map<String, String>> connectedDevices;
  final VoidCallback onToggleBluetooth;
  final VoidCallback onScanForDevices;
  final Color primaryColor;
  final Color successColor;

  const BluetoothPanelComponent({
    Key? key,
    required this.showBluetoothPanel,
    required this.animation,
    required this.isBluetoothOn,
    required this.isScanning,
    required this.connectedDevices,
    required this.onToggleBluetooth,
    required this.onScanForDevices,
    required this.primaryColor,
    required this.successColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          top: MediaQuery.of(context).size.height * (1 - animation.value * 0.7),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Drag handle
                Container(
                  margin: EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Panel header
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bluetooth',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Switch(
                        value: isBluetoothOn,
                        onChanged: (_) => onToggleBluetooth(),
                        activeColor: primaryColor,
                      ),
                    ],
                  ),
                ),
                Divider(),
                // Panel content
                Expanded(
                  child: !isBluetoothOn
                      ? _buildBluetoothDisabledMessage()
                      : _buildBluetoothEnabledContent(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBluetoothDisabledMessage() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bluetooth_disabled,
            size: 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'Bluetooth is turned off',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Enable Bluetooth to connect to your ad board',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBluetoothEnabledContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scan button
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(vertical: 16),
            child: ElevatedButton.icon(
              onPressed: isScanning ? null : onScanForDevices,
              icon: isScanning
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(Icons.search),
              label: Text(
                isScanning ? 'Scanning...' : 'Scan for Devices',
                style: GoogleFonts.poppins(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          // Connected devices section
          Text(
            'Connected Devices',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),

          // Connected devices list
          Expanded(
            child: connectedDevices.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: connectedDevices.length,
                    itemBuilder: (context, index) {
                      return _buildDeviceItem(connectedDevices[index]);
                    },
                  ),
          ),
        ],
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
}
