import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart' as provider;
import '../../../provider/providers.dart';
import '../../../providers/driver_profile_provider.dart';
import 'components/profile_header.dart';
import 'components/statistics_section.dart';
import 'components/driver_info_section.dart';
import 'components/campaigns_tab.dart';
import 'components/settings_tab.dart';

class DriverProfileScreen extends ConsumerStatefulWidget {
  const DriverProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DriverProfileScreen> createState() =>
      _DriverProfileScreenState();
}

class _DriverProfileScreenState extends ConsumerState<DriverProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Driver ID is now provided by Riverpod

  // Stats data - will be updated from API
  final Map<String, dynamic> _statsData = {
    'earnings': {'value': '₹0', 'change': '0%'},
    'trips': {'value': '0', 'change': '0%'},
    'hours': {'value': '0', 'change': '0%'},
    'rating': {'value': '0', 'change': '0%'},
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Fetch driver profile data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final driverProfileProvider =
          provider.Provider.of<DriverProfileProvider>(context, listen: false);
      final driverId = ref.read(driverIdProvider);

      // Only fetch if we have a driver ID and the profile is not loaded or has an error
      if (driverId != null &&
          (driverProfileProvider.driverProfile == null ||
              driverProfileProvider.error != null)) {
        driverProfileProvider.fetchDriverProfile(driverId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Colors
  static const Color primaryOrange = Color(0xFFFF5722); // Brand orange color
  static const Color textColor = Color(0xFF2C3E50);
  static const Color backgroundColor = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    // Get the existing provider or create if it doesn't exist yet
    final profileProvider =
        provider.Provider.of<DriverProfileProvider>(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: profileProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryOrange))
          : profileProvider.error != null
              ? Center(child: Text('Error: ${profileProvider.error}'))
              : NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      _buildAppBar(),
                    ];
                  },
                  body: Column(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x0D000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicatorColor: primaryOrange,
                          labelColor: primaryOrange,
                          unselectedLabelColor: Colors.grey,
                          labelStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          tabs: const [
                            Tab(text: 'Profile'),
                            Tab(text: 'Campaigns'),
                            Tab(text: 'Settings'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  StatisticsSection(statsData: _statsData),
                                  const SizedBox(height: 24),
                                  DriverInfoSection(),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                            CampaignsTab(),
                            SettingsTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: textColor),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: textColor),
          onPressed: () {
            // Handle notifications tap
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: textColor),
          onPressed: () {
            // Handle more options
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: ProfileHeader(),
      ),
    );
  }
}
