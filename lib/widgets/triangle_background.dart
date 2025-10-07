import 'package:flutter/material.dart';

class TriangleBackground extends StatelessWidget {
  final Widget child;

  const TriangleBackground({
    super.key, 
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 基礎背景色
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).colorScheme.surface,
        ),
        // 左上角三角形
        Positioned(
          top: 0,
          left: 0,
          child: CustomPaint(
            size: Size(MediaQuery.of(context).size.width * 0.5, MediaQuery.of(context).size.height * 0.2),
            painter: TrianglePainter(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(125, 84, 84, 84),  // 淺粉褐色
                  Color.fromARGB(125, 84, 84, 84),  // 中粉褐色
                ],
              ),
              corner: TriangleCorner.topLeft,
            ),
          ),
        ),
        // 右上角三角形
        Positioned(
          top: 0,
          right: 0,
          child: CustomPaint(
            size: Size(MediaQuery.of(context).size.width , 180),
            painter: TrianglePainter(
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color.fromARGB(125, 221, 184, 146),  // 淺棕色
                  Color.fromARGB(125, 252, 218, 23),  // 中棕色
                ],
              ),
              corner: TriangleCorner.topRight,
            ),
          ),
        ),
        // 左下角三角形
        Positioned(
          bottom: 0,
          left: 0,
          child: CustomPaint(
            size: Size(MediaQuery.of(context).size.width * 0.5, MediaQuery.of(context).size.height * 0.4),
            painter: TrianglePainter(
              gradient: const LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  Color.fromARGB(114, 193, 154, 107),  // 深棕色
                  Color.fromARGB(114, 184, 149, 111),  // 中深棕色
                ],
              ),
              corner: TriangleCorner.bottomLeft,
            ),
          ),
        ),
        // 右下角三角形
        Positioned(
          bottom: 0,
          right: 0,
          child: CustomPaint(
            size: Size(MediaQuery.of(context).size.width * 0.8, MediaQuery.of(context).size.height * 0.4),
            painter: TrianglePainter(
              gradient: const LinearGradient(
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
                colors: [
                  Color.fromARGB(114, 212, 196, 189),  // 中粉褐色
                  Color.fromARGB(114, 230, 213, 206),  // 淺粉褐色
                ],
              ),
              corner: TriangleCorner.bottomRight,
            ),
          ),
        ),
        // 主要內容
        child,
      ],
    );
  }
}

enum TriangleCorner {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

class TrianglePainter extends CustomPainter {
  final Gradient gradient;
  final TriangleCorner corner;

  TrianglePainter({
    required this.gradient,
    required this.corner,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    final Path path = Path();
    
    switch (corner) {
      case TriangleCorner.topLeft:
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(0, size.height);
        break;
      case TriangleCorner.topRight:
        path.moveTo(size.width, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, 0);
        break;
      case TriangleCorner.bottomLeft:
        path.moveTo(0, size.height);
        path.lineTo(size.width, size.height);
        path.lineTo(0, 0);
        break;
      case TriangleCorner.bottomRight:
        path.moveTo(size.width, size.height);
        path.lineTo(0, size.height);
        path.lineTo(size.width, 0);
        break;
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}