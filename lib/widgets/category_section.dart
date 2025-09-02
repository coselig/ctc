import 'package:flutter/material.dart';

/// 分類區段元件
/// 顯示一個產品大分類的標題和產品列表
class CategorySection extends StatelessWidget {
  const CategorySection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.products,
    this.gradientColors = const [Color(0xFFD17A3A), Color(0xFFB8956F)],
    this.onProductTap,
  });

  final String title;
  final String subtitle;
  final List<String> products;
  final List<Color> gradientColors;
  final Function(String)? onProductTap;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 大分類標題
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 產品列表
        ...products.map(
          (product) => GestureDetector(
            onTap: onProductTap != null ? () => onProductTap!(product) : null,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? [
                          const Color(0xFF2A2A2A), // 深灰色
                          const Color(0xFF1F1F1F), // 更深的灰色
                        ]
                      : [
                          const Color(0xFFF5E6D3), // 淺米色
                          const Color(0xFFE8D5C4), // 中等米色
                        ],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: isDarkMode
                    ? Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.3),
                        width: 1,
                      )
                    : null,
              ),
              child: Text(
                product,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color:
                      (onProductTap != null &&
                          product.contains('Home Assistant'))
                      ? Theme.of(context).colorScheme.primary
                      : isDarkMode
                      ? Colors.white.withValues(alpha: 0.9)
                      : const Color(0xFF8B6914),
                  height: 1.3,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
