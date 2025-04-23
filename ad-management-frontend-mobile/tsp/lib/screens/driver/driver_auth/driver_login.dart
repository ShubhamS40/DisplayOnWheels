import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsp/screens/driver/driver_document/documentUpload.dart';
import 'package:tsp/screens/driver/driver_document/documentVerification_Stage.dart';
import 'package:tsp/screens/driver/driver_dashboard.dart';
import 'package:tsp/screens/driver/driver_main_screen.dart';
import 'package:tsp/screens/driver/driver_auth/driver_signup.dart';
import 'package:tsp/screens/driver/driver_auth/forgot_password.dart';

class DriverLoginScreen extends StatefulWidget {
  @override
  _DriverLoginScreenState createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends State<DriverLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailPhoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> loginDriver() async {
    setState(() {
      _isLoading = true;
    });

    final email = emailPhoneController.text.trim();
    final password = passwordController.text.trim();

    final url = Uri.parse('http://localhost:5000/api/driver/login');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": email,
          "password": password,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['token'] != null) {
        final token = responseData['token'];

        // Decode the token to extract driverId
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String driverId = decodedToken['driverId'];

        // Save the driver ID and token to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('driverId', driverId);
        await prefs.setString('token', token);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful!')),
        );

        // Route driver based on document verification status
        await _checkDocumentStatusAndNavigate(driverId);
      } else {
        setState(() {
          _isLoading = false;
        });
        final errorMsg = responseData['msg'] ?? 'Login failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _checkDocumentStatusAndNavigate(String driverId) async {
    try {
      // First check if the driver has submitted documents
      final docsSubmittedResponse = await http.get(
        Uri.parse(
            'http://localhost:5000/api/driver/has-submitted-documents/$driverId'),
        headers: {"Content-Type": "application/json"},
      );

      final docsSubmittedData = json.decode(docsSubmittedResponse.body);
      final bool hasSubmittedDocs = docsSubmittedData['hasSubmitted'] ?? false;

      // If documents have not been submitted, route to document upload screen
      if (!hasSubmittedDocs) {
        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DriverVerificationScreen(driverId: driverId),
          ),
        );
        return;
      }

      // If documents have been submitted, check verification status
      final docStatusResponse = await http.get(
        Uri.parse('http://localhost:5000/api/driver/document-status/$driverId'),
        headers: {"Content-Type": "application/json"},
      );

      if (docStatusResponse.statusCode == 200) {
        final docStatusData = json.decode(docStatusResponse.body);
        final documents = docStatusData['documents'];

        // Check if all documents are approved
        final bool allApproved = documents['photoStatus'] == 'APPROVED' &&
            documents['idCardStatus'] == 'APPROVED' &&
            documents['drivingLicenseStatus'] == 'APPROVED' &&
            documents['vehicleImageStatus'] == 'APPROVED' &&
            documents['bankProofStatus'] == 'APPROVED';

        // Check if any documents are rejected
        final bool anyRejected = documents['photoStatus'] == 'REJECTED' ||
            documents['idCardStatus'] == 'REJECTED' ||
            documents['drivingLicenseStatus'] == 'REJECTED' ||
            documents['vehicleImageStatus'] == 'REJECTED' ||
            documents['bankProofStatus'] == 'REJECTED';

        setState(() {
          _isLoading = false;
        });

        if (allApproved) {
          // All documents approved - navigate directly to driver dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DriverDashboard()),
          );
        } else {
          // Documents pending or rejected - show document status screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DocumentStatusScreen()),
          );
        }
      } else {
        // Error getting document status, default to document status screen
        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DocumentStatusScreen()),
        );
      }
    } catch (e) {
      // If any errors, show error and navigate to document status screen as fallback
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error checking document status: ${e.toString()}')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DocumentStatusScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final containerColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final shadowColor =
        isDarkMode ? Colors.black54 : Colors.grey.withOpacity(0.8);
    final buttonColor = isDarkMode ? Colors.orangeAccent : Colors.orange;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset("assets/authsvg/driver_signup.png", height: 320),
                Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
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
                      children: [
                        Text(
                          "Driver Login",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        buildTextField(
                          controller: emailPhoneController,
                          label: "Email / Phone Number",
                          hint: "Enter email or phone number",
                          icon: Icons.email,
                          textColor: textColor,
                        ),
                        buildPasswordField(
                            passwordController, "Password", textColor),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ForgotPasswordDriverScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      loginDriver();
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : const Text(
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
                                    builder: (context) => DriverSignUpScreen(),
                                  ),
                                );
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
