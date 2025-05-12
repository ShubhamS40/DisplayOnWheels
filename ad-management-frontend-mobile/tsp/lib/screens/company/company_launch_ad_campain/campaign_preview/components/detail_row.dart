import 'package:flutter/material.dart';

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool valueBold;
  final double? valueFontSize;
  final bool isDarkMode;

  const DetailRow({
    Key? key,
    required this.label,
    required this.value,
    this.valueColor,
    this.valueBold = false,
    this.valueFontSize,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: valueFontSize ?? 15,
                fontWeight: valueBold ? FontWeight.bold : FontWeight.normal,
                color: valueColor ?? (isDarkMode ? Colors.white : Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
