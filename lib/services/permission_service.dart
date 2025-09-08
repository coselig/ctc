import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

/// 權限管理服務
class PermissionService {
  final SupabaseClient client;

  PermissionService(this.client);

  /// 為設計圖創建擁有者權限（上傳設計圖時自動調用）
  Future<void> createOwnerPermission({
    required String floorPlanId,
    required String floorPlanUrl,
    required String floorPlanName,
  }) async {
    final currentUser = client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('未登入');
    }

    try {
      final permission = {
        'floor_plan_id': floorPlanId,
        'floor_plan_url': floorPlanUrl,
        'floor_plan_name': floorPlanName,
        'user_id': currentUser.id,
        'user_email': currentUser.email ?? '',
        'permission_level': PermissionLevel.level3.value,
        'is_owner': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      print('正在插入擁有者權限: $permission');

      final response = await client
          .from('floor_plan_permissions')
          .insert(permission)
          .select()
          .single();

      print('擁有者權限插入成功: $response');
    } catch (e) {
      print('創建擁有者權限失敗: $e');
      // 如果是權限相關錯誤，提供更詳細的錯誤信息
      if (e.toString().contains('infinite recursion') ||
          e.toString().contains('42P17')) {
        throw Exception('資料庫權限設定錯誤，請檢查 RLS 策略設定。錯誤詳情: $e');
      }
      rethrow;
    }
  }

  /// 獲取用戶對特定設計圖的權限
  Future<FloorPlanPermission?> getUserPermission({
    required String floorPlanUrl,
    String? userId,
  }) async {
    final targetUserId = userId ?? client.auth.currentUser?.id;
    if (targetUserId == null) return null;

    try {
      final response = await client
          .from('floor_plan_permissions')
          .select()
          .eq('floor_plan_url', floorPlanUrl)
          .eq('user_id', targetUserId)
          .maybeSingle();

      if (response == null) return null;

      return FloorPlanPermission.fromJson(response);
    } catch (e) {
      print('獲取用戶權限失敗: $e');
      return null;
    }
  }

  /// 獲取設計圖的所有權限列表
  Future<List<FloorPlanPermission>> getFloorPlanPermissions(
    String floorPlanUrl,
  ) async {
    try {
      final response = await client
          .from('floor_plan_permissions')
          .select()
          .eq('floor_plan_url', floorPlanUrl)
          .order('is_owner', ascending: false)
          .order('permission_level', ascending: false)
          .order('created_at');

      return (response as List<dynamic>)
          .map((json) => FloorPlanPermission.fromJson(json))
          .toList();
    } catch (e) {
      print('獲取設計圖權限列表失敗: $e');
      return [];
    }
  }

  /// 添加用戶權限
  Future<void> addUserPermission({
    required String floorPlanUrl,
    required String floorPlanName,
    required String userEmail,
    required PermissionLevel permissionLevel,
  }) async {
    final currentUser = client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('未登入');
    }

    // 檢查當前用戶是否為設計圖擁有者
    final currentUserPermission = await getUserPermission(
      floorPlanUrl: floorPlanUrl,
    );
    if (currentUserPermission?.isOwner != true) {
      throw Exception('只有擁有者可以添加權限');
    }

    // 查找目標用戶
    final targetUserResponse = await client.auth.admin.listUsers();
    final targetUser = targetUserResponse.firstWhere(
      (user) => user.email == userEmail,
      orElse: () => throw Exception('找不到用戶: $userEmail'),
    );

    // 檢查是否已有權限
    final existingPermission = await getUserPermission(
      floorPlanUrl: floorPlanUrl,
      userId: targetUser.id,
    );
    if (existingPermission != null) {
      throw Exception('用戶已有此設計圖的權限');
    }

    final permission = {
      'floor_plan_id': floorPlanUrl.split('/').last.split('.').first,
      'floor_plan_url': floorPlanUrl,
      'floor_plan_name': floorPlanName,
      'user_id': targetUser.id,
      'user_email': userEmail,
      'permission_level': permissionLevel.value,
      'is_owner': false,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    await client.from('floor_plan_permissions').insert(permission);
  }

  /// 更新用戶權限
  Future<void> updateUserPermission({
    required String floorPlanUrl,
    required String userId,
    required PermissionLevel permissionLevel,
  }) async {
    final currentUser = client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('未登入');
    }

    // 檢查當前用戶是否為設計圖擁有者
    final currentUserPermission = await getUserPermission(
      floorPlanUrl: floorPlanUrl,
    );
    if (currentUserPermission?.isOwner != true) {
      throw Exception('只有擁有者可以修改權限');
    }

