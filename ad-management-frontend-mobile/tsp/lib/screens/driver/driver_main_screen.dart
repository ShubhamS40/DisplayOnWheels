import 'package:flutter/material.dart';
import 'package:tsp/screens/driver/driver_dashboard/driver_dashboard.dart';
import 'package:tsp/utils/auth_protection.dart';
import 'driver_profile/driver_profile_screen.dart';
import 'driver_liveloaction/driver_live_location.dart';

class DriverMainScreen extends StatefulWidget {
  const DriverMainScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<DriverMainScreen> createState() => _DriverMainScreenState();
}

class _DriverMainScreenState extends State<DriverMainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      DriverDashboard(),
      const DriverLiveLocation(),
      const DriverProfileScreen(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return AuthProtectedScreen(
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: DriverBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}

class DriverBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  static const Color primaryOrange =
      Color(0xFFFF5722); // Using the brand orange color from memories

  const DriverBottomNavigationBar({
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
              icon: Icon(Icons.dashboard),
              activeIcon: _buildActiveIcon(Icons.home),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on),
              activeIcon: _buildActiveIcon(Icons.location_on),
              label: 'Location',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              activeIcon: _buildActiveIcon(Icons.person),
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
class DriverNavigation {
  static void navigateToProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const DriverProfileScreen()),
    );
  }

  static void navigateToLiveLocation(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const DriverLiveLocation()),
    );
  }
}
