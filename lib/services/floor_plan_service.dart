import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';
import 'permission_service.dart';

/// 平面圖服務
/// 處理平面圖的上傳、載入、刪除等操作
class FloorPlanService {
  final SupabaseClient client;
  late final PermissionService permissionService;

  FloorPlanService(this.client) {
    permissionService = PermissionService(client);
  }

  /// 上傳平面圖
  Future<String> uploadFloorPlan({
    required String localPath,
    required Uint8List imageBytes,
    required String name,
  }) async {
    final currentUser = client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('未登入');
    }

    final timestamp = DateTime.now();
    final fileName = 'floorplan_${timestamp.millisecondsSinceEpoch}.jpg';
    const bucketName = 'floor-plans-file';

    // 上傳設計圖到 Storage
    await client.storage
        .from(bucketName)
        .uploadBinary(
          fileName,
          imageBytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    final publicUrl = client.storage.from(bucketName).getPublicUrl(fileName);

    // 使用事務確保資料一致性
    try {
      // 1. 先插入設計圖記錄
      final insertData = {
        'name': name,
        'image_url': publicUrl,
        'user_id': currentUser.id,
        'created_at': timestamp.toIso8601String(),
      };

      print('嘗試插入設計圖資料: $insertData');
      final response = await client
          .from('floor_plans')
          .insert(insertData)
          .select('id')
          .single();
      final floorPlanId = response['id'] as String;
      print('設計圖插入成功，ID: $floorPlanId');

      // 2. 立即為當前用戶創建擁有者權限
      print('正在創建擁有者權限...');
      await permissionService.createOwnerPermission(
        floorPlanId: floorPlanId,
        floorPlanUrl: publicUrl,
        floorPlanName: name,
      );
      print('擁有者權限創建成功');
    } catch (e) {
      print('操作失敗: $e');
      // 如果任何步驟失敗，清理已上傳的檔案
      try {
        await client.storage.from(bucketName).remove([fileName]);
        print('已清理上傳的檔案');
      } catch (cleanupError) {
        print('清理檔案失敗: $cleanupError');
      }

      // 如果設計圖記錄已經插入但權限創建失敗，也要清理設計圖記錄
      try {
        await client.from('floor_plans').delete().eq('image_url', publicUrl);
        print('已清理設計圖記錄');
      } catch (cleanupError) {
        print('清理設計圖記錄失敗: $cleanupError');
      }

      rethrow;
    }

    return publicUrl;
  }

  /// 載入用戶有權限的平面圖
  Future<List<Map<String, dynamic>>> loadFloorPlans() async {
    try {
      // 使用權限系統來獲取用戶有權限的設計圖
      final accessibleFloorPlans = await permissionService
          .getUserAccessibleFloorPlans();

      print('用戶有權限的設計圖數量: ${accessibleFloorPlans.length}');
      for (final plan in accessibleFloorPlans) {
        print(
          '設計圖: ${plan['name']}, 權限等級: ${plan['permission_level']}, 擁有者: ${plan['is_owner']}',
        );
      }

      return accessibleFloorPlans;
    } catch (e) {
      print('載入設計圖失敗: $e');
      rethrow;
    }
  }

  /// 根據 ID 獲取特定平面圖
  Future<Map<String, dynamic>?> getFloorPlanById(String floorPlanId) async {
    try {
      final response = await client
          .from('floor_plans')
          .select('*')
          .eq('id', floorPlanId)
          .maybeSingle();

      return response;
    } catch (e) {
      print('獲取平面圖失敗: $e');
      return null;
    }
  }

  /// 根據 URL 獲取平面圖
  Future<Map<String, dynamic>?> getFloorPlanByUrl(String imageUrl) async {
    try {
      final response = await client
          .from('floor_plans')
          .select('*')
          .eq('image_url', imageUrl)
          .maybeSingle();

      return response;
    } catch (e) {
      print('根據 URL 獲取平面圖失敗: $e');
      return null;
    }
  }

