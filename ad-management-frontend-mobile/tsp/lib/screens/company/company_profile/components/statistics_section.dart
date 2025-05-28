import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../providers/company_profile_provider.dart';
import 'stat_card.dart';

class CompanyStatisticsSection extends StatelessWidget {
  static const Color primaryOrange = Color(0xFFFF5722); // Using brand color
  static const Color textColor = Color(0xFF2C3E50);

  const CompanyStatisticsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<CompanyProfileProvider>(context);
    final statistics = profileProvider.statistics;
    
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
                'Company Statistics',
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
                title: 'Total Campaigns',
                value: statistics?.totalCampaigns.toString() ?? '0',
                icon: Icons.campaign,
                color: Colors.blue,
              ),
              StatCard(
                title: 'Active Campaigns',
                value: statistics?.activeCampaigns.toString() ?? '0',
                icon: Icons.play_circle_fill,
                color: Colors.green,
              ),
              StatCard(
                title: 'Completed',
                value: statistics?.completedCampaigns.toString() ?? '0',
                icon: Icons.check_circle,
                color: primaryOrange,
              ),
              StatCard(
                title: 'Total Spent',
                value: '₹${statistics?.totalSpent.toStringAsFixed(2) ?? "0.00"}',
                icon: Icons.account_balance_wallet,
                color: Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
