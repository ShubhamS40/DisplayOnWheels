import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/theme_constants.dart';
import '../admin_dashboard/admin_dashboard_screen.dart';

class AdminOtpVerificationScreen extends StatefulWidget {
  final String email;

  const AdminOtpVerificationScreen({Key? key, required this.email})
      : super(key: key);

  @override
  _AdminOtpVerificationScreenState createState() =>
      _AdminOtpVerificationScreenState();
}

class _AdminOtpVerificationScreenState
    extends State<AdminOtpVerificationScreen> {
  final List<TextEditingController> otpControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  bool isLoading = false;
  String? errorMessage;
  String? successMessage;
  int resendSeconds = 30;
  Timer? resendTimer;
  bool canResend = false;

  final Dio _dio = Dio(BaseOptions(
    baseUrl: "http://localhost:5000/api",
    connectTimeout: Duration(milliseconds: 5000),
    receiveTimeout: Duration(milliseconds: 3000),
  ));

  @override
  void initState() {
    super.initState();
    startResendTimer();
  }

  @override
  void dispose() {
    otpControllers.forEach((controller) => controller.dispose());
    focusNodes.forEach((node) => node.dispose());
    resendTimer?.cancel();
    super.dispose();
  }

  void startResendTimer() {
    setState(() {
      canResend = false;
      resendSeconds = 30;
    });

    resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (resendSeconds > 0) {
        setState(() {
          resendSeconds--;
        });
      } else {
        setState(() {
          canResend = true;
        });
        timer.cancel();
      }
    });
  }

  Future<void> verifyOtp() async {
    // Combine OTP from all fields
    final String otp =
        otpControllers.map((controller) => controller.text).join();

    if (otp.length != 6) {
      setState(() {
        errorMessage = "Please enter all 6 digits";
        successMessage = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
    });

    try {
      final response = await _dio.post(
        '/admin/login-verify-otp',
        data: {
          'email': widget.email,
          'otp': otp,
        },
      );

      if (mounted) {
        setState(() {
          isLoading = false;
          successMessage = "OTP verified successfully!";
          errorMessage = null;
        });

        // Save token and adminId to SharedPreferences
        try {
          // Print the response structure to debug
          print('OTP verification response: ${response.data}');
          
          // Extract token and adminId based on actual response structure
          String? token;
          String? adminId;
          
          if (response.data is Map) {
            // Try different response formats
            if (response.data['token'] != null) {
              token = response.data['token'];
            } else if (response.data['data'] != null && response.data['data']['token'] != null) {
              token = response.data['data']['token'];
            }
            
            // Try to find admin ID in different possible locations
            if (response.data['id'] != null) {
              adminId = response.data['id'];
            } else if (response.data['adminId'] != null) {
              adminId = response.data['adminId'];
            } else if (response.data['data'] != null && response.data['data']['id'] != null) {
              adminId = response.data['data']['id'];
            } else if (response.data['data'] != null && response.data['data']['admin'] != null) {
              adminId = response.data['data']['admin']['id'];
            }
          }
          
          if (token != null) {
            // Use SharedPreferences to store authentication details
            SharedPreferences.getInstance().then((prefs) {
              prefs.setString('token', token!);
              
              // If we found an adminId, save it
              if (adminId != null) {
                prefs.setString('adminId', adminId);
                print('Admin authentication saved: ID=$adminId');
              } else {
                // Use a placeholder admin ID to prevent authentication errors
                prefs.setString('adminId', 'admin-${DateTime.now().millisecondsSinceEpoch}');
                print('Warning: Using placeholder admin ID');
              }
              
              prefs.setString('userType', 'admin');
            });
          } else {
            print('Warning: Token missing from response');
          }
        } catch (e) {
          print('Error extracting auth data: $e');
        }

        // Navigate to admin dashboard after saving auth details
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => AdminDashboardScreen(),
              ),
              (route) => false, // This removes all previous routes
            );
          }
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        if (e is DioException) {
          if (e.response != null) {
            if (e.response?.statusCode == 401 ||
                e.response?.statusCode == 400) {
              errorMessage = 'Invalid OTP. Please try again.';
            } else {
              errorMessage = e.response?.data['msg'] ?? 'Server error';
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
      print('OTP verification error: $e');
    }
  }

  Future<void> resendOtp() async {
    if (!canResend) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
    });

    try {
      final response = await _dio.post(
        '/admin/login/resend-otp',
        data: {
          'email': widget.email,
        },
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        if (response.data != null && response.data['msg'] != null) {
          setState(() {
            successMessage = response.data['msg'];
            startResendTimer();
          });
        } else {
          setState(() {
            successMessage = "OTP resent successfully!";
            startResendTimer();
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        if (e is DioException) {
          if (e.response != null) {
            errorMessage = e.response?.data['msg'] ?? 'Server error';
          } else {
            errorMessage = 'Connection error. Please check your internet.';
          }
        } else {
          errorMessage = 'An unexpected error occurred';
        }
      });
      print('Resend OTP error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? ThemeConstants.darkBackground
        : ThemeConstants.lightBackground;
    final textColor = isDarkMode ? Colors.white : ThemeConstants.textPrimary;

    // Calculate OTP input field size based on screen width
    final otpFieldSize = (screenSize.width - 80) / 6;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('OTP Verification'),
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
                        "OTP Verification",
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

              // Email display with animation
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: Duration(milliseconds: 900),
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: value,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "We have sent a 6-digit code to\n${widget.email}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textColor.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: screenSize.height * 0.02),

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
                          maxHeight: screenSize.height * 0.2,
                        ),
                        child: Image.network(
                          ThemeConstants.otpVerificationIllustrationUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: ThemeConstants.primaryColor,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.pin,
                              size: 100,
                              color: ThemeConstants.primaryColor,
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: screenSize.height * 0.03),

              // OTP Form with animation
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
                        decoration:
                            ThemeConstants.getCardDecoration(isDarkMode),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Error or Success message
                            if (errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
                                  decoration: BoxDecoration(
                                    color:
                                        ThemeConstants.error.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: ThemeConstants.error
                                            .withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error_outline,
                                          color: ThemeConstants.error,
                                          size: 20),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          errorMessage!,
                                          style: TextStyle(
                                              color: ThemeConstants.error),
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
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
                                  decoration: BoxDecoration(
                                    color:
                                        ThemeConstants.success.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: ThemeConstants.success
                                            .withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle_outline,
                                          color: ThemeConstants.success,
                                          size: 20),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          successMessage!,
                                          style: TextStyle(
                                              color: ThemeConstants.success),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // OTP Input Fields
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenSize.width * 0.02,
                                vertical: 10,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: List.generate(
                                  6,
                                  (index) => Container(
                                    width: min(otpFieldSize, 40),
                                    height: min(otpFieldSize, 50),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: ThemeConstants.primaryColor
                                            .withOpacity(0.3),
                                      ),
                                    ),
                                    child: TextFormField(
                                      controller: otpControllers[index],
                                      focusNode: focusNodes[index],
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.zero,
                                        border: InputBorder.none,
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              color:
                                                  ThemeConstants.primaryColor),
                                        ),
                                      ),
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(1),
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      onChanged: (value) {
                                        if (value.isNotEmpty && index < 5) {
                                          FocusScope.of(context).requestFocus(
                                              focusNodes[index + 1]);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 25),

                            // Verify Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : verifyOtp,
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
                                        "Verify OTP",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),

                            SizedBox(height: 20),

                            // Resend OTP
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Didn't receive code? ",
                                  style: TextStyle(
                                      color: textColor.withOpacity(0.8)),
                                ),
                                GestureDetector(
                                  onTap: canResend ? resendOtp : null,
                                  child: Text(
                                    canResend
                                        ? "Resend OTP"
                                        : "Resend in ${resendSeconds}s",
                                    style: TextStyle(
                                      color: canResend
                                          ? ThemeConstants.primaryColor
                                          : ThemeConstants.primaryColor
                                              .withOpacity(0.5),
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
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to find the minimum of two values
  double min(double a, double b) {
    return a < b ? a : b;
  }
}
