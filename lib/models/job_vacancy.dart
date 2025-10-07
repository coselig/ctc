class JobVacancy {
  final String? id;
  final String title;
  final String department;
  final String location;
  final String type;
  final List<String> requirements;
  final List<String> responsibilities;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  JobVacancy({
    this.id,
    required this.title,
    required this.department,
    required this.location,
    required this.type,
    required this.requirements,
    required this.responsibilities,
    this.description,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory JobVacancy.fromJson(Map<String, dynamic> json) {
    return JobVacancy(
      id: json['id']?.toString(),
      title: json['title'] ?? '',
      department: json['department'] ?? '',
      location: json['location'] ?? '',
      type: json['type'] ?? '',
      requirements: _parseStringList(json['requirements']),
      responsibilities: _parseStringList(json['responsibilities']),
      description: json['description'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'department': department,
      'location': location,
      'type': type,
      'requirements': requirements,
      'responsibilities': responsibilities,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    
    if (value is String) {
      // 如果是 JSON 字符串，嘗試解析
      try {
        final List<dynamic> parsed = 
            value.startsWith('[') ? 
            (value as dynamic) : 
            value.split('\n').where((s) => s.trim().isNotEmpty).toList();
        return parsed.map((e) => e.toString().trim()).toList();
      } catch (e) {
        // 如果解析失敗，按行分割
        return value.split('\n')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
    }
    
    return [];
  }

  @override
  String toString() {
    return 'JobVacancy(id: $id, title: $title, department: $department, location: $location)';
  }
}