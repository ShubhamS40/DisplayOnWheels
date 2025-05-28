import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../providers/company_profile_provider.dart';
import 'campaign_card.dart';

class CampaignsTab extends StatelessWidget {
  static const Color primaryOrange = Color(0xFFFF5722);
  static const Color textColor = Color(0xFF2C3E50);

  const CampaignsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<CompanyProfileProvider>(context);
    final campaigns = profileProvider.campaigns;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Campaigns',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // Navigate to all campaigns
                },
                icon: const Icon(
                  Icons.add_circle_outline,
                  size: 16,
                  color: primaryOrange,
                ),
                label: Text(
                  'Create New',
                  style: GoogleFonts.poppins(
                    color: primaryOrange,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', isSelected: true),
                _buildFilterChip('Active'),
                _buildFilterChip('Completed'),
                _buildFilterChip('Pending'),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Campaigns list
          campaigns.isEmpty
              ? _buildEmptyCampaignsState()
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: campaigns.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final campaign = campaigns[index];
                    return CampaignCard(
                      id: campaign.id,
                      title: campaign.title,
                      status: campaign.status,
                      budget: campaign.budget,
                      startDate: campaign.startDate,
                      endDate: campaign.endDate,
                      assignedDrivers: campaign.assignedDrivers,
                      posterUrl: campaign.posterUrl,
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        labelStyle: GoogleFonts.poppins(
          color: isSelected ? Colors.white : textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        selected: isSelected,
        backgroundColor: Colors.grey[200],
        selectedColor: primaryOrange,
        checkmarkColor: Colors.white,
        onSelected: (selected) {
          // Handle filter selection
        },
      ),
    );
  }

  Widget _buildEmptyCampaignsState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.campaign_outlined,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Campaigns Yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first campaign to start advertising',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to create campaign
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Campaign'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
