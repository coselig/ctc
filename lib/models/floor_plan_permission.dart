import 'permission_level.dart';

/// 設計圖權限模型
class FloorPlanPermission {
  final String id;
  final String floorPlanId;
  final String floorPlanUrl;
  final String floorPlanName;
  final String userId;
  final String userEmail;
  final PermissionLevel permissionLevel;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isOwner;

  const FloorPlanPermission({
    required this.id,
    required this.floorPlanId,
    required this.floorPlanUrl,
    required this.floorPlanName,
    required this.userId,
    required this.userEmail,
    required this.permissionLevel,
    required this.createdAt,
    required this.updatedAt,
    this.isOwner = false,
  });

  /// 從 JSON 創建實例
  factory FloorPlanPermission.fromJson(Map<String, dynamic> json) {
    return FloorPlanPermission(
      id: json['id']?.toString() ?? '',
      floorPlanId: json['floor_plan_id']?.toString() ?? '',
      floorPlanUrl: json['floor_plan_url']?.toString() ?? '',
      floorPlanName: json['floor_plan_name']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      userEmail: json['user_email']?.toString() ?? '',
      permissionLevel: PermissionLevel.fromValue(
        json['permission_level'] as int? ?? 1,
      ),
      createdAt: DateTime.parse(
        json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      isOwner: json['is_owner'] as bool? ?? false,
    );
  }

  /// 轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'floor_plan_id': floorPlanId,
      'floor_plan_url': floorPlanUrl,
      'floor_plan_name': floorPlanName,
      'user_id': userId,
      'user_email': userEmail,
      'permission_level': permissionLevel.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_owner': isOwner,
    };
  }

  /// 創建副本並修改權限等級
  FloorPlanPermission copyWith({
    String? id,
    String? floorPlanId,
    String? floorPlanUrl,
    String? floorPlanName,
    String? userId,
    String? userEmail,
    PermissionLevel? permissionLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isOwner,
  }) {
    return FloorPlanPermission(
      id: id ?? this.id,
      floorPlanId: floorPlanId ?? this.floorPlanId,
      floorPlanUrl: floorPlanUrl ?? this.floorPlanUrl,
      floorPlanName: floorPlanName ?? this.floorPlanName,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      permissionLevel: permissionLevel ?? this.permissionLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isOwner: isOwner ?? this.isOwner,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FloorPlanPermission &&
        other.id == id &&
        other.floorPlanId == floorPlanId &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ floorPlanId.hashCode ^ userId.hashCode;
  }

  @override
  String toString() {
    return 'FloorPlanPermission(id: $id, floorPlanId: $floorPlanId, userId: $userId, permissionLevel: $permissionLevel, isOwner: $isOwner)';
  }
}

/// 用戶權限摘要
class UserPermissionSummary {
  final String userId;
  final String userEmail;
  final List<FloorPlanPermission> permissions;

  const UserPermissionSummary({
    required this.userId,
    required this.userEmail,
    required this.permissions,
  });

  /// 獲取用戶在特定設計圖的權限
  FloorPlanPermission? getPermissionForFloorPlan(String floorPlanUrl) {
    try {
      return permissions.firstWhere(
        (permission) => permission.floorPlanUrl == floorPlanUrl,
      );
    } catch (e) {
      return null;
    }
  }

  /// 檢查用戶是否為設計圖擁有者
  bool isOwnerOfFloorPlan(String floorPlanUrl) {
    final permission = getPermissionForFloorPlan(floorPlanUrl);
    return permission?.isOwner ?? false;
  }

  /// 獲取用戶擁有的設計圖數量
  int get ownedFloorPlansCount {
    return permissions.where((p) => p.isOwner).length;
  }

  /// 獲取用戶有權限的設計圖數量
  int get accessibleFloorPlansCount {
    return permissions.length;
  }
}
