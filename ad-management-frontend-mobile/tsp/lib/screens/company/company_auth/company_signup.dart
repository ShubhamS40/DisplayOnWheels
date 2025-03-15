import 'package:flutter/material.dart';
import 'package:tsp/screens/company/company_auth/company_login.dart';

class CompanySignUpScreen extends StatefulWidget {
  @override
  _CompanySignUpScreenState createState() => _CompanySignUpScreenState();
}

class _CompanySignUpScreenState extends State<CompanySignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController businessTypeController = TextEditingController();
  final TextEditingController emailPhoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = isDarkMode ? Colors.orangeAccent : Colors.orange;
    final Color backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color fieldColor = isDarkMode ? Colors.grey[800]! : Colors.white;

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
                  "assets/authsvg/signup_screen.png",
                  height: 250,
                ),
                const SizedBox(height: 20),
                Container(
                  height: MediaQuery.of(context).size.height / 1.4,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: fieldColor,
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode
                            ? Colors.grey.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.8),
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
                          "Create Your Account",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        buildTextField(
                          controller: businessNameController,
                          label: "Business Name",
                          hint: "Enter Your Business Name",
                          icon: Icons.business,
                          isDarkMode: isDarkMode,
                        ),
                        buildTextField(
                          controller: businessTypeController,
                          label: "Business Type",
                          hint: "Enter Your Business Type",
                          icon: Icons.category,
                          isDarkMode: isDarkMode,
                        ),
                        buildTextField(
                          controller: emailPhoneController,
                          label: "Email / Phone Number",
                          hint: "Enter email or Phone Number",
                          icon: Icons.email,
                          isDarkMode: isDarkMode,
                        ),
                        buildPasswordField(
                            passwordController, "Password", isDarkMode),
                        buildPasswordField(confirmPasswordController,
                            "Confirm Password", isDarkMode),
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
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
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
                                        builder: (context) => CompanyLogin()));
                              },
                              child: Text("Login",
                                  style: TextStyle(color: primaryColor)),
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
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle:
              TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
          hintStyle:
              TextStyle(color: isDarkMode ? Colors.white54 : Colors.black45),
          filled: true,
          fillColor: isDarkMode ? Colors.grey[900] : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          prefixIcon:
              Icon(icon, color: isDarkMode ? Colors.white70 : Colors.black87),
        ),
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        validator: (value) {
          if (value == null || value.isEmpty) return "This field is required";
          return null;
        },
      ),
    );
  }

  Widget buildPasswordField(
      TextEditingController controller, String label, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: !isPasswordVisible,
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
          filled: true,
          fillColor: isDarkMode ? Colors.grey[900] : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          prefixIcon: Icon(Icons.lock,
              color: isDarkMode ? Colors.white70 : Colors.black87),
          suffixIcon: IconButton(
            icon: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: isDarkMode ? Colors.white70 : Colors.black87),
            onPressed: () {
              setState(() {
                isPasswordVisible = !isPasswordVisible;
              });
            },
          ),
        ),
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        validator: (value) {
          if (value == null || value.isEmpty) return "Enter a password";
          if (value.length < 6) return "Password must be at least 6 characters";
          return null;
        },
      ),
    );
  }
}
