import 'package:flutter/material.dart';

/// 訊息顯示工具類
/// 統一管理 SnackBar 訊息顯示
class MessageHelper {
  MessageHelper._();

  /// 顯示成功訊息
  static void showSuccess(BuildContext context, String message) {
    _showMessage(context, message, Colors.green);
  }

  /// 顯示錯誤訊息
  static void showError(BuildContext context, String message) {
    _showMessage(context, message, Colors.red);
  }

  /// 顯示資訊訊息
  static void showInfo(BuildContext context, String message) {
    _showMessage(context, message, Colors.blue);
  }

  /// 顯示警告訊息
  static void showWarning(BuildContext context, String message) {
    _showMessage(context, message, Colors.orange);
  }

  /// 顯示載入訊息
  static void showLoading(BuildContext context, String message) {
    _showMessage(
      context,
      message,
      Colors.grey,
      icon: const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  /// 通用訊息顯示方法
  static void _showMessage(
    BuildContext context,
    String message,
    Color backgroundColor, {
    Widget? icon,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[icon, const SizedBox(width: 12)],
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// 隱藏當前 SnackBar
  static void hide(BuildContext context) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}
