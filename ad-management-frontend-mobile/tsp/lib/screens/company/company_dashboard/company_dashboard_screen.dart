import 'package:flutter/material.dart';
import 'package:tsp/screens/company/company_dashboard/components/campaign_overview_card.dart';
import 'package:tsp/screens/company/company_dashboard/components/campaign_details_card.dart';
import 'package:tsp/screens/company/company_dashboard/components/live_campaign_map.dart';
import 'package:tsp/screens/company/company_dashboard/components/subscription_plan_card.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/ad_campaign_screen.dart';

class CompanyDashboardScreen extends StatefulWidget {
  const CompanyDashboardScreen({Key? key}) : super(key: key);

  @override
  State<CompanyDashboardScreen> createState() => _CompanyDashboardScreenState();
}

class _CompanyDashboardScreenState extends State<CompanyDashboardScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  bool isLoading = true;
  String errorMessage = '';
  
  // Mock data for demonstration
  final Map<String, dynamic> campaignData = {
    'activeCampaigns': [
      {
        'id': 'abc123',
        'name': 'Campaign A',
        'validity': 10,
        'startDate': '15/06/2023',
        'endDate': '20/06/2023',
        'state': 'Delhi',
        'carsCount': 10,
      },
    ],
    'pendingCampaigns': [
      {
        'id': 'def456',
        'name': 'Campaign B',
        'validity': 10,
        'startDate': '25/06/2023',
        'endDate': '30/06/2023',
        'state': 'Mumbai',
        'carsCount': 5,
      },
    ],
    'completedCampaigns': [
      {
        'id': 'ghi789',
        'name': 'Campaign C',
        'validity': 15,
        'startDate': '01/05/2023',
        'endDate': '15/05/2023',
        'state': 'Bangalore',
        'carsCount': 8,
      },
    ],
  };
  
  // Mock subscription plan data
  final Map<String, dynamic> subscriptionData = {
    'currentPlan': 'Premium',
    'expiryDate': '24/09/2023',
    'daysLeft': 15,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchDashboardData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      isLoading = true;
    });
    
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real app, fetch data from API here
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _refreshDashboard() async {
    return await _fetchDashboardData();
  }

  void _launchNewCampaign() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdCampaignScreen()),
    ).then((_) {
      // Refresh dashboard data when returning from campaign creation
      _refreshIndicatorKey.currentState?.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final appBarColor = isDarkMode ? Colors.black : const Color(0xFFFF5722);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Company Dashboard'),
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF5722),
              ),
            )
          : RefreshIndicator(
              key: _refreshIndicatorKey,
              color: const Color(0xFFFF5722),
              onRefresh: _refreshDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Campaign Overview Card with tabs
                      CampaignOverviewCard(
                        tabController: _tabController!,
                        activeCampaigns: campaignData['activeCampaigns'],
                        pendingCampaigns: campaignData['pendingCampaigns'],
                        completedCampaigns: campaignData['completedCampaigns'],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Campaign Details Section
                      Text(
                        'Ad Campaign Details Section',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Show details of the first active campaign
                      if (campaignData['activeCampaigns'].isNotEmpty)
                        CampaignDetailsCard(
                          campaign: campaignData['activeCampaigns'][0],
                          isDarkMode: isDarkMode,
                        ),
                      
                      const SizedBox(height: 20),
                      
                      // Live Map for Active Campaign
                      if (campaignData['activeCampaigns'].isNotEmpty) ...[
                        Text(
                          'Live Location Ongoing Ad Campaign ${campaignData['activeCampaigns'][0]['name']}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        LiveCampaignMap(
                          campaignId: campaignData['activeCampaigns'][0]['id'],
                          height: 200,
                        ),
                        
                        const SizedBox(height: 20),
                      ],
                      
                      // Subscription Plan Card
                      SubscriptionPlanCard(
                        subscriptionData: subscriptionData,
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF5722),
        foregroundColor: Colors.white,
        onPressed: _launchNewCampaign,
        child: const Icon(Icons.add),
        tooltip: 'Create New Campaign',
      ),
    );
  }
}
