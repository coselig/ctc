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
}
