import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:tsp/screens/company/company_auth/company_login.dart';

class CompanyOtpVerificationScreen extends StatefulWidget {
  final String email;

  const CompanyOtpVerificationScreen({super.key, required this.email});

  @override
  State<CompanyOtpVerificationScreen> createState() =>
      _CompanyOtpVerificationScreenState();
}

class _CompanyOtpVerificationScreenState
    extends State<CompanyOtpVerificationScreen> {
  final otpController = TextEditingController();
  bool otpSent = false;
  bool isLoading = false;
  String message = '';

  final String baseUrl = "http://localhost:5000/api/company";

  @override
  void initState() {
    super.initState();
    // OTP is already sent during signup, so we don't need to send it again
    setState(() {
      otpSent = true;
      message = "OTP sent to ${widget.email}";
    });
  }

  Future<void> resendOtp() async {
    setState(() {
      isLoading = true;
      message = '';
    });

    try {
      print('Attempting to resend OTP to: ${widget.email}');
      final dio = Dio();
      final response = await dio.post(
        '$baseUrl/resend-otp',
        data: {'companyEmail': widget.email},
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      
      print('Resend OTP Response: ${response.statusCode} - ${response.data}');

      setState(() {
        isLoading = false;
        if (response.statusCode == 200) {
          otpSent = true;
          message = "OTP resent to ${widget.email}";
        } else {
          message = response.data['message'] ?? "Failed to resend OTP.";
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        if (e is DioException) {
          print('DioException during resend OTP: ${e.type} - ${e.message}');
          if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
            message = "Connection timed out. Please check your server.";
          } else if (e.type == DioExceptionType.badResponse) {
            message = "Server error (${e.response?.statusCode}): ${e.response?.data['message'] ?? 'Unknown error'}";
          } else {
            message = "Failed to resend OTP: ${e.message}";
          }
        } else {
          print('Error during resend OTP: $e');
          message = "Network error. Please check your connection.";
        }
      });
    }
  }

  Future<void> verifyOtp() async {
    if (otpController.text.isEmpty) {
      setState(() {
        message = "Please enter the OTP.";
      });
      return;
    }
    
    setState(() {
      isLoading = true;
      message = '';
    });

    try {
      print('Attempting to verify OTP for: ${widget.email} with OTP: ${otpController.text}');
      final dio = Dio();
      final response = await dio.post(
        '$baseUrl/verify-email',
        data: {
          'companyEmail': widget.email,
          'otp': otpController.text,
        },
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      
      print('Verify OTP Response: ${response.statusCode} - ${response.data}');

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message'] ?? "Email verified successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to login screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const CompanyLogin()),
          (Route<dynamic> route) => false, // Remove all previous routes
        );
      } else {
        // Failure with response
        setState(() {
          message = response.data['message'] ?? "Verification failed.";
        });
      }
    } catch (e) {
      // Exception
      setState(() {
        isLoading = false;
        if (e is DioException) {
          print('DioException during verify OTP: ${e.type} - ${e.message}');
          if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
            message = "Connection timed out. Please check your server.";
          } else if (e.type == DioExceptionType.badResponse) {
            message = "Server error (${e.response?.statusCode}): ${e.response?.data['message'] ?? 'Unknown error'}";
          } else {
            message = "Verification failed: ${e.message}";
          }
        } else {
          print('Error during verify OTP: $e');
          message = "Network error. Please check your connection.";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Company OTP Verification'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                if (!isDarkMode)
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.email_outlined,
                  size: 70,
                  color: Colors.orange,
                ),
                const SizedBox(height: 20),
                Text(
                  "OTP Verification",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Please enter the verification code sent to:",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textColor),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.email,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: otpController,
                  decoration: InputDecoration(
                    labelText: 'Enter OTP',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.orange),
                  ),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, letterSpacing: 8, color: textColor),
                ),
                const SizedBox(height: 10),
                if (message.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            message,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Verify OTP",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Didn't receive the code?", style: TextStyle(color: textColor)),
                    TextButton(
                      onPressed: isLoading ? null : resendOtp,
                      child: const Text(
                        "Resend OTP",
                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
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
  }
}
