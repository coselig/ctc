import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PhotoUploadService {
  final SupabaseClient supabase;
  final ImagePicker _picker = ImagePicker();

  PhotoUploadService(this.supabase);

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
      name = 'photo';
    }
    
    // 限制檔名長度
    if (name.length > 50) {
      name = name.substring(0, 50);
    }
    
    return '$name$extension';
  }

  /// 上傳照片到 Supabase Storage (移動平台專用)
  Future<String> uploadPhoto(File imageFile, String fileName) async {
    if (kIsWeb) {
      throw UnsupportedError('請在Web平台使用 uploadPhotoFromBytes 方法');
    }

    try {
      // 清理檔名，移除不安全字符
      final sanitizedFileName = _sanitizeFileName(fileName);
      
      // 生成唯一的檔案名稱
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_$sanitizedFileName';

      print('照片上傳：原檔名=$fileName, 清理後=$sanitizedFileName, 最終=$uniqueFileName');

      // 上傳照片到 assets/photos/ bucket
      await supabase.storage
          .from('assets')
          .upload('photos/$uniqueFileName', imageFile);

      // 獲取公開URL
      final imageUrl = supabase.storage
          .from('assets')
          .getPublicUrl('photos/$uniqueFileName');

      return imageUrl;
    } catch (e) {
      print('上傳照片失敗: $e');
      throw Exception('上傳照片失敗: $e');
    }
  }

  /// 上傳照片（從Uint8List）- 適用於Web平台
  Future<String> uploadPhotoFromBytes(
    Uint8List imageBytes,
    String fileName,
  ) async {
    try {
      // 清理檔名，移除不安全字符
      final sanitizedFileName = _sanitizeFileName(fileName);
      
      // 生成唯一的檔案名稱
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_$sanitizedFileName';

      print('照片上傳：原檔名=$fileName, 清理後=$sanitizedFileName, 最終=$uniqueFileName');

      await supabase.storage
          .from('assets')
          .uploadBinary('photos/$uniqueFileName', imageBytes);

      final imageUrl = supabase.storage
          .from('assets')
          .getPublicUrl('photos/$uniqueFileName');

      return imageUrl;
    } catch (e) {
      print('上傳照片失敗: $e');
      throw Exception('上傳照片失敗: $e');
    }
  }

  /// 從相機拍攝照片並上傳
  Future<String?> takePhotoAndUpload() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 80,
      );

      if (image == null) return null;

      // 根據平台選擇上傳方式
      if (kIsWeb) {
        final imageBytes = await image.readAsBytes();
        return await uploadPhotoFromBytes(imageBytes, image.name);
      } else {
        final imageFile = File(image.path);
        return await uploadPhoto(imageFile, image.name);
      }
    } catch (e) {
      print('拍照並上傳失敗: $e');
      throw Exception('拍照並上傳失敗: $e');
    }
  }

  /// 從圖庫選擇照片並上傳
  Future<String?> pickPhotoAndUpload() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 80,
      );

      if (image == null) return null;

      // 根據平台選擇上傳方式
      if (kIsWeb) {
        final imageBytes = await image.readAsBytes();
        return await uploadPhotoFromBytes(imageBytes, image.name);
      } else {
        final imageFile = File(image.path);
        return await uploadPhoto(imageFile, image.name);
      }
    } catch (e) {
      print('選擇並上傳照片失敗: $e');
      throw Exception('選擇並上傳照片失敗: $e');
    }
  }

  /// 顯示照片來源選擇對話框並上傳
  static Future<String?> showPhotoSourceDialog(
    BuildContext context,
    PhotoUploadService service,
  ) async {
    return showDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('選擇照片來源'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('拍照'),
                onTap: () async {
                  Navigator.of(context).pop('camera');
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('從圖庫選擇'),
                onTap: () async {
                  Navigator.of(context).pop('gallery');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
          ],
        );
      },
    ).then((result) async {
      if (result == null) return null;
      
      try {
        if (result == 'camera') {
          return await service.takePhotoAndUpload();
        } else if (result == 'gallery') {
          return await service.pickPhotoAndUpload();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('照片上傳失敗: $e')),
          );
        }
      }
      return null;
    });
  }
}