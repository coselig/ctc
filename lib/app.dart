import 'dart:async';

import 'package:ctc/pages/management/upload_asset_page.dart';
import 'package:ctc/pages/management/upload_pdf_page.dart';
import 'package:ctc/pages/pages.dart' show EmployeeManagementPage, HRReviewPage;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pages/customer/customer_home_page.dart';
import 'pages/employee/employee_pages.dart';
import 'pages/guest_welcome_page.dart';
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
  UserType _userType = UserType.guest;
  StreamSubscription<AuthState>? _authSubscription;
  late UserService _userService;
  late UserPermissionService _userPermissionService;

  @override
  void initState() {
    super.initState();
    _userService = UserService(Supabase.instance.client);
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
        // 重置用戶類型
        _userType = UserType.guest;
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
      await _userService.upsertCurrentUserProfile();

      // 然後載入主題偏好
      await _loadUserThemePreference();

      // 檢查用戶類型
      await _checkUserType();
    } catch (e) {
      debugPrint('確保用戶 profile 和載入主題失敗: $e');
    }
  }

  /// 檢查用戶的類型（員工/客戶/一般用戶）
  Future<void> _checkUserType() async {
    try {
      final userType = await _userPermissionService.getCurrentUserType();
      if (mounted) {
        setState(() {
          _userType = userType;
        });
      }
    } catch (e) {
      debugPrint('檢查用戶類型失敗: $e');
      if (mounted) {
        setState(() {
          _userType = UserType.guest;
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

      // 檢查用戶類型（如果已登入）
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await _checkUserType();
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
      final themePreference =
          (await _userService.getCurrentUserProfile())!.themePreference;
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
        final themeString = themeMode.toString().split('.').last;
        await _userService.updateCurrentUserProfile(
          themePreference: themeString,
        );
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

    debugPrint(
      '_buildHomeWidget: user = [38;5;2m${user?.email}[0m, userType = $_userType',
    );

    // 根據用戶狀態與類型，統一用 route 導向
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (user != null) {
        switch (_userType) {
          case UserType.employee:
            debugPrint('_buildHomeWidget: route /systemHome');
            navigatorKey.currentState?.pushReplacementNamed('/systemHome');
            break;
          case UserType.customer:
            debugPrint('_buildHomeWidget: route /customerHome');
            navigatorKey.currentState?.pushReplacementNamed('/customerHome');
            break;
          case UserType.guest:
            debugPrint('_buildHomeWidget: route /guestWelcome');
            navigatorKey.currentState?.pushReplacementNamed('/guestWelcome');
            break;
        }
      } else {
        debugPrint('_buildHomeWidget: route /welcome');
        navigatorKey.currentState?.pushReplacementNamed('/welcome');
      }
    });

    // 回傳一個空白頁面，避免重複 build 分頁
    return const SizedBox.shrink();
  }

  /// 高級主題切換（包含資料庫儲存）
  void _advancedToggleTheme() {
    final platformBrightness = MediaQuery.of(context).platformBrightness;

    if (platformBrightness == Brightness.dark &&
        _themeMode == ThemeMode.system) {
      // 如果系統主題是深色且當前是系統主題，切換到淺色
      _setThemeMode(ThemeMode.light);
      return;
    } else if (platformBrightness == Brightness.light &&
        _themeMode == ThemeMode.system) {
      // 如果系統主題是淺色且當前是系統主題，切換到深色
      _setThemeMode(ThemeMode.dark);
      return;
    } else {
      _setThemeMode(ThemeMode.system);
      return;
    }
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
      // 添加本地化支援
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'TW'), // 繁體中文
        Locale('en', 'US'), // 英文
      ],
      locale: const Locale('zh', 'TW'), // 預設語言
      home: _buildHomeWidget(),
      routes: {
        '/systemHome': (context) => SystemHomePage(
          title: '光悅科技管理系統',
          onThemeToggle: _advancedToggleTheme,
          currentThemeMode: _themeMode,
        ),
        '/customerHome': (context) => const CustomerHomePage(),
        '/guestWelcome': (context) =>
            GuestWelcomePage(onCustomerRegistered: _checkUserType),
        '/welcome': (context) => const WelcomePage(),
        '/attendance': (context) => AttendancePage(
          title: '打卡系統',
          onThemeToggle: _advancedToggleTheme,
          currentThemeMode: _themeMode,
        ),
        '/attendanceStats': (context) => const AttendanceStatsPage(),
        '/photoRecord': (context) => PhotoRecordPage(
          title: '工地照片記錄系統',
          onThemeToggle: _advancedToggleTheme,
          currentThemeMode: _themeMode,
        ),
        '/projectManagement': (context) => const ProjectManagementPage(),
        '/uploadPdf': (context) => const UploadPdfPage(),
        '/uploadAsset': (context) => const UploadAssetPage(),
        '/employeeManagement': (context) => EmployeeManagementPage(
          title: '員工管理系統',
          onThemeToggle: _advancedToggleTheme,
          currentThemeMode: _themeMode,
        ),
        '/hrReview': (context) => const HRReviewPage(),
      },
    );
  }
}
