import 'package:flutter/material.dart';
import 'package:tsp/screens/company/company_auth/company_signup.dart';
import 'package:tsp/screens/company/document_verification_company.dart';

class CompanyLogin extends StatefulWidget {
  const CompanyLogin({super.key});

  @override
  State<CompanyLogin> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<CompanyLogin> {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? Colors.black : Colors.white, // Dynamic Background
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),

            // Top Illustration Image
            Center(
              child: Image.asset(
                'assets/authsvg/login_screen_svg.png',
                height: 320,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            // Login Form Container
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 0),
              height: MediaQuery.of(context).size.height / 1.8,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60)),
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
                  // Login Heading
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

                  const SizedBox(height: 20),

                  // Email Input
                  const Text("Email / Phone Number",
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 5),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Enter email id or Phone Number",
                      prefixIcon: Icon(Icons.email, color: Colors.orange),
                      filled: true,
                      fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Password Input
                  const Text("Password",
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 5),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Enter Password",
                      prefixIcon: Icon(Icons.lock, color: Colors.orange),
                      filled: true,
                      fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CompanyVerificationScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

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
                                    builder: (context) =>
                                        CompanySignUpScreen()));
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
    );
  }
}
