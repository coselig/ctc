// 專案管理相關的數據模型

/// 專案狀態
enum ProjectStatus {
  active('active', '進行中'),
  completed('completed', '已完成'),
  archived('archived', '已封存'),
  onHold('on_hold', '暫停中');

  final String value;
  final String label;

  const ProjectStatus(this.value, this.label);

  static ProjectStatus fromValue(String value) {
    return ProjectStatus.values.firstWhere((e) => e.value == value);
  }
}

/// 專案模型
class Project {
  final String id;
  final String name;
  final String? description;
  final ProjectStatus status;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? budget;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    this.startDate,
    this.endDate,
    this.budget,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      status: ProjectStatus.fromValue(json['status'] as String),
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      budget: json['budget'] != null
          ? double.parse(json['budget'].toString())
          : null,
      ownerId: json['owner_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status.value,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'budget': budget,
      'owner_id': ownerId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// 專案成員角色
enum ProjectMemberRole {
  owner('owner', '擁有者'),
  admin('admin', '管理員'),
  member('member', '成員'),
  viewer('viewer', '檢視者');

  final String value;
  final String label;

  const ProjectMemberRole(this.value, this.label);

  static ProjectMemberRole fromValue(String value) {
    return ProjectMemberRole.values.firstWhere((e) => e.value == value);
  }
}

/// 專案成員模型
class ProjectMember {
  final String id;
  final String projectId;
  final String userId;
  final ProjectMemberRole role;
  final DateTime joinedAt;

  // 用戶資訊（從 join 查詢獲得）
  final String? userEmail;
  final String? userFullName;

  ProjectMember({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.userEmail,
    this.userFullName,
  });

  factory ProjectMember.fromJson(Map<String, dynamic> json) {
    return ProjectMember(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      userId: json['user_id'] as String,
      role: ProjectMemberRole.fromValue(json['role'] as String),
      joinedAt: DateTime.parse(json['joined_at'] as String),
      userEmail: json['user_email'] as String?,
      userFullName: json['user_full_name'] as String?,
    );
  }
}

/// 專案客戶模型
class ProjectClient {
  final String id;
  final String projectId;
  final String name;
  final String? company;
  final String? email;
  final String? phone;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectClient({
    required this.id,
    required this.projectId,
    required this.name,
    this.company,
    this.email,
    this.phone,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectClient.fromJson(Map<String, dynamic> json) {
    return ProjectClient(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      name: json['name'] as String,
      company: json['company'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'name': name,
      'company': company,
      'email': email,
      'phone': phone,
      'notes': notes,
    };
  }
}

/// 專案時程模型
class ProjectTimeline {
  final String id;
  final String projectId;
  final String title;
  final String? description;
  final DateTime milestoneDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 創建者資訊
  final String? creatorEmail;
  final String? creatorFullName;

  ProjectTimeline({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    required this.milestoneDate,
    required this.isCompleted,
    this.completedAt,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.creatorEmail,
    this.creatorFullName,
  });

  factory ProjectTimeline.fromJson(Map<String, dynamic> json) {
    return ProjectTimeline(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      milestoneDate: DateTime.parse(json['milestone_date'] as String),
      isCompleted: json['is_completed'] as bool,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      creatorEmail: json['creator_email'] as String?,
      creatorFullName: json['creator_full_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'title': title,
      'description': description,
      'milestone_date': milestoneDate.toIso8601String().split('T')[0],
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'created_by': createdBy,
    };
  }
}

/// 專案留言模型
class ProjectComment {
  final String id;
  final String projectId;
  final String userId;
  final String content;
  final String? parentId;
  final List<dynamic>? attachments;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 用戶資訊
  final String? userEmail;
  final String? userFullName;

  // 回覆數量
  final int? replyCount;

  ProjectComment({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.content,
    this.parentId,
    this.attachments,
    required this.createdAt,
    required this.updatedAt,
    this.userEmail,
    this.userFullName,
    this.replyCount,
  });

  factory ProjectComment.fromJson(Map<String, dynamic> json) {
    return ProjectComment(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      parentId: json['parent_id'] as String?,
      attachments: json['attachments'] as List?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      userEmail: json['user_email'] as String?,
      userFullName: json['user_full_name'] as String?,
      replyCount: json['reply_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'user_id': userId,
      'content': content,
      'parent_id': parentId,
      'attachments': attachments,
    };
  }
}

/// 任務狀態
enum TaskStatus {
  todo('todo', '待處理'),
  inProgress('in_progress', '進行中'),
  completed('completed', '已完成'),
  blocked('blocked', '已阻塞');

  final String value;
  final String label;

  const TaskStatus(this.value, this.label);

  static TaskStatus fromValue(String value) {
    return TaskStatus.values.firstWhere((e) => e.value == value);
  }
}

/// 任務優先級
enum TaskPriority {
  low('low', '低'),
  medium('medium', '中'),
  high('high', '高'),
  urgent('urgent', '緊急');

  final String value;
  final String label;

  const TaskPriority(this.value, this.label);

  static TaskPriority fromValue(String value) {
    return TaskPriority.values.firstWhere((e) => e.value == value);
  }
}

/// 專案任務模型
class ProjectTask {
  final String id;
  final String projectId;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final String? assignedTo;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 任務依賴
  final String? previousTaskId;
  final String? nextTaskId;

  final int displayOrder;
  final List<String>? tags;

  // 關聯資訊
  final String? assigneeEmail;
  final String? assigneeFullName;
  final String? creatorEmail;
  final String? creatorFullName;

  // 前後任務標題（方便顯示）
  final String? previousTaskTitle;
  final String? nextTaskTitle;

  ProjectTask({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.assignedTo,
    this.dueDate,
    this.completedAt,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.previousTaskId,
    this.nextTaskId,
    required this.displayOrder,
    this.tags,
    this.assigneeEmail,
    this.assigneeFullName,
    this.creatorEmail,
    this.creatorFullName,
    this.previousTaskTitle,
    this.nextTaskTitle,
  });

  factory ProjectTask.fromJson(Map<String, dynamic> json) {
    return ProjectTask(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: TaskStatus.fromValue(json['status'] as String),
      priority: TaskPriority.fromValue(json['priority'] as String),
      assignedTo: json['assigned_to'] as String?,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      previousTaskId: json['previous_task_id'] as String?,
      nextTaskId: json['next_task_id'] as String?,
      displayOrder: json['display_order'] as int? ?? 0,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      assigneeEmail: json['assignee_email'] as String?,
      assigneeFullName: json['assignee_full_name'] as String?,
      creatorEmail: json['creator_email'] as String?,
      creatorFullName: json['creator_full_name'] as String?,
      previousTaskTitle: json['previous_task_title'] as String?,
      nextTaskTitle: json['next_task_title'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'title': title,
      'description': description,
      'status': status.value,
      'priority': priority.value,
      'assigned_to': assignedTo,
      'due_date': dueDate?.toIso8601String().split('T')[0],
      'completed_at': completedAt?.toIso8601String(),
      'created_by': createdBy,
      'previous_task_id': previousTaskId,
      'next_task_id': nextTaskId,
      'display_order': displayOrder,
      'tags': tags,
    };
  }
}

/// 專案統計
class ProjectStatistics {
  final int totalMembers;
  final int totalClients;
  final int totalTimelineItems;
  final int completedTimelineItems;
  final int totalComments;
  final int totalTasks;
  final int completedTasks;
  final int inProgressTasks;
  final int totalFloorPlans;

  ProjectStatistics({
    required this.totalMembers,
    required this.totalClients,
    required this.totalTimelineItems,
    required this.completedTimelineItems,
    required this.totalComments,
    required this.totalTasks,
    required this.completedTasks,
    required this.inProgressTasks,
    required this.totalFloorPlans,
  });

  factory ProjectStatistics.fromJson(Map<String, dynamic> json) {
    return ProjectStatistics(
      totalMembers: json['total_members'] as int? ?? 0,
      totalClients: json['total_clients'] as int? ?? 0,
      totalTimelineItems: json['total_timeline_items'] as int? ?? 0,
      completedTimelineItems: json['completed_timeline_items'] as int? ?? 0,
      totalComments: json['total_comments'] as int? ?? 0,
      totalTasks: json['total_tasks'] as int? ?? 0,
      completedTasks: json['completed_tasks'] as int? ?? 0,
      inProgressTasks: json['in_progress_tasks'] as int? ?? 0,
      totalFloorPlans: json['total_floor_plans'] as int? ?? 0,
    );
  }

  double get timelineProgress {
    if (totalTimelineItems == 0) return 0;
    return completedTimelineItems / totalTimelineItems;
  }

  double get taskProgress {
    if (totalTasks == 0) return 0;
    return completedTasks / totalTasks;
  }
}
