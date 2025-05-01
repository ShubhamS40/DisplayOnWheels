import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:tsp/screens/company/company_auth/company_login.dart';
import 'package:tsp/screens/company/company_auth/company_otp_verification.dart';
import 'dart:async';

// Replace with your company OTP screen if needed

class CompanySignUpScreen extends StatefulWidget {
  const CompanySignUpScreen({super.key});
  
  @override
  _CompanySignUpScreenState createState() => _CompanySignUpScreenState();
}

class _CompanySignUpScreenState extends State<CompanySignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController emailPhoneController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isTermsAccepted = false;
  String? selectedBusinessType;
  bool _isLoading = false;

  final List<String> businessTypes = [
    "ECommerce",
    "Retail",
    "Manufacturing",
    "Service_Provider",
    "Technology",
    "Healthcare",
    "Education",
    "Finance",
    "Real_Estate",
    "Transportation",
    "Hospitality",
    "Other"
  ];

  @override
  void dispose() {
    businessNameController.dispose();
    emailPhoneController.dispose();
    contactNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
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

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Image.asset("assets/authsvg/driver_signup.png", height: 200),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 50,
                        spreadRadius: 3,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text("Company Sign Up",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: textColor)),
                        const SizedBox(height: 20),
                        buildTextField(businessNameController, "Business Name",
                            "Enter Business Name", Icons.business, textColor),
                        buildTextField(
                            emailPhoneController,
                            "Email",
                            "Enter Email",
                            Icons.email,
                            textColor),
                        buildTextField(
                            contactNumberController,
                            "Contact Number",
                            "Enter Contact Number",
                            Icons.phone,
                            textColor),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "Business Type",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          value: selectedBusinessType,
                          items: businessTypes
                              .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type,
                                      style: TextStyle(color: textColor))))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => selectedBusinessType = value),
                          validator: (value) =>
                              value == null ? "Select a business type" : null,
                        ),
                        const SizedBox(height: 12),
                        // Registration Number field removed
                        buildPasswordField(
                            passwordController, "Password", textColor),
                        buildPasswordField(confirmPasswordController,
                            "Confirm Password", textColor),
                        Row(
                          children: [
                            Checkbox(
                                value: isTermsAccepted,
                                onChanged: (value) =>
                                    setState(() => isTermsAccepted = value!)),
                            GestureDetector(
                              onTap: () => showTermsDialog(context),
                              child: const Text(
                                  "I accept the Terms & Conditions",
                                  style: TextStyle(
                                      color: Colors.orange,
                                      decoration: TextDecoration.underline)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSignUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text("Sign Up",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Already have an account?",
                                style: TextStyle(color: textColor)),
                            TextButton(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => CompanyLogin())),
                              child: const Text("Login",
                                  style: TextStyle(color: Colors.orange)),
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

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      if (!isTermsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please accept Terms & Conditions")));
        return;
      }

      setState(() => _isLoading = true);

      try {
        final dio = Dio();
        
        // Show loading indicator
        setState(() => _isLoading = true);
        
        final response = await dio.post(
          'http://localhost:5000/api/company/register',
          data: {
            'businessName': businessNameController.text.trim(),
            'businessType': selectedBusinessType,
            'email': emailPhoneController.text.trim(),
            'contactNumber': contactNumberController.text.trim(),
            'password': passwordController.text,
            'confirmPassword': confirmPasswordController.text,
            'acceptedTerms': isTermsAccepted,
          },
          options: Options(
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          setState(() => _isLoading = false);

          final emailOrPhone = emailPhoneController.text.trim();
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Registration successful! Please verify your account."),
              backgroundColor: Colors.green,
            )
          );

          // Navigate to OTP verification
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => CompanyOtpVerificationScreen(email: emailOrPhone),
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        String errorMsg = "Registration failed. Try again.";

        if (e is DioException) {
          if (e.response?.data is Map && e.response?.data['error'] != null) {
            errorMsg = e.response!.data['error'];
          } else if (e.type == DioExceptionType.connectionTimeout) {
            errorMsg = "Connection timeout. Please check your internet connection.";
          } else if (e.type == DioExceptionType.badResponse) {
            errorMsg = "Server error (${e.response?.statusCode}). Please try again later.";
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
          )
        );
      }
    }
  }

  Widget buildTextField(TextEditingController controller, String label,
      String hint, IconData icon, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: textColor),
        keyboardType: label.toLowerCase().contains("email") 
            ? TextInputType.emailAddress 
            : label.toLowerCase().contains("number") 
                ? TextInputType.phone 
                : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          prefixIcon: Icon(icon, color: textColor),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "This field is required";
          if (label.toLowerCase().contains("email") &&
              !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return "Please enter a valid email address";
          }
          if (label.toLowerCase().contains("contact") &&
              !RegExp(r'^[0-9]{10}$').hasMatch(value)) {
            return "Please enter a valid 10-digit phone number";
          }
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
        obscureText: label == "Password" ? !isPasswordVisible : !isConfirmPasswordVisible,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          prefixIcon: Icon(Icons.lock, color: textColor),
          suffixIcon: IconButton(
            icon: Icon(
              label == "Password"
                  ? (isPasswordVisible ? Icons.visibility : Icons.visibility_off)
                  : (isConfirmPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
              color: textColor,
            ),
            onPressed: () {
              setState(() {
                if (label == "Password") {
                  isPasswordVisible = !isPasswordVisible;
                } else {
                  isConfirmPasswordVisible = !isConfirmPasswordVisible;
                }
              });
            },
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "This field is required";

          if (label == "Password") {
            if (value.length < 8) return "Password must be at least 8 characters";
            if (!RegExp(r'[A-Z]').hasMatch(value)) {
              return "Password must contain at least one uppercase letter";
            }
            if (!RegExp(r'[0-9]').hasMatch(value)) {
              return "Password must contain at least one number";
            }
            if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
              return "Password must contain at least one special character";
            }
          }

          if (label == "Confirm Password" &&
              value != passwordController.text) {
            return "Passwords do not match";
          }

          return null;
        },
      ),
    );
  }

  void showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Terms & Conditions"),
        content: const SingleChildScrollView(
          child: Text(
            "1. Provide accurate company details.\n"
            "2. Ensure compliance with local laws.\n"
            "3. Agree to data handling policies.\n"
            "4. We may update these terms at any time.",
            textAlign: TextAlign.justify,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("OK"))
        ],
      ),
    );
  }
}
