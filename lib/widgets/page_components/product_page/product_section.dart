import 'package:flutter/material.dart';

/// 產品區段元件
/// 顯示一個產品分類及其項目列表
class ProductSection extends StatelessWidget {
  const ProductSection({
    super.key,
    required this.title,
    required this.items,
    this.titleColor = const Color(0xFF8B6914),
    this.itemColor = const Color(0xFF8B6914),
    this.bulletColor = const Color(0xFFD17A3A),
  });

  final String title;
  final List<String> items;
  final Color titleColor;
  final Color itemColor;
  final Color bulletColor;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final effectiveTitleColor = isDarkMode
        ? Theme.of(context).colorScheme.primary
        : titleColor;
    final effectiveItemColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.9)
        : itemColor;
    final effectiveBulletColor = isDarkMode
        ? Theme.of(context).colorScheme.primary
        : bulletColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: effectiveTitleColor,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    color: effectiveBulletColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 14,
                      color: effectiveItemColor,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
