import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 一鍵修復 coseligtest@gmail.com 帳號問題
class QuickFixDialog extends StatefulWidget {
  const QuickFixDialog({Key? key}) : super(key: key);

  @override
  State<QuickFixDialog> createState() => _QuickFixDialogState();
}

class _QuickFixDialogState extends State<QuickFixDialog> {
  final supabase = Supabase.instance.client;
  bool isLoading = false;
  String result = '';

  Future<void> _fixCoseligAccount() async {
    setState(() {
      isLoading = true;
      result = '';
    });

    try {
      const targetEmail = 'coseligtest@gmail.com';
      
      setState(() {
        result += '🔍 開始檢查 $targetEmail...\n';
      });
      
      // 1. 檢查 user_profiles 中是否存在
      final existingProfile = await supabase
          .from('user_profiles')
          .select('*')
          .eq('email', targetEmail)
          .maybeSingle();

      if (existingProfile == null) {
        setState(() {
          result += '❌ 在 user_profiles 中未找到記錄\n';
          result += '⚠️  問題：user_profiles 需要有效的 auth.users ID\n';
          result += '💡 建議：需要先在 Supabase Auth 中創建用戶\n';
        });
        
        // 嘗試創建一個虛擬記錄（這可能會失敗，但我們會捕捉錯誤）
        try {
          // 生成一個假的但格式正確的 UUID
          final dummyUuid = '00000000-0000-4000-8000-000000000001';
          
          final newProfile = {
            'user_id': dummyUuid,
            'email': targetEmail,
            'display_name': 'Coselig Test User (手動創建)',
            'phone': null,
            'metadata': {'created_manually': true, 'note': '這是手動創建的測試記錄'},
          };

          await supabase
              .from('user_profiles')
              .insert(newProfile);

          setState(() {
            result += '✅ 已創建用戶檔案（使用虛擬UUID）\n';
          });
        } catch (profileError) {
          setState(() {
            result += '❌ 創建用戶檔案失敗: ${profileError.toString()}\n';
            result += '💡 這是預期的，因為需要有效的認證用戶ID\n';
          });
        }
      } else {
        setState(() {
          result += '✅ 在 user_profiles 中找到記錄:\n';
          result += '   User ID: ${existingProfile['user_id']}\n';
          result += '   Display Name: ${existingProfile['display_name']}\n';
          result += '   Created At: ${existingProfile['created_at']}\n';
        });
      }

      // 2. 檢查 employees 表
      final existingEmployee = await supabase
          .from('employees')
          .select('*')
          .eq('email', targetEmail)
          .maybeSingle();

      if (existingEmployee == null) {
        setState(() {
          result += '❌ 在 employees 中未找到記錄\n';
          result += '💡 正在創建員工記錄...\n';
        });
        
        // 創建員工記錄
        final currentUser = supabase.auth.currentUser;
        if (currentUser != null) {
          // 生成唯一的員工編號
          final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
          
          final employeeData = {
            'employee_id': 'COSELIG$timestamp',
            'name': 'Coselig Test User',
            'email': targetEmail,
            'department': '研發部',
            'position': '軟體工程師',
            'hire_date': DateTime.now().toIso8601String().split('T')[0],
            'status': 'active',
            'notes': '透過修復工具手動創建的員工記錄',
            'created_by': currentUser.id,
          };

          await supabase
              .from('employees')
              .insert(employeeData);

          setState(() {
            result += '✅ 已創建員工記錄:\n';
            result += '   員工編號: COSELIG$timestamp\n';
            result += '   部門: 研發部\n';
            result += '   職位: 軟體工程師\n';
          });
        } else {
          setState(() {
            result += '❌ 無法創建員工記錄：當前沒有登入用戶\n';
          });
        }
      } else {
        setState(() {
          result += '✅ 在 employees 中找到記錄:\n';
          result += '   員工編號: ${existingEmployee['employee_id']}\n';
          result += '   姓名: ${existingEmployee['name']}\n';
          result += '   部門: ${existingEmployee['department']}\n';
          result += '   職位: ${existingEmployee['position']}\n';
          result += '   狀態: ${existingEmployee['status']}\n';
        });
      }

      setState(() {
        result += '\n� 修復摘要:\n';
        result += '現在 $targetEmail 至少在 employees 表中有記錄了！\n';
        result += '這樣就可以在員工管理系統中找到該用戶。\n';
      });

    } catch (e) {
      setState(() {
        result += '❌ 修復過程中發生錯誤: $e\n';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('🔧 修復 Coselig 帳號'),
      content: SizedBox(
        width: 400,
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '這個工具會自動修復 coseligtest@gmail.com 帳號的問題：',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• 檢查並創建用戶檔案記錄'),
            const Text('• 檢查並創建員工記錄'),
            const Text('• 確保帳號可以在系統中被找到'),
            const SizedBox(height: 16),
            
            if (isLoading)
              const Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('正在修復...'),
                ],
              )
            else
              ElevatedButton(
                onPressed: _fixCoseligAccount,
                child: const Text('開始修復'),
              ),
            
            const SizedBox(height: 16),
            
            if (result.isNotEmpty)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      result,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('關閉'),
        ),
      ],
    );
  }
}

/// 在任何頁面中顯示修復對話框的函數
void showCoseligFixDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const QuickFixDialog(),
  );
}