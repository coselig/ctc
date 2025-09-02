import 'package:flutter/material.dart';

/// 資訊對話框
/// 用於顯示產品或功能的詳細資訊
class InfoDialog extends StatelessWidget {
  const InfoDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.gradientColors = const [
      Color(0xFFF5E6D3), // 淺米色
      Color(0xFFE8D5C4), // 中等米色
    ],
    this.headerGradientColors = const [Color(0xFFD17A3A), Color(0xFFB8956F)],
  });

  final String title;
  final Widget content;
  final List<Widget>? actions;
  final List<Color> gradientColors;
  final List<Color> headerGradientColors;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // 標題欄
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: headerGradientColors),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // 內容區域
            Expanded(
              child: Padding(padding: const EdgeInsets.all(16), child: content),
            ),
            // 動作按鈕區域
            if (actions != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.black12, width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: actions!,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 顯示資訊對話框的快捷方法
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    List<Color>? gradientColors,
    List<Color>? headerGradientColors,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => InfoDialog(
        title: title,
        content: content,
        actions: actions,
        gradientColors:
            gradientColors ?? const [Color(0xFFF5E6D3), Color(0xFFE8D5C4)],
        headerGradientColors:
            headerGradientColors ??
            const [Color(0xFFD17A3A), Color(0xFFB8956F)],
      ),
    );
  }
}
