import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 用戶偏好服務
/// 處理用戶的各種偏好設置，包括主題模式
class UserPreferencesService {
  final SupabaseClient _client;

  UserPreferencesService(this._client);

  /// 主題模式枚舉
  static const String themeModeLight = 'light';
  static const String themeModeDark = 'dark';
  static const String themeModeSystem = 'system';

  /// 獲取當前用戶的主題偏好
  Future<String> getThemePreference() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return themeModeSystem;

      // 先嘗試使用 RPC 函數
      try {
        final response = await _client.rpc('get_user_theme_preference');
        return response as String? ?? themeModeSystem;
      } catch (rpcError) {
        print('RPC 函數調用失敗，嘗試直接查詢: $rpcError');

        // 如果 RPC 失敗，直接查詢 profiles 表
        final profile = await getUserProfile();
        if (profile != null && profile['theme_preference'] != null) {
          return profile['theme_preference'] as String;
        }

        return themeModeSystem;
      }
    } catch (e) {
      print('獲取主題偏好失敗: $e');
      return themeModeSystem;
    }
  }

  /// 更新用戶的主題偏好
  Future<bool> updateThemePreference(String themeMode) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      // 驗證主題模式是否有效
      if (!_isValidThemeMode(themeMode)) {
        throw ArgumentError('無效的主題模式: $themeMode');
      }

      // 先嘗試使用 RPC 函數
      try {
        final response = await _client.rpc(
          'update_user_theme_preference',
          params: {'new_theme': themeMode},
        );
        return response as bool? ?? false;
      } catch (rpcError) {
        print('RPC 函數調用失敗，嘗試直接更新: $rpcError');

        // 如果 RPC 失敗，直接更新 profiles 表
        await _client.from('profiles').upsert({
          'id': user.id,
          'email': user.email,
          'theme_preference': themeMode,
          'updated_at': DateTime.now().toIso8601String(),
        });

        return true;
      }
    } catch (e) {
      print('更新主題偏好失敗: $e');
      return false;
    }
  }

  /// 直接從 profiles 表獲取用戶資料（包含主題偏好）
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      // 先嘗試獲取現有的 profile
      final response = await _client
          .from('profiles')
          .select('*')
          .eq('id', user.id)
          .maybeSingle(); // 使用 maybeSingle 而不是 single

      // 如果 profile 存在，直接返回
      if (response != null) {
        return response;
      }

      // 如果 profile 不存在，創建一個新的
      print('用戶 profile 不存在，正在創建...');
      final success = await createOrUpdateUserProfile();

      if (success) {
        // 再次獲取創建的 profile
        final newResponse = await _client
            .from('profiles')
            .select('*')
            .eq('id', user.id)
            .maybeSingle();
        return newResponse;
      }

      return null;
    } catch (e) {
      print('獲取用戶資料失敗: $e');
      // 如果是因為 profile 不存在的錯誤，嘗試創建
      if (e.toString().contains('0 rows') ||
          e.toString().contains('PGRST116')) {
        try {
          print('嘗試為新用戶創建 profile...');
          await createOrUpdateUserProfile();

          // 再次嘗試獲取
          final user = _client.auth.currentUser;
          if (user != null) {
            final retryResponse = await _client
                .from('profiles')
                .select('*')
                .eq('id', user.id)
                .maybeSingle();
            return retryResponse;
          }
        } catch (createError) {
          print('創建用戶 profile 失敗: $createError');
        }
      }
      return null;
    }
  }

  /// 創建或更新用戶資料（首次登入時）
  Future<bool> createOrUpdateUserProfile({
    String? fullName,
    String? avatarUrl,
    String? themePreference,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      final data = {
        'id': user.id,
        'email': user.email,
        if (fullName != null) 'full_name': fullName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        'theme_preference': themePreference ?? themeModeSystem,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client.from('profiles').upsert(data);
      return true;
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
