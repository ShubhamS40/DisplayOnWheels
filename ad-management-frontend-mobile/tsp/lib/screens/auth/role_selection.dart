import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tsp/main.dart';
import 'package:tsp/screens/admin/admin_auth/admin_login.dart';
import 'package:tsp/screens/company/company_auth/company_login.dart';
import 'package:tsp/screens/driver/driver_auth/driver_login.dart';
import 'package:tsp/utils/theme_constants.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  String selectedRole = ""; // No role selected initially
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Use a consistent selection color for all roles
  final Color selectedColor = Color(0xFFE67E22); // Orange color

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);

    // Initial role selection
    Future.delayed(Duration.zero, () {
      setState(() {
        selectedRole = roleDetails[0]['title']; // Set default selected role
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void navigateToRoleScreen(BuildContext context) {
    if (selectedRole.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select a role before continuing "),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: selectedColor,
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

  // Role card details with high-quality SVG illustrations
  final List<Map<String, dynamic>> roleDetails = [
    {
      'title': 'Company',
      'icon': Icons.business,
      'description': 'Manage ad campaigns and vehicles',
      'illustration':
          'https://assets.website-files.com/5baa461315ec5c2b9c9b5499/5db7c01e89c1d87a8e72722e_building_illustration.svg',
    },
    {
      'title': 'Driver',
      'icon': Icons.directions_car,
      'description': 'Track trips and earnings',
      'illustration':
          'https://assets.website-files.com/5baa461315ec5c2b9c9b5499/5db7c01f4ea5be96784ec5b7_vehicle_illustration.svg',
    },
    {
      'title': 'Admin',
      'icon': Icons.admin_panel_settings,
      'description': 'Manage the entire platform',
      'illustration':
          'https://assets.website-files.com/5baa461315ec5c2b9c9b5499/5db7c01f4ea5be70e04ec5b8_admin_illustration.svg',
    },
  ];

  Widget buildRoleCard(Map<String, dynamic> roleData, bool isDarkMode) {
    bool isSelected = selectedRole == roleData['title'];
    final Color bgColor = isSelected
        ? selectedColor
        : (isDarkMode ? Colors.grey[850]! : Colors.white);

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      height: 85, // Reduced height to prevent overflow
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isSelected ? selectedColor.withOpacity(0.4) : Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
            spreadRadius: isSelected ? 1 : 0,
          ),
        ],
        border: isSelected
            ? Border.all(color: selectedColor.withOpacity(0.8), width: 2.5)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            setState(() {
              selectedRole = roleData['title'];
            });
            HapticFeedback.mediumImpact();
          },
          child: Row(
            children: [
              // Left side with illustration
              Container(
                width: 100,
                padding: EdgeInsets.all(16),
                child: isSelected
                    ? AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: child,
                          );
                        },
                        child: Image.network(
                          roleData['illustration'],
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            roleData['icon'],
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Image.network(
                        roleData['illustration'],
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          roleData['icon'],
                          size: 40,
                          color: selectedColor,
                        ),
                      ),
              ),

              // Right side with text content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                      right: 16.0, top: 10.0, bottom: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Role title
                      Text(
                        roleData['title'],
                        style: TextStyle(
                          fontSize: 18, // Smaller font size
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : (isDarkMode ? Colors.white : selectedColor),
                        ),
                      ),

                      SizedBox(height: 4), // Reduced spacing

                      // Role description
                      Text(
                        roleData['description'],
                        maxLines: 1, // Limit to one line
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13, // Smaller font size
                          color: isSelected
                              ? Colors.white.withOpacity(0.9)
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF121212) : Color(0xFFF5F5F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header section
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                child: Column(
                  children: [
                    // Decorative header icon
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: selectedColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.login_rounded,
                        size: 40,
                        color: selectedColor,
                      ),
                    ),

                    SizedBox(height: 16),

                    // Header text
                    Text(
                      "Welcome to TSP ",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),

                    SizedBox(height: 8),

                    // Subheader text - shorter text to reduce height
                    Text(
                      "Select your role to continue",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),

              // Role cards - vertical stacked layout
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Stack the role cards vertically with proper spacing
                    for (var roleData in roleDetails)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: buildRoleCard(roleData, isDarkMode),
                      ),
                  ],
                ),
              ),

              SizedBox(height: 16), // Add space between cards and button

              // Continue button
              Container(
                width: double.infinity,
                margin: EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: ElevatedButton(
                  onPressed: () => navigateToRoleScreen(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: selectedColor.withOpacity(0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Continue",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
