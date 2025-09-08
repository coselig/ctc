import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/permission_service.dart';

/// 調試測試頁面 - 專門用於測試使用者載入功能
class DebugUserListPage extends StatefulWidget {
  const DebugUserListPage({super.key});

  @override
  State<DebugUserListPage> createState() => _DebugUserListPageState();
}

class _DebugUserListPageState extends State<DebugUserListPage> {
  late PermissionService _permissionService;
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _permissionService = PermissionService(Supabase.instance.client);
  }

  Future<void> _testLoadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _users = [];
    });

    try {
      print('=== 開始調試使用者載入 ===');

      // 檢查 Supabase 連接狀態
      final currentUser = Supabase.instance.client.auth.currentUser;
      print('當前登入使用者: ${currentUser?.email ?? "未登入"}');
      print('使用者 ID: ${currentUser?.id ?? "無"}');

      // 測試 getAllUsers 方法
      final users = await _permissionService.getAllUsers();
      print('=== 使用者載入結果 ===');
      print('獲得使用者數量: ${users.length}');
      print('使用者清單: $users');

      setState(() {
        _users = users;
        _isLoading = false;
      });

      if (users.isEmpty) {
        print('⚠️ 警告：使用者清單為空');
        setState(() {
          _error = '使用者清單為空 - 可能是權限或 API 問題';
        });
      }
    } catch (e, stackTrace) {
      print('=== 錯誤發生 ===');
      print('錯誤: $e');
      print('錯誤類型: ${e.runtimeType}');
      print('堆疊追蹤: $stackTrace');

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('調試：使用者清單載入'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 控制按鈕
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testLoadUsers,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              label: Text(_isLoading ? '載入中...' : '測試載入使用者'),
            ),

            const SizedBox(height: 16),

            // 狀態顯示
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '調試狀態',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('載入中: $_isLoading'),
                  Text('使用者數量: ${_users.length}'),
                  Text('錯誤: ${_error ?? "無"}'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 錯誤顯示
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error, color: Colors.red.shade600),
                        const SizedBox(width: 8),
                        Text(
                          '錯誤詳情',
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_error!, style: TextStyle(color: Colors.red.shade800)),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // 使用者清單顯示
            Expanded(
              child: _users.isEmpty && !_isLoading
                  ? const Center(
                      child: Text(
                        '尚未載入使用者\n點擊上方按鈕開始測試',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Text(
                                user['email']?.isNotEmpty == true
                                    ? user['email'][0].toUpperCase()
                                    : '?',
                              ),
                            ),
                            title: Text(user['email'] ?? '無電子郵件'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ID: ${user['id'] ?? "無"}'),
                                Text('註冊時間: ${user['created_at'] ?? "無"}'),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
