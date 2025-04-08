import 'package:flutter/material.dart';
import 'about_company_screen.dart';
import 'driver_dashboard.dart';
import 'driver_help_issue_screen.dart';
import 'driver_profile_screen.dart';
import 'driver_live_location.dart';
import 'driver_upload_advertisement_proof.dart';
import 'driver_upload_status_screen.dart';

class DriverMainScreen extends StatefulWidget {
  const DriverMainScreen({Key? key}) : super(key: key);

  @override
  State<DriverMainScreen> createState() => _DriverMainScreenState();
}

class _DriverMainScreenState extends State<DriverMainScreen> {
  int _currentIndex = 0;
  static const Color primaryOrange = Color(0xFFFF7F00);

  final List<Widget> _screens = [
    const DriverDashboard(),
    const DriverLiveLocation(),
    const AboutCompanyScreen(),
    const DriverUploadAdvertisementProof(),
    const DriverHelpIssueScreen(),
    const DriverProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: DriverBottomNavigationBar(
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

class DriverBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  static const Color primaryOrange = Color(0xFFFF7F00);

  const DriverBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryOrange,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.location_on),
          label: 'Location',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.ad_units_sharp),
          label: 'Company About',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.upload),
          label: 'Upload Avertisement Proof',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.help),
          label: 'Help',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}

// Navigation helper to use in other screens
class DriverNavigation {
  static void navigateToProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const DriverProfileScreen()),
    );
  }

  static void navigateToHelp(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const DriverHelpIssueScreen()),
    );
  }

  static void navigateToCompanyInfo(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AboutCompanyScreen()),
    );
  }

  static void navigateToUploadProof(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DriverUploadAdvertisementProof(),
      ),
    );
  }

  static void navigateToUploadStatus(BuildContext context,
      {String status = 'Pending'}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DriverUploadStatusScreen(status: status),
      ),
    );
  }

  static void navigateToLiveLocation(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const DriverLiveLocation()),
    );
  }
}
