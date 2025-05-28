import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'action_button_component.dart';
import 'status_info_card_component.dart';

class ControlPanelComponent extends StatelessWidget {
  final bool isSharing;
  final String sharingStatus;
  final String lastUpdated;
  final Color successColor;
  final Color errorColor;
  final Color secondaryColor;
  final Color cardColor;
  final VoidCallback onToggleLocationSharing;
  final VoidCallback onGoToMyLocation;
  final VoidCallback onShowBluetoothPanel;
  final bool isBluetoothOn;
  final bool isTargetDeviceConnected;
  
  // Storage info
  final bool? storedInRedis;
  final bool? storedInDatabase;
  final double? nextDatabaseUpdateIn;

  const ControlPanelComponent({
    Key? key,
    required this.isSharing,
    required this.sharingStatus,
    required this.lastUpdated,
    required this.cardColor,
    required this.successColor,
    required this.errorColor,
    required this.secondaryColor,
    required this.onToggleLocationSharing,
    required this.onGoToMyLocation,
    required this.onShowBluetoothPanel,
    required this.isBluetoothOn,
    required this.isTargetDeviceConnected,
    this.storedInRedis,
    this.storedInDatabase,
    this.nextDatabaseUpdateIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 30,
      left: 15,
      right: 15,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusInfoCardComponent(
            isSharing: isSharing,
            sharingStatus: sharingStatus,
            lastUpdated: lastUpdated,
            successColor: successColor,
            cardColor: cardColor,
            isTargetDeviceConnected: isTargetDeviceConnected,
            storedInRedis: storedInRedis,
            storedInDatabase: storedInDatabase,
            nextDatabaseUpdateIn: nextDatabaseUpdateIn,
          ),
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
                    ActionButtonComponent(
                      icon: isSharing ? Icons.stop_circle : Icons.play_circle,
                      label: isSharing ? 'Stop Sharing' : 'Start Sharing',
                      color: isSharing ? errorColor : successColor,
                      onTap: onToggleLocationSharing,
                    ),
                    SizedBox(width: 12),
                    ActionButtonComponent(
                      icon: Icons.my_location,
                      label: 'My Location',
                      color: secondaryColor,
                      onTap: onGoToMyLocation,
                    ),
                    SizedBox(width: 12),
                    ActionButtonComponent(
                      icon: Icons.bluetooth,
                      label: 'Bluetooth',
                      color: isBluetoothOn ? Colors.blue : Colors.grey,
                      onTap: onShowBluetoothPanel,
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
}
