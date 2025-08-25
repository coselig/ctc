import 'package:ctc/pages/photo_record_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'pages/login_page.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  final supabase = Supabase.instance.client;
  bool _isAuthenticated = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkInitialAuthState();
    _setupAuthListener();
  }

  Future<void> _checkInitialAuthState() async {
    final session = supabase.auth.currentSession;
    if (mounted) {
      setState(() {
        _isAuthenticated = session != null;
        _isLoading = false;
      });
    }
  }

  void _setupAuthListener() {
    supabase.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;

      setState(() {
        _isAuthenticated = data.session != null;
      });
    });
  }

  Widget _buildHomeWidget() {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isAuthenticated) {
      return PhotoRecordPage(
        title: '工地照片記錄',
        onThemeToggle: toggleTheme,
        currentThemeMode: _themeMode,
      );
    } else {
      return const LoginPage();
    }
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
