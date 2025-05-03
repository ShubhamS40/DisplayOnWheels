import 'package:flutter/material.dart';
import 'package:tsp/screens/admin/admin_dashboard/components/pie_chart_view.dart';
import 'package:tsp/utils/theme_constants.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  final List<PieChartData> userDistributionData;
  final List<PieChartData> revenueDistributionData;

  const AdminAnalyticsScreen({
    Key? key,
    required this.userDistributionData,
    required this.revenueDistributionData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Performance Analytics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),

          // Distribution charts
          Column(
            children: [
              PieChartView(
                title: 'User and Advertisement Distribution',
                data: userDistributionData,
              ),
              SizedBox(height: 20),
              PieChartView(
                title: 'Revenue Distribution',
                data: revenueDistributionData,
              ),
            ],
          ),

          SizedBox(height: 20),

          // Performance metrics card
          Container(
            padding: EdgeInsets.all(16),
            decoration: ThemeConstants.getCardDecoration(
                Theme.of(context).brightness == Brightness.dark),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Performance Metrics',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                _buildMetricRow('Total Active Hours', '362 hrs', 0.75),
                SizedBox(height: 16),
                _buildMetricRow('Campaign Completion Rate', '78%', 0.78),
                SizedBox(height: 16),
                _buildMetricRow('Driver Efficiency', '84%', 0.84),
                SizedBox(height: 16),
                _buildMetricRow('Revenue Growth', '+12%', 0.62),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Monthly revenue chart
          Container(
            padding: EdgeInsets.all(16),
            decoration: ThemeConstants.getCardDecoration(
                Theme.of(context).brightness == Brightness.dark),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Revenue (in ₹)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                AspectRatio(
                  aspectRatio: 1.7,
                  child: _buildBarChart(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ThemeConstants.primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: ThemeConstants.primaryColor.withOpacity(0.2),
            valueColor:
                AlwaysStoppedAnimation<Color>(ThemeConstants.primaryColor),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    return CustomPaint(
      painter: BarChartPainter(),
    );
  }
}

class BarChartPainter extends CustomPainter {
  final List<double> values = [15000, 25000, 18000, 30000, 42000, 38000];
  final List<String> labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];

  @override
  void paint(Canvas canvas, Size size) {
    final double barWidth = size.width / (values.length * 2);
    final double maxBarHeight = size.height * 0.8;
    final double maxValue =
        values.reduce((curr, next) => curr > next ? curr : next);

    // Draw axes
    final Paint axesPaint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 1;

    // X-axis
    canvas.drawLine(
      Offset(0, size.height - 20),
      Offset(size.width, size.height - 20),
      axesPaint,
    );

    // Y-axis
    canvas.drawLine(
      Offset(0, 0),
      Offset(0, size.height - 20),
      axesPaint,
    );

    // Draw bars
    for (int i = 0; i < values.length; i++) {
      final double barHeight = (values[i] / maxValue) * maxBarHeight;
      final double barX = (i * 2 + 1) * barWidth;
      final double barY = size.height - 20 - barHeight;

      // Bar
      final Paint barPaint = Paint()
        ..color = ThemeConstants.primaryColor
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barX, barY, barWidth, barHeight),
          Radius.circular(4),
        ),
        barPaint,
      );

      // Label
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: Colors.grey,
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(barX + barWidth / 2 - textPainter.width / 2, size.height - 15),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
