import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pages/welcome_page.dart';
import 'theme/app_theme.dart';

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoading = true;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _setupGlobalAuthListener();
  }

  void _setupGlobalAuthListener() {
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      debugPrint('Global auth state changed: $event');

      // 這裡可以處理全域的認證狀態變化
      // 例如：如果用戶登出，可以清理快取、重置狀態等
      if (event == AuthChangeEvent.signedOut) {
        debugPrint('User signed out globally');
      } else if (event == AuthChangeEvent.signedIn) {
        debugPrint('User signed in globally: ${session?.user.email}');
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      // 等待 Supabase 確實可用
      await Future.delayed(const Duration(milliseconds: 100));

      // 預載入關鍵資源
      await _preloadCriticalResources();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // 即使預載入失敗，也讓應用繼續
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _preloadCriticalResources() async {
    // 這裡可以預載入關鍵圖片或資源
    // 但不阻塞主要界面的顯示
    return Future.delayed(const Duration(milliseconds: 200));
  }

  Widget _buildHomeWidget() {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/sqare_ctc_icon.png', width: 120, height: 120),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('正在載入應用程式...', style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      );
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
    return MaterialApp(
      title: '光悅科技',
      debugShowCheckedModeBanner: false, // 關閉 debug 標籤
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: _buildHomeWidget(),
    );
  }
}
