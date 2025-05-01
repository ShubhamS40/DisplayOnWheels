import 'package:flutter/material.dart';

class LiveCampaignMap extends StatelessWidget {
  final String campaignId;
  final double height;

  const LiveCampaignMap({
    Key? key,
    required this.campaignId,
    this.height = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? Colors.grey[900] : Colors.white;
    
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Mock map image
            Image.asset(
              'assets/images/map_placeholder.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              // If asset not available, use a placeholder
              errorBuilder: (context, error, stackTrace) {
                return _buildMapPlaceholder(isDarkMode);
              },
            ),
            
            // Vehicle markers
            _buildVehicleMarkers(),
            
            // Map attribution
            Positioned(
              bottom: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Map data ©2023',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            
            // Bottom button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Material(
                color: Colors.black,
                child: InkWell(
                  onTap: () {
                    // Navigate to detailed map screen
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    child: const Text(
                      'Launch New Campaign',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder(bool isDarkMode) {
    return Container(
      color: isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFE0E0E0),
      child: Stack(
        children: [
          // Map grid lines
          CustomPaint(
            size: Size.infinite,
            painter: GridPainter(
              lineColor: isDarkMode 
                  ? Colors.grey.withOpacity(0.2) 
                  : Colors.black.withOpacity(0.1),
            ),
          ),
          
          // Centered location pin
          Center(
            child: Icon(
              Icons.location_on,
              color: const Color(0xFFFF5722),
              size: 50,
            ),
          ),
          
          // Add mock car icons
          _buildVehicleMarkers(),
        ],
      ),
    );
  }
  
  Widget _buildVehicleMarkers() {
    // Fixed positions for demonstration
    final positions = [
      const Offset(0.3, 0.4),
      const Offset(0.5, 0.6),
      const Offset(0.7, 0.3),
      const Offset(0.2, 0.7),
      const Offset(0.8, 0.5),
    ];
    
    return Stack(
      children: positions.map((position) {
        return Positioned(
          left: position.dx * 100.0 + 50,
          top: position.dy * 100.0 + 20,
          child: _buildCarMarker(),
        );
      }).toList(),
    );
  }
  
  Widget _buildCarMarker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.all(4.0),
        child: Icon(
          Icons.directions_car,
          color: Color(0xFFFF5722),
          size: 18,
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final Color lineColor;
  final double spacing;
  
  GridPainter({
    required this.lineColor,
    this.spacing = 40.0,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0;
    
    // Draw horizontal lines
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
    
    // Draw vertical lines
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
