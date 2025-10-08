/// 補打卡申請類型
enum AttendanceRequestType {
  /// 補上班打卡
  checkIn('check_in', '補上班打卡'),
  
  /// 補下班打卡
  checkOut('check_out', '補下班打卡'),
  
  /// 補整天打卡
  fullDay('full_day', '補整天打卡');

  const AttendanceRequestType(this.value, this.displayName);

  final String value;
  final String displayName;

  static AttendanceRequestType fromString(String value) {
    switch (value) {
      case 'check_in':
        return AttendanceRequestType.checkIn;
      case 'check_out':
        return AttendanceRequestType.checkOut;
      case 'full_day':
        return AttendanceRequestType.fullDay;
      default:
        return AttendanceRequestType.checkIn;
    }
  }
}

/// 補打卡申請狀態
enum AttendanceRequestStatus {
  /// 待審核
  pending('pending', '待審核'),
  
  /// 已核准
  approved('approved', '已核准'),
  
  /// 已拒絕
  rejected('rejected', '已拒絕');

  const AttendanceRequestStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static AttendanceRequestStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return AttendanceRequestStatus.pending;
      case 'approved':
        return AttendanceRequestStatus.approved;
      case 'rejected':
        return AttendanceRequestStatus.rejected;
      default:
        return AttendanceRequestStatus.pending;
    }
  }
  
  bool get isPending => this == AttendanceRequestStatus.pending;
  bool get isApproved => this == AttendanceRequestStatus.approved;
  bool get isRejected => this == AttendanceRequestStatus.rejected;
}

/// 補打卡申請模型
class AttendanceLeaveRequest {
  final String? id;
  final String employeeId;
  final String employeeName;
  final AttendanceRequestType requestType;
  final DateTime requestDate;
  final DateTime? requestTime; // 單次打卡時間
  final DateTime? checkInTime; // 整天的上班時間
  final DateTime? checkOutTime; // 整天的下班時間
  final String reason;
  final AttendanceRequestStatus status;
  final String? reviewerId;
  final String? reviewerName;
  final String? reviewComment;
  final DateTime? reviewedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  AttendanceLeaveRequest({
    this.id,
    required this.employeeId,
    required this.employeeName,
    required this.requestType,
    required this.requestDate,
    this.requestTime,
    this.checkInTime,
    this.checkOutTime,
    required this.reason,
    this.status = AttendanceRequestStatus.pending,
    this.reviewerId,
    this.reviewerName,
    this.reviewComment,
    this.reviewedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory AttendanceLeaveRequest.fromJson(Map<String, dynamic> json) {
    return AttendanceLeaveRequest(
      id: json['id'] as String?,
      employeeId: json['employee_id'] as String,
      employeeName: json['employee_name'] as String,
      requestType: AttendanceRequestType.fromString(json['request_type'] as String),
      requestDate: DateTime.parse(json['request_date'] as String),
      requestTime: json['request_time'] != null 
          ? DateTime.parse(json['request_time'] as String) 
          : null,
      checkInTime: json['check_in_time'] != null 
          ? DateTime.parse(json['check_in_time'] as String) 
          : null,
      checkOutTime: json['check_out_time'] != null 
          ? DateTime.parse(json['check_out_time'] as String) 
          : null,
      reason: json['reason'] as String,
      status: AttendanceRequestStatus.fromString(json['status'] as String),
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

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'employee_id': employeeId,
      'employee_name': employeeName,
      'request_type': requestType.value,
      'request_date': requestDate.toIso8601String().split('T')[0],
      if (requestTime != null) 'request_time': requestTime!.toIso8601String(),
      if (checkInTime != null) 'check_in_time': checkInTime!.toIso8601String(),
      if (checkOutTime != null) 'check_out_time': checkOutTime!.toIso8601String(),
      'reason': reason,
      'status': status.value,
      if (reviewerId != null) 'reviewer_id': reviewerId,
      if (reviewerName != null) 'reviewer_name': reviewerName,
      if (reviewComment != null) 'review_comment': reviewComment,
      if (reviewedAt != null) 'reviewed_at': reviewedAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toJsonForInsert() {
    return {
      'employee_id': employeeId,
      'employee_name': employeeName,
      'request_type': requestType.value,
      'request_date': requestDate.toIso8601String().split('T')[0],
      if (requestTime != null) 'request_time': requestTime!.toIso8601String(),
      if (checkInTime != null) 'check_in_time': checkInTime!.toIso8601String(),
      if (checkOutTime != null) 'check_out_time': checkOutTime!.toIso8601String(),
      'reason': reason,
      'status': status.value,
    };
  }

  AttendanceLeaveRequest copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    AttendanceRequestType? requestType,
    DateTime? requestDate,
    DateTime? requestTime,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? reason,
    AttendanceRequestStatus? status,
    String? reviewerId,
    String? reviewerName,
    String? reviewComment,
    DateTime? reviewedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AttendanceLeaveRequest(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      requestType: requestType ?? this.requestType,
      requestDate: requestDate ?? this.requestDate,
      requestTime: requestTime ?? this.requestTime,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewComment: reviewComment ?? this.reviewComment,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
