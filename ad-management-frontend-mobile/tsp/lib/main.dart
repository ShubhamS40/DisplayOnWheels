import 'package:flutter/material.dart';
import 'package:tsp/screens/auth/login_screen.dart';
import 'package:tsp/screens/auth/role_selection.dart';
import 'package:tsp/screens/auth/signup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(), // Light Theme
      darkTheme: ThemeData.dark(), // Dark Theme
      themeMode: ThemeMode.system, // This will follow system theme
      home: RoleSelectionScreen(),
    );
  }
}
