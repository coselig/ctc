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
    const bucketName = 'floor_plans';
    
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

    final publicUrl = client.storage
        .from(bucketName)
        .getPublicUrl(fileName);

    // 儲存設計圖記錄到資料庫
    await client.from('floor_plans').insert({
      'name': name,
      'image_url': publicUrl,
      'user_id': currentUser.id,
      'created_at': timestamp.toIso8601String(),
    });

    return publicUrl;
  }

  Future<List<Map<String, dynamic>>> loadFloorPlans() async {
    final response = await client
        .from('floor_plans')
        .select()
        .order('created_at');

    return (response as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<List<PhotoRecord>> loadRecords() async {
    final response = await client
        .from('photo_records')
        .select()
        .order('created_at');

    return (response as List<dynamic>)
        .map((record) => PhotoRecord.fromJson(record))
        .toList();
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
        .from('site_photos')
        .uploadBinary(
          userFilePath,
          photoBytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    final publicUrl = client.storage
        .from('site_photos')
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

    return PhotoRecord.fromJson(response);
  }
}
