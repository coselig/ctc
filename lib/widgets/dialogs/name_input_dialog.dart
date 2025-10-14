import 'package:flutter/material.dart';

/// 名稱輸入對話框
/// 用於輸入設計圖名稱或其他需要名稱輸入的場景
class NameInputDialog extends StatefulWidget {
  const NameInputDialog({
    super.key,
    required this.title,
    required this.labelText,
    required this.hintText,
    this.initialValue,
  });

  final String title;
  final String labelText;
  final String hintText;
  final String? initialValue;

  @override
  State<NameInputDialog> createState() => _NameInputDialogState();
}

class _NameInputDialogState extends State<NameInputDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    debugPrint('NameInputDialog 已初始化: ${widget.title}');
  }

  @override
  void dispose() {
    _controller.dispose();
    debugPrint('NameInputDialog 已銷毀: ${widget.title}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
        ),
        autofocus: true,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        TextButton(onPressed: _submit, child: const Text('確定')),
      ],
    );
  }

  void _submit() {
    final text = _controller.text.trim();
    Navigator.of(context).pop(text.isEmpty ? null : text);
  }

}
