import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color(0xFFD17A3A); // 更鮮豔的橙棕色
  static const backgroundColor = Color(0xFF121212); // 深色背景
  static const surfaceColor = Color(0xFF1E1E1E); // 卡片背景色
  static const textColor = Colors.white;

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      onPrimary: Colors.black,
      secondary: primaryColor,
      onSecondary: Colors.black,
      surface: surfaceColor,
      onSurface: textColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: primaryColor.withValues(alpha: 0.5), width: 1),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: primaryColor, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: textColor),
      bodyMedium: TextStyle(color: textColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: primaryColor),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      onPrimary: Colors.black,
      secondary: primaryColor,
      onSecondary: Colors.black,
    ),
  );
}
