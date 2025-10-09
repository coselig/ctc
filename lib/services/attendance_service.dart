import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/attendance_record.dart';
import '../models/employee.dart';
import 'holiday_service.dart';

/// 打卡記錄服務類
class AttendanceService {
  const AttendanceService(this._client);

  final SupabaseClient _client;

  /// 獲取所有打卡記錄
  Future<List<AttendanceRecord>> getAllAttendanceRecords({
    String? employeeId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    try {
      var queryBuilder = _client.from('attendance_records').select('*');

      // 根據員工ID篩選
      if (employeeId != null) {
        queryBuilder = queryBuilder.eq('employee_id', employeeId);
      }

      // 根據日期範圍篩選
      if (startDate != null) {
        queryBuilder = queryBuilder.gte('check_in_time', startDate.toIso8601String());
      }
      if (endDate != null) {
        queryBuilder = queryBuilder.lte('check_in_time', endDate.toIso8601String());
      }

      // 應用排序
      var orderedQuery = queryBuilder.order('check_in_time', ascending: false);
      
      // 應用分頁
      if (limit != null && offset != null) {
        orderedQuery = orderedQuery.range(offset, offset + limit - 1);
      } else if (limit != null) {
        orderedQuery = orderedQuery.limit(limit);
      }

      final response = await orderedQuery;
      return (response as List)
          .map((json) => AttendanceRecord.fromJson(json))
          .toList();
    } catch (e) {
      print('獲取打卡記錄失敗: $e');
      rethrow;
    }
  }

  /// 獲取員工當日的打卡記錄
  Future<AttendanceRecord?> getTodayAttendance(String employeeId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _client
          .from('attendance_records')
          .select('*')
          .eq('employee_id', employeeId)
          .gte('check_in_time', startOfDay.toIso8601String())
          .lt('check_in_time', endOfDay.toIso8601String())
          .order('check_in_time', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        return AttendanceRecord.fromJson(response.first);
      }
      return null;
    } catch (e) {
      print('獲取今日打卡記錄失敗: $e');
      rethrow;
    }
  }

  /// 員工打卡上班
  Future<AttendanceRecord> checkIn({
    required Employee employee,
    String? location,
    String? notes,
    bool isManualEntry = false,
  }) async {
    try {
      // 檢查員工ID是否存在
      if (employee.id == null) {
        throw Exception('員工ID不能為空');
      }

      // 檢查今天是否已經打過卡
      final todayRecord = await getTodayAttendance(employee.id!);
      if (todayRecord != null) {
        throw Exception('今天已經打過卡了');
      }

      final now = DateTime.now();
      final record = AttendanceRecord(
        id: '', // 資料庫會自動生成
        employeeId: employee.id!,
        employeeName: employee.name,
        employeeEmail: employee.email ?? '',
        checkInTime: now,
        location: location,
        notes: notes,
        isManualEntry: isManualEntry,
        createdAt: now,
        updatedAt: now,
      );

      final response = await _client
          .from('attendance_records')
          .insert(record.toJsonForInsert())
          .select()
          .single();

      return AttendanceRecord.fromJson(response);
    } catch (e) {
      print('打卡上班失敗: $e');
      rethrow;
    }
  }

  /// 員工打卡下班
  Future<AttendanceRecord> checkOut({
    required String recordId,
    String? location,
    String? notes,
  }) async {
    try {
      final now = DateTime.now();
      
      // 獲取原記錄以計算工作時數
      final existingRecord = await getAttendanceRecord(recordId);
      if (existingRecord == null) {
        throw Exception('找不到打卡記錄');
      }

      if (existingRecord.checkOutTime != null) {
        throw Exception('已經打過下班卡了');
      }

      // 計算工作時數 - 確保不為負數
      final duration =
          now.difference(existingRecord.checkInTime).inMinutes / 60.0;
      final workHours = duration < 0 ? 0.0 : duration;

      final updateData = {
        'check_out_time': now.toIso8601String(),
        'work_hours': workHours,
        'location': location ?? existingRecord.location,
        'notes': notes ?? existingRecord.notes,
        'updated_at': now.toIso8601String(),
      };

      final response = await _client
          .from('attendance_records')
          .update(updateData)
          .eq('id', recordId)
          .select()
          .single();

      return AttendanceRecord.fromJson(response);
    } catch (e) {
      print('打卡下班失敗: $e');
      rethrow;
    }
  }

