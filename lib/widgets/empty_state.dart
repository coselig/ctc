import 'package:flutter/material.dart';

/// 空狀態元件
/// 統一的空數據顯示元件
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.icon,
    this.actionText,
    this.onAction,
    this.description,
  });

  final String message;
  final IconData? icon;
  final String? actionText;
  final VoidCallback? onAction;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Icon(
              icon,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(
              description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onAction, child: Text(actionText!)),
          ],
        ],
      ),
    );
  }
}

/// 特定的空狀態元件

/// 無設計圖狀態
class NoFloorPlansState extends StatelessWidget {
  const NoFloorPlansState({super.key, required this.onAddFloorPlan});

  final VoidCallback onAddFloorPlan;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.architecture,
      message: '尚未有任何設計圖',
      description: '添加您的第一個設計圖開始使用',
      actionText: '新增設計圖',
      onAction: onAddFloorPlan,
    );
  }
}

/// 無照片記錄狀態
class NoPhotosState extends StatelessWidget {
  const NoPhotosState({super.key, this.onAction});

  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.photo_camera,
      message: '尚未有照片記錄',
      description: '點擊設計圖上的位置開始拍攝記錄',
      actionText: onAction != null ? '開始拍攝' : null,
      onAction: onAction,
    );
  }
}
