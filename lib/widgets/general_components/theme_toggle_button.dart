import 'package:flutter/material.dart';

/// 主題切換按鈕
/// 統一的主題切換按鈕元件
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({
    super.key,
    required this.currentThemeMode,
    required this.onToggle,
    this.color = const Color(0xFFD17A3A),
  });

  final ThemeMode currentThemeMode;
  final VoidCallback onToggle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color == const Color(0xFFD17A3A)
        ? Theme.of(context).colorScheme.primary
        : color;

    return IconButton(
      icon: Icon(_getThemeIcon(), color: effectiveColor),
      onPressed: onToggle,
      tooltip: '切換主題',
    );
  }

  IconData _getThemeIcon() {
    switch (currentThemeMode) {
      case ThemeMode.light:
        return Icons.wb_sunny;
      case ThemeMode.dark:
        return Icons.nightlight_round;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}
