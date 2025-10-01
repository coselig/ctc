class FloorPlan {
  final String id;
  final String name;
  final String imageUrl;
  final String? userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FloorPlan({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FloorPlan.fromJson(Map<String, dynamic> json) {
    return FloorPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String,
      userId: json['user_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  FloorPlan copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FloorPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'FloorPlan(id: $id, name: $name, imageUrl: $imageUrl, '
        'userId: $userId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FloorPlan &&
        other.id == id &&
        other.name == name &&
        other.imageUrl == imageUrl &&
        other.userId == userId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        imageUrl.hashCode ^
        userId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}