    // 檢查目標權限是否存在
    final targetPermission = await getUserPermission(
      floorPlanUrl: floorPlanUrl,
      userId: userId,
    );
    if (targetPermission == null) {
      throw Exception('找不到用戶權限');
    }

    // 不能修改擁有者的權限
    if (targetPermission.isOwner) {
      throw Exception('不能修改擁有者的權限');
    }

    await client
        .from('floor_plan_permissions')
        .update({
          'permission_level': permissionLevel.value,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('floor_plan_url', floorPlanUrl)
        .eq('user_id', userId);
  }

  /// 移除用戶權限
  Future<void> removeUserPermission({
    required String floorPlanUrl,
    required String userId,
  }) async {
    final currentUser = client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('未登入');
    }

    // 檢查當前用戶是否為設計圖擁有者
    final currentUserPermission = await getUserPermission(
      floorPlanUrl: floorPlanUrl,
    );
    if (currentUserPermission?.isOwner != true) {
      throw Exception('只有擁有者可以移除權限');
    }

    // 檢查目標權限是否存在
    final targetPermission = await getUserPermission(
      floorPlanUrl: floorPlanUrl,
      userId: userId,
    );
    if (targetPermission == null) {
      throw Exception('找不到用戶權限');
    }

    // 不能移除擁有者的權限
    if (targetPermission.isOwner) {
      throw Exception('不能移除擁有者的權限');
    }

    await client
        .from('floor_plan_permissions')
        .delete()
        .eq('floor_plan_url', floorPlanUrl)
        .eq('user_id', userId);
  }

  /// 轉移擁有者權限
  Future<void> transferOwnership({
    required String floorPlanUrl,
    required String newOwnerUserId,
  }) async {
    final currentUser = client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('未登入');
    }

    // 檢查當前用戶是否為設計圖擁有者
    final currentUserPermission = await getUserPermission(
      floorPlanUrl: floorPlanUrl,
    );
    if (currentUserPermission?.isOwner != true) {
      throw Exception('只有擁有者可以轉移權限');
    }

    // 檢查新擁有者是否已有權限
    final newOwnerPermission = await getUserPermission(
      floorPlanUrl: floorPlanUrl,
      userId: newOwnerUserId,
    );
    if (newOwnerPermission == null) {
      throw Exception('新擁有者必須先有權限才能轉移');
    }

    // 使用事務確保數據一致性
    await client.rpc(
      'transfer_floor_plan_ownership',
      params: {
        'p_floor_plan_url': floorPlanUrl,
        'p_old_owner_id': currentUser.id,
        'p_new_owner_id': newOwnerUserId,
      },
    );
  }

  /// 檢查用戶是否可以刪除照片記錄
  Future<bool> canDeletePhotoRecord({
    required String floorPlanUrl,
    required String photoRecordUserId,
  }) async {
    final currentUser = client.auth.currentUser;
    if (currentUser == null) return false;

    // 如果是自己的照片記錄，總是可以刪除
    if (currentUser.id == photoRecordUserId) return true;

    // 獲取當前用戶權限
    final permission = await getUserPermission(floorPlanUrl: floorPlanUrl);
    if (permission == null) return false;

    // 檢查權限等級是否允許刪除他人的座標點
    return permission.permissionLevel.canDeleteOthersCoordinates;
  }

  /// 檢查用戶是否可以刪除設計圖
  Future<bool> canDeleteFloorPlan(String floorPlanUrl) async {
    final permission = await getUserPermission(floorPlanUrl: floorPlanUrl);
    if (permission == null) return false;

    return permission.permissionLevel.canDeleteFloorPlan;
  }

  /// 獲取用戶有權限的所有設計圖
  Future<List<FloorPlanPermission>> getUserPermissions([String? userId]) async {
    final targetUserId = userId ?? client.auth.currentUser?.id;
    if (targetUserId == null) return [];

    try {
      final response = await client
          .from('floor_plan_permissions')
          .select()
          .eq('user_id', targetUserId)
          .order('is_owner', ascending: false)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => FloorPlanPermission.fromJson(json))
          .toList();
    } catch (e) {
      print('獲取用戶權限列表失敗: $e');
      return [];
    }
  }

  /// 刪除設計圖時清理所有相關權限
  Future<void> deleteFloorPlanPermissions(String floorPlanUrl) async {
    try {
      await client
          .from('floor_plan_permissions')
          .delete()
          .eq('floor_plan_url', floorPlanUrl);
    } catch (e) {
      print('刪除設計圖權限失敗: $e');
      rethrow;
    }
  }
}
