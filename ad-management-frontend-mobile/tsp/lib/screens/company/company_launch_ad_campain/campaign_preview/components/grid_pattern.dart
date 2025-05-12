import 'package:flutter/material.dart';

class GridPattern extends StatelessWidget {
  final Color color;
  
  const GridPattern({
    Key? key,
    required this.color,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GridPainter(color: color),
    );
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  
  GridPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;
    
    const spacing = 20.0;
    
    // Draw vertical lines
    for (double i = 0; i <= size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }
    
    // Draw horizontal lines
    for (double i = 0; i <= size.height; i += spacing) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
