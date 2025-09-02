import 'package:flutter/material.dart';

class CompassBackground extends StatelessWidget {
  final Widget child;

  const CompassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 背景 Canvas
        Positioned.fill(
          child: CustomPaint(
            painter: CompassBackgroundPainter(
              isDarkMode: Theme.of(context).brightness == Brightness.dark,
            ),
          ),
        ),
        // 子組件內容
        child,
      ],
    );
  }
}

// Canvas 畫家類，用於繪製背景
class CompassBackgroundPainter extends CustomPainter {
  final bool isDarkMode;

  CompassBackgroundPainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // 根據主題選擇不同的背景漸層
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDarkMode
          ? [
              // 暗色模式背景
              const Color(0xFF1A1A1A), // 深灰色
              const Color(0xFF2C2C2C), // 中灰色
              const Color(0xFF3D3D3D), // 較亮的灰色
              const Color(0xFF4A4A4A), // 更亮的灰色
            ]
          : [
              // 亮色模式背景
              const Color(0xFFF8F6F4), // 淺米色
              const Color(0xFFF0EDE8), // 稍深米色
              const Color(0xFFE8E0D6), // 中等米色
              const Color(0xFFDDD4C7), // 深一點的米色
            ],
    );

    paint.shader = gradient.createShader(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // 繪製幾何圖形 - 左上角三角形
    final trianglePath = Path();
    trianglePath.moveTo(0, 0);
    trianglePath.lineTo(size.width * 0.6, 0);
    trianglePath.lineTo(0, size.height * 0.7);
    trianglePath.close();

    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDarkMode
          ? [
              const Color(0xFF333333).withValues(alpha: 0.6),
              const Color(0xFF444444).withValues(alpha: 0.4),
            ]
          : [
              const Color(0xFFEEDDCC).withValues(alpha: 0.8),
              const Color(0xFFE0CDB7).withValues(alpha: 0.6),
            ],
    ).createShader(trianglePath.getBounds());
    canvas.drawPath(trianglePath, paint);

    // 繪製右下角的幾何圖形
    final bottomPath = Path();
    bottomPath.moveTo(size.width, size.height);
    bottomPath.lineTo(size.width - 250, size.height); // 固定底邊長度為250
    bottomPath.lineTo(size.width, size.height - 200); // 固定高度為200
    bottomPath.close();

    paint.shader = LinearGradient(
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
      colors: isDarkMode
          ? [
              const Color(0xFF555555).withValues(alpha: 0.7),
              const Color(0xFF666666).withValues(alpha: 0.5),
            ]
          : [
              const Color(0xFFC19A6B).withValues(alpha: 0.8),
              const Color(0xFFB8956F).withValues(alpha: 0.6),
            ],
    ).createShader(bottomPath.getBounds());
    canvas.drawPath(bottomPath, paint);

    // 添加一些裝飾性的線條
    paint.shader = null;
    paint.color = isDarkMode
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.1);
    paint.strokeWidth = 1;
    paint.style = PaintingStyle.stroke;

    // 繪製一些裝飾線條
    for (int i = 0; i < 5; i++) {
      final y = size.height * 0.2 + (i * 40);
      canvas.drawLine(
        Offset(size.width * 0.1, y),
        Offset(size.width * 0.4, y),
        paint,
      );
    }

    // 添加一些圓點裝飾
    paint.style = PaintingStyle.fill;
    paint.color = isDarkMode
        ? Colors.white.withValues(alpha: 0.05)
        : const Color(0xFFD17A3A).withValues(alpha: 0.1);

    for (int i = 0; i < 8; i++) {
      final x = size.width * 0.7 + (i % 3) * 30;
      final y = size.height * 0.1 + (i ~/ 3) * 25;
      canvas.drawCircle(Offset(x, y), 3, paint);
    }
  }

  @override
  bool shouldRepaint(CompassBackgroundPainter oldDelegate) =>
      isDarkMode != oldDelegate.isDarkMode;
}
