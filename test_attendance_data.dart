import 'package:supabase_flutter/supabase_flutter.dart';

/// 測試腳本：檢查打卡記錄資料
void main() async {
  // 初始化 Supabase
  await Supabase.initialize(
    url: 'https://localhost/api',
    anonKey: 'YOUR_ANON_KEY',
  );

  final supabase = Supabase.instance.client;

  try {
    print('========== 檢查打卡記錄 ==========');
    
    // 查詢所有打卡記錄
    final response = await supabase
        .from('attendance_records')
        .select('*')
        .order('check_in_time', ascending: false)
        .limit(10);
    
    print('找到 ${response.length} 筆記錄（最近10筆）:');
    
    for (var record in response) {
      print('---');
      print('ID: ${record['id']}');
      print('員工ID: ${record['employee_id']}');
      print('上班時間: ${record['check_in_time']}');
      print('下班時間: ${record['check_out_time'] ?? '未打卡'}');
      print('工時: ${record['work_hours'] ?? 0} 小時');
    }
    
    // 統計總記錄數
    final countResponse = await supabase
        .from('attendance_records')
        .select('id', const FetchOptions(count: CountOption.exact));
    
    print('\n總打卡記錄數: ${countResponse.length}');
    
  } catch (e) {
    print('❌ 錯誤: $e');
  }
}
