import 'package:flutter/material.dart';

/// 確認對話框
/// 用於顯示需要用戶確認的操作
class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = '確定',
    this.cancelText = '取消',
    this.confirmColor,
    this.isDestructive = false,
  });

  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final buttonColor =
        confirmColor ??
        (isDestructive ? Colors.red : Theme.of(context).primaryColor);

    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: buttonColor),
          child: Text(confirmText),
        ),
      ],
    );
  }

  /// 顯示確認對話框的快捷方法
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = '確定',
    String cancelText = '取消',
    Color? confirmColor,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        isDestructive: isDestructive,
      ),
    );
  }
}
