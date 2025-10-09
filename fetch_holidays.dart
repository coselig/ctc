import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// 從政府資料開放平台爬取國定假日資料
/// 資料來源：https://data.gov.tw/dataset/14718
/// 
/// 使用方式：
/// dart fetch_holidays.dart [year]
/// 
/// 範例：
/// dart fetch_holidays.dart 2025
/// 
/// 輸出：
/// - holidays_[year].json - JSON 格式的假日資料
/// - 更新 lib/services/holiday_service.dart 的程式碼片段

class HolidayFetcher {
  // 政府資料開放平台 API
  static const String apiUrl = 'https://data.gov.tw/api/v2/rest/datastore/301000000A-000082-053';
  
  Future<List<Map<String, dynamic>>> fetchHolidays(int year) async {
    print('正在從政府資料開放平台取得 $year 年國定假日資料...');
    
    try {
      // 構建查詢參數
      final uri = Uri.parse(apiUrl).replace(
        queryParameters: {
          'filters': '西元日期,gte,$year-01-01|西元日期,lte,$year-12-31',
          'limit': '100',
        },
      );
      
      print('API URL: $uri');
      
      // 發送 HTTP 請求
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        // 解析回應
        final data = json.decode(utf8.decode(response.bodyBytes));
        
        if (data['success'] == true && data['result'] != null) {
          final records = data['result']['records'] as List;
          print('成功取得 ${records.length} 筆假日資料');
          
          // 轉換資料格式
          final holidays = <Map<String, dynamic>>[];
          
          for (final record in records) {
            // 解析日期
            final dateStr = record['西元日期'] as String;
            
            // 假日名稱
            String name = record['假別'] as String? ?? record['備註'] as String? ?? '國定假日';
            
            // 是否為放假日
            final isHoliday = record['是否放假'] == '是' || record['是否放假'] == '1';
            
            if (isHoliday) {
              holidays.add({
                'date': dateStr,
                'name': name,
                'description': record['備註'] as String? ?? '',
              });
            }
          }
          
          return holidays;
        } else {
          print('API 回應錯誤: ${data['message'] ?? '未知錯誤'}');
          return [];
        }
      } else {
        print('HTTP 請求失敗: ${response.statusCode}');
        print('回應內容: ${response.body}');
        return [];
      }
    } catch (e) {
      print('取得假日資料時發生錯誤: $e');
      return [];
    }
  }
  
  /// 生成 Dart 程式碼
  String generateDartCode(int year, List<Map<String, dynamic>> holidays) {
    final buffer = StringBuffer();
    
    buffer.writeln('    $year: [');
    
    // 按月份分組
    final monthGroups = <int, List<Map<String, dynamic>>>{};
    for (final holiday in holidays) {
      final date = DateTime.parse(holiday['date'] as String);
      monthGroups.putIfAbsent(date.month, () => []).add(holiday);
    }
    
    // 生成程式碼
    final monthNames = {
      1: '元旦',
      2: '春節/和平紀念日',
      4: '兒童節/清明節',
      5: '勞動節/端午節',
      6: '端午節',
      9: '中秋節',
      10: '國慶日/中秋節',
    };
    
    for (final month in monthGroups.keys.toList()..sort()) {
      final holidaysInMonth = monthGroups[month]!;
      
      buffer.writeln('      // ${monthNames[month] ?? '$month 月'}');
      
      for (final holiday in holidaysInMonth) {
        final date = DateTime.parse(holiday['date'] as String);
        final name = holiday['name'] as String;
        
        buffer.writeln(
          "      Holiday(date: DateTime($year, ${date.month}, ${date.day}), name: '$name'),",
        );
      }
      buffer.writeln();
    }
    
    buffer.writeln('    ],');
    
    return buffer.toString();
  }
  
  /// 儲存為 JSON 檔案
  Future<void> saveToJson(int year, List<Map<String, dynamic>> holidays) async {
    final filename = 'holidays_$year.json';
    final file = File(filename);
    
    final jsonData = {
      'year': year,
      'count': holidays.length,
      'updated': DateTime.now().toIso8601String(),
      'holidays': holidays,
    };
    
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(jsonData),
    );
    
    print('已儲存至 $filename');
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
  
  print('=' * 60);
  print('台灣國定假日資料爬取工具');
  print('=' * 60);
  print('年份: $year');
  print('資料來源: 政府資料開放平台');
  print('=' * 60);
  print('');
  
  final fetcher = HolidayFetcher();
  
  // 取得假日資料
  final holidays = await fetcher.fetchHolidays(year);
  
  if (holidays.isEmpty) {
    print('未取得任何假日資料');
    exit(1);
  }
  
  print('');
  print('假日列表:');
  print('-' * 60);
  for (final holiday in holidays) {
    print('${holiday['date']} - ${holiday['name']}');
  }
  print('-' * 60);
  print('');
  
  // 儲存為 JSON
  await fetcher.saveToJson(year, holidays);
  
  // 生成 Dart 程式碼
  print('');
  print('Dart 程式碼片段:');
  print('=' * 60);
  print(fetcher.generateDartCode(year, holidays));
  print('=' * 60);
  print('');
  print('請將上述程式碼複製到 lib/services/holiday_service.dart 的 _holidays Map 中');
  print('');
}
