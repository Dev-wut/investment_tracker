import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get mainTheme => ThemeData(
    primarySwatch: Colors.blue,
    useMaterial3: true,

    // Login Page Theme
    scaffoldBackgroundColor: Colors.transparent,

    // Card Theme for Login Card
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 30,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),

    // Button Theme for Google Sign-In Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        textStyle: const TextStyle(
          inherit: true,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // Text Themes for Login Page
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.2,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.white70,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: Colors.white60,
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: Colors.white,
      size: 80,
    ),

    // SnackBar Theme
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
  );

  // Login Page Gradient Colors
  static const List<Color> loginGradientColors = [
    Color(0xFF667eea),
    Color(0xFF764ba2),
    Color(0xFFf093fb),
  ];

  // Login Page Container Decoration
  static BoxDecoration get loginBackgroundDecoration => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: loginGradientColors,
    ),
  );

  // Login Logo Container Decoration
  static BoxDecoration get loginLogoDecoration => BoxDecoration(
    color: Colors.white.withOpacity(0.1),
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );
}