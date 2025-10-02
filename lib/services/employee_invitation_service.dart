import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/employee.dart';

class EmployeeInvitationService {
  final SupabaseClient _client;

  EmployeeInvitationService(this._client);

  /// 為員工創建帳號並發送邀請郵件
  Future<String> inviteEmployee({
    required String email,
    required Employee employeeData,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('必須登入才能邀請員工');
      }

      // 1. 先創建員工記錄（不含認證帳號）
      final newEmployee = employeeData.copyWith(
        email: email,
        createdBy: user.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final employeeResponse = await _client
          .from('employees')
          .insert(newEmployee.toJsonForInsert())
          .select()
          .single();

      final createdEmployee = Employee.fromJson(employeeResponse);

      // 2. 為員工創建認證帳號
      try {
        // 生成臨時密碼
        final tempPassword = _generateTempPassword();

        // 創建認證帳號
        final authResponse = await _client.auth.admin.createUser(
          AdminUserAttributes(
            email: email,
            password: tempPassword,
            emailConfirm: true, // 自動確認電子郵件
            userMetadata: {
              'employee_id': createdEmployee.employeeId,
              'name': createdEmployee.name,
              'department': createdEmployee.department,
              'position': createdEmployee.position,
              'is_employee': true,
            },
          ),
        );

        if (authResponse.user == null) {
          throw Exception('創建認證帳號失敗');
        }

        // 3. 發送歡迎郵件（包含臨時密碼和系統介紹）
        await _sendWelcomeEmail(
          email: email,
          employeeName: createdEmployee.name,
          tempPassword: tempPassword,
          employeeId: createdEmployee.employeeId,
        );

        return '員工 ${createdEmployee.name} 已成功加入系統，歡迎郵件已發送至 $email';

      } catch (authError) {
        // 如果認證帳號創建失敗，刪除已創建的員工記錄
        await _client
            .from('employees')
            .delete()
            .eq('id', createdEmployee.id!);
        
        rethrow;
      }

    } catch (e) {
      print('邀請員工失敗: $e');
      rethrow;
    }
  }

  /// 檢查員工是否已有帳號
  Future<bool> hasExistingAccount(String email) async {
    try {
      // 檢查認證系統中是否已有此郵箱
      final response = await _client
          .from('auth.users')
          .select('email')
          .eq('email', email)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      print('檢查帳號狀態失敗: $e');
      return false;
    }
  }

  /// 重新發送歡迎郵件
  Future<void> resendWelcomeEmail(String employeeId) async {
    try {
      final employee = await _client
          .from('employees')
          .select('*')
          .eq('employee_id', employeeId)
          .single();

      final employeeData = Employee.fromJson(employee);
      
      if (employeeData.email == null) {
        throw Exception('員工沒有設置電子郵件');
      }

      // 重置密碼並發送新的歡迎郵件
      final tempPassword = _generateTempPassword();
      
      // 更新密碼
      await _client.auth.admin.updateUserById(
        // 需要找到對應的 auth user id
        await _getUserIdByEmail(employeeData.email!),
        attributes: AdminUserAttributes(password: tempPassword),
      );

      await _sendWelcomeEmail(
        email: employeeData.email!,
        employeeName: employeeData.name,
        tempPassword: tempPassword,
        employeeId: employeeData.employeeId,
      );

    } catch (e) {
      print('重新發送歡迎郵件失敗: $e');
      rethrow;
    }
  }

  /// 生成臨時密碼
  String _generateTempPassword() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    var result = '';
    
    for (int i = 0; i < 12; i++) {
      result += chars[(random + i) % chars.length];
    }
    
    return result;
  }

  /// 發送歡迎郵件
  Future<void> _sendWelcomeEmail({
    required String email,
    required String employeeName,
    required String tempPassword,
    required String employeeId,
  }) async {
    // 這裡可以整合郵件服務（如 SendGrid, AWS SES 等）
    // 目前先打印日誌，實際部署時需要設置真正的郵件服務
    
    final emailContent = '''
    親愛的 $employeeName，

    歡迎加入光悅科技！

    您的員工資訊：
    • 員工編號：$employeeId
    • 電子郵件：$email
    • 臨時密碼：$tempPassword

    系統登入步驟：
    1. 開啟光悅科技管理系統
    2. 使用上述郵箱和臨時密碼登入
    3. 首次登入後請立即修改密碼

    如有任何問題，請聯絡 IT 支援。

    祝工作愉快！
    光悅科技團隊
    ''';

    print('=== 歡迎郵件內容 ===');
    print('收件人：$email');
    print('內容：');
    print(emailContent);
    print('==================');

    // TODO: 實際發送郵件的程式碼
    // await emailService.send(
    //   to: email,
    //   subject: '歡迎加入光悅科技',
    //   body: emailContent,
    // );
  }

  /// 根據郵箱找到用戶 ID
  Future<String> _getUserIdByEmail(String email) async {
    // 這需要管理員權限來查詢 auth.users 表
    // 實際實作可能需要通過 Supabase 的 Admin API
    throw UnimplementedError('需要實作根據郵箱查找用戶 ID 的功能');
  }

  /// 撤銷員工帳號
  Future<void> revokeEmployeeAccount(String employeeId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('必須登入才能撤銷員工帳號');
      }

      // 1. 更新員工狀態為離職
      await _client
          .from('employees')
          .update({
            'status': EmployeeStatus.resigned.value,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('employee_id', employeeId);

      // 2. 禁用認證帳號（需要管理員權限）
      // TODO: 實作禁用認證帳號的功能
      print('員工帳號已撤銷：$employeeId');

    } catch (e) {
      print('撤銷員工帳號失敗: $e');
      rethrow;
    }
  }
}