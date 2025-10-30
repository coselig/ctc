import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/company_location.dart';

/// 公司位置管理服務
class CompanyLocationService {
  static const String _companyLocationKey = 'company_location';
  
  /// 獲取當前公司位置設定
  static Future<CompanyLocation> getCurrentCompanyLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationJson = prefs.getString(_companyLocationKey);
      
      if (locationJson != null) {
        final Map<String, dynamic> json = jsonDecode(locationJson);
        return CompanyLocation.fromJson(json);
      }
    } catch (e) {
      print('Error loading company location: $e');
    }
    
    // 返回預設位置
    return const CompanyLocation(
      name: CompanyLocationConfig.defaultCompanyName,
      address: '台北市信義區',
      latitude: CompanyLocationConfig.defaultLatitude,
      longitude: CompanyLocationConfig.defaultLongitude,
      radius: CompanyLocationConfig.defaultRadius,
    );
  }
  
  /// 儲存公司位置設定
  static Future<bool> saveCompanyLocation(CompanyLocation location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationJson = jsonEncode(location.toJson());
      return await prefs.setString(_companyLocationKey, locationJson);
    } catch (e) {
      print('Error saving company location: $e');
      return false;
    }
  }
  
  /// 重設為預設位置
  static Future<bool> resetToDefault() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_companyLocationKey);
    } catch (e) {
      print('Error resetting company location: $e');
      return false;
    }
  }
  
  /// 獲取所有預定義位置
  static List<CompanyLocation> getPredefinedLocations() {
    return CompanyLocationConfig.predefinedLocations;
  }
}