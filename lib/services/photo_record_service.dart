import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/photo_record.dart';
import 'permission_service.dart';

/// 照片記錄服務
/// 處理照片記錄的上傳、載入、刪除等操作
class PhotoRecordService {
  final SupabaseClient client;
  late final PermissionService permissionService;

  PhotoRecordService(this.client) {
    permissionService = PermissionService(client);
  }

  /// 載入所有照片記錄
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

  /// 根據平面圖載入照片記錄
  Future<List<PhotoRecord>> loadRecordsByFloorPlan(String floorPlanPath) async {
    try {
      final response = await client
          .from('photo_records')
          .select()
          .eq('floor_plan_path', floorPlanPath)
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
      print('載入特定平面圖的記錄失敗: $e');
      rethrow;
    }
  }

  /// 根據用戶 ID 載入照片記錄
  Future<List<PhotoRecord>> loadRecordsByUser(String userId) async {
    try {
      final response = await client
          .from('photo_records')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>).map((record) {
        try {
          return PhotoRecord.fromJson(record);
        } catch (e) {
          print('轉換 PhotoRecord 失敗: $e, 數據: $record');
          rethrow;
        }
      }).toList();
    } catch (e) {
      print('載入用戶記錄失敗: $e');
      rethrow;
    }
  }

  /// 載入當前用戶的照片記錄
  Future<List<PhotoRecord>> loadCurrentUserRecords() async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('未登入');
      }

      return await loadRecordsByUser(currentUser.id);
    } catch (e) {
      print('載入當前用戶記錄失敗: $e');
      rethrow;
    }
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
      if (description != null) 'description': description,
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

  /// 根據 ID 獲取特定照片記錄
  Future<PhotoRecord?> getRecordById(String recordId) async {
    try {
      final response = await client
          .from('photo_records')
          .select()
          .eq('id', recordId)
          .maybeSingle();

      if (response == null) return null;

      return PhotoRecord.fromJson(response);
    } catch (e) {
      print('根據 ID 獲取記錄失敗: $e');
      return null;
    }
  }

  /// 更新照片記錄
  Future<PhotoRecord?> updateRecord({
    required String recordId,
    double? x,
    double? y,
    String? description,
  }) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('未登入');
      }

      // 先獲取記錄確認存在
      final existingRecord = await getRecordById(recordId);
      if (existingRecord == null) {
        throw Exception('找不到指定的記錄');
      }

      // 檢查權限
      final canDelete = await permissionService.canDeletePhotoRecord(
        floorPlanUrl: existingRecord.floorPlanPath,
        photoRecordUserId: existingRecord.userId,
      );

      if (!canDelete) {
        throw Exception('您沒有權限修改此照片記錄');
      }

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (x != null) updateData['x_coordinate'] = x;
      if (y != null) updateData['y_coordinate'] = y;
      if (description != null) updateData['description'] = description;

      final response = await client
          .from('photo_records')
          .update(updateData)
          .eq('id', recordId)
          .select()
          .single();

      return PhotoRecord.fromJson(response);
    } catch (e) {
      print('更新記錄失敗: $e');
      return null;
    }
  }

  /// 刪除照片記錄
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

  /// 根據記錄 ID 刪除照片記錄
  Future<void> deletePhotoRecordById(String recordId) async {
    try {
      final record = await getRecordById(recordId);
      if (record == null) {
        throw Exception('找不到指定的記錄');
      }

      await deletePhotoRecord(record);
    } catch (e) {
      print('根據 ID 刪除記錄失敗: $e');
      rethrow;
    }
  }

  /// 批量刪除照片記錄
  Future<void> deleteMultipleRecords(List<String> recordIds) async {
    for (final recordId in recordIds) {
      try {
        await deletePhotoRecordById(recordId);
      } catch (e) {
        print('刪除記錄 $recordId 失敗: $e');
        // 繼續刪除其他記錄
      }
    }
  }

  /// 根據平面圖刪除所有相關照片記錄
  Future<void> deleteRecordsByFloorPlan(String floorPlanPath) async {
    try {
      final records = await loadRecordsByFloorPlan(floorPlanPath);

      for (final record in records) {
        try {
          await deletePhotoRecord(record);
        } catch (e) {
          print('刪除記錄 ${record.id} 失敗: $e');
          // 繼續刪除其他記錄
        }
      }
    } catch (e) {
      print('批量刪除平面圖記錄失敗: $e');
      rethrow;
    }
  }

  /// 搜尋照片記錄
  Future<List<PhotoRecord>> searchRecords({
    String? floorPlanPath,
    String? userId,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      var query = client.from('photo_records').select();

      if (floorPlanPath != null) {
        query = query.eq('floor_plan_path', floorPlanPath);
      }

      if (userId != null) {
        query = query.eq('user_id', userId);
      }

      if (description != null && description.isNotEmpty) {
        query = query.ilike('description', '%$description%');
      }

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List<dynamic>).map((record) {
        try {
          return PhotoRecord.fromJson(record);
        } catch (e) {
          print('轉換搜尋結果失敗: $e, 數據: $record');
          rethrow;
        }
      }).toList();
    } catch (e) {
      print('搜尋記錄失敗: $e');
      return [];
    }
  }

  /// 獲取記錄統計資訊
  Future<Map<String, dynamic>> getRecordStatistics({
    String? floorPlanPath,
    String? userId,
  }) async {
    try {
      var query = client.from('photo_records').select('id');

      if (floorPlanPath != null) {
        query = query.eq('floor_plan_path', floorPlanPath);
      }

      if (userId != null) {
        query = query.eq('user_id', userId);
      }

      final response = await query;
      final totalCount = response.length;

      // 獲取今日記錄數
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);

      var todayQuery = client.from('photo_records').select('id');

      if (floorPlanPath != null) {
        todayQuery = todayQuery.eq('floor_plan_path', floorPlanPath);
      }

      if (userId != null) {
        todayQuery = todayQuery.eq('user_id', userId);
      }

      final todayResponse = await todayQuery.gte(
        'created_at',
        todayStart.toIso8601String(),
      );
      final todayCount = todayResponse.length;

      return {
        'total_count': totalCount,
        'today_count': todayCount,
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('獲取統計資訊失敗: $e');
      return {
        'total_count': 0,
        'today_count': 0,
        'last_updated': DateTime.now().toIso8601String(),
      };
    }
  }
}
