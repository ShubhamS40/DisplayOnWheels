import 'package:flutter/material.dart';
import 'package:tsp/screens/company/company_dashboard/company_dashboard_screen.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/ad_campaign_screen.dart';
import 'package:tsp/screens/company/company_profile/company_profile_screen.dart';

class CompanyMainScreen extends StatefulWidget {
  const CompanyMainScreen({Key? key}) : super(key: key);

  @override
  State<CompanyMainScreen> createState() => _CompanyMainScreenState();
}

class _CompanyMainScreenState extends State<CompanyMainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      const CompanyDashboardScreen(),
      const AdCampaignScreen(),
      const CompanyProfileScreen(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CompanyBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class CompanyBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  static const Color primaryOrange = Color(0xFFFF5722);

  const CompanyBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
          selectedItemColor: primaryOrange,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          iconSize: 24,
          elevation: 8,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              activeIcon: _buildActiveIcon(Icons.home),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.campaign),
              activeIcon: _buildActiveIcon(Icons.campaign),
              label: 'Launch Ad',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business),
              activeIcon: _buildActiveIcon(Icons.business),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: primaryOrange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: primaryOrange),
    );
  }
}

// Navigation helper to use in other screens
class CompanyNavigation {
  static void navigateToDashboard(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CompanyDashboardScreen()),
    );
  }

  static void navigateToAdCampaign(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AdCampaignScreen()),
    );
  }

  static void navigateToProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CompanyProfileScreen()),
    );
  }
}
