import 'package:flutter/material.dart';
import 'package:tsp/screens/admin/admin_dashboard/screens/admin_analytics/admin_analytics_screen.dart';
import 'package:tsp/screens/admin/admin_dashboard/screens/admin_management/admin_management_screen.dart';
import 'package:tsp/screens/admin/admin_dashboard/screens/admin_overview/admin_overview_screen.dart';
import 'dart:async';
import '../../../utils/theme_constants.dart';
import 'components/stat_card.dart';
import 'components/pie_chart_view.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Simulate loading data
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });

    // Set up a refresh timer (every 30 seconds)
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _refreshDashboardData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _refreshDashboardData() {
    // This would normally fetch fresh data from an API
    setState(() {
      isLoading = true;
    });

    Future.delayed(Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : ThemeConstants.textPrimary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode
            ? ThemeConstants.darkBackground
            : ThemeConstants.lightBackground,
        elevation: 0,
        title: Text(
          'ADMIN DASHBOARD',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: ThemeConstants.primaryColor),
            onPressed: _refreshDashboardData,
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined,
                color: ThemeConstants.primaryColor),
            onPressed: () {},
          ),
          IconButton(
            icon:
                Icon(Icons.person_outline, color: ThemeConstants.primaryColor),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: ThemeConstants.primaryColor,
          unselectedLabelColor: textColor.withOpacity(0.5),
          indicatorColor: ThemeConstants.primaryColor,
          tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Analytics'),
            Tab(text: 'Management'),
          ],
        ),
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: ThemeConstants.primaryColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading dashboard data...',
                    style: TextStyle(color: textColor.withOpacity(0.7)),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                // Overview Tab - Using modular component
                AdminOverviewScreen(
                  statCards: statCards,
                ),

                // Analytics Tab - Using modular component
                AdminAnalyticsScreen(
                  userDistributionData: userDistributionData,
                  revenueDistributionData: revenueDistributionData,
                ),

                // Management Tab - Using modular component
                AdminManagementScreen(),
              ],
            ),
    );
  }
}
