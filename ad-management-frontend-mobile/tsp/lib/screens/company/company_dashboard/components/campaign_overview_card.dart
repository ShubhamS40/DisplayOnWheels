import 'package:flutter/material.dart';
import '../campaign_details/campaign_detail_screen.dart';

class CampaignOverviewCard extends StatelessWidget {
  final TabController tabController;
  final List<dynamic> activeCampaigns;
  final List<dynamic> pendingCampaigns;
  final List<dynamic> completedCampaigns;

  const CampaignOverviewCard({
    Key? key,
    required this.tabController,
    required this.activeCampaigns,
    required this.pendingCampaigns,
    required this.completedCampaigns,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final dividerColor = isDarkMode ? Colors.grey[700] : Colors.grey[300];
    
    return Card(
      elevation: 4,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ad Campaign Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: tabController,
              labelColor: const Color(0xFFFF5722),
              unselectedLabelColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              indicatorColor: const Color(0xFFFF5722),
              tabs: const [
                Tab(text: 'Active'),
                Tab(text: 'Pending'),
                Tab(text: 'Completed'),
              ],
            ),
            SizedBox(
              height: 200,
              child: TabBarView(
                controller: tabController,
                children: [
                  // Active Campaigns Tab
                  _buildCampaignList(activeCampaigns, textColor, dividerColor),
                  // Pending Campaigns Tab
                  _buildCampaignList(pendingCampaigns, textColor, dividerColor),
                  // Completed Campaigns Tab
                  _buildCampaignList(completedCampaigns, textColor, dividerColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignList(List<dynamic> campaigns, Color textColor, Color? dividerColor) {
    if (campaigns.isEmpty) {
      return Center(
        child: Text(
          'No campaigns in this category',
          style: TextStyle(
            color: textColor,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: campaigns.length,
      separatorBuilder: (context, index) => Divider(color: dividerColor),
      itemBuilder: (context, index) {
        final campaign = campaigns[index];
        
        // Determine valid days text
        String validityText = '';
        if (campaign['startDate'] != null && campaign['endDate'] != null) {
          if (campaign['validity'] != null) {
            validityText = 'Validity: ${campaign['validity']} days left';
          } else {
            validityText = '${campaign['startDate']} - ${campaign['endDate']}';
          }
        } else {
          validityText = 'Dates pending';
        }
        
        // Determine plan name subtitle
        String planName = campaign['planName'] ?? '';
        String subtitle = validityText;
        if (planName.isNotEmpty) {
          subtitle = '$planName • $validityText';
        }
        
        // Determine status icon/color
        IconData statusIcon;
        Color statusColor;
        
        final status = campaign['approvalStatus'] ?? 'PENDING';
        switch (status) {
          case 'APPROVED':
            statusIcon = Icons.check_circle;
            statusColor = Colors.green;
            break;
          case 'PENDING':
            statusIcon = Icons.pending;
            statusColor = Colors.orange;
            break;
          case 'REJECTED':
            statusIcon = Icons.cancel;
            statusColor = Colors.red;
            break;
          default:
            statusIcon = Icons.help;
            statusColor = Colors.grey;
        }
        
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  campaign['name'] ?? 'Unnamed Campaign',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                statusIcon,
                size: 16,
                color: statusColor,
              ),
            ],
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: textColor.withOpacity(0.7),
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Color(0xFFFF5722),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CampaignDetailScreen(
                  campaign: campaign,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
