import 'package:flutter/material.dart';
import 'package:tsp/screens/admin/admin_dashboard/screens/admin_analytics/admin_analytics_screen.dart';
import 'package:tsp/screens/admin/admin_dashboard/screens/admin_management/admin_management_screen.dart';
import 'package:tsp/screens/admin/admin_dashboard/screens/admin_overview/admin_overview_screen.dart';
import 'package:tsp/utils/auth_protection.dart';
import 'dart:async';
import '../../../utils/theme_constants.dart';
import 'components/stat_card.dart';
import 'components/pie_chart_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../screens/auth/role_selection.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  Timer? _refreshTimer;

  // Sample data for the dashboard
  final List<Map<String, dynamic>> statCards = [
    {
      'title': 'Total Registered Drivers',
      'value': '300',
      'icon': Icons.drive_eta,
    },
    {
      'title': 'Total Driver Payout',
      'value': 'Rs 5000',
      'icon': Icons.payments,
    },
    {
      'title': 'Total Registered Company',
      'value': '20',
      'subtitle': '',
      'icon': Icons.business,
    },
    {
      'title': 'Total Company Amount',
      'value': 'Rs 10,000',
      'subtitle': '+Rs2,000',
      'icon': Icons.account_balance_wallet,
    },
    {
      'title': 'Total Active Campaigns',
      'value': '84',
      'icon': Icons.campaign,
    },
    {
      'title': 'Net Profit',
      'value': 'Rs5,000',
      'subtitle': 'company - driver = profit',
      'icon': Icons.insert_chart,
    },
  ];

  final List<PieChartData> userDistributionData = [
    PieChartData(
      label: 'Active Campaigns',
      percentage: 15.5,
      color: Colors.green,
    ),
    PieChartData(
      label: 'Companies',
      percentage: 10.0,
      color: Colors.blue,
    ),
    PieChartData(
      label: 'Drivers',
      percentage: 74.5,
      color: ThemeConstants.primaryColor,
    ),
  ];

  final List<PieChartData> revenueDistributionData = [
    PieChartData(
      label: 'Driver Payout',
      percentage: 33.3,
      color: Colors.blue,
    ),
    PieChartData(
      label: 'Admin Profit',
      percentage: 33.3,
      color: Colors.red,
    ),
    PieChartData(
      label: 'Company Amount',
      percentage: 33.4,
      color: Colors.yellow,
    ),
  ];

  // Add this method for logout functionality
  Future<void> _logout() async {
    try {
      // Clear admin token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('adminId');
      await prefs.remove('userType');

      // Navigate to role selection screen
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
          (route) => false, // This removes all previous routes
        );
      }
    } catch (e) {
      print('Error during logout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logout failed. Please try again.')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Simulate loading data
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });

    // Set up periodic refresh
    _refreshTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      if (mounted) {
        setState(() {
          // Refresh data here
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthProtectedScreen(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          backgroundColor: ThemeConstants.primaryColor,
          actions: [
            // Add logout button to app bar
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
          ],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: 'Overview'),
                      Tab(text: 'Analytics'),
                      Tab(text: 'Management'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        AdminOverviewScreen(statCards: statCards),
                        AdminAnalyticsScreen(
                          userDistributionData: userDistributionData,
                          revenueDistributionData: revenueDistributionData,
                        ),
                        AdminManagementScreen(),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
