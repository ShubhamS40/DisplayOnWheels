import 'package:flutter/material.dart';
import 'package:tsp/screens/company/company_dashboard/components/campaign_overview_card.dart';
import 'package:tsp/screens/company/company_dashboard/components/campaign_details_card.dart';

import 'package:tsp/screens/company/company_dashboard/components/subscription_plan_card.dart';
import 'package:tsp/screens/company/company_dashboard/screens/company_drivers_map_screen.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/ad_campaign_screen.dart';
import 'package:tsp/services/campaign/campaign_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompanyDashboardScreen extends StatefulWidget {
  const CompanyDashboardScreen({Key? key}) : super(key: key);

  @override
  State<CompanyDashboardScreen> createState() => _CompanyDashboardScreenState();
}

class _CompanyDashboardScreenState extends State<CompanyDashboardScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool isLoading = true;
  String errorMessage = '';

  // Campaign data from API
  Map<String, dynamic> campaignData = {
    'activeCampaigns': [],
    'pendingCampaigns': [],
    'completedCampaigns': [],
  };

  // Subscription plan data
  final Map<String, dynamic> subscriptionData = {
    'currentPlan': 'Premium',
    'expiryDate': '24/09/2023',
    'daysLeft': 15,
  };

  // Company ID from shared preferences
  String? companyId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _getCompanyId();
    _fetchDashboardData();
  }

  // Get company ID from shared preferences
  Future<void> _getCompanyId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      companyId = prefs.getString('companyId');
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Fetch campaign data from the API
      final result = await CampaignService().fetchCompanyCampaigns();

      setState(() {
        if (result['success']) {
          campaignData = {
            'activeCampaigns': result['activeCampaigns'],
            'pendingCampaigns': result['pendingCampaigns'],
            'completedCampaigns': result['completedCampaigns'],
          };
        } else {
          errorMessage = result['message'] ?? 'Failed to fetch campaign data';
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
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
                        const SizedBox(height: 20),
                      ],

                      // Subscription Plan Card
                      SubscriptionPlanCard(
                        subscriptionData: subscriptionData,
                        isDarkMode: isDarkMode,
                      ),

                      const SizedBox(height: 20),

                      // Live Driver Tracking Button
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CompanyDriversMapScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.grey[900]
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFF5722),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF5722),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Live Driver Tracking',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Track all your campaign drivers in real-time',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDarkMode
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ],
                          ),
                        ),
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
