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

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards(Size screenSize) {
    // Calculate optimal size based on screen width to prevent overflow
    final double cardWidth = (screenSize.width - 48) /
        2; // 16px padding on each side + 16px between cards
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
}
