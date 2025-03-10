import 'package:flutter/material.dart';
import 'package:tsp/screens/driver/driver_auth/driver_login.dart';

class DriverSignUpScreen extends StatefulWidget {
  @override
  _DriverSignUpScreenState createState() => _DriverSignUpScreenState();
}

class _DriverSignUpScreenState extends State<DriverSignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailPhoneController = TextEditingController();
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isPasswordVisible = false;
  String? selectedVehicleType;

  final List<String> vehicleTypes = ["Hatchback", "SUV", "Sedan", "Other"];

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
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/authsvg/driver_signup.png",
                  height: 200,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60)),
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
                        Text(
                          "Driver Sign Up",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        buildTextField(
                          controller: fullNameController,
                          label: "Full Name",
                          hint: "Enter Your Full Name",
                          icon: Icons.person,
                          textColor: textColor,
                        ),
                        buildTextField(
                          controller: emailPhoneController,
                          label: "Email / Phone Number",
                          hint: "Enter Email or Phone Number",
                          icon: Icons.email,
                          textColor: textColor,
                        ),
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
                          onChanged: (value) {
                            setState(() {
                              selectedVehicleType = value;
                            });
                          },
                          validator: (value) =>
                              value == null ? "Select a vehicle type" : null,
                        ),
                        const SizedBox(height: 12),
                        buildTextField(
                          controller: vehicleNumberController,
                          label: "Vehicle Number",
                          hint: "Enter Your Vehicle Number",
                          icon: Icons.directions_car,
                          textColor: textColor,
                        ),
                        buildPasswordField(
                            passwordController, "Password", textColor),
                        buildPasswordField(confirmPasswordController,
                            "Confirm Password", textColor),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Sign-Up Logic
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
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
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            DriverLoginScreen()));
                              },
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
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          prefixIcon: Icon(icon, color: textColor),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? "This field is required" : null,
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          prefixIcon: Icon(Icons.lock, color: textColor),
          suffixIcon: IconButton(
            icon: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: textColor),
            onPressed: () =>
                setState(() => isPasswordVisible = !isPasswordVisible),
          ),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? "Enter a password" : null,
      ),
    );
  }
}
