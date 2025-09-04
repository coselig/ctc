import 'package:flutter/material.dart';

class PhotoRecord {
  final String? id;
  final String userId;
  final String username;
  final String imagePath;
  final bool isLocal;
  final Offset point;
  final DateTime timestamp;
  final String? description;
  final String floorPlanPath; // 新增：記錄照片所屬的平面圖路徑

  PhotoRecord({
    this.id,
    required this.userId,
    required this.username,
    required this.imagePath,
    required this.point,
    required this.timestamp,
    required this.floorPlanPath,
    this.description,
    this.isLocal = false,
  });

  // 從 Supabase 數據轉換為 PhotoRecord
  factory PhotoRecord.fromJson(Map<String, dynamic> json) {
    return PhotoRecord(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      username: json['username']?.toString() ?? '未知用戶',
      imagePath: json['image_url']?.toString() ?? '',
      point: Offset(
        (json['x_coordinate'] as num?)?.toDouble() ?? 0.0,
        (json['y_coordinate'] as num?)?.toDouble() ?? 0.0,
      ),
      timestamp: DateTime.parse(
        json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      description: json['description']?.toString(),
      floorPlanPath: json['floor_plan_path']?.toString() ?? '',
      isLocal: false,
    );
  }

  // 轉換為 JSON 格式以存儲到 Supabase
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'image_url': imagePath,
      'x_coordinate': point.dx,
      'y_coordinate': point.dy,
      'created_at': timestamp.toIso8601String(),
      'description': description,
      'username': username,
      'floor_plan_path': floorPlanPath,
    };
  }
}
