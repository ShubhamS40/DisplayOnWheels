import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart' as provider;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsp/screens/auth/role_selection.dart';
import 'package:tsp/services/auth_service.dart';
import '../../../provider/providers.dart';
import '../../../providers/company_profile_provider.dart';
import 'components/profile_header.dart';
import 'components/statistics_section.dart';
import 'components/company_info_section.dart';
import 'components/campaigns_tab.dart';
import 'components/settings_tab.dart';

class CompanyProfileScreen extends ConsumerStatefulWidget {
  const CompanyProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CompanyProfileScreen> createState() =>
      _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends ConsumerState<CompanyProfileScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Fetch company profile data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get both providers we need
      final companyProfileProvider =
          provider.Provider.of<CompanyProfileProvider>(context, listen: false);
      final companyId = ref.read(companyIdProvider);

      print('Company ID from provider: $companyId');

      // If no company ID from provider, show a message instead of using a default ID
      if (companyId == null || companyId.isEmpty) {
        print('No valid company ID found. Please login again.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No valid company ID found. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );
        return; // Don't fetch profile without a valid ID
      }

      // Always fetch to ensure we have the latest data
      print('Fetching company profile for ID: $companyId');
      companyProfileProvider.fetchCompanyProfile(companyId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    try {
      // Get the ProviderContainer from the ProviderScope
      final container = ProviderScope.containerOf(context);
      // Pass the container to the logout method
      await _authService.logout(context, container: container);
    } catch (e) {
      // If logout fails, manually navigate to role selection
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove("token");
      // Also clear provider states
      ref.read(companyIdProvider.notifier).state = null;
      ref.read(driverIdProvider.notifier).state = null;
      ref.read(rechargePlanIdProvider.notifier).state = null;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
        (route) => false,
      );
    }
  }

  // Colors
  static const Color primaryOrange = Color(0xFFFF5722); // Brand orange color
  static const Color textColor = Color(0xFF2C3E50);
  static const Color backgroundColor = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    // Get the existing provider or create if it doesn't exist yet
    final profileProvider =
        provider.Provider.of<CompanyProfileProvider>(context);

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
                                  const CompanyStatisticsSection(),
                                  const SizedBox(height: 24),
                                  const CompanyInfoSection(),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                            const CampaignsTab(),
                            const SettingsTab(),
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
        background: const CompanyProfileHeader(),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required bool isDarkMode,
  }) {
    final cardColor = isDarkMode ? Colors.grey[850] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFFFF5722),
            size: 28,
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required bool isDarkMode,
  }) {
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFFF5722),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
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
