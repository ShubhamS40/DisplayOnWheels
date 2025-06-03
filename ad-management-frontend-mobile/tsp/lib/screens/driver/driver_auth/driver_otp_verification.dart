import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'driver_login.dart';

class DriverOtpVerificationScreen extends StatefulWidget {
  final String emailOrPhone;

  const DriverOtpVerificationScreen({required this.emailOrPhone});

  @override
  _DriverOtpVerificationScreenState createState() =>
      _DriverOtpVerificationScreenState();
}

class _DriverOtpVerificationScreenState
    extends State<DriverOtpVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  bool _isVerifying = false;
  bool _isResending = false;

  void verifyOtp() async {
    if (otpController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Enter the OTP")));
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final dio = Dio();
      final response = await dio.post(
        'http://3.110.135.112:5000/api/driver/verify-email',
        data: {
          'email': widget.emailOrPhone,
          'otp': otpController.text,
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("OTP verified!")));
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => DriverLoginScreen()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Invalid OTP or server error")));
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  void resendOtp() async {
    setState(() => _isResending = true);

    try {
      final dio = Dio();
      final response = await dio.post(
        'http://3.110.135.112:5000/api/driver/resend-otp',
        data: {
          'email': widget.emailOrPhone,
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("OTP resent successfully")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to resend OTP")));
    } finally {
      setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
                "An OTP has been sent to ${widget.emailOrPhone}. Enter it below to complete registration."),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Enter OTP"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isVerifying ? null : verifyOtp,
              child: _isVerifying
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Verify OTP"),
            ),
            TextButton(
              onPressed: _isResending ? null : resendOtp,
              child: _isResending
                  ? CircularProgressIndicator()
                  : Text("Resend OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
