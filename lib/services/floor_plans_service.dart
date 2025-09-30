import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FloorPlansService {
  final SupabaseClient supabase;
  FloorPlansService(this.supabase);

  /// 上傳圖片到 Supabase Storage (移動平台專用)
  Future<String> uploadFloorPlanImage(File imageFile, String fileName) async {
    if (kIsWeb) {
      throw UnsupportedError('請在Web平台使用 uploadFloorPlanImageFromBytes 方法');
    }

    try {
      // 生成唯一的檔案名稱（如果需要）
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_$fileName';

      // 上傳圖片到 assets/floor_plans/ bucket
      await supabase.storage
          .from('assets')
          .upload('floor_plans/$uniqueFileName', imageFile);

      // 獲取公開URL
      final imageUrl = supabase.storage
          .from('assets')
          .getPublicUrl('floor_plans/$uniqueFileName');

      return imageUrl;
    } catch (e) {
      print('上傳圖片失敗: $e');
      throw Exception('上傳圖片失敗: $e');
    }
  }

  /// 上傳圖片（從Uint8List）- 適用於Web平台
  Future<String> uploadFloorPlanImageFromBytes(
    Uint8List imageBytes,
    String fileName,
  ) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_$fileName';

      await supabase.storage
          .from('assets')
          .uploadBinary('floor_plans/$uniqueFileName', imageBytes);

      final imageUrl = supabase.storage
          .from('assets')
          .getPublicUrl('floor_plans/$uniqueFileName');

      return imageUrl;
    } catch (e) {
      print('上傳圖片失敗: $e');
      throw Exception('上傳圖片失敗: $e');
    }
  }

  /// 從相機或圖庫選擇圖片並上傳
  Future<String?> pickAndUploadImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 80,
      );

      if (image == null) return null;

      // 根據平台選擇上傳方式
      if (kIsWeb) {
        // Web平台使用bytes
        final imageBytes = await image.readAsBytes();
        return await uploadFloorPlanImageFromBytes(imageBytes, image.name);
      } else {
        // 移動平台使用File
        final imageFile = File(image.path);
        return await uploadFloorPlanImage(imageFile, image.name);
      }
    } catch (e) {
      print('選擇並上傳圖片失敗: $e');
      throw Exception('選擇並上傳圖片失敗: $e');
    }
  }

  /// 刪除Storage中的圖片
  Future<void> deleteFloorPlanImage(String imageUrl) async {
    try {
      // 從URL中提取檔案路徑
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      // 找到 'floor_plans/' 之後的路徑
      final floorPlansIndex = pathSegments.indexOf('floor_plans');
      if (floorPlansIndex != -1 && floorPlansIndex < pathSegments.length - 1) {
        final fileName = pathSegments[floorPlansIndex + 1];

        await supabase.storage.from('assets').remove(['floor_plans/$fileName']);
      }
    } catch (e) {
      print('刪除圖片失敗: $e');
      throw Exception('刪除圖片失敗: $e');
    }
  }

  /// 創建設計圖記錄（包含圖片上傳）
  Future<Map<String, dynamic>> createFloorPlanWithImage({
    required String name,
    File? imageFile,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    try {
      String? imageUrl;

      // 如果提供了圖片，先上傳
      if (kIsWeb) {
        if (imageBytes != null && fileName != null) {
          imageUrl = await uploadFloorPlanImageFromBytes(imageBytes, fileName);
        }
      } else {
        if (imageFile != null && fileName != null) {
          imageUrl = await uploadFloorPlanImage(imageFile, fileName);
        }
      }

      // 創建資料庫記錄
      final response = await supabase
          .from('floor_plans')
          .insert({
            'name': name,
            'image_url': imageUrl ?? '',
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return response;
    } catch (e) {
      print('創建設計圖失敗: $e');
      throw Exception('創建設計圖失敗: $e');
    }
  }

  /// 更新設計圖的圖片
  Future<void> updateFloorPlanImage(
    int floorPlanId,
    dynamic imageData, // File 或 Uint8List
    String fileName,
  ) async {
    try {
      // 先獲取舊的圖片URL（用於後續刪除）
      final oldRecord = await supabase
          .from('floor_plans')
          .select('image_url')
          .eq('id', floorPlanId)
          .single();

      // 上傳新圖片
      String newImageUrl;
      if (kIsWeb && imageData is Uint8List) {
        newImageUrl = await uploadFloorPlanImageFromBytes(imageData, fileName);
      } else if (!kIsWeb && imageData is File) {
        newImageUrl = await uploadFloorPlanImage(imageData, fileName);
      } else {
        throw Exception('不支援的圖片資料類型');
      }

      // 更新資料庫記錄
      await supabase
          .from('floor_plans')
          .update({
            'image_url': newImageUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', floorPlanId);

      // 刪除舊圖片（如果存在）
      final oldImageUrl = oldRecord['image_url'] as String?;
      if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
        await deleteFloorPlanImage(oldImageUrl);
      }
    } catch (e) {
      print('更新設計圖圖片失敗: $e');
      throw Exception('更新設計圖圖片失敗: $e');
    }
  }

  Future<void> createFloorPlanFile() async {}
}
