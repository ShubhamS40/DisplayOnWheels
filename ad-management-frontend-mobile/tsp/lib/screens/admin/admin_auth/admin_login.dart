import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../utils/theme_constants.dart';
import 'admin_otp_verification.dart';
import 'admin_forgot_password.dart';

class AdminLoginScreen extends StatefulWidget {
  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isLoading = false;
  String? errorMessage;

  // Initialize Dio instance with base URL
  final Dio _dio = Dio(BaseOptions(
    baseUrl: "http://3.110.135.112:5000/api",
    connectTimeout: Duration(milliseconds: 5000),
    receiveTimeout: Duration(milliseconds: 3000),
  ));

  Future<void> _login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _dio.post(
        '/admin/login',
        data: {
          'email': emailController.text.trim(),
          'password': passwordController.text,
        },
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        // API returned success, verify the response structure
        if (response.data != null && response.data['msg'] != null) {
          // OTP was sent successfully, navigate to OTP verification
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminOtpVerificationScreen(
                email: emailController.text.trim(),
              ),
            ),
          );
        } else {
          // Unexpected success response structure
          setState(() {
            errorMessage = 'Unexpected response from server';
          });
        }
      } else {
        // Handle other status codes (should not reach here due to Dio exceptions)
        setState(() {
          errorMessage = 'Unexpected response status: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        if (e is DioException) {
          if (e.response != null) {
            // Server responded with an error status code
            if (e.response?.statusCode == 401 || e.response?.statusCode == 400) {
              errorMessage = 'Invalid credentials';
            } else {
              errorMessage = e.response?.data['message'] ?? 'Server error';
            }
          } else if (e.type == DioExceptionType.connectionTimeout || 
                    e.type == DioExceptionType.receiveTimeout) {
            errorMessage = 'Connection timeout. Please check your internet.';
          } else {
            errorMessage = 'Connection error. Please check your internet.';
          }
        } else {
          errorMessage = 'An unexpected error occurred';
        }
      });
      print('Login error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? ThemeConstants.darkBackground : ThemeConstants.lightBackground;
    final textColor = isDarkMode ? Colors.white : ThemeConstants.textPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenSize.height * 0.05),
                
                // Title with animation effect
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 800),
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Text(
                          "Admin Login",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: ThemeConstants.primaryColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                SizedBox(height: screenSize.height * 0.03),
                
                // Illustration Image from URL with animation
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 1000),
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.scale(
                        scale: 0.8 + (0.2 * value),
                        child: Container(
                          width: screenSize.width * 0.8,
                          constraints: BoxConstraints(
                            maxHeight: screenSize.height * 0.3,
                          ),
                          child: Image.network(
                            ThemeConstants.loginIllustrationUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  color: ThemeConstants.primaryColor,
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / 
                                        (loadingProgress.expectedTotalBytes ?? 1)
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.admin_panel_settings,
                                size: 120,
                                color: ThemeConstants.primaryColor,
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                SizedBox(height: screenSize.height * 0.04),

                // Login Form with animation
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 1200),
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: Container(
                          padding: const EdgeInsets.all(25),
                          decoration: ThemeConstants.getCardDecoration(isDarkMode),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Error message
                                if (errorMessage != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                      decoration: BoxDecoration(
                                        color: ThemeConstants.error.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: ThemeConstants.error.withOpacity(0.3)),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.error_outline, color: ThemeConstants.error, size: 20),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              errorMessage!,
                                              style: TextStyle(color: ThemeConstants.error),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                // Email Field
                                TextFormField(
                                  controller: emailController,
                                  style: TextStyle(color: textColor),
                                  decoration: ThemeConstants.getInputDecoration(
                                    label: "Email",
                                    hint: "Enter Your Email",
                                    prefixIcon: Icons.email,
                                    isDarkMode: isDarkMode,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return "Email is required";
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                      return "Enter a valid email";
                                    }
                                    return null;
                                  },
                                ),

                                SizedBox(height: 16),

                                // Password Field
                                TextFormField(
                                  controller: passwordController,
                                  obscureText: !isPasswordVisible,
                                  style: TextStyle(color: textColor),
                                  decoration: ThemeConstants.getInputDecoration(
                                    label: "Password",
                                    hint: "Enter Your Password",
                                    prefixIcon: Icons.lock,
                                    suffixIcon: isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    suffixIconOnPressed: () {
                                      setState(() {
                                        isPasswordVisible = !isPasswordVisible;
                                      });
                                    },
                                    isDarkMode: isDarkMode,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return "Password is required";
                                    if (value.length < 6) return "Password must be at least 6 characters";
                                    return null;
                                  },
                                ),

                                // Forgot Password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 12, bottom: 20),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context, 
                                          MaterialPageRoute(
                                            builder: (context) => AdminForgotPasswordScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "Forgot Password?",
                                        style: TextStyle(
                                          color: ThemeConstants.primaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Login Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : () {
                                      if (_formKey.currentState!.validate()) {
                                        _login();
                                      }
                                    },
                                    style: ThemeConstants.primaryButtonStyle,
                                    child: isLoading
                                        ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            "Login",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
