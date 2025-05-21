import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsp/provider/providers.dart';
import 'package:tsp/utils/constants.dart';

// Component imports
import 'package:tsp/screens/driver/driver_dashboard/components/driver_header.dart';
import 'package:tsp/screens/driver/driver_dashboard/components/active_campaign_section.dart';
import 'package:tsp/screens/driver/driver_dashboard/components/earning_insights_section.dart';
import 'package:tsp/screens/driver/driver_dashboard/components/pickup_location_section.dart';
import 'package:tsp/screens/driver/driver_dashboard/components/driving_statistics_section.dart';
import 'package:tsp/screens/driver/driver_dashboard/components/payment_section.dart';

class DriverDashboard extends ConsumerStatefulWidget {
  const DriverDashboard({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends ConsumerState<DriverDashboard> {
  bool isLoading = true;
  String error = '';
  Map<String, dynamic>? driverData;
  List<dynamic> campaigns = [];

  @override
  void initState() {
    super.initState();
    _fetchDriverData();
  }

  Future<void> _fetchDriverData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        setState(() {
          isLoading = false;
          error = 'Authentication required. Please login again.';
        });
        return;
      }

      // Using the provided API endpoint to fetch driver and campaign data
      final response = await http.get(
        Uri.parse(
            '${Constants.baseUrl}/api/driver-dashboard/campaigns-details/${ref.read(driverIdProvider) ?? ''}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == 'success' &&
            responseData['data'] is List) {
          // Properly convert the response data to handle type safety
          final List<Map<String, dynamic>> typedCampaigns = [];

          // Convert each campaign to a typed Map<String, dynamic>
          for (var campaign in responseData['data']) {
            if (campaign is Map) {
              final Map<String, dynamic> typedCampaign = {};
              campaign.forEach((key, value) {
                typedCampaign[key.toString()] = value;
              });
              typedCampaigns.add(typedCampaign);
            }
          }

          Map<String, dynamic>? typedDriverData;

          // Extract driver data and ensure it's properly typed
          if (typedCampaigns.isNotEmpty &&
              typedCampaigns[0].containsKey('driver')) {
            final driverInfo = typedCampaigns[0]['driver'];
            if (driverInfo is Map) {
              typedDriverData = {};
              driverInfo.forEach((key, value) {
                typedDriverData![key.toString()] = value;
              });
            }
          }

          setState(() {
            isLoading = false;
            campaigns = typedCampaigns;
            driverData = typedDriverData;
          });
        } else {
          setState(() {
            isLoading = false;
            error = 'Invalid data format received';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          error = 'Failed to load data. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        error = 'Error: $e';
      });
    }
  }

  String _getDriverName() {
    return driverData != null ? driverData!['fullName'] : 'Driver';
  }

  String _getDriverId() {
    if (driverData != null && driverData!['id'] != null) {
      // Extract the first 6 characters of the UUID for a shorter display
      return driverData!['id'].toString().substring(0, 6);
    }
    return 'Unknown';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache images to prevent memory issues
    precacheImage(
      const AssetImage('assets/images/earnings_chart.png'),
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Driver header component
            DriverHeader(
              driverName: _getDriverName(),
              driverId: _getDriverId(),
              onNotificationTap: () {
                // Handle notifications
              },
              onMenuTap: () {
                // Handle menu
              },
            ),

            // Main content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Active campaign section component
                    ActiveCampaignSection(
                      isLoading: isLoading,
                      error: error,
                      campaigns: campaigns,
                    ),
                    const SizedBox(height: 24),

                    // Earnings insights component
                    const EarningInsightsSection(),
                    const SizedBox(height: 24),

                    // Pickup location component
                    const PickupLocationSection(),
                    const SizedBox(height: 24),

                    // Driving statistics component
                    const DrivingStatisticsSection(),
                    const SizedBox(height: 24),

                    // Payment section component
                    const PaymentSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
