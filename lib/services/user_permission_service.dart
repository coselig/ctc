import 'package:supabase_flutter/supabase_flutter.dart';

/// 用戶權限檢查服務
class UserPermissionService {
  final SupabaseClient _supabase;

  UserPermissionService(this._supabase);

  /// 檢查當前用戶是否在員工列表中
  /// 
  /// 返回 true 表示用戶有員工權限，可以進入系統功能頁面
  /// 返回 false 表示用戶只是一般註冊用戶，只能訪問一般首頁
  Future<bool> isUserInEmployeeList() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // 查詢員工表，檢查是否有對應的 id (使用 auth.users.id)
      final response = await _supabase
          .from('employees')
          .select('id, name, status')
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        print('用戶 ${user.email} 不在員工列表中');
        return false;
      }

      // 檢查員工狀態是否為在職
      final status = response['status'] as String?;
      if (status != '在職') {
        print('用戶 ${user.email} 在員工列表中，但狀態為: $status');
        return false;
      }

      print('用戶 ${user.email} 在員工列表中，姓名: ${response['name']}');
      return true;
    } catch (e) {
      print('檢查用戶權限時發生錯誤: $e');
      // 發生錯誤時預設為無權限，確保安全
      return false;
    }
  }

  /// 獲取當前用戶的員工資訊
  /// 
  /// 如果用戶在員工列表中，返回員工資訊
  /// 否則返回 null
  Future<Map<String, dynamic>?> getCurrentEmployeeInfo() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('employees')
          .select('*')
          .eq('id', user.id)
          .eq('status', '在職')
          .maybeSingle();

      return response;
    } catch (e) {
      print('獲取員工資訊時發生錯誤: $e');
      return null;
    }
  }
}
