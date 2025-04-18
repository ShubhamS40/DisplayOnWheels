import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:tsp/screens/driver/driver_auth/driver_login.dart';
import 'dart:async';

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
  String? _errorMessage;
  bool _signupSuccess = false;
  
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

  final List<String> vehicleTypes = ["Hatchback", "SUV", "Sedan", "Compact", "Convertible", "Coupe", "Crossover", "Minivan","Autorickshaw", "Pickup Truck", "Van", "Wagon", "Other"];

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
              crossAxisAlignment: CrossAxisAlignment.center,
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Driver Sign Up",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            )),
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
                            "Enter Your Contact Number",
                            Icons.phone,
                            textColor),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "Vehicle Type",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          value: selectedVehicleType,
                          items: vehicleTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type,
                                  style: TextStyle(color: textColor)),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => selectedVehicleType = value),
                          validator: (value) =>
                              value == null ? "Select a vehicle type" : null,
                        ),
                        const SizedBox(height: 12),
                        buildTextField(
                            vehicleNumberController,
                            "Vehicle Number",
                            "Enter Your Vehicle Number",
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
                                  setState(() => isTermsAccepted = value!),
                            ),
                            GestureDetector(
                              onTap: () => showTermsDialog(context),
                              child: Text("I accept the Terms & Conditions",
                                  style: TextStyle(
                                    color: Colors.orange,
                                    decoration: TextDecoration.underline,
                                  )),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: _isLoading 
                                ? null 
                                : () async {
                                  if (_formKey.currentState!.validate()) {
                                    if (!isTermsAccepted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Please accept Terms & Conditions")),
                                      );
                                      return;
                                    }

                                    // Execute sign-up with loading state
                                    setState(() {
                                      _isLoading = true;
                                      _errorMessage = null;
                                    });
                                    
                                    // Make the actual API call to register driver
                                    try {
                                      final dio = Dio();
                                      final response = await dio.post(
                                        'http://localhost:5000/api/driver/register',
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
                                      
                                      // Successfully registered
                                      if (response.statusCode == 201 || response.statusCode == 200) {
                                        setState(() {
                                          _isLoading = false;
                                          _signupSuccess = true;
                                        });
                                        
                                        // Show success message
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Registration successful!')),
                                        );
                                        
                                        // After 2 seconds, navigate to login
                                        Timer(const Duration(seconds: 2), () {
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(builder: (context) => DriverLoginScreen()),
                                          );
                                        });
                                      }
                                    } catch (error) {
                                      // Handle errors
                                      setState(() {
                                        _isLoading = false;
                                      });
                                      
                                      String errorMessage = 'Registration failed. Please try again.';
                                      
                                      if (error is DioException && error.response != null) {
                                        // Extract error message from API response
                                        final responseData = error.response?.data;
                                        if (responseData != null && responseData['error'] != null) {
                                          errorMessage = responseData['error'];
                                        }
                                      }
                                      
                                      // Show error message
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(errorMessage)),
                                      );
                                    }
                                  }
                                },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : _signupSuccess
                                    ? const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.check_circle, color: Colors.white),
                                          SizedBox(width: 8),
                                          Text(
                                            "Registration Successful!",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Text(
                                        "Sign Up",
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
                            Text("Already have an account?",
                                style: TextStyle(color: textColor)),
                            TextButton(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DriverLoginScreen())),
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
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.orange, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.red.shade400),
          ),
          prefixIcon: Icon(icon, color: textColor),
          filled: true,
          fillColor: Colors.transparent,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "This field is required";
          }
          
          // Email validation if this is the email field
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
    final isConfirmField = label.toLowerCase().contains("confirm");
    final passwordVisibility = isConfirmField ? isConfirmPasswordVisible : isPasswordVisible;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: !passwordVisibility,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.orange, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.red.shade400),
          ),
          prefixIcon: Icon(Icons.lock, color: textColor),
          suffixIcon: IconButton(
            icon: Icon(
                passwordVisibility ? Icons.visibility : Icons.visibility_off,
                color: textColor),
            onPressed: () => setState(() => isConfirmField 
                ? isConfirmPasswordVisible = !isConfirmPasswordVisible
                : isPasswordVisible = !isPasswordVisible),
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Enter a password";
          }
          
          if (!isConfirmField && value.length < 6) {
            return "Password must be at least 6 characters";
          }
          
          if (isConfirmField && value != passwordController.text) {
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
      builder: (context) {
        return AlertDialog(
          title: const Text("Terms & Conditions"),
          content: SingleChildScrollView(
            child: Text(
              "1. You must follow traffic laws and drive responsibly.\n"
              "2. You are responsible for any damage caused by your vehicle.\n"
              "3. The company is not liable for any accidents or injuries.\n"
              "4. Payments will be made as per company policies.\n"
              "5. You must provide accurate and up-to-date information.\n"
              "6. Your account may be suspended for policy violations.\n"
              "7. The company reserves the right to modify these terms.\n"
              "8. Unauthorized use of company assets is strictly prohibited.\n"
              "9. Drivers must maintain a professional attitude at all times.\n"
              "10. Privacy policies must be adhered to at all times.",
              textAlign: TextAlign.justify,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        );
      },
    );
  }
}
