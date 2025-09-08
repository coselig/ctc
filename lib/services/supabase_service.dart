import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/photo_record.dart';
import 'permission_service.dart';

class SupabaseService {
  final SupabaseClient client;
  late final PermissionService permissionService;

  SupabaseService(this.client) {
    permissionService = PermissionService(client);
  }

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
      await client.from('floor_plans').insert(insertData);
      print('設計圖插入成功');

      // 2. 立即為當前用戶創建擁有者權限
      print('正在創建擁有者權限...');
      await permissionService.createOwnerPermission(
        floorPlanId: fileName.split('.').first,
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

  Future<List<Map<String, dynamic>>> loadFloorPlans() async {
    try {
      final response = await client
          .from('floor_plans')
          .select()
          .order('created_at');

      return (response as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (e) {
      print('載入設計圖失敗: $e');
      rethrow;
    }
  }

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

  Future<List<PhotoRecord>> loadRecords() async {
    try {
      final response = await client
          .from('photo_records')
          .select()
          .order('created_at');

      return (response as List<dynamic>).map((record) {
        try {
          return PhotoRecord.fromJson(record);
        } catch (e) {
          print('轉換 PhotoRecord 失敗: $e, 數據: $record');
          rethrow;
        }
      }).toList();
    } catch (e) {
      print('載入記錄失敗: $e');
      rethrow;
    }
  }

  Future<PhotoRecord> uploadPhotoAndCreateRecord({
    required String localPath,
    required Uint8List photoBytes,
    required double x,
    required double y,
    required String floorPlanPath,
  }) async {
    final currentUser = client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('未登入');
    }

    final timestamp = DateTime.now();
    final fileName = '${timestamp.millisecondsSinceEpoch}.jpg';
    final userFilePath = 'user_${currentUser.id}/$fileName';

    // 上傳圖片到 Storage
    await client.storage
        .from('site-photos')
        .uploadBinary(
          userFilePath,
          photoBytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    final publicUrl = client.storage
        .from('site-photos')
        .getPublicUrl(userFilePath);

    // 儲存記錄到資料庫
    final recordData = {
      'user_id': currentUser.id,
      'username': currentUser.email,
      'image_url': publicUrl,
      'x_coordinate': x,
      'y_coordinate': y,
      'created_at': timestamp.toIso8601String(),
      'floor_plan_path': floorPlanPath,
    };

    final response = await client
        .from('photo_records')
        .insert(recordData)
        .select()
        .single();

    try {
      return PhotoRecord.fromJson(response);
    } catch (e) {
      print('轉換上傳響應失敗: $e, 響應數據: $response');
      rethrow;
    }
  }

  /// 檢查並刪除照片記錄
  Future<void> deletePhotoRecord(PhotoRecord record) async {
    final currentUser = client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('未登入');
    }

    // 檢查權限
    final canDelete = await permissionService.canDeletePhotoRecord(
      floorPlanUrl: record.floorPlanPath,
      photoRecordUserId: record.userId,
    );

    if (!canDelete) {
      throw Exception('您沒有權限刪除此照片記錄');
    }

    // 刪除照片文件
    final photoPath = Uri.parse(record.imagePath).pathSegments.last;
    await client.storage.from('site-photos').remove([
      'user_${record.userId}/$photoPath',
    ]);

    // 刪除資料庫記錄
    await client
        .from('photo_records')
        .delete()
        .eq('image_url', record.imagePath);
  }
}