  /// 獲取單一打卡記錄
  Future<AttendanceRecord?> getAttendanceRecord(String id) async {
    try {
      final response = await _client
          .from('attendance_records')
          .select('*')
          .eq('id', id)
          .maybeSingle();

      if (response != null) {
        return AttendanceRecord.fromJson(response);
      }
      return null;
    } catch (e) {
      print('獲取打卡記錄失敗: $e');
      rethrow;
    }
  }

  /// 更新打卡記錄
  Future<AttendanceRecord> updateAttendanceRecord({
    required String id,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? location,
    String? notes,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      
      if (checkInTime != null) {
        updateData['check_in_time'] = checkInTime.toIso8601String();
      }
      if (checkOutTime != null) {
        updateData['check_out_time'] = checkOutTime.toIso8601String();
      }
      if (location != null) {
        updateData['location'] = location;
      }
      if (notes != null) {
        updateData['notes'] = notes;
      }

      // 如果有上下班時間，重新計算工作時數
      final existingRecord = await getAttendanceRecord(id);
      if (existingRecord != null) {
        final newCheckIn = checkInTime ?? existingRecord.checkInTime;
        final newCheckOut = checkOutTime ?? existingRecord.checkOutTime;
        
        if (newCheckOut != null) {
          final duration = newCheckOut.difference(newCheckIn).inMinutes / 60.0;
          // 確保工作時數不為負數
          final workHours = duration < 0 ? 0.0 : duration;
          updateData['work_hours'] = workHours;
        }
      }

      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('attendance_records')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return AttendanceRecord.fromJson(response);
    } catch (e) {
      print('更新打卡記錄失敗: $e');
      rethrow;
    }
  }

  /// 刪除打卡記錄
  Future<void> deleteAttendanceRecord(String id) async {
    try {
      await _client.from('attendance_records').delete().eq('id', id);
    } catch (e) {
      print('刪除打卡記錄失敗: $e');
      rethrow;
    }
  }

  /// 補登打卡記錄（手動輸入上下班時間）
  Future<AttendanceRecord> createManualAttendance({
    required Employee employee,
    required DateTime checkInTime,
    DateTime? checkOutTime,
    String? location,
    required String notes, // 補打卡必須填寫原因
  }) async {
    try {
      // 檢查員工ID是否存在
      if (employee.id == null) {
        throw Exception('員工ID不能為空');
      }

      // 檢查該日期是否已經有打卡記錄
      final targetDate = DateTime(
        checkInTime.year,
        checkInTime.month,
        checkInTime.day,
      );
      final existingRecords = await getAllAttendanceRecords(
        employeeId: employee.id!,
        startDate: targetDate,
        endDate: targetDate.add(const Duration(days: 1)),
      );

      if (existingRecords.isNotEmpty) {
        throw Exception('該日期已經有打卡記錄\n請在頁面上選擇該日期後使用編輯模式修改');
      }

      // 計算工作時數
      double? workHours;
      if (checkOutTime != null) {
        final duration = checkOutTime.difference(checkInTime).inMinutes / 60.0;
        workHours = duration < 0 ? 0.0 : duration;
      }

      final now = DateTime.now();
      final record = AttendanceRecord(
        id: '', // 資料庫會自動生成
        employeeId: employee.id!,
        employeeName: employee.name,
        employeeEmail: employee.email ?? '',
        checkInTime: checkInTime,
        checkOutTime: checkOutTime,
        workHours: workHours,
        location: location,
        notes: '【補打卡】$notes',
        isManualEntry: true,
        createdAt: now,
        updatedAt: now,
      );

      final response = await _client
          .from('attendance_records')
          .insert(record.toJsonForInsert())
          .select()
          .single();

      return AttendanceRecord.fromJson(response);
    } catch (e) {
      print('補登打卡記錄失敗: $e');
      rethrow;
    }
  }

