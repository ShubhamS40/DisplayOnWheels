import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoItem extends StatelessWidget {
  static const Color primaryOrange = Color(0xFFFF5722); // Using brand orange color
  
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool showAction;
  final IconData? actionIcon;
  final VoidCallback? onActionPressed;

  const InfoItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.showAction = false,
    this.actionIcon,
    this.onActionPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (showAction)
          IconButton(
            onPressed: onActionPressed ?? () {
              // Default action
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit functionality coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: Icon(
              actionIcon ?? Icons.arrow_forward_ios,
              size: 16,
              color: primaryOrange,
            ),
            splashRadius: 20,
          ),
      ],
    );
  }
}
