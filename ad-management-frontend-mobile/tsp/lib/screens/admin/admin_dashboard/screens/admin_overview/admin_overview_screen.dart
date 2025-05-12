import 'package:flutter/material.dart';
import 'package:tsp/screens/admin/admin_dashboard/components/stat_card.dart';
import 'package:tsp/utils/theme_constants.dart';

class AdminOverviewScreen extends StatelessWidget {
  final List<Map<String, dynamic>> statCards;

  const AdminOverviewScreen({
    Key? key,
    required this.statCards,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return RefreshIndicator(
      color: Colors.orange,
      onRefresh: () async {
        // Simulate network delay
        await Future.delayed(Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Dashboard Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            // Stat cards grid - fixed to prevent overflow
            _buildStatCards(screenSize),

            SizedBox(height: 20),

            // Live Map with Vehicle Tracking
            _buildVehicleTracking(context),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards(Size screenSize) {
    // Calculate optimal size based on screen width to prevent overflow
    final double cardWidth = (screenSize.width - 48) / 2; // 16px padding on each side + 16px between cards
    final double cardHeight = 120; // Increased height to prevent overflow
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: cardWidth / cardHeight,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
        ),
        itemCount: statCards.length,
        itemBuilder: (context, index) {
          return Container(
            constraints: BoxConstraints(minHeight: cardHeight),
            child: StatCard(
              title: statCards[index]['title'],
              value: statCards[index]['value'],
              subtitle: statCards[index]['subtitle'],
              icon: statCards[index]['icon'],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVehicleTracking(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
          child: Text(
            'Live Vehicle Tracking',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            color: Colors.grey[300],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: Stack(
              children: [
                // Using a real map image
                Image.network(
                  // Commented out Google Maps until API key is set
                  // 'https://maps.googleapis.com/maps/api/staticmap?center=28.6139,77.2090&zoom=14&size=600x300&maptype=roadmap&markers=color:red|28.6139,77.2090&markers=color:green|28.6219,77.2190&markers=color:blue|28.6100,77.2090&key=YOUR_API_KEY',
                  'https://via.placeholder.com/600x300/1a1a1a/FF5722?text=Team+TSP+Map+View',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    // Backup image if the API call fails
                    return Image.network(
                      'https://i.imgur.com/RHGgzhD.png',
                      fit: BoxFit.cover,
                    );
                  },
                ),
                // Vehicle markers
                Positioned(
                  top: 30,
                  left: 100,
                  child: _buildVehicleMarker(true),
                ),
                Positioned(
                  top: 120,
                  left: 180,
                  child: _buildVehicleMarker(true),
                ),
                Positioned(
                  top: 80,
                  left: 240,
                  child: _buildVehicleMarker(false),
                ),
                Positioned(
                  top: 160,
                  left: 50,
                  child: _buildVehicleMarker(true),
                ),
                // Legend
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Active',
                          style: TextStyle(fontSize: 12),
                        ),
                        SizedBox(width: 8),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Idle',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode
                ? ThemeConstants.darkCardColor
                : ThemeConstants.lightCardColor,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusCounter(Icons.directions_car, '12', 'On Route'),
              _buildStatusCounter(Icons.pause_circle_outline, '3', 'Idle'),
              _buildStatusCounter(Icons.verified, '22', 'Completed'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleMarker(bool isActive) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.directions_car,
          color: isActive ? Colors.green : Colors.red,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildStatusCounter(IconData icon, String count, String label) {
    return Column(
      children: [
        Icon(
          icon,
          color: ThemeConstants.primaryColor,
          size: 22,
        ),
        SizedBox(height: 4),
        Text(
          count,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
