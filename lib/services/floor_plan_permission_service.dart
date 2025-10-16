import 'package:supabase_flutter/supabase_flutter.dart';

/// 設計圖權限等級
enum PermissionLevel {
  viewer(1, '檢視者'),
  editor(2, '編輯者'),
  admin(3, '管理員');

  final int value;
  final String label;

  const PermissionLevel(this.value, this.label);

  static PermissionLevel fromValue(int value) {
    return PermissionLevel.values.firstWhere((e) => e.value == value);
  }
}

/// 設計圖權限模型
class FloorPlanPermission {
  final String id;
  final String floorPlanId;
  final String userId;
  final PermissionLevel permissionLevel;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 用戶資訊（從 join 查詢獲得）
  final String? userEmail;
  final String? userFullName;

  FloorPlanPermission({
    required this.id,
    required this.floorPlanId,
    required this.userId,
    required this.permissionLevel,
    required this.createdAt,
    required this.updatedAt,
    this.userEmail,
    this.userFullName,
  });

  factory FloorPlanPermission.fromJson(Map<String, dynamic> json) {
    return FloorPlanPermission(
      id: json['id'] as String,
      floorPlanId: json['floor_plan_id'] as String,
      userId: json['user_id'] as String,
      permissionLevel: PermissionLevel.fromValue(
        json['permission_level'] as int,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      userEmail: json['user_email'] as String?,
      userFullName: json['user_full_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'floor_plan_id': floorPlanId,
      'user_id': userId,
      'permission_level': permissionLevel.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// 設計圖權限管理服務
class FloorPlanPermissionService {
  final SupabaseClient _client;

  FloorPlanPermissionService(this._client);

  /// 檢查當前用戶是否為設計圖擁有者
  Future<bool> isOwner(String floorPlanId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      final response = await _client
          .from('floor_plans')
          .select('user_id')
          .eq('id', floorPlanId)
          .maybeSingle();

      if (response == null) return false;

      return response['user_id'] == user.id;
    } catch (e) {
      print('檢查擁有者失敗: $e');
      return false;
    }
  }

  /// 檢查當前用戶對設計圖的權限等級
  Future<PermissionLevel?> getUserPermission(String floorPlanId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      // 先檢查是否為擁有者
      if (await isOwner(floorPlanId)) {
        return PermissionLevel.admin; // 擁有者擁有最高權限
      }

      // 檢查權限表
      final response = await _client
          .from('floor_plan_permissions')
          .select('permission_level')
          .eq('floor_plan_id', floorPlanId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (response == null) return null;

      return PermissionLevel.fromValue(response['permission_level'] as int);
    } catch (e) {
      print('檢查權限失敗: $e');
      return null;
    }
  }

  /// 檢查用戶是否有管理權限（擁有者或管理員）
  Future<bool> canManage(String floorPlanId) async {
    final permission = await getUserPermission(floorPlanId);
    return permission == PermissionLevel.admin;
  }

  /// 檢查用戶是否可以編輯（編輯者或以上）
  Future<bool> canEdit(String floorPlanId) async {
    final permission = await getUserPermission(floorPlanId);
    return permission != null &&
        permission.value >= PermissionLevel.editor.value;
  }

  /// 獲取設計圖的所有權限列表（包含用戶資訊，包含創建者）
  Future<List<FloorPlanPermission>> getPermissions(String floorPlanId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('請先登入');
      }

      // 檢查是否有管理權限
      if (!await canManage(floorPlanId)) {
        throw Exception('無權限查看權限列表');
      }

      List<FloorPlanPermission> permissions = [];

      // 1. 先獲取創建者資訊
      final floorPlanResponse = await _client
          .from('floor_plans')
          .select('user_id, created_at')
          .eq('id', floorPlanId)
          .single();

      final ownerId = floorPlanResponse['user_id'] as String;
      final createdAt = DateTime.parse(
        floorPlanResponse['created_at'] as String,
      );

      // 獲取創建者的用戶資訊
      final ownerProfile = await _client
          .from('profiles')
          .select('email, full_name')
          .eq('id', ownerId)
          .maybeSingle();

      // 添加創建者到列表（作為擁有者）
      permissions.add(
        FloorPlanPermission(
          id: 'owner_$ownerId', // 特殊 ID 標識擁有者
          floorPlanId: floorPlanId,
          userId: ownerId,
          permissionLevel: PermissionLevel.admin,
          createdAt: createdAt,
          updatedAt: createdAt,
          userEmail: ownerProfile?['email'] as String?,
          userFullName: ownerProfile?['full_name'] as String?,
        ),
      );

      // 2. 獲取其他成員的權限
      try {
        // 使用 RPC 函數查詢
        final response = await _client.rpc(
          'get_floor_plan_permissions',
          params: {'p_floor_plan_id': floorPlanId},
        );

        permissions.addAll(
          (response as List)
              .map((json) => FloorPlanPermission.fromJson(json))
              .toList(),
        );
      } catch (e) {
        print('RPC 查詢失敗，使用基本查詢: $e');

        // 如果 RPC 函數不存在，使用基本查詢
        final response = await _client
            .from('floor_plan_permissions')
            .select('*')
            .eq('floor_plan_id', floorPlanId);

        permissions.addAll(
          (response as List)
              .map((json) => FloorPlanPermission.fromJson(json))
              .toList(),
        );
      }

      // 3. 按創建時間排序（創建者優先）
      permissions.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      return permissions;
    } catch (e) {
      print('獲取權限列表失敗: $e');
      rethrow;
    }
  }

  /// 添加用戶權限
  Future<FloorPlanPermission> addPermission({
    required String floorPlanId,
    required String targetUserId,
    required PermissionLevel permissionLevel,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('請先登入');
      }

      // 檢查是否有管理權限
      if (!await canManage(floorPlanId)) {
        throw Exception('無權限添加成員');
      }

      // 檢查目標用戶是否已有權限
      final existing = await _client
          .from('floor_plan_permissions')
          .select()
          .eq('floor_plan_id', floorPlanId)
          .eq('user_id', targetUserId)
          .maybeSingle();

      if (existing != null) {
        throw Exception('該用戶已有權限');
      }

      // 添加權限
      final response = await _client
          .from('floor_plan_permissions')
          .insert({
            'floor_plan_id': floorPlanId,
            'user_id': targetUserId,
            'permission_level': permissionLevel.value,
          })
          .select()
          .single();

      return FloorPlanPermission.fromJson(response);
    } catch (e) {
      print('添加權限失敗: $e');
      rethrow;
    }
  }

  /// 更新用戶權限等級
  Future<void> updatePermission({
    required String permissionId,
    required PermissionLevel newLevel,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('請先登入');
      }

      // 獲取權限記錄以檢查 floor_plan_id
      final permission = await _client
          .from('floor_plan_permissions')
          .select('floor_plan_id')
          .eq('id', permissionId)
          .single();

      // 檢查是否有管理權限
      if (!await canManage(permission['floor_plan_id'])) {
        throw Exception('無權限修改權限');
      }

      await _client
          .from('floor_plan_permissions')
          .update({
            'permission_level': newLevel.value,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', permissionId);
    } catch (e) {
      print('更新權限失敗: $e');
      rethrow;
    }
  }

  /// 移除用戶權限
  Future<void> removePermission(String permissionId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('請先登入');
      }

      // 獲取權限記錄以檢查 floor_plan_id
      final permission = await _client
          .from('floor_plan_permissions')
          .select('floor_plan_id')
          .eq('id', permissionId)
          .single();

      // 檢查是否有管理權限
      if (!await canManage(permission['floor_plan_id'])) {
        throw Exception('無權限移除成員');
      }

      await _client
          .from('floor_plan_permissions')
          .delete()
          .eq('id', permissionId);
    } catch (e) {
      print('移除權限失敗: $e');
      rethrow;
    }
  }

  /// 通過 email 搜尋用戶
  Future<List<Map<String, dynamic>>> searchUsersByEmail(String email) async {
    try {
      // 從 profiles 表搜尋（假設有存儲 email）
      final response = await _client
          .from('profiles')
          .select('id, email, full_name')
          .ilike('email', '%$email%')
          .limit(10);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('搜尋用戶失敗: $e');
      return [];
    }
  }
}
