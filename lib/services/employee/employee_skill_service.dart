import 'package:ctc/models/employee.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmployeeSkillService {
  final SupabaseClient _client;

  EmployeeSkillService(this._client);

  /// 獲取員工技能列表
  Future<List<EmployeeSkill>> getEmployeeSkills(String employeeId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('必須登入才能查看技能資料');
      }

      final response = await _client
          .from('employee_skills')
          .select('*')
          .eq('employee_id', employeeId)
          .order('created_at', ascending: false);

      return response
          .map<EmployeeSkill>((json) => EmployeeSkill.fromJson(json))
          .toList();
    } catch (e) {
      print('獲取員工技能失敗: $e');
      rethrow;
    }
  }

  /// 添加員工技能
  Future<EmployeeSkill> addEmployeeSkill(EmployeeSkill skill) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('必須登入才能添加技能');
      }

      final response = await _client
          .from('employee_skills')
          .insert(skill.toJsonForInsert())
          .select()
          .single();

      return EmployeeSkill.fromJson(response);
    } catch (e) {
      print('添加員工技能失敗: $e');
      rethrow;
    }
  }

  /// 刪除員工技能
  Future<void> deleteEmployeeSkill(String skillId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('必須登入才能刪除技能');
      }

      await _client.from('employee_skills').delete().eq('id', skillId);
    } catch (e) {
      print('刪除員工技能失敗: $e');
      rethrow;
    }
  }
}

