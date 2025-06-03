import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'driver_login.dart';
import 'driver_otp_verification.dart'; // ✅ Import OTP screen

class DriverSignUpScreen extends StatefulWidget {
  @override
  _DriverSignUpScreenState createState() => _DriverSignUpScreenState();
}

class _DriverSignUpScreenState extends State<DriverSignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailPhoneController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isTermsAccepted = false;
  String? selectedVehicleType;
  bool _isLoading = false;

  final List<String> vehicleTypes = [
    "Hatchback",
    "SUV",
    "Sedan",
    "Compact",
    "Convertible",
    "Coupe",
    "Crossover",
    "Minivan",
    "Autorickshaw",
    "Pickup Truck",
    "Van",
    "Wagon",
    "Other"
  ];

  @override
  void dispose() {
    fullNameController.dispose();
    emailPhoneController.dispose();
    contactNumberController.dispose();
    vehicleNumberController.dispose();
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
                        Text("Driver Sign Up",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: textColor)),
                        const SizedBox(height: 20),
                        buildTextField(fullNameController, "Full Name",
                            "Enter Your Full Name", Icons.person, textColor),
                        buildTextField(
                            emailPhoneController,
                            "Email / Phone Number",
                            "Enter Email or Phone",
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
                            labelText: "Vehicle Type",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          value: selectedVehicleType,
                          items: vehicleTypes
                              .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type,
                                      style: TextStyle(color: textColor))))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => selectedVehicleType = value),
                          validator: (value) =>
                              value == null ? "Select a vehicle type" : null,
                        ),
                        const SizedBox(height: 12),
                        buildTextField(
                            vehicleNumberController,
                            "Vehicle Number",
                            "Enter Vehicle Number",
                            Icons.directions_car,
                            textColor),
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
                                      builder: (_) => DriverLoginScreen())),
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
        final response = await dio.post(
          'http://3.110.135.112:5000/api/driver/register',
          data: {
            'fullName': fullNameController.text.trim(),
            'email': emailPhoneController.text.trim(),
            'contactNumber': contactNumberController.text.trim(),
            'vehicleType': selectedVehicleType,
            'vehicleNumber': vehicleNumberController.text.trim(),
            'password': passwordController.text,
            'confirmPassword': confirmPasswordController.text,
            'acceptedTerms': isTermsAccepted,
          },
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          setState(() => _isLoading = false);

          final emailOrPhone = emailPhoneController.text.trim();

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) =>
                  DriverOtpVerificationScreen(emailOrPhone: emailOrPhone),
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        String errorMsg = "Registration failed. Try again.";

        if (e is DioException && e.response?.data['error'] != null) {
          errorMsg = e.response!.data['error'];
        }

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMsg)));
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
          return null;
        },
      ),
    );
  }

  Widget buildPasswordField(
      TextEditingController controller, String label, Color textColor) {
    final isConfirm = label.toLowerCase().contains("confirm");
    final isVisible = isConfirm ? isConfirmPasswordVisible : isPasswordVisible;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(Icons.lock, color: textColor),
          suffixIcon: IconButton(
            icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off,
                color: textColor),
            onPressed: () => setState(() {
              if (isConfirm) {
                isConfirmPasswordVisible = !isConfirmPasswordVisible;
              } else {
                isPasswordVisible = !isPasswordVisible;
              }
            }),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "Enter a password";
          if (!isConfirm && value.length < 6)
            return "Password must be at least 6 characters";
          if (isConfirm && value != passwordController.text)
            return "Passwords do not match";
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
            "1. Drive responsibly.\n2. Follow traffic laws.\n3. Provide accurate information.\n"
            "4. Company isn't liable for accidents.\n5. Terms may be updated.",
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
