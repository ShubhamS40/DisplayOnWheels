import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../providers/driver_profile_provider.dart';
import '../../../../models/driver_profile_model.dart';
import 'campaign_card.dart';

class CampaignsTab extends StatefulWidget {
  const CampaignsTab({Key? key}) : super(key: key);

  @override
  State<CampaignsTab> createState() => _CampaignsTabState();
}

class _CampaignsTabState extends State<CampaignsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const Color primaryOrange = Color(0xFFFF5722); // Using brand orange color
  static const Color textColor = Color(0xFF2C3E50);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<DriverProfileProvider>(context);
    final campaigns = profileProvider.campaigns;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCampaignsTabs(),
          const SizedBox(height: 16),
          _buildCampaignList(),
        ],
      ),
    );
  }

  Widget _buildCampaignsTabs() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: primaryOrange,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Active'),
          Tab(text: 'Completed'),
          Tab(text: 'Upcoming'),
        ],
      ),
    );
  }

  Widget _buildCampaignList() {
    final profileProvider = Provider.of<DriverProfileProvider>(context);
    final allCampaigns = profileProvider.campaigns;
    
    // Filter campaigns based on status
    final activeCampaigns = allCampaigns.where((c) => 
      c.driverStatus == 'ASSIGNED' || c.driverStatus == 'IN_PROGRESS').toList();
      
    final completedCampaigns = allCampaigns.where((c) => 
      c.driverStatus == 'COMPLETED').toList();
      
    final upcomingCampaigns = allCampaigns.where((c) => 
      c.campaignStatus == 'PENDING_PAYMENT' || 
      c.campaignStatus == 'PENDING_APPROVAL').toList();
    
    return SizedBox(
      height: MediaQuery.of(context).size.height - 200, // Approximate height
      child: TabBarView(
        controller: _tabController,
        children: [
          // Active campaigns
          activeCampaigns.isEmpty
          ? _buildEmptyState('No active campaigns')
          : ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: activeCampaigns.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final campaign = activeCampaigns[index];
                return CampaignCard(
                  title: campaign.title,
                  company: 'Campaign ID: ${campaign.id.substring(0, 8)}',
                  category: campaign.driverStatus,
                  startDate: _formatDate(campaign.assignedAt),
                  endDate: '', // No end date in API
                  payment: '₹${campaign.earnings.toStringAsFixed(2)}',
                  status: _getCampaignStatusText(campaign.campaignStatus),
                  daysLeft: _getDaysLeftText(campaign.campaignStatus),
                  imagePath: campaign.proofPhoto ?? 
                    'https://via.placeholder.com/600x300/FF5722/FFFFFF?text=${campaign.title}',
                );
              },
            ),
          
          // Completed campaigns
          completedCampaigns.isEmpty
          ? _buildEmptyState('No completed campaigns')
          : ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: completedCampaigns.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final campaign = completedCampaigns[index];
                return CampaignCard(
                  title: campaign.title,
                  company: 'Campaign ID: ${campaign.id.substring(0, 8)}',
                  category: campaign.driverStatus,
                  startDate: _formatDate(campaign.assignedAt),
                  endDate: '', // No end date in API
                  payment: '₹${campaign.earnings.toStringAsFixed(2)}',
                  status: 'Completed',
                  daysLeft: 'Completed',
                  imagePath: campaign.proofPhoto ?? 
                    'https://via.placeholder.com/600x300/2196F3/FFFFFF?text=${campaign.title}',
                );
              },
            ),
          
          // Upcoming campaigns
          upcomingCampaigns.isEmpty
          ? _buildEmptyState('No upcoming campaigns')
          : ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: upcomingCampaigns.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final campaign = upcomingCampaigns[index];
                return CampaignCard(
                  title: campaign.title,
                  company: 'Campaign ID: ${campaign.id.substring(0, 8)}',
                  category: campaign.campaignStatus,
                  startDate: _formatDate(campaign.assignedAt),
                  endDate: '', // No end date in API
                  payment: '₹${campaign.earnings.toStringAsFixed(2)}',
                  status: 'Upcoming',
                  daysLeft: _getUpcomingStatusText(campaign.campaignStatus),
                  imagePath: 'https://via.placeholder.com/600x300/9C27B0/FFFFFF?text=${campaign.title}',
                );
              },
            ),
        ],
      ),
    );
  }
  
  // Helper methods for campaign data formatting
  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }
  
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
  
  String _getCampaignStatusText(String status) {
    switch (status) {
      case 'ACTIVE':
        return 'Active';
      case 'PENDING_PAYMENT':
        return 'Pending Payment';
      case 'PAYMENT_VERIFIED':
        return 'Payment Verified';
      case 'PENDING_APPROVAL':
        return 'Pending Approval';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      case 'REJECTED':
        return 'Rejected';
      default:
        return status;
    }
  }
  
  String _getDaysLeftText(String status) {
    switch (status) {
      case 'ACTIVE':
        return 'In progress';
      case 'PENDING_PAYMENT':
        return 'Awaiting payment';
      case 'PAYMENT_VERIFIED':
        return 'Starting soon';
      case 'PENDING_APPROVAL':
        return 'Awaiting approval';
      default:
        return 'Status: $status';
    }
  }
  
  String _getUpcomingStatusText(String status) {
    switch (status) {
      case 'PENDING_PAYMENT':
        return 'Waiting for payment';
      case 'PENDING_APPROVAL':
        return 'Waiting for approval';
      default:
        return 'Starting soon';
    }
  }
  
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.campaign_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
