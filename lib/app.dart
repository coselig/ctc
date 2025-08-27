import 'package:flutter/material.dart';
import 'dart:async';
import 'pages/welcome_page.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 短暫延遲以確保應用程式初始化完成
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Widget _buildHomeWidget() {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return WelcomePage(
      onThemeToggle: toggleTheme,
      currentThemeMode: _themeMode,
    );
  }

  void toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else if (_themeMode == ThemeMode.dark) {
        _themeMode = ThemeMode.system;
      } else {
        _themeMode = ThemeMode.light;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const lightPrimaryColor = Colors.deepPurple;
    const darkPrimaryColor = Colors.purple;

    return MaterialApp(
      title: '工地照片記錄',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: lightPrimaryColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: darkPrimaryColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: _buildHomeWidget(),
    );
  }
}
