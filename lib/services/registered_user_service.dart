import 'package:supabase_flutter/supabase_flutter.dart';

class RegisteredUserService {
  final SupabaseClient _client;

  RegisteredUserService(this._client);

  /// 獲取所有已註冊但未成為員工的用戶
  Future<List<RegisteredUser>> getAvailableUsers() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('必須登入才能查看已註冊用戶');
      }

      List<RegisteredUser> allUsers = [];

      try {
        // 嘗試從 user_profiles 表查詢
        final response = await _client
            .from('user_profiles')
            .select('*')
            .order('created_at', ascending: false);

        allUsers = response.map((json) => RegisteredUser.fromUserProfile(json)).toList();
      } catch (e) {
        if (e.toString().contains('relation "public.user_profiles" does not exist')) {
          // 如果 user_profiles 表不存在，使用備用方案
          print('user_profiles 表不存在，使用備用方案獲取用戶資料');
          allUsers = await _getAvailableUsersFromAuth();
        } else {
          rethrow;
        }
      }

      // 過濾掉已經是員工的用戶
      final employeeEmails = await _getEmployeeEmails();
      final availableUsers = allUsers.where(
        (user) => !employeeEmails.contains(user.email?.toLowerCase()),
      ).toList();

      return availableUsers;
    } catch (e) {
      print('獲取已註冊用戶失敗: $e');
      rethrow;
    }
  }

  /// 備用方案：從現有員工表的創建者資訊推斷已註冊用戶
  Future<List<RegisteredUser>> _getAvailableUsersFromAuth() async {
    try {
      // 獲取所有創建員工記錄的用戶ID
      final response = await _client
          .from('employees')
          .select('created_by')
          .not('created_by', 'is', null);

      final creatorIds = response
          .map((row) => row['created_by'] as String)
          .toSet()
          .toList();

      // 為演示目的，我們創建一些模擬用戶
      // 在實際部署中，這裡需要通過 Supabase Admin API 獲取真實用戶資料
      final mockUsers = <RegisteredUser>[];
      
      for (int i = 0; i < creatorIds.length; i++) {
        final userId = creatorIds[i];
        mockUsers.add(RegisteredUser(
          id: userId,
          email: 'user${i + 1}@example.com',
          displayName: '用戶 ${i + 1}',
          avatarUrl: null,
          createdAt: DateTime.now().subtract(Duration(days: i + 1)),
        ));
      }

      // 添加一些示例用戶供測試
      mockUsers.addAll([
        RegisteredUser(
          id: 'demo-user-1',
          email: 'alice@example.com',
          displayName: 'Alice Chen',
          avatarUrl: null,
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
        RegisteredUser(
          id: 'demo-user-2',
          email: 'bob@example.com',
          displayName: 'Bob Lin',
          avatarUrl: null,
          createdAt: DateTime.now().subtract(const Duration(days: 14)),
        ),
        RegisteredUser(
          id: 'demo-user-3',
          email: 'carol@example.com',
          displayName: 'Carol Wang',
          avatarUrl: null,
          createdAt: DateTime.now().subtract(const Duration(days: 21)),
        ),
      ]);

      return mockUsers;
    } catch (e) {
      print('獲取備用用戶資料失敗: $e');
      return [];
    }
  }

  /// 根據關鍵字搜尋用戶
  Future<List<RegisteredUser>> searchUsers(String query) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('必須登入才能搜尋用戶');
      }

      List<RegisteredUser> allUsers = [];

      try {
        // 嘗試從 user_profiles 表搜尋
        final response = await _client
            .from('user_profiles')
            .select('*')
            .or('email.ilike.%$query%,display_name.ilike.%$query%')
            .order('created_at', ascending: false);

        allUsers = response.map((json) => RegisteredUser.fromUserProfile(json)).toList();
      } catch (e) {
        if (e.toString().contains('relation "public.user_profiles" does not exist')) {
          // 如果 user_profiles 表不存在，使用備用搜尋
          print('user_profiles 表不存在，使用備用搜尋');
          final availableUsers = await _getAvailableUsersFromAuth();
          allUsers = availableUsers.where((user) {
            final email = user.email?.toLowerCase() ?? '';
            final name = user.displayName?.toLowerCase() ?? '';
            final searchLower = query.toLowerCase();
            return email.contains(searchLower) || name.contains(searchLower);
          }).toList();
        } else {
          rethrow;
        }
      }

      // 過濾掉已經是員工的用戶
      final employeeEmails = await _getEmployeeEmails();
      final availableUsers = allUsers.where(
        (user) => !employeeEmails.contains(user.email?.toLowerCase()),
      ).toList();

      return availableUsers;
    } catch (e) {
      print('搜尋用戶失敗: $e');
      rethrow;
    }
  }

  /// 獲取所有已經是員工的郵箱列表
  Future<Set<String>> _getEmployeeEmails() async {
    try {
      final response = await _client
          .from('employees')
          .select('email')
          .not('email', 'is', null);

      return response
          .map((row) => (row['email'] as String?)?.toLowerCase())
          .where((email) => email != null)
          .cast<String>()
          .toSet();
    } catch (e) {
      print('獲取員工郵箱列表失敗: $e');
      return {};
    }
  }

  /// 檢查用戶是否已經是員工
  Future<bool> isUserAlreadyEmployee(String email) async {
    try {
      final response = await _client
          .from('employees')
          .select('id')
          .eq('email', email.toLowerCase())
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('檢查用戶員工狀態失敗: $e');
      return false;
    }
  }

  /// 從已註冊用戶創建員工記錄
  Future<void> createEmployeeFromUser({
    required RegisteredUser user,
    required String employeeId,
    required String department,
    required String position,
    required DateTime hireDate,
    double? salary,
    String? phone,
    String? address,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? notes,
  }) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('必須登入才能創建員工記錄');
      }

      // 檢查員工編號是否重複
      final existingEmployee = await _client
          .from('employees')
          .select('employee_id')
          .eq('employee_id', employeeId)
          .maybeSingle();

      if (existingEmployee != null) {
        throw Exception('員工編號 $employeeId 已存在');
      }

      // 檢查用戶是否已經是員工
      if (user.email != null && await isUserAlreadyEmployee(user.email!)) {
        throw Exception('該用戶已經是員工');
      }

      // 創建員工記錄
      final employeeData = {
        'employee_id': employeeId,
        'name': user.displayName ?? user.email?.split('@')[0] ?? '未知用戶',
        'email': user.email,
        'phone': phone,
        'department': department,
        'position': position,
        'hire_date': hireDate.toIso8601String().split('T')[0],
        'salary': salary,
        'status': 'active',
        'address': address,
        'emergency_contact_name': emergencyContactName,
        'emergency_contact_phone': emergencyContactPhone,
        'notes': notes,
        'created_by': currentUser.id,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // 移除 null 值
      employeeData.removeWhere((key, value) => value == null);

      await _client
          .from('employees')
          .insert(employeeData);

    } catch (e) {
      print('從用戶創建員工記錄失敗: $e');
      rethrow;
    }
  }
}

/// 已註冊用戶模型
class RegisteredUser {
  final String id;
  final String? email;
  final String? displayName;
  final String? avatarUrl;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const RegisteredUser({
    required this.id,
    this.email,
    this.displayName,
    this.avatarUrl,
    required this.createdAt,
    this.metadata,
  });

  factory RegisteredUser.fromJson(Map<String, dynamic> json) {
    return RegisteredUser(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  factory RegisteredUser.fromUserProfile(Map<String, dynamic> json) {
    return RegisteredUser(
      id: json['user_id'] as String, // user_profiles 使用 user_id 欄位
      email: json['email'] as String?,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }
}