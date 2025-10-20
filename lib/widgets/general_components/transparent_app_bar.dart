import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 透明應用程式列
/// 統一的透明 AppBar 樣式，用於各個頁面
class TransparentAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TransparentAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.iconColor = const Color(0xFFD17A3A),
    this.titleStyle,
    this.showUserInfo = false,
  });

  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color iconColor;
  final TextStyle? titleStyle;
  final bool showUserInfo;

  /// 提取郵箱中 @ 符號前面的英文和數字
  String _extractEmailPrefix(String email) {
    final atIndex = email.indexOf('@');
    if (atIndex == -1) return email;

    final prefix = email.substring(0, atIndex);
    // 只保留英文字母和數字
    final cleanPrefix = prefix.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    return cleanPrefix.isNotEmpty ? cleanPrefix : prefix;
  }

  /// 建立用戶資訊 Widget
  Widget _buildUserInfo(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user?.email == null) return const SizedBox.shrink();

    final emailPrefix = _extractEmailPrefix(user!.email!);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_circle,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            emailPrefix,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor == const Color(0xFFD17A3A)
        ? Theme.of(context).colorScheme.primary
        : iconColor;

    // 建立新的 actions 列表
    List<Widget>? effectiveActions;
    if (showUserInfo || actions != null) {
      effectiveActions = [
        // 加入用戶資訊（如果需要顯示）
        if (showUserInfo) ...[
          Center(child: _buildUserInfo(context)),
          const SizedBox(width: 8),
        ],
        // 加入原有的 actions
        if (actions != null) ...actions!,
      ];
    }

    return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent, // 確保沒有 surface tint 顏色
      elevation: 0,
      scrolledUnderElevation: 0, // 滾動時也保持透明
      centerTitle: centerTitle,
      leading: leading,
      title: title != null
          ? DefaultTextStyle(
              style:
                  titleStyle ??
                  TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
              child: title!,
            )
          : null,
      iconTheme: IconThemeData(color: effectiveIconColor),
      actions: effectiveActions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
