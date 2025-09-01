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
          child: CustomPaint(painter: CompassBackgroundPainter()),
        ),
        // 子組件內容
        child,
      ],
    );
  }
}

// Canvas 畫家類，用於繪製背景
class CompassBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // 背景漸層
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFF5E6D3), // 淺米色
        const Color(0xFFE8D5C4), // 中等米色
        const Color(0xFFD4B896), // 深一點的米色
        const Color(0xFFB8956F), // 棕色調
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

    paint.shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFEEDDCC), Color(0xFFE0CDB7)],
    ).createShader(trianglePath.getBounds());
    canvas.drawPath(trianglePath, paint);

    // 繪製右下角的幾何圖形 - 保持三角形底邊不變，固定與邊界的距離
    final bottomPath = Path();
    bottomPath.moveTo(size.width, size.height);
    bottomPath.lineTo(size.width - 250, size.height); // 固定底邊長度為250
    bottomPath.lineTo(size.width, size.height - 200); // 固定高度為200
    bottomPath.close();

    paint.shader = const LinearGradient(
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
      colors: [Color(0xFFC19A6B), Color(0xFFB8956F)],
    ).createShader(bottomPath.getBounds());
    canvas.drawPath(bottomPath, paint);

    // 添加一些裝飾性的線條
    paint.shader = null;
    paint.color = Colors.white.withOpacity(0.3);
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
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
