import 'package:flutter/material.dart';
import 'package:tsp/screens/admin/admin_auth/admin_login.dart';
import 'package:tsp/screens/company/company_auth/company_login.dart';
import 'package:tsp/screens/driver/driver_auth/driver_login.dart';

class RoleSelectionScreen extends StatefulWidget {
  @override
  _RoleSelectionScreenState createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String selectedRole = ""; // No role selected initially

  void navigateToRoleScreen(BuildContext context) {
    if (selectedRole.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a role before continuing."),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    switch (selectedRole) {
      case "Company":
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => CompanyLogin()));
        break;
      case "Driver":
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => DriverLoginScreen()));
        break;
      case "Admin":
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => AdminLoginScreen()));
        break;
    }
  }

  Widget buildRoleCard(String role, IconData icon, bool isDarkMode) {
    bool isSelected = selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = role;
        });
      },
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.orange
              : (isDarkMode ? Colors.grey[900] : Colors.white),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colors.orange.withOpacity(0.4)
                  : Colors.grey.withOpacity(0.2),
              blurRadius: 12,
              spreadRadius: 3,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: isSelected
                ? Colors.orange.shade700
                : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
                Icon(
                  icon,
                  size: 45,
                  color: isSelected
                      ? Colors.white
                      : (isDarkMode ? Colors.white70 : Colors.orange.shade700),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              role,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? Colors.white
                    : (isDarkMode ? Colors.white70 : Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                "Select Your Role",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "Choose the role that best suits you. Your selection will help us tailor your experience accordingly.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    buildRoleCard("Company", Icons.business, isDarkMode),
                    buildRoleCard("Driver", Icons.directions_car, isDarkMode),
                    buildRoleCard(
                        "Admin", Icons.admin_panel_settings, isDarkMode),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    navigateToRoleScreen(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shadowColor: Colors.orange.withOpacity(0.5),
                    elevation: 6,
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
