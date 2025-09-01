import 'package:flutter/material.dart';
import '../models/photo_record.dart';

class MarkerPainter extends CustomPainter {
  final List<PhotoRecord> records;
  final Offset? selectedPoint;
  final PhotoRecord? selectedRecord;
  final String currentFloorPlan;

  MarkerPainter({
    required this.records,
    required this.currentFloorPlan,
    this.selectedPoint,
    this.selectedRecord,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color =
          const Color(0xFFD17A3A) // 橘棕色
      ..strokeWidth = 10
      ..style = PaintingStyle.fill;

    for (var record in records) {
      // 只繪製當前平面圖的標記點
      if (record.floorPlanPath == currentFloorPlan) {
        if (record == selectedRecord) {
          dotPaint.color = const Color(0xFF8B6914); // 金棕色（選中）
        } else if (record.isLocal) {
          dotPaint.color = const Color(0xFFB8956F); // 深棕色（本地）
        } else {
          dotPaint.color = const Color(0xFFD17A3A); // 橘棕色（預設）
        }
        canvas.drawCircle(record.point, 8, dotPaint);
      }
    }

    if (selectedPoint != null) {
      final selectedPaint = Paint()
        ..color =
            const Color(0xFF8B6914) // 金棕色（選中點）
        ..strokeWidth = 10
        ..style = PaintingStyle.fill;
      canvas.drawCircle(selectedPoint!, 8, selectedPaint);
    }
  }

  @override
  bool shouldRepaint(covariant MarkerPainter oldDelegate) {
    return oldDelegate.records != records ||
        oldDelegate.selectedPoint != selectedPoint ||
        oldDelegate.selectedRecord != selectedRecord;
  }
}
