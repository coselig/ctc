
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/employee.dart';
import '../general/user_service.dart';

class EmployeeService extends UserService {
  EmployeeService(SupabaseClient client) : super(client);

  /// 取得目前登入者的員工資料
  Future<Employee?> getCurrentEmployee() async {
    final user = requireAuthUser();
    return getEmployeeById(user.id);
  }

  /// 獲取所有員工列表
  Future<List<Employee>> getAllEmployees({
    String? department,
    EmployeeStatus? status,
    String? searchQuery,
  }) async {
    try {
      requireAuthUser();

      var query = client.from('employees').select('*');

      // 篩選條件
      if (department != null && department.isNotEmpty) {
        query = query.eq('department', department);
      }

      if (status != null) {
        query = query.eq('status', status.value);
      }

      // 搜尋功能（姓名或員工編號）
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'name.ilike.%$searchQuery%,employee_id.ilike.%$searchQuery%',
        );
      }

      final response = await query.order('created_at', ascending: false);
      return response.map<Employee>((json) => Employee.fromJson(json)).toList();
    } catch (e) {
      print('獲取員工列表失敗: $e');
      rethrow;
    }
  }

  /// 根據ID獲取單個員工資料
  Future<Employee?> getEmployeeById(String id) async {
    try {
      requireAuthUser();

      final response = await client
          .from('employees')
          .select('*')
          .eq('id', id)
          .single();

      return Employee.fromJson(response);
    } catch (e) {
      print('獲取員工資料失敗: $e');
      return null;
    }
  }

  /// 根據Email獲取員工資料
  Future<Employee?> getEmployeeByEmail(String email) async {
    try {
      requireAuthUser();

      final response = await client
          .from('employees')
          .select('*')
          .eq('email', email)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return Employee.fromJson(response);
    } catch (e) {
      print('根據Email獲取員工資料失敗: $e');
      return null;
    }
  }

  /// 創建新員工
  Future<Employee> createEmployee(Employee employee) async {
    try {
      final user = requireAuthUser();

      // 檢查員工編號是否重複
      final existingEmployee = await client
          .from('employees')
          .select('employee_id')
          .eq('employee_id', employee.employeeId)
          .maybeSingle();

      if (existingEmployee != null) {
        throw Exception('員工編號 ${employee.employeeId} 已存在');
      }

      final newEmployee = employee.copyWith(
        createdBy: user.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final response = await client
          .from('employees')
          .insert(newEmployee.toJsonForInsert())
          .select()
          .single();

      return Employee.fromJson(response);
    } catch (e) {
      print('創建員工失敗: $e');
      rethrow;
    }
  }

  /// 更新員工資料
  Future<Employee> updateEmployee(String id, Employee employee) async {
    try {
      requireAuthUser();

      final updatedEmployee = employee.copyWith(
        id: id,
        updatedAt: DateTime.now(),
      );

      final response = await client
          .from('employees')
          .update(updatedEmployee.toJson())
          .eq('id', id)
          .select()
          .single();

      return Employee.fromJson(response);
    } catch (e) {
      print('更新員工資料失敗: $e');
      rethrow;
    }
  }

  /// 刪除員工（軟刪除，設為離職狀態）
  Future<void> deleteEmployee(String id) async {
    try {
      requireAuthUser();

      await client
          .from('employees')
          .update({
            'status': EmployeeStatus.resigned.value,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      print('刪除員工失敗: $e');
      rethrow;
    }
  }

  /// 獲取所有部門列表
  Future<List<String>> getDepartments() async {
    try {
      requireAuthUser();

      final response = await client
          .from('employees')
          .select('department')
          .neq('status', 'resigned');

      final departments = response
          .map((row) => row['department'] as String)
          .toSet()
          .toList();

      departments.sort();
      return departments;
    } catch (e) {
      print('獲取部門列表失敗: $e');
      return [];
    }
  }

  /// 獲取所有職位列表
  Future<List<String>> getPositions() async {
    try {
      requireAuthUser();

      final response = await client
          .from('employees')
          .select('position')
          .neq('status', 'resigned');

      final positions = response
          .map((row) => row['position'] as String)
          .toSet()
          .toList();

      positions.sort();
      return positions;
    } catch (e) {
      print('獲取職位列表失敗: $e');
      return [];
    }
  }

  /// 生成下一個員工編號
  Future<String> generateEmployeeId() async {
    try {
      final response = await client
          .from('employees')
          .select('employee_id')
          .order('employee_id', ascending: false)
          .limit(1);

      if (response.isEmpty) {
        return 'EMP001';
      }

      final lastId = response.first['employee_id'] as String;
      final match = RegExp(r'EMP(\d+)').firstMatch(lastId);

      if (match != null) {
        final number = int.parse(match.group(1)!) + 1;
        return 'EMP${number.toString().padLeft(3, '0')}';
      } else {
        return 'EMP001';
      }
    } catch (e) {
      print('生成員工編號失敗: $e');
      return 'EMP001';
    }
  }

  /// 獲取員工統計資料
  Future<Map<String, int>> getEmployeeStatistics() async {
    try {
      requireAuthUser();

      final response = await client.from('employees').select('status');

      final stats = <String, int>{};
      for (final status in EmployeeStatus.values) {
        stats[status.displayName] = response
            .where((row) => row['status'] == status.value)
            .length;
      }

      return stats;
    } catch (e) {
      print('獲取統計資料失敗: $e');
      return {};
    }
  }
}