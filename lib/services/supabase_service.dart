import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import '../models/photo_record.dart';

class SupabaseService {
  final SupabaseClient client;

  SupabaseService(this.client);

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
    };

    final response = await client
        .from('photo_records')
        .insert(recordData)
        .select()
        .single();

    return PhotoRecord.fromJson(response);
  }
}
