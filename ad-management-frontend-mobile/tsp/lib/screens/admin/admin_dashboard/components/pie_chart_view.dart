import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../utils/theme_constants.dart';

class PieChartView extends StatelessWidget {
  final String title;
  final List<PieChartData> data;
  final double height;

  const PieChartView({
    Key? key,
    required this.title,
    required this.data,
    this.height = 180,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : ThemeConstants.textPrimary;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: ThemeConstants.getCardDecoration(isDarkMode),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              // Pie chart
              Container(
                height: height,
                width: height,
                child: CustomPaint(
                  painter: PieChartPainter(data: data),
                ),
              ),
              
              // Legend
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: data.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: item.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${item.percentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<PieChartData> data;

  PieChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    // Calculate total for percentages
    final total = data.fold(0.0, (sum, item) => sum + item.percentage);
    
    // Draw sectors
    double startAngle = -math.pi / 2; // Start from top
    
    for (var item in data) {
      final sweepAngle = 2 * math.pi * (item.percentage / total);
      
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = item.color;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      // Prepare for next sector
      startAngle += sweepAngle;
    }
    
    // Draw center circle (optional for donut chart)
    final centerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
      
    canvas.drawCircle(center, radius * 0.0, centerPaint); // Set to 0 for pie, 0.6 for donut
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class PieChartData {
  final String label;
  final double percentage;
  final Color color;

  PieChartData({
    required this.label,
    required this.percentage,
    required this.color,
  });
}
