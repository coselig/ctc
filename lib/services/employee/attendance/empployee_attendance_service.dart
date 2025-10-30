import 'package:ctc/models/employee.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmployeeAttendanceService {
  final SupabaseClient _client;

  EmployeeAttendanceService(this._client);

  /// 獲取員工考勤記錄
  Future<List<EmployeeAttendance>> getEmployeeAttendance(
    String employeeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('必須登入才能查看考勤記錄');
      }

      var query = _client
          .from('employee_attendance')
          .select('*')
          .eq('employee_id', employeeId);

      if (startDate != null) {
        query = query.gte('date', startDate.toIso8601String().split('T')[0]);
      }

      if (endDate != null) {
        query = query.lte('date', endDate.toIso8601String().split('T')[0]);
      }

      final response = await query.order('date', ascending: false);
      return response
          .map<EmployeeAttendance>((json) => EmployeeAttendance.fromJson(json))
          .toList();
    } catch (e) {
      print('獲取考勤記錄失敗: $e');
      rethrow;
    }
  }

  /// 記錄考勤
  Future<EmployeeAttendance> recordAttendance(
    EmployeeAttendance attendance,
  ) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('必須登入才能記錄考勤');
      }

      final response = await _client
          .from('employee_attendance')
          .upsert(attendance.toJson())
          .select()
          .single();

      return EmployeeAttendance.fromJson(response);
    } catch (e) {
      print('記錄考勤失敗: $e');
      rethrow;
    }
  }
}
