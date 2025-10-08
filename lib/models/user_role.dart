/// 用戶角色枚舉
enum UserRole {
  /// 老闆：最高權限
  boss('boss', '老闆'),
  
  /// 人事：人力資源管理權限
  hr('hr', '人事'),
  
  /// 一般員工：基本權限
  employee('employee', '一般員工');

  const UserRole(this.value, this.displayName);

  final String value;
  final String displayName;

  /// 從字串轉換為角色
  static UserRole fromString(String value) {
    switch (value) {
      case 'boss':
        return UserRole.boss;
      case 'hr':
        return UserRole.hr;
      case 'employee':
      default:
        return UserRole.employee;
    }
  }

  /// 是否為老闆
  bool get isBoss => this == UserRole.boss;

  /// 是否為人事
  bool get isHR => this == UserRole.hr;

  /// 是否為一般員工
  bool get isEmployee => this == UserRole.employee;

  /// 是否為管理者（老闆或人事）
  bool get isManager => this == UserRole.boss || this == UserRole.hr;

  // ============ 權限檢查 ============

  /// 是否可以查看所有員工資料
  bool get canViewAllEmployees => isManager;

  /// 是否可以編輯員工資料
  bool get canEditEmployees => isManager;

  /// 是否可以刪除員工
  bool get canDeleteEmployees => isBoss;

  /// 是否可以查看薪資資訊
  bool get canViewSalary => isManager;

  /// 是否可以編輯薪資資訊
  bool get canEditSalary => isBoss;

  /// 是否可以查看所有打卡記錄
  bool get canViewAllAttendance => isManager;

  /// 是否可以補打卡（為他人新增打卡記錄）
  bool get canManualAttendance => isManager;

  /// 是否可以匯出報表
  bool get canExportReports => isManager;

  /// 是否可以修改系統設定
  bool get canEditSettings => isBoss;

  /// 是否可以管理角色權限
  bool get canManageRoles => isBoss;

  /// 是否可以查看指定員工的詳細資料
  /// [employeeId] 要查看的員工ID
  /// [currentUserId] 當前用戶ID
  bool canViewEmployeeDetail(String employeeId, String currentUserId) {
    if (isManager) return true;
    return employeeId == currentUserId;
  }

  /// 是否可以編輯指定員工的資料
  /// [targetRole] 目標員工的角色
  /// [employeeId] 要編輯的員工ID
  /// [currentUserId] 當前用戶ID
  bool canEditEmployeeDetail(
    UserRole targetRole,
    String employeeId,
    String currentUserId,
  ) {
    // 老闆可以編輯所有人
    if (isBoss) return true;
    
    // 人事可以編輯除了老闆以外的所有人
    if (isHR && !targetRole.isBoss) return true;
    
    // 一般員工只能編輯自己的基本資料
    if (isEmployee && employeeId == currentUserId) return true;
    
    return false;
  }

  /// 是否可以查看指定員工的打卡記錄
  /// [employeeId] 要查看的員工ID
  /// [currentUserId] 當前用戶ID
  bool canViewAttendance(String employeeId, String currentUserId) {
    if (isManager) return true;
    return employeeId == currentUserId;
  }
}
