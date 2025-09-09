import 'package:flutter/material.dart';

class PhotoRecord {
  final String? id;
  final String floorPlanId;
  final Offset point;
  final String imageUrl;
  final String? description;
  String userId;
  final DateTime timestamp;
  final bool isLocal;

  PhotoRecord({
    this.id,
    required this.floorPlanId,
    required this.point,
    required this.imageUrl,
    this.description,
    required this.userId,
    required this.timestamp,
    this.isLocal = false,
  });

  // 從 Supabase 數據轉換為 PhotoRecord
  factory PhotoRecord.fromJson(Map<String, dynamic> json) {
    return PhotoRecord(
      id: json['id'] as String?,
      floorPlanId: json['floor_plan_id'] as String,
      point: Offset(
        (json['x_coordinate'] as num).toDouble(),
        (json['y_coordinate'] as num).toDouble(),
      ),
      imageUrl: json['image_url'] as String,
      description: json['description'] as String?,
      userId: json['user_id'] as String,
      timestamp: DateTime.parse(json['created_at'] as String),
      isLocal: false,
    );
  }

  // 轉換為 JSON 格式以存儲到 Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'floor_plan_id': floorPlanId,
      'x_coordinate': point.dx,
      'y_coordinate': point.dy,
      'image_url': imageUrl,
      'description': description,
      'user_id': userId,
      'created_at': timestamp.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
