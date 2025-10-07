/// 打卡記錄資料模型
class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.employeeEmail,
    required this.checkInTime,
    this.checkOutTime,
    this.workHours,
    this.location,
    this.notes,
    this.isManualEntry = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String employeeId;
  final String employeeName;
  final String employeeEmail;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final double? workHours; // 工作小時數
  final String? location; // 打卡地點
  final String? notes; // 備註
  final bool isManualEntry; // 是否為手動輸入
  final DateTime createdAt;
  final DateTime updatedAt;

  /// 是否已經打卡下班
  bool get isCheckedOut => checkOutTime != null;

  /// 計算工作時間（小時）
  double? get calculatedWorkHours {
    if (checkOutTime == null) return null;
    final duration = checkOutTime!.difference(checkInTime);
    return duration.inMinutes / 60.0;
  }

  /// 獲取工作狀態
  String get workStatus {
    if (checkOutTime == null) {
      return '工作中';
    } else {
      return '已下班';
    }
  }

  /// 從 JSON 創建實例
  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as String,
      employeeId: json['employee_id'] as String,
      employeeName: json['employee_name'] as String,
      employeeEmail: json['employee_email'] as String,
      checkInTime: DateTime.parse(json['check_in_time'] as String),
      checkOutTime: json['check_out_time'] != null 
          ? DateTime.parse(json['check_out_time'] as String) 
          : null,
      workHours: json['work_hours'] != null 
          ? (json['work_hours'] as num).toDouble() 
          : null,
      location: json['location'] as String?,
      notes: json['notes'] as String?,
      isManualEntry: json['is_manual_entry'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// 轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'employee_name': employeeName,
      'employee_email': employeeEmail,
      'check_in_time': checkInTime.toIso8601String(),
      'check_out_time': checkOutTime?.toIso8601String(),
      'work_hours': workHours,
      'location': location,
      'notes': notes,
      'is_manual_entry': isManualEntry,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 用於資料庫插入的 JSON（不包含 ID 和時間戳）
  Map<String, dynamic> toJsonForInsert() {
    return {
      'employee_id': employeeId,
      'employee_name': employeeName,
      'employee_email': employeeEmail,
      'check_in_time': checkInTime.toIso8601String(),
      'check_out_time': checkOutTime?.toIso8601String(),
      'work_hours': workHours,
      'location': location,
      'notes': notes,
      'is_manual_entry': isManualEntry,
    };
  }

  /// 用於更新的 JSON
  Map<String, dynamic> toJsonForUpdate() {
    return {
      'check_out_time': checkOutTime?.toIso8601String(),
      'work_hours': calculatedWorkHours,
      'location': location,
      'notes': notes,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// 複製並修改部分屬性
  AttendanceRecord copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    String? employeeEmail,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    double? workHours,
    String? location,
    String? notes,
    bool? isManualEntry,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      employeeEmail: employeeEmail ?? this.employeeEmail,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      workHours: workHours ?? this.workHours,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      isManualEntry: isManualEntry ?? this.isManualEntry,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AttendanceRecord('
        'id: $id, '
        'employeeName: $employeeName, '
        'checkInTime: $checkInTime, '
        'checkOutTime: $checkOutTime, '
        'workHours: $workHours, '
        'status: $workStatus'
        ')';
  }
}

/// 打卡統計資料模型
class AttendanceStats {
  const AttendanceStats({
    required this.totalDays,
    required this.workDays,
    required this.totalHours,
    required this.averageHours,
    required this.attendanceRate,
    required this.lateCount,
    required this.earlyLeaveCount,
  });

  final int totalDays; // 總天數
  final int workDays; // 工作天數
  final double totalHours; // 總工作時數
  final double averageHours; // 平均每日工作時數
  final double attendanceRate; // 出勤率
  final int lateCount; // 遲到次數
  final int earlyLeaveCount; // 早退次數

}