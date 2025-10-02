import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  try {
    // 初始化 Supabase
    await Supabase.initialize(
      url: 'http://coselig.com:8000',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJhbm9uIiwKICAgICJpc3MiOiAic3VwYWJhc2UtZGVtbyIsCiAgICAiaWF0IjogMTY0MTc2OTIwMCwKICAgICJleHAiOiAxNzk5NTM1NjAwCn0.dc_X5iR_VP_qT0zsiyj_I_OZ2T9FtRU2BBNWN8Bu4GE',
    );

    final client = Supabase.instance.client;
    
    print('=== 檢查帳號：coseligtest@gmail.com ===\n');
    
    // 1. 檢查 user_profiles 表
    print('1. 檢查 user_profiles 表...');
    try {
      final userProfileResponse = await client
          .from('user_profiles')
          .select('*')
          .eq('email', 'coseligtest@gmail.com');
      
      if (userProfileResponse.isNotEmpty) {
        print('✅ 在 user_profiles 中找到:');
        for (final profile in userProfileResponse) {
          print('   ID: ${profile['id']}');
          print('   User ID: ${profile['user_id']}');
          print('   Email: ${profile['email']}');
          print('   Display Name: ${profile['display_name']}');
          print('   Created At: ${profile['created_at']}');
        }
      } else {
        print('❌ 在 user_profiles 中未找到');
      }
    } catch (e) {
      print('❗ user_profiles 表查詢錯誤: $e');
    }
    
    print('');

    // 2. 檢查 employees 表
    print('2. 檢查 employees 表...');
    try {
      final employeeResponse = await client
          .from('employees')
          .select('*')
          .eq('email', 'coseligtest@gmail.com');
      
      if (employeeResponse.isNotEmpty) {
        print('✅ 在 employees 中找到:');
        for (final employee in employeeResponse) {
          print('   ID: ${employee['id']}');
          print('   Employee ID: ${employee['employee_id']}');
          print('   Name: ${employee['name']}');
          print('   Email: ${employee['email']}');
          print('   Department: ${employee['department']}');
          print('   Position: ${employee['position']}');
          print('   Status: ${employee['status']}');
          print('   Created At: ${employee['created_at']}');
        }
      } else {
        print('❌ 在 employees 中未找到');
      }
    } catch (e) {
      print('❗ employees 表查詢錯誤: $e');
    }

    print('');

    // 3. 列出所有 user_profiles（檢查是否有類似郵箱）
    print('3. 列出所有 user_profiles 中的郵箱...');
    try {
      final allProfilesResponse = await client
          .from('user_profiles')
          .select('email, display_name, created_at')
          .order('created_at', ascending: false);
      
      print('總共找到 ${allProfilesResponse.length} 個用戶檔案:');
      for (final profile in allProfilesResponse) {
        final email = profile['email'] ?? '無郵箱';
        final name = profile['display_name'] ?? '無姓名';
        final isTarget = email.toString().toLowerCase().contains('coselig') || 
                        email.toString().toLowerCase() == 'coseligtest@gmail.com';
        final marker = isTarget ? '🎯 ' : '   ';
        print('$marker$email ($name)');
      }
    } catch (e) {
      print('❗ 列出用戶檔案錯誤: $e');
    }

    print('');

    // 4. 搜尋包含 "coselig" 的郵箱
    print('4. 搜尋包含 "coselig" 的郵箱...');
    try {
      final searchResponse = await client
          .from('user_profiles')
          .select('*')
          .like('email', '%coselig%');
      
      if (searchResponse.isNotEmpty) {
        print('✅ 找到包含 "coselig" 的郵箱:');
        for (final profile in searchResponse) {
          print('   Email: ${profile['email']}');
          print('   Display Name: ${profile['display_name']}');
          print('   User ID: ${profile['user_id']}');
        }
      } else {
        print('❌ 未找到包含 "coselig" 的郵箱');
      }
    } catch (e) {
      print('❗ 搜尋 coselig 郵箱錯誤: $e');
    }

  } catch (e) {
    print('❌ 初始化或查詢失敗: $e');
  }
}