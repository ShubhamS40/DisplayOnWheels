import 'package:flutter/material.dart';
import '../../../../utils/theme_constants.dart';

class MapView extends StatelessWidget {
  final double height;
  final String? campaignTitle;

  const MapView({
    Key? key,
    this.height = 220,
    this.campaignTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemeConstants.primaryColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Map image placeholder
          Container(
            height: height,
            child: Stack(
              children: [
                // Map image from network
                Image.network(
                  'https://i.imgur.com/RHGgzhD.png', // Map with locations image
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      child: Center(
                        child: Icon(
                          Icons.map_outlined,
                          size: 48,
                          color: ThemeConstants.primaryColor,
                        ),
                      ),
                    );
                  },
                ),
                
                // Overlay for vehicle markers
                Positioned.fill(
                  child: Container(
                    color: Colors.transparent,
                    child: CustomPaint(
                      painter: VehicleMarkerPainter(),
                    ),
                  ),
                ),
                
                // Legend for map
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDarkMode 
                          ? Colors.black.withOpacity(0.7)
                          : Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLegendItem('Running', Colors.green),
                        SizedBox(width: 8),
                        _buildLegendItem('Idle', Colors.orange),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Campaign info if provided
          if (campaignTitle != null)
            Container(
              padding: EdgeInsets.all(12),
              color: isDarkMode
                  ? ThemeConstants.darkCardColor
                  : ThemeConstants.lightCardColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ad Duration Tracking',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  _buildCampaignItem(
                    'Campaign XYZ',
                    'Running',
                    'Days Left: 15',
                    true,
                    context,
                  ),
                  Divider(),
                  _buildCampaignItem(
                    'Campaign 123',
                    'Expired',
                    'Campaign Expired',
                    false,
                    context,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCampaignItem(
    String title,
    String status,
    String details,
    bool isActive,
    BuildContext context,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: textColor,
            ),
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                status,
                style: TextStyle(
                  color: isActive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                details,
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive
                      ? ThemeConstants.primaryColor
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
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

class VehicleMarkerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // This would normally plot vehicle markers based on real data
    // For demo purposes, we're adding stub markers
    _drawMarker(canvas, Offset(size.width * 0.3, size.height * 0.2), true);
    _drawMarker(canvas, Offset(size.width * 0.7, size.height * 0.3), false);
    _drawMarker(canvas, Offset(size.width * 0.5, size.height * 0.6), true);
    _drawMarker(canvas, Offset(size.width * 0.2, size.height * 0.7), true);
    _drawMarker(canvas, Offset(size.width * 0.8, size.height * 0.8), false);
  }

  void _drawMarker(Canvas canvas, Offset position, bool isActive) {
    final paint = Paint()
      ..color = isActive ? Colors.green : Colors.orange
      ..style = PaintingStyle.fill;

    // Draw small circle for vehicle marker
    canvas.drawCircle(position, 6, paint);
    
    // Draw outline
    final outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
      
    canvas.drawCircle(position, 6, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
