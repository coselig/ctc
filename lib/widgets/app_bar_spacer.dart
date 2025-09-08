import 'package:flutter/material.dart';

/// AppBar 間距小工具
/// 用於在使用透明 AppBar 時提供正確的間距
class AppBarSpacer extends StatelessWidget {
  const AppBarSpacer({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 創建與 AppBar 等高的空間
        SizedBox(height: AppBar().preferredSize.height),
        if (child != null) Expanded(child: child!),
      ],
    );
  }
}

/// 帶有 AppBar 間距的安全區域
class SafeAreaWithAppBar extends StatelessWidget {
  const SafeAreaWithAppBar({
    super.key,
    required this.child,
    this.maintainBottomViewPadding = true,
  });

  final Widget child;
  final bool maintainBottomViewPadding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      maintainBottomViewPadding: maintainBottomViewPadding,
      child: Padding(
        padding: EdgeInsets.only(top: AppBar().preferredSize.height),
        child: child,
      ),
    );
  }
}
