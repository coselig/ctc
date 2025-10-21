import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// 從政府網站下載國定假日 CSV 並匯入 Supabase
/// 
/// 使用方式：
/// dart import_holidays_to_db.dart [year]
/// 
/// 範例：
/// dart import_holidays_to_db.dart 2025

class HolidayImporter {
  final SupabaseClient supabase;
  
  HolidayImporter(this.supabase);
  
  /// 政府資料開放平台 CSV 下載連結
  /// 需要從網站上手動取得正確的下載連結
  Map<int, String> get csvUrls => {
    2024: 'https://www.dgpa.gov.tw/FileConversion?filename=dgpa/files/202407/777152e9-fdd1-4a61-876c-2733e7692538.csv&nfix=&name=113%E5%B9%B4%E4%B8%AD%E8%8F%AF%E6%B0%91%E5%9C%8B%E6%94%BF%E5%BA%9C%E8%A1%8C%E6%94%BF%E6%A9%9F%E9%97%9C%E8%BE%A6%E5%85%AC%E6%97%A5%E6%9B%86%E8%A1%A8.csv',
    2025: 'https://www.dgpa.gov.tw/FileConversion?filename=dgpa/files/202407/22f9fcbc-fbb2-4387-8bcf-73b2279666c2.csv&nfix=&name=114%E5%B9%B4%E4%B8%AD%E8%8F%AF%E6%B0%91%E5%9C%8B%E6%94%BF%E5%BA%9C%E8%A1%8C%E6%94%BF%E6%A9%9F%E9%97%9C%E8%BE%A6%E5%85%AC%E6%97%A5%E6%9B%86%E8%A1%A8.csv',
  };
  
