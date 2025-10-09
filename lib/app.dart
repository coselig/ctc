import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pages/employee/employee_pages.dart';
import 'pages/public/public_pages.dart';
import 'services/services.dart';
import 'theme/app_theme.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoading = true;
  bool _hasEmployeePermission = false;
  StreamSubscription<AuthState>? _authSubscription;
  late UserPreferencesService _userPreferencesService;
  late UserPermissionService _userPermissionService;

  @override
  void initState() {
    super.initState();
    _userPreferencesService = UserPreferencesService(Supabase.instance.client);
    _userPermissionService = UserPermissionService(Supabase.instance.client);
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
        // 登出時重置為系統主題
        _setThemeMode(ThemeMode.system, saveToDatabase: false);
        // 重置員工權限狀態
        _hasEmployeePermission = false;
        // 觸發介面重建以返回歡迎頁面
        if (mounted) {
          setState(() {});
        }
      } else if (event == AuthChangeEvent.signedIn) {
        debugPrint('User signed in globally: ${session?.user.email}');
        // 登入時確保用戶 profile 存在，然後載入主題偏好
        _ensureUserProfileAndLoadTheme();
        // 觸發介面重建以跳轉到管理頁面
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  /// 確保用戶 profile 存在並載入主題偏好
  Future<void> _ensureUserProfileAndLoadTheme() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // 先確保用戶 profile 存在
      await _userPreferencesService.createOrUpdateUserProfile();

      // 然後載入主題偏好
      await _loadUserThemePreference();

      // 檢查用戶是否有員工權限
      await _checkEmployeePermission();
    } catch (e) {
      debugPrint('確保用戶 profile 和載入主題失敗: $e');
    }
  }

  /// 檢查用戶的員工權限
  Future<void> _checkEmployeePermission() async {
    try {
      final hasPermission = await _userPermissionService.isUserInEmployeeList();
      if (mounted) {
        setState(() {
          _hasEmployeePermission = hasPermission;
        });
      }
    } catch (e) {
      debugPrint('檢查員工權限失敗: $e');
      if (mounted) {
        setState(() {
          _hasEmployeePermission = false;
        });
      }
    }
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

      // 載入用戶主題偏好（如果已登入）
      await _loadUserThemePreference();

      // 檢查用戶員工權限（如果已登入）
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await _checkEmployeePermission();
      }

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

  /// 載入用戶的主題偏好
  Future<void> _loadUserThemePreference() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final themePreference = await _userPreferencesService
          .getThemePreference();
      final themeMode = UserPreferencesService.stringToThemeMode(
        themePreference,
      );

      if (mounted) {
        setState(() {
          _themeMode = themeMode;
        });
      }
    } catch (e) {
      debugPrint('載入主題偏好失敗: $e');
    }
  }

  /// 設置主題模式
  Future<void> _setThemeMode(
    ThemeMode themeMode, {
    bool saveToDatabase = true,
  }) async {
    setState(() {
      _themeMode = themeMode;
    });

    // 如果用戶已登入且需要儲存到資料庫
    if (saveToDatabase && Supabase.instance.client.auth.currentUser != null) {
      try {
        final themeString = UserPreferencesService.themeModeToString(themeMode);
        await _userPreferencesService.updateThemePreference(themeString);
      } catch (e) {
        debugPrint('儲存主題偏好失敗: $e');
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

    // 檢查用戶登入狀態
    final user = Supabase.instance.client.auth.currentUser;
    
    // 如果用戶已登入
    if (user != null) {
      // 檢查是否有員工權限
      if (_hasEmployeePermission) {
        // 有員工權限 → 進入系統功能頁面
        return SystemHomePage(
          title: '光悅科技管理系統',
          onThemeToggle: _advancedToggleTheme,
          currentThemeMode: _themeMode,
        );
      } else {
        // 沒有員工權限 → 顯示一般首頁（但已登入狀態）
        return WelcomePage(
          onThemeToggle: _advancedToggleTheme,
          currentThemeMode: _themeMode,
        );
      }
    }

    // 如果用戶未登入，顯示歡迎頁面
    return WelcomePage(
      onThemeToggle: _advancedToggleTheme,
      currentThemeMode: _themeMode,
    );
  }

  void toggleTheme() {
    ThemeMode newThemeMode;
    if (_themeMode == ThemeMode.light) {
      newThemeMode = ThemeMode.dark;
    } else if (_themeMode == ThemeMode.dark) {
      newThemeMode = ThemeMode.system;
    } else {
      newThemeMode = ThemeMode.light;
    }

    _setThemeMode(newThemeMode);
  }

  /// 高級主題切換（包含資料庫儲存）
  void _advancedToggleTheme() {
    toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: '光悅科技',
      debugShowCheckedModeBanner: false, // 關閉 debug 標籤
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: _buildHomeWidget(),
    );
  }
}
