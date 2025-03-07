import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  @override
  Widget build(BuildContext context) {
    // Detect Theme Mode
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white, // Auto Theme
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFFE89C08),
                // Auto Theme
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                ),
              ),
              child: SafeArea(
                child: Text(
                  "Create Your Account",
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Form Container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  formField(
                      "Business Name", "Enter Your Business Name", isDarkMode),
                  formField(
                      "Business Type", "Enter Your Business Type", isDarkMode),
                  formField("Email / Phone Number",
                      "Enter email id or Phone Number", isDarkMode),
                  formField("Password", "Enter Password", isDarkMode,
                      obscure: true),
                  formField("Confirm Password", "Re-enter Password", isDarkMode,
                      obscure: true),

                  const SizedBox(height: 20),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Upload Verification Documents
                  const Text(
                    "Verification",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text("Upload Business Verification Documents"),
                  const SizedBox(height: 10),

                  // Upload Boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      uploadBox(isDarkMode),
                      uploadBox(isDarkMode),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Already have an account? Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Login",
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),

                  // Next Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon:
                          const Icon(Icons.arrow_forward, color: Colors.white),
                      label: const Text(
                        "Next",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable Input Field Widget
  Widget formField(String label, String hint, bool isDarkMode,
      {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white : Colors.black)),
        const SizedBox(height: 5),
        TextField(
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFFD2D2D2)), // Applied #D2D2D2
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFFD2D2D2)), // Applied #D2D2D2
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: Color(0xFFD2D2D2), width: 2), // Thicker on focus
            ),
          ),
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  // Upload Box Widget
  Widget uploadBox(bool isDarkMode) {
    return Container(
      width: 130,
      height: 100,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[400],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.upload, color: Colors.white, size: 40),
      ),
    );
  }
}
