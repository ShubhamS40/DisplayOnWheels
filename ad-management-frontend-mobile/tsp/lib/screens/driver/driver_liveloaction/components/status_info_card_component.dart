import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusInfoCardComponent extends StatelessWidget {
  final bool isSharing;
  final String sharingStatus;
  final String lastUpdated;
  final Color successColor;
  final Color cardColor;
  final bool isTargetDeviceConnected;
  
  // Storage info
  final bool? storedInRedis;
  final bool? storedInDatabase;
  final double? nextDatabaseUpdateIn;

  const StatusInfoCardComponent({
    Key? key,
    required this.isSharing,
    required this.sharingStatus,
    required this.lastUpdated,
    required this.successColor,
    required this.cardColor,
    required this.isTargetDeviceConnected,
    this.storedInRedis,
    this.storedInDatabase,
    this.nextDatabaseUpdateIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: 2,
            offset: Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSharing ? successColor.withOpacity(0.1) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isSharing ? Icons.location_on : Icons.location_off,
                  color: isSharing ? successColor : Colors.grey,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status: $sharingStatus',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  if (lastUpdated.isNotEmpty)
                    Text(
                      lastUpdated,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          // Storage Info
          if (isSharing && storedInRedis != null)
            _buildStorageInfoRow(),
          SizedBox(height: 12),
          _buildDeviceStatusRow(),
        ],
      ),
    );
  }

  Widget _buildStorageInfoRow() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.storage,
            color: Color(0xFFFF5722),
            size: 20,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Storage: ',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: storedInRedis == true ? Colors.green : Colors.grey,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Redis',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: storedInRedis == true ? Colors.green : Colors.grey,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: storedInDatabase == true ? Colors.green : Colors.grey,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'DB',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: storedInDatabase == true ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
              if (nextDatabaseUpdateIn != null && nextDatabaseUpdateIn! > 0)
                Text(
                  'Next DB update in ${nextDatabaseUpdateIn!.toStringAsFixed(1)}s',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceStatusRow() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isTargetDeviceConnected
                ? successColor.withOpacity(0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.bluetooth,
            color: isTargetDeviceConnected ? successColor : Colors.grey,
            size: 20,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Ad Board: ',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    isTargetDeviceConnected ? 'Connected' : 'Not Connected',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isTargetDeviceConnected ? successColor : Colors.red,
                    ),
                  ),
                ],
              ),
              if (isTargetDeviceConnected)
                Text(
                  'Device ID: 19:2b:20:a4:ef:43',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                )
              else
                Text(
                  'Tap Bluetooth to connect',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
