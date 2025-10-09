/// 請假類型
enum LeaveType {
  /// 病假
  sick('sick', '病假', 30, requiresDocument: false),
  
  /// 事假
  personal('personal', '事假', 14, requiresDocument: false),
  
  /// 特休 (年假)
  annual('annual', '特休', 14, requiresDocument: false),
  
  /// 育嬰假
  parental('parental', '育嬰假', 730, requiresDocument: true), // 2年
  
  /// 婚假
  marriage('marriage', '婚假', 8, requiresDocument: true),
  
  /// 喪假
  bereavement('bereavement', '喪假', 8, requiresDocument: true),
  
  /// 公假
  official('official', '公假', 365, requiresDocument: true),
  
  /// 產假
  maternity('maternity', '產假', 56, requiresDocument: true), // 8週
  
  /// 陪產假
  paternity('paternity', '陪產假', 7, requiresDocument: true),
  
  /// 生理假
  menstrual('menstrual', '生理假', 12, requiresDocument: false);

  const LeaveType(
    this.value, 
    this.displayName, 
    this.defaultDaysPerYear, {
    this.requiresDocument = false,
  });

  final String value;
  final String displayName;
  final int defaultDaysPerYear; // 每年可請天數
  final bool requiresDocument; // 是否需要證明文件

  static LeaveType fromString(String value) {
    return LeaveType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => LeaveType.personal,
    );
  }
  
  /// 取得假別說明
  String get description {
    switch (this) {
      case LeaveType.sick:
        return '因疾病或受傷需要治療或休養';
      case LeaveType.personal:
        return '因私人事務需要請假';
      case LeaveType.annual:
        return '年度特別休假';
      case LeaveType.parental:
        return '照顧未滿3歲子女，最長2年';
      case LeaveType.marriage:
        return '結婚登記後可請8日';
      case LeaveType.bereavement:
        return '直系親屬喪亡可請假';
      case LeaveType.official:
        return '因公務需要或法定義務';
      case LeaveType.maternity:
        return '產前產後共56日 (8週)';
      case LeaveType.paternity:
        return '配偶分娩可請7日';
      case LeaveType.menstrual:
        return '每月可請1日生理假';
    }
  }
}

/// 請假申請狀態
enum LeaveRequestStatus {
  /// 待審核
  pending('pending', '待審核'),
  
  /// 已核准
  approved('approved', '已核准'),
  
  /// 已拒絕
  rejected('rejected', '已拒絕'),
  
  /// 已取消
  cancelled('cancelled', '已取消');

  const LeaveRequestStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static LeaveRequestStatus fromString(String value) {
    return LeaveRequestStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => LeaveRequestStatus.pending,
    );
  }
  
  bool get isPending => this == LeaveRequestStatus.pending;
  bool get isApproved => this == LeaveRequestStatus.approved;
  bool get isRejected => this == LeaveRequestStatus.rejected;
  bool get isCancelled => this == LeaveRequestStatus.cancelled;
}

/// 請假時段
enum LeavePeriod {
  /// 全天
  fullDay('full_day', '全天'),
  
  /// 上午
  morning('morning', '上午'),
  
  /// 下午
  afternoon('afternoon', '下午');

  const LeavePeriod(this.value, this.displayName);

  final String value;
  final String displayName;

  static LeavePeriod fromString(String value) {
    return LeavePeriod.values.firstWhere(
      (period) => period.value == value,
      orElse: () => LeavePeriod.fullDay,
    );
  }
  
  /// 計算請假天數
  double get days {
    switch (this) {
      case LeavePeriod.fullDay:
        return 1.0;
      case LeavePeriod.morning:
      case LeavePeriod.afternoon:
        return 0.5;
    }
  }
}