  /// 下載 CSV 檔案
  Future<String?> downloadCsv(int year) async {
    final url = csvUrls[year];
    if (url == null) {
      print('❌ 未找到 $year 年的 CSV 下載連結');
      return null;
    }
    
    print('📥 正在下載 $year 年國定假日 CSV 檔案...');
    print('URL: $url');
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        // 嘗試使用 UTF-8 解碼，如果失敗則使用 Big5
        String content;
        try {
          content = utf8.decode(response.bodyBytes);
        } catch (e) {
          // 如果 UTF-8 解碼失敗，可能是 Big5 編碼
          print('⚠️  UTF-8 解碼失敗，嘗試使用 Big5 編碼...');
          // 注意：Dart 標準庫不支援 Big5，需要使用 latin1 作為替代
          content = latin1.decode(response.bodyBytes);
        }
        
        print('✅ 下載成功！檔案大小: ${response.bodyBytes.length} bytes');
        return content;
      } else {
        print('❌ HTTP 請求失敗: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ 下載失敗: $e');
      return null;
    }
  }
  
  /// 解析 CSV 內容
  List<Map<String, dynamic>> parseCsv(String csvContent, int year) {
    print('\n📋 正在解析 CSV 內容...');
    
    final lines = csvContent.split('\n');
    if (lines.isEmpty) {
      print('❌ CSV 檔案為空');
      return [];
    }
    
    // 解析標題行
    final headers = lines[0].split(',').map((h) => h.trim()).toList();
    print('CSV 欄位: $headers');
    
    final holidays = <Map<String, dynamic>>[];
    
    // 解析資料行
    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      
      final values = line.split(',').map((v) => v.trim()).toList();
      if (values.length < headers.length) continue;
      
      // 建立資料對應
      final row = <String, String>{};
      for (var j = 0; j < headers.length && j < values.length; j++) {
        row[headers[j]] = values[j];
      }
      
      // 提取所需欄位
      final dateStr = row['西元日期'] ?? row['日期'] ?? '';
      final isHoliday = row['是否放假'] == '是' || row['是否放假'] == '1' || row['是否放假'] == '2';
      final description = row['備註'] ?? '';
      
      // 假日名稱可能在不同欄位
      String name = row['假別'] ?? row['名稱'] ?? '';
      if (name.isEmpty && description.isNotEmpty) {
        name = description.split('(').first.trim();
      }
      
      if (dateStr.isNotEmpty && isHoliday && name.isNotEmpty) {
        try {
          DateTime.parse(dateStr); // 驗證日期格式
          holidays.add({
            'date': dateStr,
            'name': name,
            'year': year,
            'description': description,
            'is_workday': false,
          });
        } catch (e) {
          print('⚠️  無法解析日期: $dateStr');
        }
      }
    }
    
    print('✅ 解析完成！找到 ${holidays.length} 筆假日資料');
    return holidays;
  }
  
  /// 匯入資料到 Supabase
  Future<bool> importToDatabase(List<Map<String, dynamic>> holidays) async {
    if (holidays.isEmpty) {
      print('❌ 沒有資料可以匯入');
      return false;
    }
    
    print('\n💾 正在匯入資料到 Supabase...');
    
    try {
      // 使用 upsert 來避免重複資料
      await supabase.from('holidays').upsert(
        holidays,
        onConflict: 'date', // 如果日期重複，則更新
      );
      
      print('✅ 成功匯入 ${holidays.length} 筆假日資料！');
      return true;
    } catch (e) {
      print('❌ 匯入失敗: $e');
      return false;
    }
  }
  
  /// 執行完整的匯入流程
  Future<bool> run(int year) async {
    print('=' * 60);
    print('國定假日資料自動匯入工具');
    print('=' * 60);
    print('年份: $year');
    print('目標: Supabase 資料庫');
    print('=' * 60);
    print('');
    
    // 1. 下載 CSV
    final csvContent = await downloadCsv(year);
    if (csvContent == null) {
      print('\n❌ 下載失敗，無法繼續');
      return false;
    }
    
    // 2. 解析 CSV
    final holidays = parseCsv(csvContent, year);
    if (holidays.isEmpty) {
      print('\n❌ 解析失敗，沒有找到假日資料');
      return false;
    }
    
    // 3. 顯示資料預覽
    print('\n📅 假日列表預覽:');
    print('-' * 60);
    for (final holiday in holidays) {
      print('${holiday['date']} - ${holiday['name']}');
    }
    print('-' * 60);
    
    // 4. 匯入資料庫
    final success = await importToDatabase(holidays);
    
    if (success) {
      print('\n✨ 完成！資料已成功匯入資料庫');
      print('');
      print('📊 統計資訊:');
      print('  - 年份: $year');
      print('  - 假日數量: ${holidays.length}');
      print('  - 資料表: holidays');
      print('');
    }
    
    return success;
  }
}

void main(List<String> args) async {
  // 取得年份參數
  int year;
  if (args.isNotEmpty) {
    year = int.tryParse(args[0]) ?? DateTime.now().year;
  } else {
    year = DateTime.now().year;
  }
  
  // 初始化 Supabase
  print('🔧 正在初始化 Supabase...');
  
  // 從環境變數讀取 Supabase 設定
  final supabaseUrl = Platform.environment['SUPABASE_URL'] ?? 
                      'https://coselig.com/api';
  final supabaseKey = Platform.environment['SUPABASE_KEY'] ?? 
                      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJhbm9uIiwKICAgICJpc3MiOiAic3VwYWJhc2UtZGVtbyIsCiAgICAiaWF0IjogMTY0MTc2OTIwMCwKICAgICJleHAiOiAxNzk5NTM1NjAwCn0.dc_X5iR_VP_qT0zsiyj_I_OZ2T9FtRU2BBNWN8Bu4GE';
  
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );
  
  print('✅ Supabase 初始化完成');
  print('');
  
  // 執行匯入
  final importer = HolidayImporter(Supabase.instance.client);
  final success = await importer.run(year);
  
  // 結束程式
  exit(success ? 0 : 1);
}
