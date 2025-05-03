import 'package:flutter/material.dart';

class ThemeConstants {
  // Primary color - Team TSP Amber/Gold
  static const Color primaryColor = Color(0xFFE89C08);
  
  // Secondary colors
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF757575);
  
  // Light theme colors
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Colors.white;
  static const Color lightCardColor = Colors.white;
  static const Color lightShadowColor = Color(0x40000000);
  
  // Dark theme colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCardColor = Color(0xFF2D2D2D);
  static const Color darkShadowColor = Color(0x40000000);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE89C08); 
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Illustration URLs
  static const String loginIllustrationUrl = "https://cdni.iconscout.com/illustration/premium/thumb/admin-login-3939164-3276540.png";
  static const String forgotPasswordIllustrationUrl = "https://cdni.iconscout.com/illustration/premium/thumb/forgot-password-4920809-4106454.png";
  static const String otpVerificationIllustrationUrl = "https://cdni.iconscout.com/illustration/premium/thumb/otp-verification-4571946-3798464.png";
  
  // Button styles
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    padding: const EdgeInsets.symmetric(vertical: 14),
    elevation: 2,
  );
  
  // Input decoration
  static InputDecoration getInputDecoration({
    required String label,
    required String hint,
    required IconData prefixIcon,
    IconData? suffixIcon,
    VoidCallback? suffixIconOnPressed,
    bool isDarkMode = false,
  }) {
    Color textColor = isDarkMode ? Colors.white : textPrimary;
    
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: textColor),
      hintText: hint,
      hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: primaryColor),
      ),
      prefixIcon: Icon(prefixIcon, color: textColor),
      suffixIcon: suffixIcon != null 
        ? IconButton(
            icon: Icon(suffixIcon, color: textColor),
            onPressed: suffixIconOnPressed,
          )
        : null,
    );
  }
  
  // Card decoration
  static BoxDecoration getCardDecoration(bool isDarkMode) {
    return BoxDecoration(
      color: isDarkMode ? darkCardColor : lightCardColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: isDarkMode ? darkShadowColor : lightShadowColor,
          blurRadius: 10,
          spreadRadius: 2,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}