/// 請假申請模型
class LeaveRequest {
  final String? id;
  final String employeeId;
  final String employeeName;
  final LeaveType leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final LeavePeriod startPeriod; // 開始時段
  final LeavePeriod endPeriod;   // 結束時段
  final double totalDays;        // 總請假天數
  final String reason;
  final String? attachmentUrl;   // 證明文件 URL
  final LeaveRequestStatus status;
  final String? reviewerId;
  final String? reviewerName;
  final String? reviewComment;
  final DateTime? reviewedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  LeaveRequest({
    this.id,
    required this.employeeId,
    required this.employeeName,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    this.startPeriod = LeavePeriod.fullDay,
    this.endPeriod = LeavePeriod.fullDay,
    required this.totalDays,
    required this.reason,
    this.attachmentUrl,
    this.status = LeaveRequestStatus.pending,
    this.reviewerId,
    this.reviewerName,
    this.reviewComment,
    this.reviewedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// 從 JSON 建立
  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'] as String?,
      employeeId: json['employee_id'] as String,
      employeeName: json['employee_name'] as String,
      leaveType: LeaveType.fromString(json['leave_type'] as String),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      startPeriod: LeavePeriod.fromString(json['start_period'] as String? ?? 'full_day'),
      endPeriod: LeavePeriod.fromString(json['end_period'] as String? ?? 'full_day'),
      totalDays: (json['total_days'] as num).toDouble(),
      reason: json['reason'] as String,
      attachmentUrl: json['attachment_url'] as String?,
      status: LeaveRequestStatus.fromString(json['status'] as String),
      reviewerId: json['reviewer_id'] as String?,
      reviewerName: json['reviewer_name'] as String?,
      reviewComment: json['review_comment'] as String?,
      reviewedAt: json['reviewed_at'] != null 
          ? DateTime.parse(json['reviewed_at'] as String) 
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// 轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'employee_id': employeeId,
      'employee_name': employeeName,
      'leave_type': leaveType.value,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'start_period': startPeriod.value,
      'end_period': endPeriod.value,
      'total_days': totalDays,
      'reason': reason,
      if (attachmentUrl != null) 'attachment_url': attachmentUrl,
      'status': status.value,
      if (reviewerId != null) 'reviewer_id': reviewerId,
      if (reviewerName != null) 'reviewer_name': reviewerName,
      if (reviewComment != null) 'review_comment': reviewComment,
      if (reviewedAt != null) 'reviewed_at': reviewedAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 轉換為插入用 JSON (不含 id、時間戳記)
  Map<String, dynamic> toJsonForInsert() {
    return {
      'employee_id': employeeId,
      'employee_name': employeeName,
      'leave_type': leaveType.value,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'start_period': startPeriod.value,
      'end_period': endPeriod.value,
      'total_days': totalDays,
      'reason': reason,
      if (attachmentUrl != null) 'attachment_url': attachmentUrl,
      'status': status.value,
    };
  }

  /// 複製並修改部分欄位
  LeaveRequest copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    LeaveType? leaveType,
    DateTime? startDate,
    DateTime? endDate,
    LeavePeriod? startPeriod,
    LeavePeriod? endPeriod,
    double? totalDays,
    String? reason,
    String? attachmentUrl,
    LeaveRequestStatus? status,
    String? reviewerId,
    String? reviewerName,
    String? reviewComment,
    DateTime? reviewedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LeaveRequest(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      leaveType: leaveType ?? this.leaveType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startPeriod: startPeriod ?? this.startPeriod,
      endPeriod: endPeriod ?? this.endPeriod,
      totalDays: totalDays ?? this.totalDays,
      reason: reason ?? this.reason,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      status: status ?? this.status,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewComment: reviewComment ?? this.reviewComment,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// 計算日期範圍內的請假天數
  static double calculateLeaveDays({
    required DateTime startDate,
    required DateTime endDate,
    required LeavePeriod startPeriod,
    required LeavePeriod endPeriod,
  }) {
    // 如果是同一天
    if (startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day) {
      // 同一天，全天 = 1，半天 = 0.5
      if (startPeriod == LeavePeriod.fullDay || endPeriod == LeavePeriod.fullDay) {
        return 1.0;
      }
      if (startPeriod == endPeriod) {
        return 0.5; // 只請上午或下午
      }
      return 1.0; // 上午 + 下午 = 全天
    }
    
    // 計算天數差
    final daysDiff = endDate.difference(startDate).inDays;
    
    // 基礎天數
    double totalDays = daysDiff.toDouble();
    
    // 處理開始日期的時段
    if (startPeriod == LeavePeriod.afternoon) {
      totalDays -= 0.5; // 開始日只請下午，減去上午
    } else if (startPeriod == LeavePeriod.morning) {
      totalDays -= 0.5; // 開始日只請上午，減去下午
    }
    // fullDay 不用處理
    
    // 處理結束日期的時段
    if (endPeriod == LeavePeriod.morning) {
      totalDays -= 0.5; // 結束日只請上午，減去下午
    } else if (endPeriod == LeavePeriod.afternoon) {
      totalDays -= 0.5; // 結束日只請下午，減去上午
    } else if (endPeriod == LeavePeriod.fullDay) {
      totalDays += 1.0; // 結束日全天，需要加1
    }
    
    return totalDays > 0 ? totalDays : 0.5; // 至少 0.5 天
  }
}

/// 員工假別額度模型
class LeaveBalance {
  final String employeeId;
  final LeaveType leaveType;
  final double totalDays;    // 總額度
  final double usedDays;     // 已使用
  final double pendingDays;  // 審核中
  final double remainingDays; // 剩餘額度
  
  LeaveBalance({
    required this.employeeId,
    required this.leaveType,
    required this.totalDays,
    required this.usedDays,
    required this.pendingDays,
  }) : remainingDays = totalDays - usedDays - pendingDays;
  
  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    return LeaveBalance(
      employeeId: json['employee_id'] as String,
      leaveType: LeaveType.fromString(json['leave_type'] as String),
      totalDays: (json['total_days'] as num).toDouble(),
      usedDays: (json['used_days'] as num).toDouble(),
      pendingDays: (json['pending_days'] as num).toDouble(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'leave_type': leaveType.value,
      'total_days': totalDays,
      'used_days': usedDays,
      'pending_days': pendingDays,
      'remaining_days': remainingDays,
    };
  }
}
