import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FloorPlansService {
  final SupabaseClient supabase;
  FloorPlansService(this.supabase);

  /// 清理檔名，移除中文字符、空格和特殊字符
  String _sanitizeFileName(String fileName) {
    // 取得檔案擴展名
    final lastDotIndex = fileName.lastIndexOf('.');
    String name = fileName;
    String extension = '';

    if (lastDotIndex != -1) {
      name = fileName.substring(0, lastDotIndex);
      extension = fileName.substring(lastDotIndex);
    }

    // 移除或替換不安全字符
    name = name
        .replaceAll(RegExp(r'[^\x00-\x7F]'), '') // 移除非ASCII字符（包含中文）
        .replaceAll(RegExp(r'[\s\-_]+'), '_') // 將空格、連字符轉為底線
        .replaceAll(RegExp(r'[^\w\.]'), '') // 只保留字母、數字、底線和點
        .replaceAll(RegExp(r'_+'), '_') // 將多個底線合併為一個
        .replaceAll(RegExp(r'^_|_$'), ''); // 移除開頭和結尾的底線

    // 如果名稱為空或太短，使用預設名稱
    if (name.isEmpty || name.length < 2) {
      name = 'floor_plan';
    }

    // 限制檔名長度
    if (name.length > 50) {
      name = name.substring(0, 50);
    }

    return '$name$extension';
  }

  /// 上傳圖片到 Supabase Storage (移動平台專用)
  Future<String> uploadFloorPlanImage(File imageFile, String fileName) async {
    if (kIsWeb) {
      throw UnsupportedError('請在Web平台使用 uploadFloorPlanImageFromBytes 方法');
    }

    try {
      // 清理檔名，移除不安全字符
      final sanitizedFileName = _sanitizeFileName(fileName);

      // 生成唯一的檔案名稱
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_$sanitizedFileName';

      print('原檔名: $fileName');
      print('清理後檔名: $sanitizedFileName');
      print('最終檔名: $uniqueFileName');

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
      // 清理檔名，移除不安全字符
      final sanitizedFileName = _sanitizeFileName(fileName);

      // 生成唯一的檔案名稱
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_$sanitizedFileName';

      print('原檔名: $fileName');
      print('清理後檔名: $sanitizedFileName');
      print('最終檔名: $uniqueFileName');

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

  /// 創建設計圖記錄（只創建資料庫記錄，需要提供圖片URL）
  Future<Map<String, dynamic>> createFloorPlanRecord({
    required String name,
    required String imageUrl,
  }) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('請先登入');
      }

      // 確保 imageUrl 不為空
      if (imageUrl.isEmpty) {
        throw Exception('圖片URL不能為空');
      }

      print('創建設計圖記錄：name=$name, imageUrl=$imageUrl, userId=${user.id}');

      // 創建資料庫記錄，讓資料庫自動生成UUID
      final response = await supabase
          .from('floor_plans')
          .insert({'name': name, 'image_url': imageUrl, 'user_id': user.id})
          .select()
          .single();

      print('設計圖創建成功：${response['id']}');
      return response;
    } catch (e) {
      print('創建設計圖失敗: $e');
      throw Exception('創建設計圖失敗: $e');
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

      // 確保有圖片URL
      if (imageUrl == null || imageUrl.isEmpty) {
        throw Exception('必須提供圖片');
      }

      // 使用新的方法創建記錄
      return await createFloorPlanRecord(name: name, imageUrl: imageUrl);
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

  /// 獲取當前用戶的設計圖列表
  Future<List<Map<String, dynamic>>> getUserFloorPlans() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('請先登入');
      }

      final response = await supabase
          .from('floor_plans')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('獲取設計圖列表失敗: $e');
      throw Exception('獲取設計圖列表失敗: $e');
    }
  }

  /// 根據 ID 獲取特定設計圖
  Future<Map<String, dynamic>?> getFloorPlanById(String id) async {
    try {
      final response = await supabase
          .from('floor_plans')
          .select('*')
          .eq('id', id)
          .maybeSingle();

      return response;
    } catch (e) {
      print('獲取設計圖失敗: $e');
      return null;
    }
  }

  /// 更新設計圖名稱
  Future<void> updateFloorPlanName(String id, String newName) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('請先登入');
      }

      if (newName.trim().isEmpty) {
        throw Exception('設計圖名稱不能為空');
      }

      print('更新設計圖名稱: $id -> $newName');

      await supabase
          .from('floor_plans')
          .update({
            'name': newName.trim(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .eq('user_id', user.id); // 只能更新自己的設計圖

      print('設計圖名稱更新成功');
    } catch (e) {
      print('更新設計圖名稱失敗: $e');
      throw Exception('更新設計圖名稱失敗: $e');
    }
  }

  /// 刪除設計圖（包含圖片）
  Future<void> deleteFloorPlan(String id) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('請先登入');
      }

      // 先獲取設計圖資訊並檢查權限
      final floorPlan = await supabase
          .from('floor_plans')
          .select('*')
          .eq('id', id)
          .eq('user_id', user.id) // 只能刪除自己的設計圖
          .maybeSingle();

      if (floorPlan == null) {
        throw Exception('找不到指定的設計圖或無權限刪除');
      }

      print('開始刪除設計圖: $id (${floorPlan['name']})');

      // 刪除相關的照片記錄（只刪除該用戶的記錄）
      await supabase
          .from('photo_records')
          .delete()
          .eq('floor_plan_id', id)
          .eq('user_id', user.id);

      // 刪除設計圖記錄（只能刪除自己的）
      await supabase
          .from('floor_plans')
          .delete()
          .eq('id', id)
          .eq('user_id', user.id);

      // 刪除圖片檔案
      final imageUrl = floorPlan['image_url'] as String?;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await deleteFloorPlanImage(imageUrl);
      }
    } catch (e) {
      print('刪除設計圖失敗: $e');
      throw Exception('刪除設計圖失敗: $e');
    }
  }

  Future<void> createFloorPlanFile() async {}
}
