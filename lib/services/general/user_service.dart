import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_profile.dart';

/// 用戶服務
/// 處理與用戶資料相關的所有操作
class UserService {
  /// 檢查是否有登入，回傳 User，否則丟出 Exception
  User requireAuthUser() {
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception('沒有用戶登入');
    }
    return user;
  }

  final SupabaseClient client;

  UserService(this.client);

  /// 透過 auth.users.id 取得用戶的 profile 資料
  Future<UserProfile?> getUserProfileById(String userId) async {
    try {
      final response = await client
          .from('profiles')
          .select('*')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        print('找不到用戶 ID: $userId 的 profile 資料');
        return null;
      }

      return UserProfile.fromJson(response);
    } catch (e) {
      print('透過 ID 獲取用戶 profile 失敗: $e');
      return null;
    }
  }

  /// 取得當前登入用戶的 profile 資料
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final user = requireAuthUser();
      return await getUserProfileById(user.id);
    } catch (e) {
      print('獲取當前用戶 profile 失敗: $e');
      return null;
    }
  }

  /// 創建新的用戶 profile
  Future<UserProfile?> createUserProfile({
    required String userId,
    String? email,
    String? fullName,
    String? avatarUrl,
    String themePreference = 'system',
  }) async {
    try {
      final now = DateTime.now();
      final data = {
        'id': userId,
        'email': email,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'theme_preference': themePreference,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final response = await client
          .from('profiles')
          .insert(data)
          .select('*')
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      print('創建用戶 profile 失敗: $e');
      return null;
    }
  }

  /// 更新用戶 profile
  Future<UserProfile?> updateUserProfile({
    required String userId,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? themePreference,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (email != null) updateData['email'] = email;
      if (fullName != null) updateData['full_name'] = fullName;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
      if (themePreference != null)
        updateData['theme_preference'] = themePreference;

      final response = await client
          .from('profiles')
          .update(updateData)
          .eq('id', userId)
          .select('*')
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      print('更新用戶 profile 失敗: $e');
      return null;
    }
  }

  /// 更新當前用戶的 profile
  Future<UserProfile?> updateCurrentUserProfile({
    String? email,
    String? fullName,
    String? avatarUrl,
    String? themePreference,
  }) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        print('沒有用戶登入');
        return null;
      }

      return await updateUserProfile(
        userId: currentUser.id,
        email: email,
        fullName: fullName,
        avatarUrl: avatarUrl,
        themePreference: themePreference,
      );
    } catch (e) {
      print('更新當前用戶 profile 失敗: $e');
      return null;
    }
  }

  /// 創建或更新用戶 profile（如果不存在則創建，存在則更新）
  Future<UserProfile?> upsertUserProfile({
    required String userId,
    String? email,
    String? fullName,
    String? avatarUrl,
    String themePreference = 'system',
  }) async {
    try {
      final now = DateTime.now();
      final data = {
        'id': userId,
        'email': email,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'theme_preference': themePreference,
        'updated_at': now.toIso8601String(),
      };

      final response = await client
          .from('profiles')
          .upsert(data)
          .select('*')
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      print('Upsert 用戶 profile 失敗: $e');
      return null;
    }
  }

  /// 為當前登入用戶創建或更新 profile
  Future<UserProfile?> upsertCurrentUserProfile({
    String? fullName,
    String? avatarUrl,
    String themePreference = 'system',
  }) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        print('沒有用戶登入');
        return null;
      }

      return await upsertUserProfile(
        userId: currentUser.id,
        email: currentUser.email,
        fullName: fullName,
        avatarUrl: avatarUrl,
        themePreference: themePreference,
      );
    } catch (e) {
      print('Upsert 當前用戶 profile 失敗: $e');
      return null;
    }
  }

  /// 刪除用戶 profile
  Future<bool> deleteUserProfile(String userId) async {
    try {
      await client.from('profiles').delete().eq('id', userId);

      return true;
    } catch (e) {
      print('刪除用戶 profile 失敗: $e');
      return false;
    }
  }

  /// 檢查用戶 profile 是否存在
  Future<bool> userProfileExists(String userId) async {
    try {
      final response = await client
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('檢查用戶 profile 是否存在失敗: $e');
      return false;
    }
  }

  /// 批量獲取多個用戶的 profile
  Future<List<UserProfile>> getUserProfilesByIds(List<String> userIds) async {
    try {
      if (userIds.isEmpty) return [];

      final response = await client
          .from('profiles')
          .select('*')
          .inFilter('id', userIds);

      return (response as List<dynamic>)
          .map((data) => UserProfile.fromJson(data))
          .toList();
    } catch (e) {
      print('批量獲取用戶 profiles 失敗: $e');
      return [];
    }
  }

  /// 搜尋用戶（依據 email 或 full_name）
  Future<List<UserProfile>> searchUsers({
    String? email,
    String? fullName,
    int limit = 50,
  }) async {
    try {
      var query = client.from('profiles').select('*');

      if (email != null && email.isNotEmpty) {
        query = query.ilike('email', '%$email%');
      }

      if (fullName != null && fullName.isNotEmpty) {
        query = query.ilike('full_name', '%$fullName%');
      }

      final response = await query.limit(limit);

      return (response as List<dynamic>)
          .map((data) => UserProfile.fromJson(data))
          .toList();
    } catch (e) {
      print('搜尋用戶失敗: $e');
      return [];
    }
  }

  /// 獲取所有用戶（分頁）
  Future<List<UserProfile>> getAllUsers({
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      final from = page * pageSize;
      final to = from + pageSize - 1;

      final response = await client
          .from('profiles')
          .select('*')
          .order('created_at', ascending: false)
          .range(from, to);

      return (response as List<dynamic>)
          .map((data) => UserProfile.fromJson(data))
          .toList();
    } catch (e) {
      print('獲取所有用戶失敗: $e');
      return [];
    }
  }
}
