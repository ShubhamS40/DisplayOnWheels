import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusBarComponent extends StatelessWidget {
  final bool isSharing;
  final Color successColor;
  final VoidCallback onBackPressed;
  final Function(bool) onToggleSharing;

  const StatusBarComponent({
    Key? key,
    required this.isSharing,
    required this.successColor,
    required this.onBackPressed,
    required this.onToggleSharing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              onPressed: onBackPressed,
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
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text(
                isSharing ? 'Sharing' : 'Not Sharing',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSharing ? successColor : Colors.black54,
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: isSharing,
                onChanged: onToggleSharing,
                activeColor: successColor,
                activeTrackColor: successColor.withOpacity(0.4),
                inactiveThumbColor: Colors.grey.shade400,
                inactiveTrackColor: Colors.grey.shade300,
              ),
            ])
          ],
        ),
      ),
    );
  }
}
