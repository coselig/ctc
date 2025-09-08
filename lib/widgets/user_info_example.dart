import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'transparent_app_bar.dart';

/// 示範如何使用帶有用戶資訊的 TransparentAppBar
class UserInfoExamplePage extends StatelessWidget {
  const UserInfoExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: TransparentAppBar(
        title: const Text('用戶資訊示例'),
        showUserInfo: user != null, // 只有登入時才顯示
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // 設定功能
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user != null) ...[
              Text('已登入用戶', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Text('完整郵箱: ${user.email}'),
              const SizedBox(height: 8),
              Text(
                'AppBar 顯示: ${_extractEmailPrefix(user.email!)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ] else ...[
              Text('未登入', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              const Text('請先登入以查看用戶資訊'),
            ],
          ],
        ),
      ),
    );
  }

  /// 提取郵箱中 @ 符號前面的英文和數字
  String _extractEmailPrefix(String email) {
    final atIndex = email.indexOf('@');
    if (atIndex == -1) return email;

    final prefix = email.substring(0, atIndex);
    // 只保留英文字母和數字
    final cleanPrefix = prefix.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    return cleanPrefix.isNotEmpty ? cleanPrefix : prefix;
  }
}
