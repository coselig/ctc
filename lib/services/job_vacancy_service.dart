import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/job_vacancy.dart';

class JobVacancyService {
  final SupabaseClient _client;

  JobVacancyService(this._client);

  /// 獲取所有活躍的職位空缺
  Future<List<JobVacancy>> getActiveJobVacancies() async {
    try {
      final response = await _client
          .from('job_vacancies')
          .select('*')
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return response
          .map<JobVacancy>((json) => JobVacancy.fromJson(json))
          .toList();
    } catch (e) {
      print('獲取職位空缺失敗: $e');
      throw Exception('獲取職位空缺失敗: $e');
    }
  }

  /// 根據部門獲取職位空缺
  Future<List<JobVacancy>> getJobVacanciesByDepartment(String department) async {
    try {
      final response = await _client
          .from('job_vacancies')
          .select('*')
          .eq('is_active', true)
          .eq('department', department)
          .order('created_at', ascending: false);

      return response
          .map<JobVacancy>((json) => JobVacancy.fromJson(json))
          .toList();
    } catch (e) {
      print('根據部門獲取職位空缺失敗: $e');
      throw Exception('根據部門獲取職位空缺失敗: $e');
    }
  }

  /// 根據類型獲取職位空缺
  Future<List<JobVacancy>> getJobVacanciesByType(String type) async {
    try {
      final response = await _client
          .from('job_vacancies')
          .select('*')
          .eq('is_active', true)
          .eq('type', type)
          .order('created_at', ascending: false);

      return response
          .map<JobVacancy>((json) => JobVacancy.fromJson(json))
          .toList();
    } catch (e) {
      print('根據類型獲取職位空缺失敗: $e');
      throw Exception('根據類型獲取職位空缺失敗: $e');
    }
  }

  /// 獲取特定職位詳情
  Future<JobVacancy?> getJobVacancyById(String id) async {
    try {
      final response = await _client
          .from('job_vacancies')
          .select('*')
          .eq('id', id)
          .eq('is_active', true)
          .maybeSingle();

      if (response != null) {
        return JobVacancy.fromJson(response);
      }
      return null;
    } catch (e) {
      print('獲取職位詳情失敗: $e');
      throw Exception('獲取職位詳情失敗: $e');
    }
  }

  /// 創建新職位空缺（管理員功能）
  Future<JobVacancy> createJobVacancy(JobVacancy jobVacancy) async {
    try {
      final data = jobVacancy.toJson()..remove('id'); // 移除 id，讓資料庫自動生成
      
      final response = await _client
          .from('job_vacancies')
          .insert(data)
          .select()
          .single();

      return JobVacancy.fromJson(response);
    } catch (e) {
      print('創建職位空缺失敗: $e');
      throw Exception('創建職位空缺失敗: $e');
    }
  }

  /// 更新職位空缺（管理員功能）
  Future<JobVacancy> updateJobVacancy(String id, JobVacancy jobVacancy) async {
    try {
      final data = jobVacancy.toJson();
      data['updated_at'] = DateTime.now().toIso8601String();
      
      final response = await _client
          .from('job_vacancies')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return JobVacancy.fromJson(response);
    } catch (e) {
      print('更新職位空缺失敗: $e');
      throw Exception('更新職位空缺失敗: $e');
    }
  }

  /// 刪除職位空缺（軟刪除，設為不活躍）
  Future<void> deleteJobVacancy(String id) async {
    try {
      await _client
          .from('job_vacancies')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      print('刪除職位空缺失敗: $e');
      throw Exception('刪除職位空缺失敗: $e');
    }
  }

  /// 獲取可用的部門列表
  Future<List<String>> getDepartments() async {
    try {
      final response = await _client
          .from('job_vacancies')
          .select('department')
          .eq('is_active', true);

      final departments = response
          .map<String>((item) => item['department'] as String)
          .toSet()
          .toList();
      
      departments.sort();
      return departments;
    } catch (e) {
      print('獲取部門列表失敗: $e');
      throw Exception('獲取部門列表失敗: $e');
    }
  }

  /// 獲取可用的職位類型列表
  Future<List<String>> getJobTypes() async {
    try {
      final response = await _client
          .from('job_vacancies')
          .select('type')
          .eq('is_active', true);

      final types = response
          .map<String>((item) => item['type'] as String)
          .toSet()
          .toList();
      
      types.sort();
      return types;
    } catch (e) {
      print('獲取職位類型列表失敗: $e');
      throw Exception('獲取職位類型列表失敗: $e');
    }
  }
}