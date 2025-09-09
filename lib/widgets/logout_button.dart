import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 登出按鈕
/// 統一的登出按鈕元件，包含確認對話框和登出邏輯
class LogoutButton extends StatelessWidget {
  const LogoutButton({
    super.key,
    this.color,
    this.onLogoutStart,
    this.onLogoutSuccess,
    this.onLogoutError,
  });

  final Color? color;
  final VoidCallback? onLogoutStart;
  final VoidCallback? onLogoutSuccess;
  final ValueChanged<String>? onLogoutError;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;

    return IconButton(
      icon: Icon(Icons.logout, color: effectiveColor),
      onPressed: () => _handleLogout(context),
      tooltip: '登出',
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    // 顯示確認對話框
    final shouldLogout = await _showLogoutConfirmationDialog(context);

    if (shouldLogout == true) {
      onLogoutStart?.call();

      try {
        // 先清除所有頁面到根級別
        if (context.mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }

        // 執行登出 - 全域認證監聽器會處理 UI 更新
        await Supabase.instance.client.auth.signOut();

        onLogoutSuccess?.call();
      } catch (e) {
        final errorMessage = '登出失敗: $e';
        onLogoutError?.call(errorMessage);

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
      }
    }
  }

  Future<bool?> _showLogoutConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認登出'),
        content: const Text('您確定要登出嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('登出'),
          ),
        ],
      ),
    );
  }
}