  /// 更新平面圖資訊
  Future<bool> updateFloorPlan({
    required String floorPlanId,
    String? name,
  }) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('未登入');
      }

      // 先獲取平面圖資訊
      final floorPlan = await getFloorPlanById(floorPlanId);
      if (floorPlan == null) {
        throw Exception('找不到指定的平面圖');
      }

      // 檢查權限 - 只有擁有者可以更新
      final permission = await permissionService.getUserPermission(
        floorPlanUrl: floorPlan['image_url'] as String,
      );
      if (permission == null || !permission.isOwner) {
        throw Exception('您沒有權限編輯此平面圖');
      }

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) {
        updateData['name'] = name;
      }

      await client.from('floor_plans').update(updateData).eq('id', floorPlanId);

      return true;
    } catch (e) {
      print('更新平面圖失敗: $e');
      return false;
    }
  }

  /// 刪除平面圖
  Future<void> deleteFloorPlan(String imageUrl) async {
    final currentUser = client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('未登入');
    }

    // 檢查權限
    final canDelete = await permissionService.canDeleteFloorPlan(imageUrl);
    if (!canDelete) {
      throw Exception('您沒有權限刪除此設計圖');
    }

    // 1. 刪除相關的照片記錄
    final records = await client
        .from('photo_records')
        .select()
        .eq('floor_plan_path', imageUrl);

    // 2. 從 Storage 刪除相關的照片
    for (final record in records as List<dynamic>) {
      final photoUrl = record['image_url'] as String;
      final photoPath = Uri.parse(photoUrl).pathSegments.last;
      await client.storage.from('site-photos').remove([
        'user_${currentUser.id}/$photoPath',
      ]);
    }

    // 3. 從資料庫刪除相關的照片記錄
    await client.from('photo_records').delete().eq('floor_plan_path', imageUrl);

    // 4. 從資料庫刪除平面圖記錄
    await client.from('floor_plans').delete().eq('image_url', imageUrl);

    // 5. 清理權限記錄
    await permissionService.deleteFloorPlanPermissions(imageUrl);

    // 6. 從 Storage 刪除平面圖
    final floorPlanPath = Uri.parse(imageUrl).pathSegments.last;
    await client.storage.from('floor-plans-file').remove([floorPlanPath]);
  }

  /// 獲取用戶自己的平面圖
  Future<List<Map<String, dynamic>>> getUserOwnedFloorPlans() async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('未登入');
      }

      final response = await client
          .from('floor_plans')
          .select('*')
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('獲取用戶擁有的平面圖失敗: $e');
      rethrow;
    }
  }

  /// 分享平面圖給其他用戶
  Future<bool> shareFloorPlan({
    required String floorPlanId,
    required String targetUserId,
    required int permissionLevel, // 1=檢視, 2=編輯, 3=管理
  }) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('未登入');
      }

      // 獲取平面圖資訊
      final floorPlan = await getFloorPlanById(floorPlanId);
      if (floorPlan == null) {
        throw Exception('找不到指定的平面圖');
      }

      // 檢查當前用戶是否有分享權限（只有擁有者可以分享）
      final permission = await permissionService.getUserPermission(
        floorPlanUrl: floorPlan['image_url'] as String,
      );
      if (permission == null || !permission.isOwner) {
        throw Exception('您沒有權限分享此平面圖');
      }

      // 獲取目標用戶資訊
      final allUsers = await permissionService.getAllUsers();
      final targetUser = allUsers.firstWhere(
        (user) => user['id'] == targetUserId,
        orElse: () => throw Exception('找不到目標用戶'),
      );

      await permissionService.addUserPermission(
        floorPlanUrl: floorPlan['image_url'] as String,
        floorPlanName: floorPlan['name'] as String,
        userEmail: targetUser['email'] as String,
        permissionLevel: PermissionLevel.fromValue(permissionLevel),
      );

      return true;
    } catch (e) {
      print('分享平面圖失敗: $e');
      return false;
    }
  }

  /// 取消分享平面圖
  Future<bool> unshareFloorPlan({
    required String floorPlanId,
    required String targetUserId,
  }) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('未登入');
      }

      // 獲取平面圖資訊
      final floorPlan = await getFloorPlanById(floorPlanId);
      if (floorPlan == null) {
        throw Exception('找不到指定的平面圖');
      }

      // 檢查當前用戶是否有管理權限（只有擁有者可以移除權限）
      final permission = await permissionService.getUserPermission(
        floorPlanUrl: floorPlan['image_url'] as String,
      );
      if (permission == null || !permission.isOwner) {
        throw Exception('您沒有權限管理此平面圖的分享設定');
      }

      await permissionService.removeUserPermission(
        floorPlanUrl: floorPlan['image_url'] as String,
        userId: targetUserId,
      );

      return true;
    } catch (e) {
      print('取消分享平面圖失敗: $e');
      return false;
    }
  }

  /// 獲取平面圖的分享列表
  Future<List<Map<String, dynamic>>> getFloorPlanSharedUsers(
    String floorPlanId,
  ) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('未登入');
      }

      // 獲取平面圖資訊
      final floorPlan = await getFloorPlanById(floorPlanId);
      if (floorPlan == null) {
        throw Exception('找不到指定的平面圖');
      }

      // 檢查用戶是否有查看權限
      final permission = await permissionService.getUserPermission(
        floorPlanUrl: floorPlan['image_url'] as String,
      );
      if (permission == null) {
        throw Exception('您沒有權限查看此平面圖的分享資訊');
      }

      final permissions = await permissionService.getFloorPlanPermissions(
        floorPlan['image_url'] as String,
      );

      // 將 FloorPlanPermission 轉換為 Map
      return permissions.map((permission) => permission.toJson()).toList();
    } catch (e) {
      print('獲取平面圖分享列表失敗: $e');
      rethrow;
    }
  }
}
