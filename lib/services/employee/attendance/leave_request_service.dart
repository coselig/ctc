import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/models.dart';

/// 請假申請服務
class LeaveRequestService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ==================== 請假申請 CRUD ====================

  /// 建立請假申請
  Future<LeaveRequest> createLeaveRequest(LeaveRequest request) async {
    try {
      final data = request.toJsonForInsert();
      
      debugPrint('準備插入資料: $data');
      
      final response = await _supabase
          .from('leave_requests')
          .insert(data)
          .select()
          .single();

      debugPrint('插入成功: $response');
      return LeaveRequest.fromJson(response);
    } catch (e, stackTrace) {
      debugPrint('建立請假申請失敗: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('建立請假申請失敗: $e');
    }
  }

  /// 取得員工的請假申請列表
  Future<List<LeaveRequest>> getEmployeeLeaveRequests(
    String employeeId, {
    LeaveRequestStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase
          .from('leave_requests')
          .select()
          .eq('employee_id', employeeId);

      if (status != null) {
        query = query.eq('status', status.value);
      }

      if (startDate != null) {
        query = query.gte('start_date', startDate.toIso8601String().split('T')[0]);
      }

      if (endDate != null) {
        query = query.lte('end_date', endDate.toIso8601String().split('T')[0]);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => LeaveRequest.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('取得請假申請失敗: $e');
    }
  }

  /// 取得所有待審核的請假申請（管理者用）
  Future<List<LeaveRequest>> getPendingLeaveRequests() async {
    try {
      final response = await _supabase
          .from('leave_requests')
          .select()
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => LeaveRequest.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('取得待審核請假申請失敗: $e');
    }
  }

  /// 取得所有請假申請（管理者用）
  Future<List<LeaveRequest>> getAllLeaveRequests({
    LeaveRequestStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase.from('leave_requests').select();

      if (status != null) {
        query = query.eq('status', status.value);
      }

      if (startDate != null) {
        query = query.gte('start_date', startDate.toIso8601String().split('T')[0]);
      }

      if (endDate != null) {
        query = query.lte('end_date', endDate.toIso8601String().split('T')[0]);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => LeaveRequest.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('取得所有請假申請失敗: $e');
    }
  }

  /// 取消請假申請（員工只能取消待審核的）
  Future<void> cancelLeaveRequest(String requestId) async {
    try {
      await _supabase
          .from('leave_requests')
          .update({
            'status': 'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', requestId)
          .eq('status', 'pending'); // 只能取消待審核的

    } catch (e) {
      throw Exception('取消請假申請失敗: $e');
    }
  }

  /// 審核請假申請（核准/拒絕）
  Future<void> reviewLeaveRequest({
    required String requestId,
    required String reviewerId,
    required String reviewerName,
    required bool approved,
    String? comment,
  }) async {
    try {
      await _supabase
          .from('leave_requests')
          .update({
            'status': approved ? 'approved' : 'rejected',
            'reviewer_id': reviewerId,
            'reviewer_name': reviewerName,
            'review_comment': comment,
            'reviewed_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', requestId);

    } catch (e) {
      throw Exception('審核請假申請失敗: $e');
    }
  }

  // ==================== 假別額度管理 ====================

  /// 初始化員工的假別額度
  Future<void> initializeLeaveBalance({
    required String employeeId,
    required LeaveType leaveType,
    required int year,
    required double totalDays,
  }) async {
    try {
      await _supabase.rpc('initialize_leave_balance', params: {
        'p_employee_id': employeeId,
        'p_leave_type': leaveType.value,
        'p_year': year,
        'p_total_days': totalDays,
      });
    } catch (e) {
      throw Exception('初始化假別額度失敗: $e');
    }
  }

  /// 批次初始化員工的所有假別額度（新員工入職時使用）
  Future<void> initializeAllLeaveBalances({
    required String employeeId,
    int? year,
  }) async {
    final targetYear = year ?? DateTime.now().year;

    try {
      // 初始化各種假別的額度
      final leaveTypes = [
        (LeaveType.annual, 14.0),      // 特休 14 天
        (LeaveType.sick, 30.0),        // 病假 30 天
        (LeaveType.personal, 14.0),    // 事假 14 天
        (LeaveType.menstrual, 12.0),   // 生理假 12 天
        (LeaveType.marriage, 8.0),     // 婚假 8 天
        (LeaveType.bereavement, 8.0),  // 喪假 8 天
        (LeaveType.paternity, 7.0),    // 陪產假 7 天
        (LeaveType.maternity, 56.0),   // 產假 56 天
        (LeaveType.parental, 730.0),   // 育嬰假 730 天
        (LeaveType.official, 365.0),   // 公假 365 天
      ];

      for (final (leaveType, totalDays) in leaveTypes) {
        await initializeLeaveBalance(
          employeeId: employeeId,
          leaveType: leaveType,
          year: targetYear,
          totalDays: totalDays,
        );
      }
    } catch (e) {
      throw Exception('批次初始化假別額度失敗: $e');
    }
  }

  /// 取得員工的假別額度
  Future<List<LeaveBalance>> getEmployeeLeaveBalances(
    String employeeId, {
    int? year,
  }) async {
    try {
      final targetYear = year ?? DateTime.now().year;

      final response = await _supabase
          .from('leave_balances')
          .select()
          .eq('employee_id', employeeId)
          .eq('year', targetYear);

      return (response as List)
          .map((json) => LeaveBalance.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('取得假別額度失敗: $e');
    }
  }

  /// 取得特定假別的額度
  Future<LeaveBalance?> getLeaveBalance({
    required String employeeId,
    required LeaveType leaveType,
    int? year,
  }) async {
    try {
      final targetYear = year ?? DateTime.now().year;

      final response = await _supabase
          .from('leave_balances')
          .select()
          .eq('employee_id', employeeId)
          .eq('leave_type', leaveType.value)
          .eq('year', targetYear)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return LeaveBalance.fromJson(response);
    } catch (e) {
      throw Exception('取得假別額度失敗: $e');
    }
  }

  /// 更新假別額度
  Future<void> updateLeaveBalance({
    required String employeeId,
    required LeaveType leaveType,
    required int year,
    required double totalDays,
  }) async {
    try {
      await _supabase
          .from('leave_balances')
          .update({
            'total_days': totalDays,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('employee_id', employeeId)
          .eq('leave_type', leaveType.value)
          .eq('year', year);
    } catch (e) {
      throw Exception('更新假別額度失敗: $e');
    }
  }

  // ==================== 統計與報表 ====================

  /// 取得員工某時段的請假統計
  Future<Map<LeaveType, double>> getEmployeeLeaveStatistics({
    required String employeeId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final requests = await getEmployeeLeaveRequests(
        employeeId,
        status: LeaveRequestStatus.approved,
        startDate: startDate,
        endDate: endDate,
      );

      final statistics = <LeaveType, double>{};

      for (final request in requests) {
        statistics[request.leaveType] = 
            (statistics[request.leaveType] ?? 0) + request.totalDays;
      }

      return statistics;
    } catch (e) {
      throw Exception('取得請假統計失敗: $e');
    }
  }

  /// 檢查員工是否有足夠的假別額度
  Future<bool> hasEnoughLeaveBalance({
    required String employeeId,
    required LeaveType leaveType,
    required double requestDays,
    int? year,
  }) async {
    try {
      final balance = await getLeaveBalance(
        employeeId: employeeId,
        leaveType: leaveType,
        year: year,
      );

      if (balance == null) {
        return false;
      }

      return balance.remainingDays >= requestDays;
    } catch (e) {
      throw Exception('檢查假別額度失敗: $e');
    }
  }

  /// 取得部門的請假統計（管理者用）
  Future<Map<String, dynamic>> getDepartmentLeaveStatistics({
    String? department,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase
          .from('leave_requests')
          .select('employee_id, employee_name, leave_type, total_days, status');

      if (startDate != null) {
        query = query.gte('start_date', startDate.toIso8601String().split('T')[0]);
      }

      if (endDate != null) {
        query = query.lte('end_date', endDate.toIso8601String().split('T')[0]);
      }

      final response = await query.eq('status', 'approved');

      final statistics = <String, dynamic>{
        'total_requests': (response as List).length,
        'total_days': 0.0,
        'by_type': <String, double>{},
        'by_employee': <String, double>{},
      };

      for (final item in response) {
        final totalDays = (item['total_days'] as num).toDouble();
        final leaveType = item['leave_type'] as String;
        final employeeName = item['employee_name'] as String;

        statistics['total_days'] += totalDays;
        statistics['by_type'][leaveType] = 
            (statistics['by_type'][leaveType] ?? 0.0) + totalDays;
        statistics['by_employee'][employeeName] = 
            (statistics['by_employee'][employeeName] ?? 0.0) + totalDays;
      }

      return statistics;
    } catch (e) {
      throw Exception('取得部門請假統計失敗: $e');
    }
  }
}
