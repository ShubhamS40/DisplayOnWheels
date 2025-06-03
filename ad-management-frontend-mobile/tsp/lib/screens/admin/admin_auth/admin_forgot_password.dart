import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../utils/theme_constants.dart';
import 'admin_otp_verification.dart';

class AdminForgotPasswordScreen extends StatefulWidget {
  @override
  _AdminForgotPasswordScreenState createState() => _AdminForgotPasswordScreenState();
}

class _AdminForgotPasswordScreenState extends State<AdminForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  final Dio _dio = Dio(BaseOptions(
    baseUrl: "http://3.110.135.112:5000/api",
    connectTimeout: Duration(milliseconds: 5000),
    receiveTimeout: Duration(milliseconds: 3000),
  ));

  Future<void> _sendResetRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
    });

    try {
      final response = await _dio.post(
        '/admin/forgot-password',
        data: {
          'email': emailController.text.trim(),
        },
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        if (response.data['msg'] != null) {
          setState(() {
            successMessage = response.data['msg'];
          });
        } else {
          setState(() {
            successMessage = "Password reset OTP has been sent to your email";
          });
        }

        // Navigate to OTP verification after a short delay to show success message
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminOtpVerificationScreen(
                  email: emailController.text.trim(),
                ),
              ),
            );
          }
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        if (e is DioException) {
          if (e.response != null) {
            errorMessage = e.response?.data['msg'] ?? 'Server error';
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
      print('Forgot password error: $e');
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
      appBar: AppBar(
        title: Text('Forgot Password'),
        backgroundColor: ThemeConstants.primaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenSize.height * 0.03),
              
              // Title with animation
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: Duration(milliseconds: 800),
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Text(
                        "Password Reset",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: ThemeConstants.primaryColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              SizedBox(height: screenSize.height * 0.03),
              
              // Illustration with animation
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
                          maxHeight: screenSize.height * 0.25,
                        ),
                        child: Image.network(
                          ThemeConstants.forgotPasswordIllustrationUrl,
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
                              Icons.lock_reset,
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

              // Form with animation
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: Duration(milliseconds: 1200),
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 30 * (1 - value)),
                      child: Container(
                        padding: EdgeInsets.all(25),
                        decoration: ThemeConstants.getCardDecoration(isDarkMode),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Description text
                              Text(
                                "Enter your email address to receive a password reset code",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: textColor.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 20),

                              // Error or Success message
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
                              if (successMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                    decoration: BoxDecoration(
                                      color: ThemeConstants.success.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: ThemeConstants.success.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.check_circle_outline, color: ThemeConstants.success, size: 20),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            successMessage!,
                                            style: TextStyle(color: ThemeConstants.success),
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
                                  hint: "Enter your email address",
                                  prefixIcon: Icons.email,
                                  isDarkMode: isDarkMode,
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Email is required";
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                    return "Enter a valid email";
                                  }
                                  return null;
                                },
                              ),
                              
                              SizedBox(height: 25),

                              // Reset Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _sendResetRequest,
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
                                      : Text(
                                          "Send Reset Code",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                              
                              SizedBox(height: 20),

                              // Back to Login
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Remember your password? ",
                                    style: TextStyle(color: textColor.withOpacity(0.8)),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "Login",
                                      style: TextStyle(
                                        color: ThemeConstants.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
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
    );
  }
}
