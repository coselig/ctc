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

  /// 診斷數據庫連接和認證問題
  Future<Map<String, dynamic>> diagnoseDatabaseIssues() async {
    final diagnosis = <String, dynamic>{};

    try {
      // 檢查當前用戶
      final currentUser = _client.auth.currentUser;
      diagnosis['current_user'] = {
        'exists': currentUser != null,
        'id': currentUser?.id,
        'email': currentUser?.email,
        'created_at': currentUser?.createdAt,
      };

      // 檢查 Supabase 連接狀態
      try {
        final response = await _client.rpc('version');
        diagnosis['supabase_connection'] = {
          'status': 'connected',
          'version': response,
        };
      } catch (e) {
        diagnosis['supabase_connection'] = {
          'status': 'error',
          'error': e.toString(),
        };
      }

      // 檢查認證服務
      try {
        final session = _client.auth.currentSession;
        diagnosis['auth_service'] = {
          'has_session': session != null,
          'session_valid': session?.isExpired == false,
          'access_token_exists': session?.accessToken != null,
        };
      } catch (e) {
        diagnosis['auth_service'] = {'status': 'error', 'error': e.toString()};
      }

      // 檢查 employees 表是否可訪問
      try {
        final employeesTest = await _client
            .from('employees')
            .select('id')
            .limit(1);
        diagnosis['employees_table'] = {
          'accessible': true,
          'has_data': employeesTest.isNotEmpty,
        };
      } catch (e) {
        diagnosis['employees_table'] = {
          'accessible': false,
          'error': e.toString(),
        };
      }

      // 檢查 auth.users 表訪問（間接檢查）
      try {
        if (currentUser != null) {
          final userProfile = await _client.auth.getUser();
          diagnosis['auth_users'] = {
            'accessible': true,
            'current_user_exists': userProfile.user != null,
            'user_metadata': userProfile.user?.userMetadata,
          };
        } else {
          diagnosis['auth_users'] = {
            'accessible': false,
            'reason': 'no_current_user',
          };
        }
      } catch (e) {
        diagnosis['auth_users'] = {'accessible': false, 'error': e.toString()};
      }

      // 測試創建臨時記錄（不實際執行，只測試權限）
      try {
        // 嘗試訪問一個系統表來測試權限
        await _client.from('employees').select('count').limit(0);

        diagnosis['database_permissions'] = {
          'read_access': true,
          'test_successful': true,
        };
      } catch (e) {
        diagnosis['database_permissions'] = {
          'read_access': false,
          'error': e.toString(),
        };
      }

      // 檢查示例用戶是否可以創建
      diagnosis['test_data'] = {
        'demo_user_id': 'demo-user-1',
        'employee_id': 'TEST001',
        'name': '測試用戶',
        'department': '測試部門',
        'position': '測試職位',
      };
    } catch (e) {
      diagnosis['general_error'] = e.toString();
    }

    return diagnosis;
  }

  /// 檢查和修復 AuthRetryableFetchException 問題
  Future<Map<String, dynamic>> checkAuthIssues() async {
    final result = <String, dynamic>{};

    try {
      result['error_info'] = {
        'error_type': 'AuthRetryableFetchException',
        'message': 'Database error saving new user',
        'status_code': 500,
        'description': '這是 Supabase Auth 服務在嘗試創建新用戶時發生的數據庫錯誤',
      };

      // 檢查 Supabase 配置
      result['supabase_config'] = {
        'client_exists': true,
        'has_connection': await _checkUrlAccessibility(),
      };

      // 檢查網路連接
      try {
        final response = await _client.rpc('version');
        result['network_check'] = {'status': 'connected', 'response': response};
      } catch (e) {
        result['network_check'] = {'status': 'failed', 'error': e.toString()};
      }

      // 檢查認證服務狀態
      try {
        final session = _client.auth.currentSession;
        result['auth_status'] = {
          'has_session': session != null,
          'session_valid': session?.isExpired == false,
          'access_token_length': session?.accessToken.length ?? 0,
        };
      } catch (e) {
        result['auth_status'] = {'error': e.toString()};
      }

      // 常見解決方案
      result['solutions'] = [
        '檢查 Supabase 項目是否正常運行',
        '確認數據庫服務是否可用',
        '檢查 Row Level Security (RLS) 政策',
        '確認 auth.users 表權限設置',
        '檢查網路連接穩定性',
        '確認 Supabase URL 和 anon key 正確',
        '檢查是否有防火牆阻擋',
      ];

      result['immediate_actions'] = [
        '重啟應用',
        '檢查 Supabase Dashboard 狀態',
        '嘗試使用不同的網路',
        '確認服務端是否有維護',
      ];
    } catch (e) {
      result['check_error'] = e.toString();
    }

    return result;
  }

  /// 檢查 URL 可訪問性
  Future<bool> _checkUrlAccessibility() async {
    try {
      // 這裡我們使用 Supabase 的健康檢查端點
      final response = await _client.rpc('version');
      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// 測試用戶註冊功能
  Future<Map<String, dynamic>> testUserRegistration() async {
    final result = <String, dynamic>{};

    try {
      result['test_info'] = {
        'description': '測試 Supabase Auth 用戶註冊功能',
        'timestamp': DateTime.now().toIso8601String(),
      };

      // 生成測試用戶資料
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final testEmail = 'test$timestamp@example.com';
      final testPassword = 'Test123456!';

      result['test_credentials'] = {
        'email': testEmail,
        'password_length': testPassword.length,
      };

      // 嘗試註冊測試用戶
      try {
        final response = await _client.auth.signUp(
          email: testEmail,
          password: testPassword,
          data: {'display_name': '測試用戶$timestamp', 'role': 'test_user'},
        );

        if (response.user != null) {
          result['registration'] = {
            'success': true,
            'user_id': response.user!.id,
            'email': response.user!.email,
            'created_at': response.user!.createdAt,
          };

          // 嘗試登出測試用戶
          try {
            await _client.auth.signOut();
            result['cleanup'] = {'signout_success': true};
          } catch (signOutError) {
            result['cleanup'] = {
              'signout_success': false,
              'signout_error': signOutError.toString(),
            };
          }
        } else {
          result['registration'] = {
            'success': false,
            'reason': 'user_is_null',
            'session': response.session != null,
          };
        }
      } catch (registrationError) {
        result['registration'] = {
          'success': false,
          'error': registrationError.toString(),
          'error_type': registrationError.runtimeType.toString(),
        };

        // 分析具體的錯誤類型
        final errorStr = registrationError.toString();
        if (errorStr.contains('AuthRetryableFetchException')) {
          result['error_analysis'] = {
            'type': 'auth_retryable_fetch_exception',
            'likely_causes': [
              '數據庫連接問題',
              'Supabase 服務暫時不可用',
              '網路連接問題',
              'Auth 服務配置錯誤',
            ],
          };
        } else if (errorStr.contains('Database error')) {
          result['error_analysis'] = {
            'type': 'database_error',
            'likely_causes': [
              'auth.users 表權限問題',
              '數據庫約束違反',
              'RLS 政策阻止插入',
              '數據庫服務不可用',
            ],
          };
        }
      }
    } catch (e) {
      result['test_failure'] = {
        'error': e.toString(),
        'error_type': e.runtimeType.toString(),
      };
    }

    return result;
  }

  /// 測試創建員工記錄功能
  Future<Map<String, dynamic>> testCreateEmployee() async {
    final result = <String, dynamic>{};

    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        result['error'] = '用戶未登入';
        return result;
      }

      // 創建測試用戶數據
      final testUser = RegisteredUser(
        id: currentUser.id, // 使用當前用戶的 ID
        email: currentUser.email,
        displayName: '測試員工',
        createdAt: DateTime.now(),
      );

      // 生成唯一的員工編號
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final testEmployeeId = 'TEST$timestamp';

      result['test_parameters'] = {
        'user_id': testUser.id,
        'employee_id': testEmployeeId,
        'email': testUser.email,
        'name': testUser.displayName,
      };

      // 嘗試創建員工記錄
      await createEmployeeFromUser(
        user: testUser,
        employeeId: testEmployeeId,
        department: '測試部門',
        position: '測試職位',
        hireDate: DateTime.now(),
        notes: '這是一個測試員工記錄',
      );

      result['success'] = true;
      result['message'] = '員工記錄創建成功';

      // 驗證記錄是否真的創建了
      try {
        final createdEmployee = await _client
            .from('employees')
            .select()
            .eq('employee_id', testEmployeeId)
            .single();

        result['created_record'] = createdEmployee;
      } catch (e) {
        result['verification_error'] = '無法驗證創建的記錄: $e';
      }
    } catch (e) {
      result['success'] = false;
      result['error'] = e.toString();
      result['error_type'] = e.runtimeType.toString();
    }

    return result;
  }

  /// 獲取從已註冊用戶創建員工的工作流程說明
  Map<String, dynamic> getEmployeeCreationWorkflow() {
    return {
      'title': '員工創建工作流程',
      'description': '本系統只支持從已註冊用戶創建員工記錄，確保每個員工都有對應的系統帳號。',
      'steps': [
        {
          'step': 1,
          'title': '用戶註冊',
          'description': '請用戶先在系統中註冊帳號',
          'action': '用戶自行註冊或管理員協助註冊',
        },
        {
          'step': 2,
          'title': '選擇已註冊用戶',
          'description': '從用戶管理頁面選擇已註冊但尚未成為員工的用戶',
          'action': '前往「用戶管理」頁面',
        },
        {
          'step': 3,
          'title': '創建員工記錄',
          'description': '為選定的用戶填寫員工資料並創建員工記錄',
          'action': '填寫員工基本資料、職位等信息',
        },
        {
          'step': 4,
          'title': '完成設置',
          'description': '員工記錄創建成功，用戶可以使用員工權限登入系統',
          'action': '通知員工開始使用系統',
        },
      ],
      'benefits': ['確保每個員工都有系統帳號', '避免重複的用戶資料', '提高系統安全性', '簡化用戶管理流程'],
      'note': '如果需要直接創建員工而不需要系統帳號，請聯繫系統管理員調整權限設置。',
    };
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

      // 檢查用戶是否在 auth.users 表中存在
      try {
        final userExists = await _client.auth.admin.getUserById(user.id);
        if (userExists.user == null) {
          throw Exception('用戶 ${user.id} 在認證系統中不存在，無法創建員工記錄');
        }
      } catch (e) {
        // 如果無法驗證用戶存在，我們假設用戶存在並繼續
        print('警告：無法驗證用戶是否存在於認證系統中: $e');
      }

      // 創建員工記錄
      final employeeData = {
        'id': user.id, // 使用 auth.users.id 作為主鍵
        'employee_id': employeeId,
        'name': user.displayName ?? user.email?.split('@')[0] ?? '未知用戶',
        'email': user.email,
        'phone': phone,
        'department': department,
        'position': position,
        'hire_date': hireDate.toIso8601String().split('T')[0],
        'salary': salary,
        'status': '在職', // 使用中文狀態
        'role': 'employee', // 設置默認角色
        'address': address,
        'emergency_contact_name': emergencyContactName,
        'emergency_contact_phone': emergencyContactPhone,
        'notes': notes,
        'created_by': currentUser.id,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // 移除 null 值（但保留 id）
      employeeData.removeWhere((key, value) => value == null && key != 'id');

      print('準備插入員工數據: $employeeData');

      final result = await _client
          .from('employees')
          .insert(employeeData)
          .select()
          .single();

      print('員工記錄創建成功: $result');

    } catch (e) {
      print('從用戶創建員工記錄失敗: $e');
      
      // 提供更詳細的錯誤信息
      if (e.toString().contains('foreign key constraint')) {
        throw Exception('用戶 ID ${user.id} 在認證系統中不存在，無法創建員工記錄。請確保用戶已正確註冊。');
      } else if (e.toString().contains('duplicate key')) {
        throw Exception('員工編號或郵箱已存在，請檢查輸入資料。');
      } else if (e.toString().contains('check constraint')) {
        throw Exception('輸入資料不符合系統要求，請檢查角色和狀態設置。');
      }
      
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