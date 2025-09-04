import 'package:flutter/material.dart';

class AppTheme {
  // 亮色主題顏色
  static const lightPrimaryColor = Color(0xFFD17A3A); // 橙棕色
  static const lightBackgroundColor = Color(0xFFF8F6F4); // 淺米色背景
  static const lightSurfaceColor = Color(0xFFFFFFFF); // 白色卡片
  static const lightTextColor = Color(0xFF2C2C2C); // 深色文字
  static const lightSecondaryColor = Color(0xFFB8956F); // 輔助色

  // 暗色主題顏色
  static const darkPrimaryColor = Color(0xFFE8956A); // 稍亮的橙棕色
  static const darkBackgroundColor = Color(0xFF121212); // 深色背景
  static const darkSurfaceColor = Color(0xFF1E1E1E); // 卡片背景色
  static const darkTextColor = Colors.white;
  static const darkSecondaryColor = Color(0xFFC19A6B); // 輔助色

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Iansui',
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: lightPrimaryColor,
      onPrimary: Colors.white,
      secondary: lightSecondaryColor,
      onSecondary: Colors.white,
      surface: lightSurfaceColor,
      onSurface: lightTextColor,
      outline: Colors.grey.shade400,
    ),
    scaffoldBackgroundColor: lightBackgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: lightBackgroundColor,
      foregroundColor: lightTextColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: lightSurfaceColor,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        color: lightTextColor,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: lightTextColor,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: lightTextColor,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: lightPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: lightPrimaryColor,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(color: lightTextColor),
      bodyMedium: TextStyle(color: lightTextColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: lightPrimaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: lightPrimaryColor),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: lightPrimaryColor, width: 2),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Iansui',
    colorScheme: ColorScheme.dark(
      primary: darkPrimaryColor,
      onPrimary: Colors.black,
      secondary: darkSecondaryColor,
      onSecondary: Colors.black,
      surface: darkSurfaceColor,
      onSurface: darkTextColor,
      outline: Colors.grey.shade600,
    ),
    scaffoldBackgroundColor: darkBackgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: darkBackgroundColor,
      foregroundColor: darkTextColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: darkSurfaceColor,
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: darkPrimaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        color: darkTextColor,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: darkTextColor,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: darkTextColor,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: darkPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: darkPrimaryColor,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(color: darkTextColor),
      bodyMedium: TextStyle(color: darkTextColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimaryColor,
        foregroundColor: Colors.black,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: darkPrimaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: darkPrimaryColor),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: darkPrimaryColor, width: 2),
      ),
    ),
  );
}
