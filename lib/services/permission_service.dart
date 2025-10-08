import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/employee.dart';
import '../models/user_role.dart';

/// 權限管理服務
class PermissionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 獲取當前用戶的員工資料（包含角色）
  Future<Employee?> getCurrentEmployee() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('employees')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) return null;
      return Employee.fromJson(response);
    } catch (e) {
      print('獲取當前用戶員工資料失敗: $e');
      return null;
    }
  }

  /// 獲取當前用戶的角色
  Future<UserRole> getCurrentUserRole() async {
    final employee = await getCurrentEmployee();
    return employee?.role ?? UserRole.employee;
  }

  /// 檢查當前用戶是否為老闆
  Future<bool> isBoss() async {
    final role = await getCurrentUserRole();
    return role.isBoss;
  }

  /// 檢查當前用戶是否為人事
  Future<bool> isHR() async {
    final role = await getCurrentUserRole();
    return role.isHR;
  }

  /// 檢查當前用戶是否為管理者（老闆或人事）
  Future<bool> isManager() async {
    final role = await getCurrentUserRole();
    return role.isManager;
  }

  /// 檢查是否可以查看所有員工資料
  Future<bool> canViewAllEmployees() async {
    final role = await getCurrentUserRole();
    return role.canViewAllEmployees;
  }

  /// 檢查是否可以編輯員工資料
  Future<bool> canEditEmployees() async {
    final role = await getCurrentUserRole();
    return role.canEditEmployees;
  }

  /// 檢查是否可以刪除員工
  Future<bool> canDeleteEmployees() async {
    final role = await getCurrentUserRole();
    return role.canDeleteEmployees;
  }

  /// 檢查是否可以查看薪資資訊
  Future<bool> canViewSalary() async {
    final role = await getCurrentUserRole();
    return role.canViewSalary;
  }

  /// 檢查是否可以編輯薪資資訊
  Future<bool> canEditSalary() async {
    final role = await getCurrentUserRole();
    return role.canEditSalary;
  }

  /// 檢查是否可以查看所有打卡記錄
  Future<bool> canViewAllAttendance() async {
    final role = await getCurrentUserRole();
    return role.canViewAllAttendance;
  }

  /// 檢查是否可以補打卡
  Future<bool> canManualAttendance() async {
    final role = await getCurrentUserRole();
    return role.canManualAttendance;
  }

  /// 檢查是否可以匯出報表
  Future<bool> canExportReports() async {
    final role = await getCurrentUserRole();
    return role.canExportReports;
  }

  /// 檢查是否可以修改系統設定
  Future<bool> canEditSettings() async {
    final role = await getCurrentUserRole();
    return role.canEditSettings;
  }

  /// 檢查是否可以管理角色權限
  Future<bool> canManageRoles() async {
    final role = await getCurrentUserRole();
    return role.canManageRoles;
  }

  /// 檢查是否可以查看指定員工的詳細資料
  Future<bool> canViewEmployeeDetail(String employeeId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    final role = await getCurrentUserRole();
    return role.canViewEmployeeDetail(employeeId, user.id);
  }

  /// 檢查是否可以編輯指定員工的資料
  Future<bool> canEditEmployeeDetail(String employeeId, UserRole targetRole) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    final role = await getCurrentUserRole();
    return role.canEditEmployeeDetail(targetRole, employeeId, user.id);
  }

  /// 檢查是否可以查看指定員工的打卡記錄
  Future<bool> canViewAttendanceForEmployee(String employeeId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    final role = await getCurrentUserRole();
    return role.canViewAttendance(employeeId, user.id);
  }

  /// 更新員工角色（僅老闆可用）
  Future<bool> updateEmployeeRole(String employeeId, UserRole newRole) async {
    try {
      // 檢查權限
      if (!await canManageRoles()) {
        print('沒有權限修改員工角色');
        return false;
      }

      await _supabase
          .from('employees')
          .update({'role': newRole.value})
          .eq('id', employeeId);

      return true;
    } catch (e) {
      print('更新員工角色失敗: $e');
      return false;
    }
  }

  /// 獲取所有管理者（老闆和人事）
  Future<List<Employee>> getManagers() async {
    try {
      final response = await _supabase
          .from('employees')
          .select()
          .inFilter('role', ['boss', 'hr']);

      return (response as List)
          .map((json) => Employee.fromJson(json))
          .toList();
    } catch (e) {
      print('獲取管理者列表失敗: $e');
      return [];
    }
  }

  /// 獲取所有老闆
  Future<List<Employee>> getBosses() async {
    try {
      final response = await _supabase
          .from('employees')
          .select()
          .eq('role', 'boss');

      return (response as List)
          .map((json) => Employee.fromJson(json))
          .toList();
    } catch (e) {
      print('獲取老闆列表失敗: $e');
      return [];
    }
  }

  /// 獲取所有人事
  Future<List<Employee>> getHRs() async {
    try {
      final response = await _supabase
          .from('employees')
          .select()
          .eq('role', 'hr');

      return (response as List)
          .map((json) => Employee.fromJson(json))
          .toList();
    } catch (e) {
      print('獲取人事列表失敗: $e');
      return [];
    }
  }
}
