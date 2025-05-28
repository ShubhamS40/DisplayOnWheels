import 'package:flutter/material.dart';
import 'package:tsp/screens/admin/admin_dashboard/screens/admin_management/setRechargePlan/setrecharge_plan.dart';
import 'package:tsp/utils/theme_constants.dart';
import 'package:tsp/screens/admin/company_documentsVerification/company_lists_not_verifiedDocuments.dart';
import 'package:tsp/screens/admin/driver_documentsVerification/driver_lists_not_verifiedDocumnets.dart';
import 'package:tsp/screens/company/company_recharge_plan/ad_recharge_plan_screen.dart';
import 'package:tsp/screens/admin/company_campaign_management/campaign_approval.dart';
import 'package:tsp/screens/admin/admin_dashboard/screens/admin_management/campaign_driver_verification/campaign_driver_verification_list.dart';
import 'package:tsp/screens/admin/admin_dashboard/screens/admin_management/drivers_livelocation/admin_drivers_map_screen.dart';

class AdminManagementScreen extends StatelessWidget {
  const AdminManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'User Management',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),

          // User management tools
          Container(
            padding: EdgeInsets.all(16),
            decoration: ThemeConstants.getCardDecoration(isDarkMode),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildManagementTool(
                      icon: Icons.person,
                      label: 'Drivers',
                      count: '300',
                      color: Colors.blue,
                      context: context,
                    ),
                    _buildManagementTool(
                      icon: Icons.business,
                      label: 'Companies',
                      count: '20',
                      color: ThemeConstants.primaryColor,
                      context: context,
                    ),
                    _buildManagementTool(
                      icon: Icons.admin_panel_settings,
                      label: 'Admins',
                      count: '5',
                      color: Colors.purple,
                      context: context,
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Quick Actions
          Container(
            padding: EdgeInsets.all(16),
            decoration: ThemeConstants.getCardDecoration(isDarkMode),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  childAspectRatio: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _buildQuickAction(
                      icon: Icons.location_on,
                      label: 'View All Drivers Live Location',
                      color: Color(0xFFFF5722),
                      context: context,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminDriversMapScreen(),
                          ),
                        );
                      },
                    ),
                    _buildQuickAction(
                      icon: Icons.campaign_outlined,
                      label: 'View All Campaigns',
                      color: Colors.green,
                      context: context,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CampaignApprovalScreen(),
                          ),
                        );
                      },
                    ),
                    _buildQuickAction(
                      icon: Icons.verified_outlined,
                      label: 'Ad Proof Verification',
                      color: Colors.amber,
                      context: context,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CampaignDriverVerificationList(),
                          ),
                        );
                      },
                    ),
                    _buildQuickAction(
                      icon: Icons.assignment_outlined,
                      label: 'Campaign Management',
                      color: Colors.orange,
                      context: context,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CampaignApprovalScreen(),
                          ),
                        );
                      },
                    ),
                    _buildQuickAction(
                      icon: Icons.people_alt_outlined,
                      label: 'View All Drivers',
                      color: Colors.blue,
                      context: context,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Viewing all drivers'),
                            backgroundColor: ThemeConstants.primaryColor,
                          ),
                        );
                      },
                    ),
                    _buildQuickAction(
                      icon: Icons.business_outlined,
                      label: 'View All Companies',
                      color: ThemeConstants.primaryColor,
                      context: context,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Viewing all companies'),
                            backgroundColor: ThemeConstants.primaryColor,
                          ),
                        );
                      },
                    ),
                    _buildQuickAction(
                      icon: Icons.payment,
                      label: 'Set Recharge Plan',
                      color: Colors.amber,
                      context: context,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminRechargePlansScreen(),
                          ),
                        );
                      },
                    ),
                    _buildQuickAction(
                      icon: Icons.description,
                      label: 'Verify Company Docs',
                      color: Colors.teal,
                      context: context,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PendingCompanyVerificationList(),
                          ),
                        );
                      },
                    ),
                    _buildQuickAction(
                      icon: Icons.badge,
                      label: 'Verify Driver Docs',
                      color: Colors.deepOrange,
                      context: context,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PendingDriverVerificationList(),
                          ),
                        );
                      },
                    ),
                    _buildQuickAction(
                      icon: Icons.money,
                      label: 'Payouts',
                      color: Colors.purple,
                      context: context,
                    ),
                    _buildQuickAction(
                      icon: Icons.search_outlined,
                      label: 'Track Ads',
                      color: Colors.indigo,
                      context: context,
                    ),
                    _buildQuickAction(
                      icon: Icons.settings,
                      label: 'Settings',
                      color: Colors.grey,
                      context: context,
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Recent Activities
          Container(
            padding: EdgeInsets.all(16),
            decoration: ThemeConstants.getCardDecoration(isDarkMode),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Activities',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                _buildActivityItem(
                  title: 'New driver registered',
                  subtitle: 'John Doe - 10 minutes ago',
                  leadingIcon: Icons.person_add,
                  color: Colors.green,
                  context: context,
                ),
                _buildActivityItem(
                  title: 'Campaign approved',
                  subtitle: 'Company ABC - 25 minutes ago',
                  leadingIcon: Icons.check_circle,
                  color: ThemeConstants.primaryColor,
                  context: context,
                ),
                _buildActivityItem(
                  title: 'Payment received',
                  subtitle: 'Rs 2,000 from Company XYZ - 1 hour ago',
                  leadingIcon: Icons.payments,
                  color: Colors.blue,
                  context: context,
                ),
                _buildActivityItem(
                  title: 'Driver document rejected',
                  subtitle: 'Driver #1242 - 2 hours ago',
                  leadingIcon: Icons.cancel,
                  color: Colors.red,
                  context: context,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementTool({
    required IconData icon,
    required String label,
    required String count,
    required Color color,
    required BuildContext context,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 32,
          ),
        ),
        SizedBox(height: 8),
        Text(
          count,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required BuildContext context,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Selected: $label'),
                  backgroundColor: ThemeConstants.primaryColor,
                ),
              );
            },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String subtitle,
    required IconData leadingIcon,
    required Color color,
    required BuildContext context,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : ThemeConstants.textPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              leadingIcon,
              color: color,
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
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
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
