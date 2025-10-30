import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/attendance_leave_request.dart';

/// 補打卡申請服務
class AttendanceLeaveRequestService {
  final SupabaseClient _supabase;

  AttendanceLeaveRequestService(this._supabase);

  /// 創建補打卡申請
  Future<AttendanceLeaveRequest> createRequest(AttendanceLeaveRequest request) async {
    final response = await _supabase
        .from('attendance_leave_requests')
        .insert(request.toJsonForInsert())
        .select()
        .single();

    return AttendanceLeaveRequest.fromJson(response);
  }

  /// 獲取當前用戶的所有申請
  Future<List<AttendanceLeaveRequest>> getMyRequests({
    AttendanceRequestStatus? status,
  }) async {
    var query = _supabase
        .from('attendance_leave_requests')
        .select()
        .eq('employee_id', _supabase.auth.currentUser!.id);

    if (status != null) {
      query = query.eq('status', status.value);
    }

    final response = await query.order('created_at', ascending: false);
    return (response as List)
        .map((json) => AttendanceLeaveRequest.fromJson(json))
        .toList();
  }

  /// 獲取所有待審核的申請（HR/老闆用）
  Future<List<AttendanceLeaveRequest>> getPendingRequests() async {
    final response = await _supabase
        .from('attendance_leave_requests')
        .select()
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => AttendanceLeaveRequest.fromJson(json))
        .toList();
  }

  /// 獲取所有申請（HR/老闆用）
  Future<List<AttendanceLeaveRequest>> getAllRequests({
    AttendanceRequestStatus? status,
    String? employeeId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = _supabase
        .from('attendance_leave_requests')
        .select();

    if (status != null) {
      query = query.eq('status', status.value);
    }

    if (employeeId != null) {
      query = query.eq('employee_id', employeeId);
    }

    if (startDate != null) {
      query = query.gte('request_date', startDate.toIso8601String().split('T')[0]);
    }

    if (endDate != null) {
      query = query.lte('request_date', endDate.toIso8601String().split('T')[0]);
    }

    final response = await query.order('created_at', ascending: false);
    return (response as List)
        .map((json) => AttendanceLeaveRequest.fromJson(json))
        .toList();
  }

  /// 核准申請
  Future<void> approveRequest(
    String requestId,
    String reviewerId,
    String reviewerName, {
    String? comment,
  }) async {
    await _supabase
        .from('attendance_leave_requests')
        .update({
          'status': 'approved',
          'reviewer_id': reviewerId,
          'reviewer_name': reviewerName,
          'review_comment': comment,
          'reviewed_at': DateTime.now().toIso8601String(),
        })
        .eq('id', requestId);
  }

  /// 拒絕申請
  Future<void> rejectRequest(
    String requestId,
    String reviewerId,
    String reviewerName, {
    String? comment,
  }) async {
    await _supabase
        .from('attendance_leave_requests')
        .update({
          'status': 'rejected',
          'reviewer_id': reviewerId,
          'reviewer_name': reviewerName,
          'review_comment': comment,
          'reviewed_at': DateTime.now().toIso8601String(),
        })
        .eq('id', requestId);
  }

  /// 更新申請（僅待審核狀態可更新）
  Future<void> updateRequest(AttendanceLeaveRequest request) async {
    await _supabase
        .from('attendance_leave_requests')
        .update(request.toJsonForInsert())
        .eq('id', request.id!)
        .eq('status', 'pending'); // 確保只能更新待審核的申請
  }

  /// 刪除申請（僅待審核狀態可刪除）
  Future<void> deleteRequest(String requestId) async {
    await _supabase
        .from('attendance_leave_requests')
        .delete()
        .eq('id', requestId)
        .eq('status', 'pending'); // 確保只能刪除待審核的申請
  }

  /// 獲取待審核申請數量
  Future<int> getPendingRequestCount() async {
    final response = await _supabase
        .from('attendance_leave_requests')
        .select()
        .eq('status', 'pending');

    return (response as List).length;
  }

  /// 根據申請ID獲取申請詳情
  Future<AttendanceLeaveRequest?> getRequestById(String requestId) async {
    final response = await _supabase
        .from('attendance_leave_requests')
        .select()
        .eq('id', requestId)
        .maybeSingle();

    if (response == null) return null;
    return AttendanceLeaveRequest.fromJson(response);
  }
}
