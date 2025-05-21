import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EarningInsightsSection extends StatelessWidget {
  const EarningInsightsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Earning Insights',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B00).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'This Month',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFFFF6B00),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            width: double.infinity,
            child: Image.asset(
              'assets/images/earnings_chart.png',
              fit: BoxFit.cover,
              cacheHeight: 400, // Optimize memory usage with cache size
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: Icon(Icons.insert_chart_outlined,
                        size: 64, color: Colors.grey[400]),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildEarningInfoItem(
                  'Total Earnings',
                  '\$1,250',
                  Icons.account_balance_wallet_outlined,
                  const Color(0xFF4CAF50),
                  '+15%',
                ),
                _buildEarningInfoItem(
                  'Campaigns',
                  '3 Active',
                  Icons.campaign_outlined,
                  const Color(0xFF2196F3),
                  '+1',
                ),
                _buildEarningInfoItem(
                  'Avg. Per Day',
                  '\$42',
                  Icons.insert_chart_outlined,
                  const Color(0xFFFF5722),
                  '+5%',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningInfoItem(
      String label, String value, IconData icon, Color color, String change) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              change,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
