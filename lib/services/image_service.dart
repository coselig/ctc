import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  final _supabase = Supabase.instance.client;
  final _cache = <String, String>{};

  

  Future<String> getImageUrl(String fileName) async {
    if (_cache.containsKey(fileName)) {
      return _cache[fileName]!;
    }

    try {
      debugPrint('Fetching URL for $fileName from Supabase storage');
      final url = await _supabase.storage
          .from('assets')
          .createSignedUrl(fileName, 3600);

      _cache[fileName] = url;
      // debugPrint('Successfully generated URL for $fileName: $url');
      return url;
    } catch (e) {
      // debugPrint('Error getting URL for $fileName: $e');
      rethrow;
    }
  }

  Future<List<String>> getImageUrls(List<String> fileNames) async {
    final List<String> urls = [];
    for (var fileName in fileNames) {
      try {
        final url = await getImageUrl(fileName);
        urls.add(url);
      } catch (e) {
        // debugPrint('Error getting URL for $fileName: $e');
      }
    }
    return urls;
  }
}
