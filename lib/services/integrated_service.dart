import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';
import 'floor_plan_service.dart';
import 'photo_record_service.dart';
import 'permission_service.dart';

/// 整合服務
/// 協調 FloorPlanService 和 PhotoRecordService 的操作
/// 這個服務可以作為原有 SupabaseService 的替代品
class IntegratedService {
  final SupabaseClient client;
  late final FloorPlanService floorPlanService;
  late final PhotoRecordService photoRecordService;
  late final PermissionService permissionService;

  IntegratedService(this.client) {
    floorPlanService = FloorPlanService(client);
    photoRecordService = PhotoRecordService(client);
    permissionService = PermissionService(client);
  }

  // ============ Floor Plan 相關方法 ============

  /// 上傳平面圖
  Future<String> uploadFloorPlan({
    required String localPath,
    required Uint8List imageBytes,
    required String name,
  }) async {
    return await floorPlanService.uploadFloorPlan(
      localPath: localPath,
      imageBytes: imageBytes,
      name: name,
    );
  }

  /// 載入平面圖
  Future<List<Map<String, dynamic>>> loadFloorPlans() async {
    return await floorPlanService.loadFloorPlans();
  }

  /// 刪除平面圖
  Future<void> deleteFloorPlan(String imageUrl) async {
    // 先刪除相關的照片記錄
    await photoRecordService.deleteRecordsByFloorPlan(imageUrl);

    // 再刪除平面圖
    await floorPlanService.deleteFloorPlan(imageUrl);
  }

  /// 獲取用戶擁有的平面圖
  Future<List<Map<String, dynamic>>> getUserOwnedFloorPlans() async {
    return await floorPlanService.getUserOwnedFloorPlans();
  }

  /// 分享平面圖
  Future<bool> shareFloorPlan({
    required String floorPlanId,
    required String targetUserId,
    required int permissionLevel,
  }) async {
    return await floorPlanService.shareFloorPlan(
      floorPlanId: floorPlanId,
      targetUserId: targetUserId,
      permissionLevel: permissionLevel,
    );
  }

  // ============ Photo Record 相關方法 ============

  /// 載入記錄
  Future<List<PhotoRecord>> loadRecords() async {
    return await photoRecordService.loadRecords();
  }

  /// 根據平面圖載入記錄
  Future<List<PhotoRecord>> loadRecordsByFloorPlan(String floorPlanPath) async {
    return await photoRecordService.loadRecordsByFloorPlan(floorPlanPath);
  }

  /// 上傳照片並創建記錄
  Future<PhotoRecord> uploadPhotoAndCreateRecord({
    required String localPath,
    required Uint8List photoBytes,
    required double x,
    required double y,
    required String floorPlanPath,
    String? description,
  }) async {
    return await photoRecordService.uploadPhotoAndCreateRecord(
      localPath: localPath,
      photoBytes: photoBytes,
      x: x,
      y: y,
      floorPlanPath: floorPlanPath,
      description: description,
    );
  }

  /// 刪除照片記錄
  Future<void> deletePhotoRecord(PhotoRecord record) async {
    await photoRecordService.deletePhotoRecord(record);
  }

  /// 根據 ID 刪除照片記錄
  Future<void> deletePhotoRecordById(String recordId) async {
    await photoRecordService.deletePhotoRecordById(recordId);
  }

  // ============ 統計和搜尋方法 ============

