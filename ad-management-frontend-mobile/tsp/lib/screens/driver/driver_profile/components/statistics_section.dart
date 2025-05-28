import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'stat_card.dart';

class StatisticsSection extends StatelessWidget {
  static const Color primaryOrange = Color(0xFFFF5722); // Using brand color
  static const Color textColor = Color(0xFF2C3E50);
  
  final Map<String, dynamic> statsData;

  const StatisticsSection({
    Key? key,
    required this.statsData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Statistics',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // View detailed stats
                },
                icon: const Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: primaryOrange,
                ),
                label: Text(
                  'View All',
                  style: GoogleFonts.poppins(
                    color: primaryOrange,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              StatCard(
                title: 'Earnings',
                value: statsData['earnings']['value'],
                change: statsData['earnings']['change'],
                icon: Icons.attach_money,
                color: Colors.green,
              ),
              StatCard(
                title: 'Trips',
                value: statsData['trips']['value'],
                change: statsData['trips']['change'],
                icon: Icons.directions_car,
                color: Colors.blue,
              ),
              StatCard(
                title: 'Hours',
                value: statsData['hours']['value'],
                change: statsData['hours']['change'],
                icon: Icons.access_time,
                color: Colors.orange,
              ),
              StatCard(
                title: 'Rating',
                value: statsData['rating']['value'],
                change: statsData['rating']['change'],
                icon: Icons.star,
                color: Colors.amber,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
