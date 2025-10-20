import 'package:ctc/widgets/general_components/logout_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LogoutButton', () {
    testWidgets('renders logout icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(appBar: AppBar(actions: const [LogoutButton()])),
        ),
      );

      // 驗證登出圖標是否顯示
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('shows confirmation dialog on tap', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(appBar: AppBar(actions: const [LogoutButton()])),
        ),
      );

      // 點擊登出按鈕
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      // 驗證確認對話框是否顯示
      expect(find.text('確認登出'), findsOneWidget);
      expect(find.text('您確定要登出嗎？'), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);
      expect(find.text('登出'), findsOneWidget);
    });

    testWidgets('cancels logout when cancel is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(appBar: AppBar(actions: const [LogoutButton()])),
        ),
      );

      // 點擊登出按鈕
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      // 點擊取消按鈕
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      // 驗證對話框已消失
      expect(find.text('確認登出'), findsNothing);
    });

    testWidgets('accepts custom color', (WidgetTester tester) async {
      const customColor = Colors.red;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(actions: const [LogoutButton(color: customColor)]),
          ),
        ),
      );

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      final icon = iconButton.icon as Icon;

      expect(icon.color, customColor);
    });
  });
}
