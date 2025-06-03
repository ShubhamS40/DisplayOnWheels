import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tsp/provider/providers.dart';
import 'package:tsp/screens/company/company_auth/company_signup.dart';
import 'package:tsp/screens/company/company_auth/company_forgot_password.dart';
import 'package:tsp/screens/company/company_document/company_upload_documents.dart';
import 'package:tsp/screens/company/company_document/company_verification_stage.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/ad_campaign_screen.dart';
import 'package:tsp/screens/company/company_dashboard/company_dashboard_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:tsp/screens/company/company_main_screen/company_main_screen.dart';

class CompanyLogin extends ConsumerStatefulWidget {
  const CompanyLogin({super.key});

  @override
  ConsumerState<CompanyLogin> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<CompanyLogin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String _errorMessage = '';
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Check document status and navigate based on verification stage
  Future<void> _checkDocumentStatusAndNavigate(String companyId) async {
    try {
      // First check if the company has submitted documents
      final docsSubmittedResponse = await http.get(
        Uri.parse(
            'http://3.110.135.112:5000/api/company-docs/has-submitted-documents/$companyId'),
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
            builder: (context) =>
                CompanyDocumentUploadScreen(companyId: companyId),
          ),
        );
        return;
      }

      // If documents have been submitted, check verification status
      final docStatusResponse = await http.get(
        Uri.parse(
            'http://3.110.135.112:5000/api/company-docs/document-status/$companyId'),
        headers: {"Content-Type": "application/json"},
      );

      if (docStatusResponse.statusCode == 200) {
        final docStatusData = json.decode(docStatusResponse.body);
        final documents = docStatusData['documents'];

        // Check if all documents are approved
        final bool allApproved =
            documents['companyRegistrationStatus'] == 'APPROVED' &&
                documents['idCardStatus'] == 'APPROVED' &&
                documents['gstNumberStatus'] == 'APPROVED';

        setState(() {
          _isLoading = false;
        });

        if (allApproved) {
          // All documents approved - navigate directly to company dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const CompanyMainScreen()), // Navigate to company dashboard
          );
        } else {
          // Documents pending or rejected - show document status screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => CompanyDocumentStatusScreen()),
          );
        }
      } else {
        // Error getting document status, default to document status screen
        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => CompanyDocumentStatusScreen()),
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

      // Default to document upload screen as fallback
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CompanyDocumentUploadScreen(companyId: companyId),
        ),
      );
    }
  }

  Future<void> _handleLogin() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final dio = Dio();

      print('Attempting to login with email: ${emailController.text}');

      final response = await dio.post(
        'http://3.110.135.112:5000/api/company/login',
        data: {
          'email': emailController.text.trim(),
          'password': passwordController.text,
        },
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      print('Login Response: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200) {
        // Store the token for future requests
        final token = response.data['token'];
        String companyId = '';

        // Extract companyId from token if possible
        try {
          // Split the token into parts
          final parts = token.split('.');
          if (parts.length > 1) {
            // Decode the payload part (middle part)
            final payload = parts[1];
            final normalized = base64Url.normalize(payload);
            final decodedPayload = utf8.decode(base64Url.decode(normalized));
            final payloadMap = json.decode(decodedPayload);

            // Extract companyId from payload
            companyId = payloadMap['companyId'] ?? '';
            print('Extracted companyId from token: $companyId');
          }
        } catch (e) {
          print('Failed to extract companyId from token: $e');
        }

        // Save token and companyId to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('companyId', companyId);
        
        // Set companyId in the provider
        ref.read(companyIdProvider.notifier).state = companyId;

        print('Login successful! Token and companyId saved');

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login successful!"),
            backgroundColor: Colors.green,
          ),
        );

        // Check document status and navigate to the appropriate screen
        await _checkDocumentStatusAndNavigate(companyId);
      } else {
        setState(() {
          _errorMessage =
              response.data['message'] ?? 'Login failed. Please try again.';
        });
      }
    } catch (e) {
      print('Error during login: $e');
      setState(() {
        _isLoading = false;
        if (e is DioException) {
          if (e.response != null) {
            _errorMessage = e.response?.data['message'] ??
                'Login failed. Please try again.';
          } else if (e.type == DioExceptionType.connectionTimeout) {
            _errorMessage =
                'Connection timeout. Please check your internet connection.';
          } else {
            _errorMessage = 'Network error. Please try again later.';
          }
        } else {
          _errorMessage = 'An error occurred. Please try again.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Top Image
              Center(
                child: Image.asset(
                  'assets/authsvg/login_screen_svg.png',
                  height: MediaQuery.of(context).size.height * 0.3,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),

              // Login Form Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[900] : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                  boxShadow: [
                    if (!isDarkMode)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 8,
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Center(
                      child: Text(
                        "Company Login",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Email
                          const Text("Email",
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 5),
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: "Enter email address",
                              prefixIcon:
                                  const Icon(Icons.email, color: Colors.orange),
                              filled: true,
                              fillColor:
                                  isDarkMode ? Colors.grey[800] : Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your email";
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return "Please enter a valid email address";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 10),

                          const SizedBox(height: 10),

                          // Password
                          const Text("Password",
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 5),
                          TextFormField(
                            controller: passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              hintText: "Enter Password",
                              prefixIcon:
                                  const Icon(Icons.lock, color: Colors.orange),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor:
                                  isDarkMode ? Colors.grey[800] : Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your password";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ForgotPasswordCompanyScreen(),
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

                    // Error message display
                    if (_errorMessage.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.red, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
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
                                    fontSize: 16, color: Colors.white),
                              ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Signup Text
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CompanySignUpScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Sign up",
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
