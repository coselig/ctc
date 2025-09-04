import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import '../models/photo_record.dart';

class SupabaseService {
  final SupabaseClient client;

  SupabaseService(this.client);

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

    // 儲存設計圖記錄到資料庫
    try {
      final insertData = {
        'name': name,
        'image_url': publicUrl,
        'user_id': currentUser.id,
        'created_at': timestamp.toIso8601String(),
      };

      print('嘗試插入資料: $insertData');
      print('當前用戶: ${currentUser.id}, ${currentUser.email}');

      final response = await client.from('floor_plans').insert(insertData);
      print('插入成功: $response');
    } catch (e) {
      print('插入失敗: $e');
      // 如果資料庫插入失敗，清理已上傳的檔案
      try {
        await client.storage.from(bucketName).remove([fileName]);
      } catch (cleanupError) {
        print('清理檔案失敗: $cleanupError');
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

    // 5. 從 Storage 刪除平面圖
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
}