  /// 獲取員工打卡統計
  Future<AttendanceStats> getAttendanceStats({
    required String employeeId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final records = await getAllAttendanceRecords(
        employeeId: employeeId,
        startDate: startDate,
        endDate: endDate,
      );

      // 計算工作日天數（週一至週五），但只計算到今天
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      // 計算結束日期：取 endDate 和 today 中較早的那個
      final calculationEndDate = endDate.isBefore(today) ? endDate : today;

      // 建立國定假日服務
      final holidayService = HolidayService();

      int expectedWorkDays = 0;
      DateTime currentDate = startDate;
      while (currentDate.isBefore(calculationEndDate) ||
          currentDate.isAtSameMomentAs(calculationEndDate)) {
        // 1 = Monday, 5 = Friday
        if (currentDate.weekday >= 1 && currentDate.weekday <= 5) {
          // 檢查是否為國定假日
          if (holidayService.isHoliday(currentDate) == null) {
            expectedWorkDays++;
          }
        }
        currentDate = currentDate.add(const Duration(days: 1));
      }

      // 計算統計資料
      final totalDays = endDate.difference(startDate).inDays + 1;
      final workDays = records.length;
      final totalHours = records
          .where((r) => r.workHours != null)
          .fold<double>(0.0, (sum, r) => sum + (r.workHours ?? 0));
      
      final averageHours = workDays > 0 ? totalHours / workDays : 0.0;
      // 使用工作日計算出勤率（只計算到今天）
      final attendanceRate = expectedWorkDays > 0
          ? (workDays / expectedWorkDays) * 100
          : 0.0;

      // 計算遲到和早退次數 (假設標準工時是 8:30-17:30)
      int lateCount = 0;
      int earlyLeaveCount = 0;

      for (final record in records) {
        final checkInHour = record.checkInTime.hour + record.checkInTime.minute / 60.0;
        if (checkInHour > 8.5) {
          // 8:30 = 8.5小時
          lateCount++;
        }

        if (record.checkOutTime != null) {
          final checkOutHour = record.checkOutTime!.hour + record.checkOutTime!.minute / 60.0;
          if (checkOutHour < 17.5) {
            // 17:30 = 17.5小時
            earlyLeaveCount++;
          }
        }
      }

      return AttendanceStats(
        totalDays: totalDays,
        workDays: workDays,
        totalHours: totalHours,
        averageHours: averageHours,
        attendanceRate: attendanceRate,
        lateCount: lateCount,
        earlyLeaveCount: earlyLeaveCount,
      );
    } catch (e) {
      print('獲取打卡統計失敗: $e');
      rethrow;
    }
  }

