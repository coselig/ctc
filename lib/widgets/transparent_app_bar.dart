import 'package:flutter/material.dart';

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
  });

  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color iconColor;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: centerTitle,
      leading: leading,
      title: title != null
          ? DefaultTextStyle(
              style:
                  titleStyle ??
                  TextStyle(color: Theme.of(context).colorScheme.onSurface),
              child: title!,
            )
          : null,
      iconTheme: IconThemeData(color: iconColor),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
