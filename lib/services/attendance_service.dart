import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/attendance_record.dart';
import '../models/employee.dart';

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

      // 計算統計資料
      final totalDays = endDate.difference(startDate).inDays + 1;
      final workDays = records.length;
      final totalHours = records
          .where((r) => r.workHours != null)
          .fold<double>(0.0, (sum, r) => sum + (r.workHours ?? 0));
      
      final averageHours = workDays > 0 ? totalHours / workDays : 0.0;
      final attendanceRate = totalDays > 0 ? (workDays / totalDays) * 100 : 0.0;

      // 計算遲到和早退次數 (假設標準工時是 9:00-18:00)
      int lateCount = 0;
      int earlyLeaveCount = 0;

      for (final record in records) {
        final checkInHour = record.checkInTime.hour + record.checkInTime.minute / 60.0;
        if (checkInHour > 9.0) {
          lateCount++;
        }

        if (record.checkOutTime != null) {
          final checkOutHour = record.checkOutTime!.hour + record.checkOutTime!.minute / 60.0;
          if (checkOutHour < 18.0) {
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
}