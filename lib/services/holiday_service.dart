import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 國定假日資料
class Holiday {
  final DateTime date;
  final String name;
  final String? description;
  final Color color;

  Holiday({
    required this.date,
    required this.name,
    this.description,
    this.color = Colors.red,
  });
  
  /// 從資料庫記錄建立 Holiday 物件
  factory Holiday.fromDatabase(Map<String, dynamic> data) {
    return Holiday(
      date: DateTime.parse(data['date'] as String),
      name: data['name'] as String,
      description: data['description'] as String?,
      color: Colors.red,
    );
  }
}

/// 國定假日服務
class HolidayService {
  final SupabaseClient? _supabase;

  /// 資料庫載入的假日快取
  static final Map<int, List<Holiday>> _databaseCache = {};

  /// 是否已從資料庫載入
  static bool _isLoadedFromDatabase = false;

  HolidayService([SupabaseClient? supabase]) : _supabase = supabase;

  /// 台灣國定假日（靜態備份資料，當資料庫無法連線時使用）
  static final Map<int, List<Holiday>> _fallbackHolidays = {
    2025: [
      // 元旦
      Holiday(date: DateTime(2025, 1, 1), name: '中華民國開國紀念日'),
      
      // 農曆春節
      Holiday(date: DateTime(2025, 1, 27), name: '農曆除夕'),
      Holiday(date: DateTime(2025, 1, 28), name: '春節'),
      Holiday(date: DateTime(2025, 1, 29), name: '春節'),
      Holiday(date: DateTime(2025, 1, 30), name: '春節'),
      Holiday(date: DateTime(2025, 1, 31), name: '春節'),
      
      // 和平紀念日
      Holiday(date: DateTime(2025, 2, 28), name: '和平紀念日'),
      
      // 兒童節、民族掃墓節
      Holiday(date: DateTime(2025, 4, 4), name: '兒童節及民族掃墓節'),
      Holiday(date: DateTime(2025, 4, 5), name: '民族掃墓節補假'),
      
      // 勞動節
      Holiday(date: DateTime(2025, 5, 1), name: '勞動節'),
      
      // 端午節
      Holiday(date: DateTime(2025, 5, 31), name: '端午節'),
      
      // 中秋節
      Holiday(date: DateTime(2025, 10, 6), name: '中秋節'),
      
      // 國慶日
      Holiday(date: DateTime(2025, 10, 10), name: '國慶日'),
    ],
    2024: [
      // 元旦
      Holiday(date: DateTime(2024, 1, 1), name: '中華民國開國紀念日'),
      
      // 農曆春節
      Holiday(date: DateTime(2024, 2, 8), name: '農曆除夕'),
      Holiday(date: DateTime(2024, 2, 9), name: '春節'),
      Holiday(date: DateTime(2024, 2, 10), name: '春節'),
      Holiday(date: DateTime(2024, 2, 11), name: '春節'),
      Holiday(date: DateTime(2024, 2, 12), name: '春節'),
      Holiday(date: DateTime(2024, 2, 13), name: '春節'),
      Holiday(date: DateTime(2024, 2, 14), name: '春節補假'),
      
      // 和平紀念日
      Holiday(date: DateTime(2024, 2, 28), name: '和平紀念日'),
      
      // 兒童節、民族掃墓節
      Holiday(date: DateTime(2024, 4, 4), name: '兒童節及民族掃墓節'),
      Holiday(date: DateTime(2024, 4, 5), name: '民族掃墓節'),
      
      // 勞動節
      Holiday(date: DateTime(2024, 5, 1), name: '勞動節'),
      
      // 端午節
      Holiday(date: DateTime(2024, 6, 10), name: '端午節'),
      
      // 中秋節
      Holiday(date: DateTime(2024, 9, 17), name: '中秋節'),
      
      // 國慶日
      Holiday(date: DateTime(2024, 10, 10), name: '國慶日'),
    ],
  };

  /// 從資料庫載入假日資料
  Future<void> loadFromDatabase() async {
    if (_supabase == null) return;
    if (_isLoadedFromDatabase) return; // 避免重複載入

    try {
      print('📥 正在從資料庫載入國定假日資料...');

      final response = await _supabase
          .from('holidays')
          .select()
          .eq('is_workday', false)
          .order('date', ascending: true);

      final data = response as List<dynamic>;

      // 清空快取
      _databaseCache.clear();

      // 按年份分組
      for (final item in data) {
        final holiday = Holiday.fromDatabase(item as Map<String, dynamic>);
        final year = holiday.date.year;
        _databaseCache.putIfAbsent(year, () => []).add(holiday);
      }

      _isLoadedFromDatabase = true;
      print('✅ 成功載入 ${data.length} 筆假日資料，涵蓋 ${_databaseCache.length} 個年度');
    } catch (e) {
      print('⚠️  從資料庫載入假日失敗: $e');
      print('   將使用內建的備份資料');
    }
  }

  /// 獲取假日資料（優先從資料庫快取，其次使用備份資料）
  Map<int, List<Holiday>> get _holidays {
    if (_databaseCache.isNotEmpty) {
      return _databaseCache;
    }
    return _fallbackHolidays;
  }
  
  /// 獲取指定年份的所有國定假日
  Future<List<Holiday>> getHolidays(int year) async {
    // 如果還沒從資料庫載入，先載入
    if (!_isLoadedFromDatabase && _supabase != null) {
      await loadFromDatabase();
    }
    return _holidays[year] ?? [];
  }

  /// 檢查指定日期是否為國定假日（同步版本，使用快取）
  Holiday? isHoliday(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final yearHolidays = _holidays[date.year] ?? [];
    
    for (final holiday in yearHolidays) {
      final holidayDate = DateTime(holiday.date.year, holiday.date.month, holiday.date.day);
      if (normalizedDate.isAtSameMomentAs(holidayDate)) {
        return holiday;
      }
    }
    return null;
  }

  /// 計算期間內的國定假日工作日數量（排除週末）
  int getWorkdayHolidayCount(DateTime startDate, DateTime endDate) {
    int count = 0;
    final yearHolidays = _holidays[startDate.year] ?? [];
    
    for (final holiday in yearHolidays) {
      final holidayDate = holiday.date;
      
      // 檢查假日是否在範圍內
      if ((holidayDate.isAfter(startDate) || holidayDate.isAtSameMomentAs(startDate)) &&
          (holidayDate.isBefore(endDate) || holidayDate.isAtSameMomentAs(endDate))) {
        // 只計算平日的國定假日（週一到週五）
        if (holidayDate.weekday >= 1 && holidayDate.weekday <= 5) {
          count++;
        }
      }
    }
    
    // 如果跨年，也要檢查下一年的假日
    if (startDate.year != endDate.year) {
      final nextYearHolidays = _holidays[endDate.year] ?? [];
      for (final holiday in nextYearHolidays) {
        final holidayDate = holiday.date;
        
        if ((holidayDate.isAfter(startDate) || holidayDate.isAtSameMomentAs(startDate)) &&
            (holidayDate.isBefore(endDate) || holidayDate.isAtSameMomentAs(endDate))) {
          if (holidayDate.weekday >= 1 && holidayDate.weekday <= 5) {
            count++;
          }
        }
      }
    }
    
    return count;
  }

  /// 獲取指定月份的所有國定假日
  List<Holiday> getMonthHolidays(int year, int month) {
    final yearHolidays = _holidays[year] ?? [];
    return yearHolidays.where((holiday) {
      return holiday.date.year == year && holiday.date.month == month;
    }).toList();
  }
}
