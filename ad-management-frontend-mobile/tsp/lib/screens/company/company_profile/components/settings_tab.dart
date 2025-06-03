import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsp/screens/auth/role_selection.dart';
import 'package:tsp/screens/company/company_profile/contact_support_screen.dart';
import 'package:tsp/screens/company/company_profile/document_view_screen.dart';
import 'package:tsp/screens/company/company_profile/edit_company_profile_screen.dart';
import 'package:tsp/services/auth_service.dart';
import 'settings_card.dart';

class SettingsTab extends StatelessWidget {
  static const Color primaryOrange = Color(0xFFFF5722);
  static const Color textColor = Color(0xFF2C3E50);

  const SettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),

          // Account Section
          SettingsCard(
            title: 'Account',
            items: [
              SettingsItem(
                icon: Icons.person_outline,
                title: 'Edit Company Profile',
                subtitle: 'Update your company information',
                iconColor: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditCompanyProfileScreen(),
                    ),
                  );
                },
              ),
              SettingsItem(
                icon: Icons.lock_outline,
                title: 'Change Password',
                subtitle: 'Update your account password',
                iconColor: Colors.purple,
                onTap: () {
                  // Navigate to change password screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Change password functionality coming soon')),
                  );
                },
              ),
              SettingsItemSwitch(
                icon: Icons.notifications_none,
                title: 'Notifications',
                subtitle: 'Enable or disable notifications',
                iconColor: Colors.amber,
                value: true,
                onChanged: (value) {
                  // Update notification preferences
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Payment Section
          SettingsCard(
            title: 'Payment & Billing',
            items: [
              SettingsItem(
                icon: Icons.payment,
                title: 'Payment Methods',
                subtitle: 'Manage your payment options',
                iconColor: Colors.green,
                onTap: () {
                  // Navigate to payment methods screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Payment methods functionality coming soon')),
                  );
                },
              ),
              SettingsItem(
                icon: Icons.receipt_long,
                title: 'Billing History',
                subtitle: 'View your transaction history',
                iconColor: Colors.blueGrey,
                onTap: () {
                  // Navigate to billing history screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Billing history functionality coming soon')),
                  );
                },
              ),
              SettingsItem(
                icon: Icons.workspace_premium,
                title: 'Subscription Plan',
                subtitle: 'Manage your subscription',
                iconColor: primaryOrange,
                onTap: () {
                  // Navigate to subscription management screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Subscription management coming soon')),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Support Section
          SettingsCard(
            title: 'Support & Help',
            items: [
              SettingsItem(
                icon: Icons.help_outline,
                title: 'Help Center',
                subtitle: 'Get answers to your questions',
                iconColor: Colors.cyan,
                onTap: () {
                  // Navigate to help center
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Help center coming soon')),
                  );
                },
              ),
              SettingsItem(
                icon: Icons.description_outlined,
                title: 'My Documents',
                subtitle: 'View your uploaded documents',
                iconColor: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DocumentViewScreen(),
                    ),
                  );
                },
              ),
              SettingsItem(
                icon: Icons.support_agent,
                title: 'Contact Support',
                subtitle: 'Get in touch with our team',
                iconColor: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContactSupportScreen(),
                    ),
                  );
                },
              ),
              SettingsItem(
                icon: Icons.feedback_outlined,
                title: 'Send Feedback',
                subtitle: 'Help us improve our service',
                iconColor: Colors.indigo,
                onTap: () {
                  // Navigate to feedback form
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Feedback form coming soon')),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // App Settings Section
          SettingsCard(
            title: 'App Settings',
            items: [
              SettingsItemSwitch(
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                subtitle: 'Enable or disable dark mode',
                iconColor: Colors.deepPurple,
                value: isDarkMode,
                onChanged: (value) {
                  // Toggle theme
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Theme toggle functionality coming soon')),
                  );
                },
              ),
              SettingsItem(
                icon: Icons.language,
                title: 'Language',
                subtitle: 'Change app language',
                iconColor: Colors.orange,
                onTap: () {
                  // Navigate to language settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Language settings coming soon')),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Logout Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () => _showLogoutConfirmationDialog(context),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
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
                _logout(context);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    final AuthService _authService = AuthService();
    try {
      await _authService.logout(context);
    } catch (e) {
      // If logout fails, manually navigate to role selection
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove("token");
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
          (route) => false,
        );
      }
    }
  }
}
