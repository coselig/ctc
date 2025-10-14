import 'package:flutter/material.dart';

/// 編輯描述對話框元件
class EditDescriptionDialog extends StatefulWidget {
  const EditDescriptionDialog({
    super.key,
    this.initialDescription,
    this.title = '編輯記錄描述',
    this.labelText = '描述/備註',
    this.hintText = '請輸入描述內容...',
    this.maxLines = 3,
  });

  /// 初始描述內容
  final String? initialDescription;

  /// 對話框標題
  final String title;

  /// 輸入框標籤
  final String labelText;

  /// 輸入框提示文字
  final String hintText;

  /// 最大行數
  final int maxLines;

  /// 顯示對話框並返回編輯後的描述
  ///
  /// 如果用戶取消或關閉對話框，返回 null
  /// 如果用戶保存，返回修改後的描述文字
  static Future<String?> show(
    BuildContext context, {
    String? initialDescription,
    String title = '編輯記錄描述',
    String labelText = '描述/備註',
    String hintText = '請輸入描述內容...',
    int maxLines = 3,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => EditDescriptionDialog(
        initialDescription: initialDescription,
        title: title,
        labelText: labelText,
        hintText: hintText,
        maxLines: maxLines,
      ),
    );
  }

  @override
  State<EditDescriptionDialog> createState() => _EditDescriptionDialogState();
}

class _EditDescriptionDialogState extends State<EditDescriptionDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialDescription ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSave() {
    Navigator.of(context).pop(_controller.text.trim());
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hintText,
              border: const OutlineInputBorder(),
            ),
            maxLines: widget.maxLines,
            autofocus: true,
            textInputAction: TextInputAction.newline,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: _handleCancel, child: const Text('取消')),
        FilledButton(onPressed: _handleSave, child: const Text('保存')),
      ],
    );
  }
}