  /// 搜尋照片記錄
  Future<List<PhotoRecord>> searchPhotoRecords({
    String? floorPlanPath,
    String? userId,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    return await photoRecordService.searchRecords(
      floorPlanPath: floorPlanPath,
      userId: userId,
      description: description,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );
  }

  /// 獲取記錄統計
  Future<Map<String, dynamic>> getRecordStatistics({
    String? floorPlanPath,
    String? userId,
  }) async {
    return await photoRecordService.getRecordStatistics(
      floorPlanPath: floorPlanPath,
      userId: userId,
    );
  }

  // ============ 權限相關方法 ============

  /// 獲取用戶權限
  Future<FloorPlanPermission?> getUserPermission({
    required String floorPlanUrl,
    String? userId,
  }) async {
    return await permissionService.getUserPermission(
      floorPlanUrl: floorPlanUrl,
      userId: userId,
    );
  }

  /// 添加用戶權限
  Future<void> addUserPermission({
    required String floorPlanUrl,
    required String floorPlanName,
    required String userEmail,
    required PermissionLevel permissionLevel,
  }) async {
    await permissionService.addUserPermission(
      floorPlanUrl: floorPlanUrl,
      floorPlanName: floorPlanName,
      userEmail: userEmail,
      permissionLevel: permissionLevel,
    );
  }

  /// 移除用戶權限
  Future<void> removeUserPermission({
    required String floorPlanUrl,
    required String userId,
  }) async {
    await permissionService.removeUserPermission(
      floorPlanUrl: floorPlanUrl,
      userId: userId,
    );
  }

  /// 獲取所有使用者
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    return await permissionService.getAllUsers();
  }

  // ============ 便利方法 ============

  /// 獲取平面圖的完整資訊（包含權限和記錄數量）
  Future<Map<String, dynamic>?> getFloorPlanDetails(String floorPlanId) async {
    try {
      final floorPlan = await floorPlanService.getFloorPlanById(floorPlanId);
      if (floorPlan == null) return null;

      final records = await photoRecordService.loadRecordsByFloorPlan(
        floorPlan['image_url'] as String,
      );

      final permissions = await floorPlanService.getFloorPlanSharedUsers(
        floorPlanId,
      );

      final statistics = await photoRecordService.getRecordStatistics(
        floorPlanPath: floorPlan['image_url'] as String,
      );

      return {
        ...floorPlan,
        'records_count': records.length,
        'shared_users_count': permissions.length,
        'statistics': statistics,
      };
    } catch (e) {
      print('獲取平面圖詳細資訊失敗: $e');
      return null;
    }
  }

  /// 檢查當前用戶對平面圖的權限
  Future<Map<String, bool>> checkFloorPlanPermissions(
    String floorPlanUrl,
  ) async {
    try {
      final permission = await permissionService.getUserPermission(
        floorPlanUrl: floorPlanUrl,
      );

      if (permission == null) {
        return {
          'canView': false,
          'canEdit': false,
          'canDelete': false,
          'canShare': false,
          'isOwner': false,
        };
      }

      final permissionLevel = permission.permissionLevel;
      return {
        'canView': true,
        'canEdit':
            permissionLevel == PermissionLevel.level2 ||
            permissionLevel == PermissionLevel.level3,
        'canDelete': permissionLevel == PermissionLevel.level3,
        'canShare': permission.isOwner,
        'isOwner': permission.isOwner,
      };
    } catch (e) {
      print('檢查權限失敗: $e');
      return {
        'canView': false,
        'canEdit': false,
        'canDelete': false,
        'canShare': false,
        'isOwner': false,
      };
    }
  }

  /// 獲取用戶的完整儀表板資料
  Future<Map<String, dynamic>> getUserDashboard() async {
    try {
      final floorPlans = await floorPlanService.loadFloorPlans();
      final ownedFloorPlans = await floorPlanService.getUserOwnedFloorPlans();
      final userRecords = await photoRecordService.loadCurrentUserRecords();

      final totalStatistics = await photoRecordService.getRecordStatistics();

      return {
        'accessible_floor_plans': floorPlans,
        'owned_floor_plans': ownedFloorPlans,
        'user_records': userRecords,
        'statistics': {
          'accessible_floor_plans_count': floorPlans.length,
          'owned_floor_plans_count': ownedFloorPlans.length,
          'user_records_count': userRecords.length,
          'total_statistics': totalStatistics,
        },
      };
    } catch (e) {
      print('獲取用戶儀表板資料失敗: $e');
      return {
        'accessible_floor_plans': [],
        'owned_floor_plans': [],
        'user_records': [],
        'statistics': {
          'accessible_floor_plans_count': 0,
          'owned_floor_plans_count': 0,
          'user_records_count': 0,
          'total_statistics': {'total_count': 0, 'today_count': 0},
        },
      };
    }
  }
}
