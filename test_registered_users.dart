import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'lib/services/registered_user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 Supabase
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  // 測試註冊用戶服務
  final service = RegisteredUserService(Supabase.instance.client);
  
  print('=== 測試註冊用戶服務 ===');
  
  try {
    print('正在獲取可用用戶...');
    final users = await service.getAvailableUsers();
    print('成功獲取 ${users.length} 個用戶');
    
    for (final user in users) {
      print('- ${user.email} (${user.displayName ?? "未設定姓名"})');
    }
    
    if (users.isNotEmpty) {
      final testEmail = users.first.email;
      if (testEmail != null) {
        print('\n正在檢查用戶 $testEmail 是否為員工...');
        final isEmployee = await service.isUserAlreadyEmployee(testEmail);
        print('結果: ${isEmployee ? "是員工" : "不是員工"}');
      }
    }
    
  } catch (e) {
    print('測試失敗: $e');
  }
  
  print('\n=== 測試完成 ===');
}