import 'dart:convert';
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

    // 查找目標用戶 - 使用我們的 getAllUsers 方法而不是 admin API
    final allUsers = await getAllUsers();
    final targetUserData = allUsers.firstWhere(
      (user) => user['email'] == userEmail,
      orElse: () => throw Exception('找不到用戶: $userEmail'),
    );

    final targetUserId = targetUserData['id'] as String;

    // 檢查是否已有權限
    final existingPermission = await getUserPermission(
      floorPlanUrl: floorPlanUrl,
      userId: targetUserId,
    );
    if (existingPermission != null) {
      throw Exception('用戶已有此設計圖的權限');
    }

    final permission = {
      'floor_plan_id': floorPlanUrl.split('/').last.split('.').first,
      'floor_plan_url': floorPlanUrl,
      'floor_plan_name': floorPlanName,
      'user_id': targetUserId,
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

  /// 獲取系統中所有使用者（用於權限管理）
  /// 從 profiles 表或權限表中獲取使用者資訊
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      print('開始獲取所有使用者...');

      // 方法 1: 嘗試使用 RPC 函數
      try {
        final rpcResponse = await client.rpc('get_all_users');
        if (rpcResponse != null) {
          print('RPC 原始回應: $rpcResponse');
          print('RPC 回應類型: ${rpcResponse.runtimeType}');

          List<Map<String, dynamic>> userList = [];

          if (rpcResponse is List) {
            userList = rpcResponse.cast<Map<String, dynamic>>();
          } else if (rpcResponse is String) {
            // 如果回應是 JSON 字符串，嘗試解析
            try {
              final decoded = jsonDecode(rpcResponse);
              if (decoded is List) {
                userList = decoded.cast<Map<String, dynamic>>();
              }
            } catch (e) {
              print('JSON 解析失敗: $e');
            }
          } else if (rpcResponse is Map) {
            // 處理可能的單個對象回應
            userList = [rpcResponse.cast<String, dynamic>()];
          } else {
            // 嘗試直接轉換
            try {
              if (rpcResponse != null) {
                final converted = List<Map<String, dynamic>>.from(rpcResponse);
                userList = converted;
              }
            } catch (e) {
              print('直接轉換失敗: $e');
            }
          }

          if (userList.isNotEmpty) {
            print('從 RPC 函數獲取到 ${userList.length} 個使用者');
            return userList;
          }
        }
      } catch (e) {
        print('get_all_users RPC 函數調用失敗: $e');
      }

      // 嘗試備用的 RPC 函數
      try {
        final rpcResponse = await client.rpc('list_users');
        if (rpcResponse != null &&
            rpcResponse is List &&
            rpcResponse.isNotEmpty) {
          print('從 list_users RPC 函數獲取到 ${rpcResponse.length} 個使用者');
          // 轉換字段名稱以匹配預期格式
          final userList = rpcResponse
              .map(
                (user) => {
                  'id': user['user_id'],
                  'email': user['user_email'],
                  'created_at': user['user_created_at'],
                },
              )
              .toList()
              .cast<Map<String, dynamic>>();
          return userList;
        }
      } catch (e) {
        print('list_users RPC 函數調用失敗: $e');
      }

      // 方法 2: 嘗試從 profiles 表獲取
      try {
        final profilesResponse = await client
            .from('profiles')
            .select('id, email, created_at')
            .order('created_at', ascending: false);

        if (profilesResponse.isNotEmpty) {
          print('從 profiles 表獲取到 ${profilesResponse.length} 個使用者');
          return profilesResponse.cast<Map<String, dynamic>>();
        }
      } catch (e) {
        print('profiles 表訪問失敗: $e');
      }

      // 方法 3: 從權限表中獲取唯一使用者
      try {
        final permissionsResponse = await client
            .from('floor_plan_permissions')
            .select('user_id, user_email, created_at')
            .order('created_at', ascending: false);

        // 去除重複的使用者
        final uniqueUsers = <String, Map<String, dynamic>>{};
        for (final permission in permissionsResponse) {
          final userId = permission['user_id'] as String;
          if (!uniqueUsers.containsKey(userId)) {
            uniqueUsers[userId] = {
              'id': userId,
              'email': permission['user_email'] ?? '',
              'created_at': permission['created_at'],
            };
          }
        }

        final userList = uniqueUsers.values.toList();
        print('從權限表獲取到 ${userList.length} 個唯一使用者');

        if (userList.isNotEmpty) {
          return userList;
        }
      } catch (e) {
        print('從權限表獲取使用者失敗: $e');
      }

      // 方法 4: 臨時解決方案 - 創建模擬使用者清單供測試
      print('⚠️ 所有方法都失敗，返回當前使用者作為測試');
      final currentUser = client.auth.currentUser;
      if (currentUser != null) {
        return [
          {
            'id': currentUser.id,
            'email': currentUser.email ?? '',
            'created_at': currentUser.createdAt,
          },
        ];
      }

      print('❌ 無法獲取任何使用者資訊');
      return [];
    } catch (e) {
      print('獲取所有使用者失敗: $e');
      print('錯誤類型: ${e.runtimeType}');
      return [];
    }
  }

  /// 獲取當前用戶有權限訪問的設計圖列表
  Future<List<Map<String, dynamic>>> getUserAccessibleFloorPlans() async {
    final currentUser = client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('未登入');
    }

    try {
      // 獲取用戶有權限的設計圖
      final permissionsResponse = await client
          .from('floor_plan_permissions')
          .select('floor_plan_url, floor_plan_name, permission_level, is_owner')
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false);

      // 轉換為設計圖格式
      final accessibleFloorPlans = permissionsResponse.map((permission) {
        return {
          'image_url': permission['floor_plan_url'],
          'name': permission['floor_plan_name'],
          'permission_level': permission['permission_level'],
          'is_owner': permission['is_owner'],
        };
      }).toList();

      return accessibleFloorPlans.cast<Map<String, dynamic>>();
    } catch (e) {
      print('獲取用戶設計圖權限失敗: $e');
      rethrow;
    }
  }
}