  /// 獲取月度出勤報表
  Future<List<AttendanceRecord>> getMonthlyReport({
    String? employeeId,
    required int year,
    required int month,
  }) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    return getAllAttendanceRecords(
      employeeId: employeeId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// 檢查員工今天是否已經打卡
  Future<bool> hasCheckedInToday(String employeeId) async {
    final todayRecord = await getTodayAttendance(employeeId);
    return todayRecord != null;
  }

  /// 檢查員工今天是否已經打卡下班
  Future<bool> hasCheckedOutToday(String employeeId) async {
    final todayRecord = await getTodayAttendance(employeeId);
    return todayRecord?.checkOutTime != null;
  }

  // ==================== 補打卡申請相關方法 ====================

  /// 獲取指定日期的打卡記錄
  Future<AttendanceRecord?> getAttendanceByDate({
    required String employeeId,
    required DateTime date,
  }) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _client
          .from('attendance_records')
          .select('*')
          .eq('employee_id', employeeId)
          .gte('check_in_time', startOfDay.toIso8601String())
          .lt('check_in_time', endOfDay.toIso8601String())
          .order('check_in_time', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        return AttendanceRecord.fromJson(response.first);
      }
      return null;
    } catch (e) {
      print('獲取指定日期打卡記錄失敗: $e');
      rethrow;
    }
  }

  /// 補上班打卡（用於補打卡申請核准後）
  Future<AttendanceRecord> createManualCheckIn({
    required String employeeId,
    required String employeeName,
    required String employeeEmail,
    required DateTime checkInTime,
    String? location,
    String? notes,
  }) async {
    try {
      // 檢查該日期是否已有打卡記錄
      final existingRecord = await getAttendanceByDate(
        employeeId: employeeId,
        date: checkInTime,
      );

      if (existingRecord != null) {
        throw Exception('該日期已有打卡記錄，請使用編輯功能');
      }

      final record = AttendanceRecord(
        id: '',
        employeeId: employeeId,
        employeeName: employeeName,
        employeeEmail: employeeEmail,
        checkInTime: checkInTime,
        location: location ?? '補打卡申請',
        notes: notes ?? '補打卡申請已核准',
        isManualEntry: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final response = await _client
          .from('attendance_records')
          .insert(record.toJsonForInsert())
          .select()
          .single();

      return AttendanceRecord.fromJson(response);
    } catch (e) {
      print('補上班打卡失敗: $e');
      rethrow;
    }
  }

  /// 建立補下班打卡記錄（用於補打卡申請核准後）
  ///
  /// [checkInTime] 選填：如果提供，會同時修改上班時間
  Future<void> createManualCheckOut({
    required String employeeId,
    required DateTime checkOutTime,
    DateTime? checkInTime, // 新增：允許修改上班時間
    String? location,
    String? notes,
  }) async {
    try {
      print('🔄 建立補下班打卡記錄...');
      print('員工ID: $employeeId');
      print('下班時間: $checkOutTime');
      if (checkInTime != null) {
        print('上班時間（修改）: $checkInTime');
      }

      // 1. 取得當天的打卡記錄
      final existingRecord = await getAttendanceByDate(
        employeeId: employeeId,
        date: checkOutTime,
      );

      if (existingRecord == null) {
        throw Exception('找不到該日期的上班打卡記錄，無法補下班打卡');
      }

      if (existingRecord.checkOutTime != null) {
        print('⚠️ 該記錄已有下班時間: ${existingRecord.checkOutTime}');
      }

      // 2. 計算工作時數
      // 如果有提供新的上班時間，使用新的；否則使用原有的
      final actualCheckIn = checkInTime ?? existingRecord.checkInTime;
      final duration = checkOutTime.difference(actualCheckIn);
      final workHours = duration.inMinutes / 60.0;

      print('上班時間: $actualCheckIn');
      print('下班時間: $checkOutTime');
      print('工作時數: $workHours 小時');

      // 3. 更新打卡記錄
      final updateData = {
        'check_out_time': checkOutTime.toIso8601String(),
        'work_hours': workHours,
        'is_manual_entry': true,
      };

      // 如果有提供新的上班時間，也更新它
      if (checkInTime != null) {
        updateData['check_in_time'] = checkInTime.toIso8601String();
      }

      if (location != null) {
        updateData['location'] = location;
      }

      if (notes != null) {
        updateData['notes'] = notes;
      }

      final result = await _client
          .from('attendance_records')
          .update(updateData)
          .eq('id', existingRecord.id)
          .select()
          .single();

      print('✅ 補下班打卡記錄建立成功');
      print('記錄ID: ${result['id']}');
      if (checkInTime != null) {
        print('已同時更新上班時間');
      }
    } catch (e, stack) {
      print('❌ 建立補下班打卡記錄失敗: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  /// 補整天打卡（用於補打卡申請核准後）
  Future<AttendanceRecord> createManualFullDayRecord({
    required String employeeId,
    required String employeeName,
    required String employeeEmail,
    required DateTime checkInTime,
    required DateTime checkOutTime,
    String? location,
    String? notes,
  }) async {
    try {
      // 檢查該日期是否已有打卡記錄
      final existingRecord = await getAttendanceByDate(
        employeeId: employeeId,
        date: checkInTime,
      );

      if (existingRecord != null) {
        throw Exception('該日期已有打卡記錄，請使用編輯功能');
      }

      // 計算工作時數
      final duration = checkOutTime.difference(checkInTime).inMinutes / 60.0;
      final workHours = duration < 0 ? 0.0 : duration;

      final record = AttendanceRecord(
        id: '',
        employeeId: employeeId,
        employeeName: employeeName,
        employeeEmail: employeeEmail,
        checkInTime: checkInTime,
        checkOutTime: checkOutTime,
        workHours: workHours,
        location: location ?? '補打卡申請',
        notes: notes ?? '補打卡申請已核准',
        isManualEntry: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final response = await _client
          .from('attendance_records')
          .insert(record.toJsonForInsert())
          .select()
          .single();

      return AttendanceRecord.fromJson(response);
    } catch (e) {
      print('補整天打卡失敗: $e');
      rethrow;
    }
  }
}