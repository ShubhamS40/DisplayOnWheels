import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tsp/screens/driver/driver_help_issue_screen/driver_help_issue_screen.dart';
import 'package:tsp/services/auth_service.dart';
import 'settings_card.dart';
import 'settings_item.dart';
import 'settings_item_switch.dart';
import 'vehicle_details_view.dart';
import 'bank_details_view.dart';
import 'document_details_view.dart';
import 'edit_profile_view.dart';

import '../../about_company_dow/about_company_screen.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({Key? key}) : super(key: key);

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  // Switch states
  bool _notificationsEnabled = true;
  bool _locationTracking = true;
  bool _darkMode = false;
  bool _saveData = false;

  static const Color primaryOrange =
      Color(0xFFFF5722); // Using brand orange color
  static const Color textColor = Color(0xFF2C3E50);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),

          // Account settings
          SettingsCard(
            title: 'Account',
            children: [
              SettingsItem(
                title: 'View Documents',
                subtitle: 'View your verification documents',
                icon: Icons.file_copy,
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DocumentDetailsView(),
                    ),
                  );
                },
              ),
              const Divider(),
              SettingsItem(
                title: 'Edit Profile',
                subtitle: 'Change your account information',
                icon: Icons.person,
                color: primaryOrange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileView(),
                    ),
                  );
                },
              ),
              const Divider(),
              SettingsItem(
                title: 'Change Password',
                subtitle: 'Update your password',
                icon: Icons.lock,
                color: Colors.blue,
                onTap: () {
                  // Handle change password
                },
              ),
              const Divider(),
              SettingsItem(
                title: 'Vehicle Information',
                subtitle: 'Update your vehicle details',
                icon: Icons.directions_car,
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VehicleDetailsView(),
                    ),
                  );
                },
              ),
              const Divider(),
              SettingsItem(
                title: 'Bank Details',
                subtitle: 'Manage your payment information',
                icon: Icons.account_balance,
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BankDetailsView(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Notification settings
          SettingsCard(
            title: 'Notifications',
            children: [
              SettingsItemSwitch(
                title: 'Push Notifications',
                subtitle: 'Receive notifications on your device',
                icon: Icons.notifications,
                color: Colors.amber,
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              const Divider(),
              SettingsItem(
                title: 'Email Notifications',
                subtitle: 'Manage email alerts',
                icon: Icons.email,
                color: Colors.red,
                onTap: () {
                  // Handle email notifications
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // App settings
          SettingsCard(
            title: 'App Settings',
            children: [
              SettingsItemSwitch(
                title: 'Location Tracking',
                subtitle: 'Allow app to track your location',
                icon: Icons.location_on,
                color: Colors.green,
                value: _locationTracking,
                onChanged: (value) {
                  setState(() {
                    _locationTracking = value;
                  });
                },
              ),
              const Divider(),
              SettingsItemSwitch(
                title: 'Dark Mode',
                subtitle: 'Switch between light and dark themes',
                icon: Icons.dark_mode,
                color: Colors.indigo,
                value: _darkMode,
                onChanged: (value) {
                  setState(() {
                    _darkMode = value;
                  });
                },
              ),
              const Divider(),
              SettingsItemSwitch(
                title: 'Save Data',
                subtitle: 'Reduce data usage in the app',
                icon: Icons.data_usage,
                color: Colors.blue,
                value: _saveData,
                onChanged: (value) {
                  setState(() {
                    _saveData = value;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Help and support
          SettingsCard(
            title: 'Help & Support',
            children: [
              SettingsItem(
                title: 'Driver Support',
                subtitle: 'Get help with your driver account',
                icon: Icons.help,
                color: Colors.teal,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const DriverHelpIssueScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              SettingsItem(
                title: 'Contact Support',
                subtitle: 'Reach out to our support team',
                icon: Icons.support_agent,
                color: Colors.cyan,
                onTap: () {
                  // Handle contact support
                },
              ),
              const Divider(),
              SettingsItem(
                title: 'About Company & Privacy',
                subtitle: 'Read about our company and privacy policy',
                icon: Icons.privacy_tip,
                color: Colors.blue,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AboutCompanyScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Logout
          SettingsCard(
            title: 'Account Actions',
            children: [
              SettingsItem(
                title: 'Log Out',
                subtitle: 'Sign out from your account',
                icon: Icons.logout,
                color: Colors.red,
                onTap: () {
                  // Show confirmation dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Logout Confirmation'),
                        content: const Text('Are you sure you want to log out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              // Use AuthService to logout
                              final authService = AuthService();
                              authService.logout(context);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Logout'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
