import 'package:supabase_flutter/supabase_flutter.dart';

/// 簡單的修復腳本
void main() async {
  try {
    // 初始化 Supabase
    await Supabase.initialize(
      url: 'http://coselig.com:8000',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJhbm9uIiwKICAgICJpc3MiOiAic3VwYWJhc2UtZGVtbyIsCiAgICAiaWF0IjogMTY0MTc2OTIwMCwKICAgICJleHAiOiAxNzk5NTM1NjAwCn0.dc_X5iR_VP_qT0zsiyj_I_OZ2T9FtRU2BBNWN8Bu4GE',
    );

    final client = Supabase.instance.client;
    const targetEmail = 'coseligtest@gmail.com';
    
    print('🔍 正在檢查 $targetEmail...\n');

    // 1. 檢查 employees 表
    final existingEmployee = await client
        .from('employees')
        .select('*')
        .eq('email', targetEmail)
        .maybeSingle();

    if (existingEmployee != null) {
      print('✅ 帳號已存在於 employees 表:');
      print('   員工編號: ${existingEmployee['employee_id']}');
      print('   姓名: ${existingEmployee['name']}');
      print('   部門: ${existingEmployee['department']}');
      print('   狀態: ${existingEmployee['status']}');
      return;
    }

    print('❌ 在 employees 表中找不到記錄');
    print('💡 正在創建員工記錄...\n');

    // 2. 獲取一個現有用戶作為創建者
    final users = await client
        .from('employees')
        .select('created_by')
        .not('created_by', 'is', null)
        .limit(1);

    String createdBy;
    if (users.isNotEmpty) {
      createdBy = users.first['created_by'];
    } else {
      // 如果沒有現有員工，使用一個預設UUID
      createdBy = '00000000-0000-4000-8000-000000000001';
    }

    // 3. 創建員工記錄
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    
    final employeeData = {
      'employee_id': 'COSELIG$timestamp',
      'name': 'Coselig Test User',
      'email': targetEmail,
      'department': '資訊部',
      'position': '系統管理員',
      'hire_date': DateTime.now().toIso8601String().split('T')[0],
      'status': 'active',
      'notes': '透過修復腳本自動創建',
      'created_by': createdBy,
    };

    await client
        .from('employees')
        .insert(employeeData);

    print('✅ 成功創建員工記錄:');
    print('   員工編號: COSELIG$timestamp');
    print('   姓名: Coselig Test User');
    print('   部門: 資訊部');
    print('   職位: 系統管理員');
    print('   狀態: active');
    print('\n🎉 修復完成！現在 $targetEmail 可以在已註冊用戶中找到了。');

  } catch (e) {
    print('❌ 修復失敗: $e');
    
    if (e.toString().contains('duplicate key')) {
      print('💡 帳號可能已經存在，請檢查員工編號是否重複。');
    } else if (e.toString().contains('foreign key')) {
      print('💡 外鍵約束問題，可能是 created_by 用戶不存在。');
    }
  }
}