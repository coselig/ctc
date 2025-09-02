import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  final _supabase = Supabase.instance.client;
  final _cache = <String, String>{};
  final _widthCache = <String, int>{};
  final _heightCache = <String, int>{};

  Future<String> getImageUrl(String fileName) async {
    if (_cache.containsKey(fileName)) {
      return _cache[fileName]!;
    }
    try {
      final url = await _supabase.storage
          .from('assets')
          .createSignedUrl(fileName, 3600);
      _cache[fileName] = url;
      return url;
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getImageWidth(String fileName) async {
    // 檢查緩存中是否已有圖片寬度
    if (_widthCache.containsKey(fileName)) {
      return _widthCache[fileName]!;
    }

    // 如果沒有緩存，獲取完整尺寸並返回寬度
    final dimensions = await getImageDimensions(fileName);
    return dimensions.width;
  }

  Future<int> getImageHeight(String fileName) async {
    // 檢查緩存中是否已有圖片高度
    if (_heightCache.containsKey(fileName)) {
      return _heightCache[fileName]!;
    }

    // 如果沒有緩存，獲取完整尺寸並返回高度
    final dimensions = await getImageDimensions(fileName);
    return dimensions.height;
  }

  Future<({int width, int height})> getImageDimensions(String fileName) async {
    // 檢查緩存中是否已有圖片尺寸
    if (_widthCache.containsKey(fileName) &&
        _heightCache.containsKey(fileName)) {
      return (width: _widthCache[fileName]!, height: _heightCache[fileName]!);
    }

    try {
      // 獲取圖片 URL
      final imageUrl = await getImageUrl(fileName);

      // 下載圖片數據
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to load image');
      }

      final Uint8List bytes = response.bodyBytes;

      // 解碼圖片以獲取尺寸
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      // 獲取圖片寬度和高度
      final width = image.width;
      final height = image.height;
      image.dispose();

      // 將尺寸存入緩存
      _widthCache[fileName] = width;
      _heightCache[fileName] = height;

      return (width: width, height: height);
    } catch (e) {
      throw Exception('Failed to get image dimensions: $e');
    }
  }

  Future<List<String>> getImageUrls(List<String> fileNames) async {
    final List<String> urls = [];
    for (var fileName in fileNames) {
      try {
        final url = await getImageUrl(fileName);
        urls.add(url);
      } catch (ignore) {}
    }
    return urls;
  }
}
