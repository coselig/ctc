import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/photo_record.dart';

class PhotoRecordService {
  final SupabaseClient _client;
  PhotoRecordService(this._client);

  Future<PhotoRecord> read(String id) async {
    try {
      final response = await _client
          .from('photo_records')
          .select('*')
          .eq('id', id)
          .maybeSingle();

      return response != null
          ? PhotoRecord.fromJson(response)
          : throw Exception('找不到照片記錄 ID: $id');
    } catch (e) {
      print('讀取照片記錄失敗: $e');
      rethrow;
    }
  }

  Future<PhotoRecord> create(PhotoRecord record) async {
    try {
      // 確保用戶已登入
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('必須登入才能創建照片記錄');
      }

      record.userId = user.id;

      // 準備要插入的數據，移除 id 欄位
      final dataToInsert = record.toJson()..remove('id');

      print('準備插入的數據：$dataToInsert'); // 調試用

      final response = await _client
          .from('photo_records')
          .insert(dataToInsert) // 使用不包含 id 的數據
          .select()
          .single();

      print('創建照片記錄成功: ${response['id']}');
      return PhotoRecord.fromJson(response);
    } catch (e) {
      print('創建照片記錄失敗: $e');
      print('Current auth status:');
      print('User ID: ${_client.auth.currentUser?.id}');
      print('Has valid session: ${_client.auth.currentSession != null}');
      print('Token expiry: ${_client.auth.currentSession?.expiresAt}');
      rethrow;
    }
  }
}
