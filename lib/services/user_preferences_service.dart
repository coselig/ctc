import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_service.dart';

/// 用戶偏好服務
/// 處理用戶的各種偏好設置，包括主題模式
/// 現在使用 UserService 來管理用戶資料
class UserPreferencesService {
  final SupabaseClient _client;
  late final UserService _userService;

  UserPreferencesService(this._client) {
    _userService = UserService(_client);
  }

  /// 主題模式枚舉
  static const String themeModeLight = 'light';
  static const String themeModeDark = 'dark';
  static const String themeModeSystem = 'system';

  /// 獲取當前用戶的主題偏好
  Future<String> getThemePreference() async {
    try {
      final userProfile = await _userService.getCurrentUserProfile();

      if (userProfile != null) {
        return userProfile.themePreference;
      }

      // 如果 profile 不存在，嘗試創建一個預設的
      await _userService.upsertCurrentUserProfile();
      return themeModeSystem;
    } catch (e) {
      print('獲取主題偏好失敗: $e');
      return themeModeSystem;
    }
  }

  /// 更新用戶的主題偏好
  Future<bool> updateThemePreference(String themeMode) async {
    try {
      // 驗證主題模式是否有效
      if (!_isValidThemeMode(themeMode)) {
        throw ArgumentError('無效的主題模式: $themeMode');
      }

      final updatedProfile = await _userService.updateCurrentUserProfile(
        themePreference: themeMode,
      );

      return updatedProfile != null;
    } catch (e) {
      print('更新主題偏好失敗: $e');
      return false;
    }
  }

  /// 直接從 profiles 表獲取用戶資料（包含主題偏好）
  /// 推薦使用 UserService.getCurrentUserProfile() 替代
  @Deprecated('請使用 UserService.getCurrentUserProfile() 替代')
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userProfile = await _userService.getCurrentUserProfile();
      return userProfile?.toJson();
    } catch (e) {
      print('獲取用戶資料失敗: $e');
      return null;
    }
  }

  /// 創建或更新用戶資料（首次登入時）
  /// 推薦使用 UserService.upsertCurrentUserProfile() 替代
  @Deprecated('請使用 UserService.upsertCurrentUserProfile() 替代')
  Future<bool> createOrUpdateUserProfile({
    String? fullName,
    String? avatarUrl,
    String? themePreference,
  }) async {
    try {
      final result = await _userService.upsertCurrentUserProfile(
        fullName: fullName,
        avatarUrl: avatarUrl,
        themePreference: themePreference ?? themeModeSystem,
      );
      return result != null;
    } catch (e) {
      print('創建/更新用戶資料失敗: $e');
      return false;
    }
  }

  /// 驗證主題模式是否有效
  bool _isValidThemeMode(String themeMode) {
    return [themeModeLight, themeModeDark, themeModeSystem].contains(themeMode);
  }

  /// 將字符串轉換為 ThemeMode 枚舉
  static ThemeMode stringToThemeMode(String themeMode) {
    switch (themeMode) {
      case themeModeLight:
        return ThemeMode.light;
      case themeModeDark:
        return ThemeMode.dark;
      case themeModeSystem:
      default:
        return ThemeMode.system;
    }
  }

  /// 將 ThemeMode 枚舉轉換為字符串
  static String themeModeToString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return themeModeLight;
      case ThemeMode.dark:
        return themeModeDark;
      case ThemeMode.system:
        return themeModeSystem;
    }
  }
}
