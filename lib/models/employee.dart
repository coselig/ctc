import 'user_role.dart';

class Employee {
  final String? id;
  final String employeeId; // 員工編號
  final String name;
  final String? email;
  final String? phone;
  final String department;
  final String position;
  final DateTime hireDate;
  final double? salary;
  final EmployeeStatus status;
  final UserRole role; // 員工角色
  final String? managerId;
  final String? avatarUrl;
  final String? address;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Employee({
    this.id,
    required this.employeeId,
    required this.name,
    this.email,
    this.phone,
    required this.department,
    required this.position,
    required this.hireDate,
    this.salary,
    this.status = EmployeeStatus.active,
    this.role = UserRole.employee,
    this.managerId,
    this.avatarUrl,
    this.address,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.notes,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as String?,
      employeeId: json['employee_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      department: json['department'] as String,
      position: json['position'] as String,
      hireDate: DateTime.parse(json['hire_date'] as String),
      salary: json['salary'] != null ? (json['salary'] as num).toDouble() : null,
      status: EmployeeStatus.fromString(json['status'] as String? ?? 'active'),
      role: UserRole.fromString(json['role'] as String? ?? 'employee'),
      managerId: json['manager_id'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      address: json['address'] as String?,
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactPhone: json['emergency_contact_phone'] as String?,
      notes: json['notes'] as String?,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'name': name,
      'email': email,
      'phone': phone,
      'department': department,
      'position': position,
      'hire_date': hireDate.toIso8601String(),
      'salary': salary,
      'status': status.value,
      'role': role.value,
      'manager_id': managerId,
      'avatar_url': avatarUrl,
      'address': address,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'notes': notes,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 用於插入新員工到資料庫（必須包含 id 欄位，使用 auth.users.id）
  Map<String, dynamic> toJsonForInsert() {
    final json = <String, dynamic>{
      'id': id, // 必須包含，使用 auth.users.id
      'employee_id': employeeId,
      'name': name,
      'email': email,
      'phone': phone,
      'department': department,
      'position': position,
      'hire_date': hireDate.toIso8601String(),
      'salary': salary,
      'status': status.value,
      'role': role.value,
      'manager_id': managerId,
      'avatar_url': avatarUrl,
      'address': address,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'notes': notes,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    
    // 移除 null 值欄位（但保留 id）
    json.removeWhere((key, value) => value == null && key != 'id');
    return json;
  }

  Employee copyWith({
    String? id,
    String? employeeId,
    String? name,
    String? email,
    String? phone,
    String? department,
    String? position,
    DateTime? hireDate,
    double? salary,
    EmployeeStatus? status,
    UserRole? role,
    String? managerId,
    String? avatarUrl,
    String? address,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Employee(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      position: position ?? this.position,
      hireDate: hireDate ?? this.hireDate,
      salary: salary ?? this.salary,
      status: status ?? this.status,
      role: role ?? this.role,
      managerId: managerId ?? this.managerId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      address: address ?? this.address,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum EmployeeStatus {
  active('在職', '在職'),
  inactive('留職停薪', '留職停薪'),
  resigned('離職', '離職'),
  terminated('解雇', '解雇');

  const EmployeeStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static EmployeeStatus fromString(String value) {
    switch (value) {
      case '在職':
      case 'active':
        return EmployeeStatus.active;
      case '留職停薪':
      case 'inactive':
        return EmployeeStatus.inactive;
      case '離職':
      case 'resigned':
        return EmployeeStatus.resigned;
      case '解雇':
      case 'terminated':
        return EmployeeStatus.terminated;
      default:
        return EmployeeStatus.active;
    }
  }
}

class EmployeeSkill {
  final String? id;
  final String employeeId;
  final String skillName;
  final int proficiencyLevel; // 1-5 級
  final DateTime createdAt;

  const EmployeeSkill({
    this.id,
    required this.employeeId,
    required this.skillName,
    required this.proficiencyLevel,
    required this.createdAt,
  });

  factory EmployeeSkill.fromJson(Map<String, dynamic> json) {
    return EmployeeSkill(
      id: json['id'] as String?,
      employeeId: json['employee_id'] as String,
      skillName: json['skill_name'] as String,
      proficiencyLevel: json['proficiency_level'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'skill_name': skillName,
      'proficiency_level': proficiencyLevel,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// 用於插入新技能到資料庫（不包含 id 欄位）
  Map<String, dynamic> toJsonForInsert() {
    return {
      'employee_id': employeeId,
      'skill_name': skillName,
      'proficiency_level': proficiencyLevel,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class EmployeeAttendance {
  final String? id;
  final String employeeId;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final int breakDuration; // 分鐘
  final double? totalHours;
  final AttendanceStatus status;
  final String? notes;
  final DateTime createdAt;

  const EmployeeAttendance({
    this.id,
    required this.employeeId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.breakDuration = 0,
    this.totalHours,
    this.status = AttendanceStatus.present,
    this.notes,
    required this.createdAt,
  });

  factory EmployeeAttendance.fromJson(Map<String, dynamic> json) {
    return EmployeeAttendance(
      id: json['id'] as String?,
      employeeId: json['employee_id'] as String,
      date: DateTime.parse(json['date'] as String),
      checkInTime: json['check_in_time'] != null 
          ? DateTime.parse(json['check_in_time'] as String) 
          : null,
      checkOutTime: json['check_out_time'] != null 
          ? DateTime.parse(json['check_out_time'] as String) 
          : null,
      breakDuration: json['break_duration'] as int? ?? 0,
      totalHours: json['total_hours'] != null 
          ? (json['total_hours'] as num).toDouble() 
          : null,
      status: AttendanceStatus.fromString(json['status'] as String? ?? 'present'),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'date': date.toIso8601String().split('T')[0], // 只保留日期部分
      'check_in_time': checkInTime?.toIso8601String(),
      'check_out_time': checkOutTime?.toIso8601String(),
      'break_duration': breakDuration,
      'total_hours': totalHours,
      'status': status.value,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// 用於插入新考勤記錄到資料庫（不包含 id 欄位）
  Map<String, dynamic> toJsonForInsert() {
    final json = <String, dynamic>{
      'employee_id': employeeId,
      'date': date.toIso8601String().split('T')[0],
      'check_in_time': checkInTime?.toIso8601String(),
      'check_out_time': checkOutTime?.toIso8601String(),
      'break_duration': breakDuration,
      'total_hours': totalHours,
      'status': status.value,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
    
    // 移除 null 值欄位
    json.removeWhere((key, value) => value == null);
    return json;
  }
}

enum AttendanceStatus {
  present('present', '出勤'),
  absent('absent', '缺勤'),
  late('late', '遲到'),
  sickLeave('sick_leave', '病假'),
  annualLeave('annual_leave', '年假'),
  personalLeave('personal_leave', '事假');

  const AttendanceStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static AttendanceStatus fromString(String value) {
    switch (value) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent':
        return AttendanceStatus.absent;
      case 'late':
        return AttendanceStatus.late;
      case 'sick_leave':
        return AttendanceStatus.sickLeave;
      case 'annual_leave':
        return AttendanceStatus.annualLeave;
      case 'personal_leave':
        return AttendanceStatus.personalLeave;
      default:
        return AttendanceStatus.present;
    }
  }
}

class EmployeeEvaluation {
  final String? id;
  final String employeeId;
  final String evaluationPeriod;
  final int? overallRating; // 1-5 分
  final String? performanceGoals;
  final String? achievements;
  final String? areasForImprovement;
  final String evaluatorId;
  final DateTime evaluationDate;
  final DateTime createdAt;

  const EmployeeEvaluation({
    this.id,
    required this.employeeId,
    required this.evaluationPeriod,
    this.overallRating,
    this.performanceGoals,
    this.achievements,
    this.areasForImprovement,
    required this.evaluatorId,
    required this.evaluationDate,
    required this.createdAt,
  });

  factory EmployeeEvaluation.fromJson(Map<String, dynamic> json) {
    return EmployeeEvaluation(
      id: json['id'] as String?,
      employeeId: json['employee_id'] as String,
      evaluationPeriod: json['evaluation_period'] as String,
      overallRating: json['overall_rating'] as int?,
      performanceGoals: json['performance_goals'] as String?,
      achievements: json['achievements'] as String?,
      areasForImprovement: json['areas_for_improvement'] as String?,
      evaluatorId: json['evaluator_id'] as String,
      evaluationDate: DateTime.parse(json['evaluation_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'evaluation_period': evaluationPeriod,
      'overall_rating': overallRating,
      'performance_goals': performanceGoals,
      'achievements': achievements,
      'areas_for_improvement': areasForImprovement,
      'evaluator_id': evaluatorId,
      'evaluation_date': evaluationDate.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// 用於插入新評估到資料庫（不包含 id 欄位）
  Map<String, dynamic> toJsonForInsert() {
    final json = <String, dynamic>{
      'employee_id': employeeId,
      'evaluation_period': evaluationPeriod,
      'overall_rating': overallRating,
      'performance_goals': performanceGoals,
      'achievements': achievements,
      'areas_for_improvement': areasForImprovement,
      'evaluator_id': evaluatorId,
      'evaluation_date': evaluationDate.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
    };
    
    // 移除 null 值欄位
    json.removeWhere((key, value) => value == null);
    return json;
  }
}