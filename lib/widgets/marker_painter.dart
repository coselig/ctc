import 'package:flutter/material.dart';
import '../models/photo_record.dart';

class MarkerPainter extends CustomPainter {
  final List<PhotoRecord> records;
  final Offset? selectedPoint;
  final PhotoRecord? selectedRecord;
  final String currentFloorPlan;
  final bool isDarkMode;
  final Color primaryColor;

  MarkerPainter({
    required this.records,
    required this.currentFloorPlan,
    required this.isDarkMode,
    required this.primaryColor,
    this.selectedPoint,
    this.selectedRecord,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color =
          primaryColor // 使用主題主色
      ..strokeWidth = 10
      ..style = PaintingStyle.fill;

    for (var record in records) {
      // 只繪製當前平面圖的標記點
      if (record.imageUrl == currentFloorPlan) {
        if (record == selectedRecord) {
          // 選中狀態使用更亮的色彩
          dotPaint.color = isDarkMode
              ? primaryColor.withValues(alpha: 0.8)
              : const Color(0xFF8B6914); // 金棕色（選中）
        } else if (record.isLocal) {
          // 本地記錄使用稍暗的色彩
          dotPaint.color = isDarkMode
              ? primaryColor.withValues(alpha: 0.6)
              : const Color(0xFFB8956F); // 深棕色（本地）
        } else {
          // 預設使用主題主色
          dotPaint.color = primaryColor;
        }
        canvas.drawCircle(record.point, 8, dotPaint);
      }
    }

    if (selectedPoint != null) {
      final selectedPaint = Paint()
        ..color = isDarkMode
            ? primaryColor.withValues(alpha: 0.9)
            : const Color(0xFF8B6914) // 金棕色（選中點）
        ..strokeWidth = 10
        ..style = PaintingStyle.fill;
      canvas.drawCircle(selectedPoint!, 8, selectedPaint);
    }
  }

  @override
  bool shouldRepaint(covariant MarkerPainter oldDelegate) {
    return oldDelegate.records != records ||
        oldDelegate.selectedPoint != selectedPoint ||
        oldDelegate.selectedRecord != selectedRecord ||
        oldDelegate.isDarkMode != isDarkMode ||
        oldDelegate.primaryColor != primaryColor;
  }
}
