import 'dart:convert';
import 'package:flutter/services.dart';

class VersionUtil {
  static Future<String> getVersionString() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/version.json');
      final jsonMap = json.decode(jsonStr);
      final version = jsonMap['version'] ?? '';
      final build = jsonMap['build_number'] ?? '';
      return 'v$version+$build';
    } catch (e) {
      return '';
    }
  }
}
