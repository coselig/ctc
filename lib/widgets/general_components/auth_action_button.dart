import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../pages/public/auth_page.dart';

/// 自動判定登入/登出按鈕
class AuthActionButton extends StatelessWidget {
  const AuthActionButton({
    super.key,
    this.color,
    this.onLogin,
    this.onLogoutStart,
    this.onLogoutSuccess,
    this.onLogoutError,
  });

  final Color? color;
  final VoidCallback? onLogin;
  final VoidCallback? onLogoutStart;
  final VoidCallback? onLogoutSuccess;
  final ValueChanged<String>? onLogoutError;

  bool get _isLoggedIn => Supabase.instance.client.auth.currentSession != null;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    return IconButton(
      icon: Icon(_isLoggedIn ? Icons.logout : Icons.login, color: effectiveColor),
      onPressed: () => _isLoggedIn ? _handleLogout(context) : _handleLogin(context),
      tooltip: _isLoggedIn ? '登出' : '登入',
    );
  }

  Future<void> _handleLogin(BuildContext context) async {
    onLogin?.call();
    // 導向 AuthPage
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AuthPage(
          onThemeToggle: () {},
          currentThemeMode: ThemeMode.system,
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await _showLogoutConfirmationDialog(context);
    if (shouldLogout == true) {
      onLogoutStart?.call();
      try {
        if (context.mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
        await Supabase.instance.client.auth.signOut();
        onLogoutSuccess?.call();
      } catch (e) {
        final errorMessage = '登出失敗: $e';
        onLogoutError?.call(errorMessage);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
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
