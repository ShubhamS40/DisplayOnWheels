import 'package:flutter/material.dart';
import 'package:tsp/screens/driver/document_verification_driver.dart';
import 'package:tsp/screens/driver/driver_auth/driver_signup.dart';

class DriverLoginScreen extends StatefulWidget {
  @override
  _DriverLoginScreenState createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends State<DriverLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailPhoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final containerColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final shadowColor =
        isDarkMode ? Colors.black54 : Colors.grey.withOpacity(0.8);
    final buttonColor = isDarkMode ? Colors.orangeAccent : Colors.orange;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Illustration Image
                Image.asset(
                  "assets/authsvg/driver_signup.png", // Replace with your asset
                  height: 400,
                ),
                const SizedBox(height: 20),

                // Container with Rounded Corners & Shadow
                Container(
                  padding: const EdgeInsets.all(20),
                  height: MediaQuery.of(context).size.height / 2.1,
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60)),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 40,
                        spreadRadius: 3,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Title
                        Text(
                          "Driver Login",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Email/Phone Field
                        buildTextField(
                          controller: emailPhoneController,
                          label: "Email / Phone Number",
                          hint: "Enter email or phone number",
                          icon: Icons.email,
                          textColor: textColor,
                        ),

                        // Password Field
                        buildPasswordField(
                            passwordController, "Password", textColor),

                        const SizedBox(height: 20),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DriverVerificationScreen()));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // Don't have an account? Sign Up
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account?",
                                style: TextStyle(color: textColor)),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            DriverSignUpScreen()));
                              },
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(color: Colors.orange),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable Text Field Widget
  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: textColor),
          hintText: hint,
          hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          prefixIcon: Icon(icon, color: textColor),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "This field is required";
          return null;
        },
      ),
    );
  }

  // Reusable Password Field Widget
  Widget buildPasswordField(
      TextEditingController controller, String label, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: !isPasswordVisible,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: textColor),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          prefixIcon: Icon(Icons.lock, color: textColor),
          suffixIcon: IconButton(
            icon: Icon(
              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: textColor,
            ),
            onPressed: () {
              setState(() {
                isPasswordVisible = !isPasswordVisible;
              });
            },
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "Enter a password";
          return null;
        },
      ),
    );
  }
}
