import 'package:flutter/material.dart';

class AppTheme {
  // Warna utama
  static const Color primary = Color(0xFF0066FF);
  static const Color secondary = Color(0xFF0053CC);

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,

    primaryColor: primary,
    scaffoldBackgroundColor: Colors.white,

    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      elevation: 0,
      foregroundColor: Colors.white,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(primary),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        textStyle: WidgetStatePropertyAll(
          const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      labelStyle: const TextStyle(fontSize: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black26),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    listTileTheme: const ListTileThemeData(
      iconColor: primary,
      textColor: Colors.black87,
    ),
  );
}
