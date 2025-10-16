import 'package:ctc/models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 專案管理服務
class ProjectService {
  final SupabaseClient _client;

  ProjectService(this._client);

  /// 獲取用戶的所有專案
  Future<List<Project>> getProjects() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('請先登入');

      final response = await _client
          .from('projects')
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((json) => Project.fromJson(json)).toList();
    } catch (e) {
      print('獲取專案列表失敗: $e');
      rethrow;
    }
  }

  /// 獲取單個專案
  Future<Project> getProject(String projectId) async {
    try {
      final response = await _client
          .from('projects')
          .select()
          .eq('id', projectId)
          .single();

      return Project.fromJson(response);
    } catch (e) {
      print('獲取專案失敗: $e');
      rethrow;
    }
  }

  /// 創建專案
  Future<Project> createProject({
    required String name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('請先登入');

      final response = await _client
          .from('projects')
          .insert({
            'name': name,
            'description': description,
            'start_date': startDate?.toIso8601String().split('T')[0],
            'end_date': endDate?.toIso8601String().split('T')[0],
            'budget': budget,
            'owner_id': user.id,
            'status': 'active',
          })
          .select()
          .single();

      return Project.fromJson(response);
    } catch (e) {
      print('創建專案失敗: $e');
      rethrow;
    }
  }

  /// 更新專案
  Future<void> updateProject(
    String projectId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _client.from('projects').update(updates).eq('id', projectId);
    } catch (e) {
      print('更新專案失敗: $e');
      rethrow;
    }
  }

  /// 刪除專案
  Future<void> deleteProject(String projectId) async {
    try {
      await _client.from('projects').delete().eq('id', projectId);
    } catch (e) {
      print('刪除專案失敗: $e');
      rethrow;
    }
  }

  /// 獲取專案統計
  Future<ProjectStatistics> getProjectStatistics(String projectId) async {
    try {
      final response = await _client.rpc(
        'get_project_statistics',
        params: {'p_project_id': projectId},
      );

      return ProjectStatistics.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('獲取專案統計失敗: $e');
      rethrow;
    }
  }

  // ==================== 成員管理 ====================

  /// 獲取專案成員
  Future<List<ProjectMember>> getMembers(String projectId) async {
    try {
      final response = await _client
          .from('project_members')
          .select('''
            *,
            user_email:profiles!project_members_user_id_fkey(email),
            user_full_name:profiles!project_members_user_id_fkey(full_name)
          ''')
          .eq('project_id', projectId)
          .order('joined_at');

      return (response as List).map((json) {
        // 扁平化處理
        final flatJson = Map<String, dynamic>.from(json);
        if (json['user_email'] != null) {
          flatJson['user_email'] = json['user_email']['email'];
        }
        if (json['user_full_name'] != null) {
          flatJson['user_full_name'] = json['user_full_name']['full_name'];
        }
        return ProjectMember.fromJson(flatJson);
      }).toList();
    } catch (e) {
      print('獲取成員列表失敗: $e');
      rethrow;
    }
  }

  /// 添加成員
  Future<void> addMember({
    required String projectId,
    required String userId,
    required ProjectMemberRole role,
  }) async {
    try {
      await _client.from('project_members').insert({
        'project_id': projectId,
        'user_id': userId,
        'role': role.value,
      });
    } catch (e) {
      print('添加成員失敗: $e');
      rethrow;
    }
  }

  /// 更新成員角色
  Future<void> updateMemberRole({
    required String memberId,
    required ProjectMemberRole role,
  }) async {
    try {
      await _client
          .from('project_members')
          .update({'role': role.value})
          .eq('id', memberId);
    } catch (e) {
      print('更新成員角色失敗: $e');
      rethrow;
    }
  }

  /// 移除成員
  Future<void> removeMember(String memberId) async {
    try {
      await _client.from('project_members').delete().eq('id', memberId);
    } catch (e) {
      print('移除成員失敗: $e');
      rethrow;
    }
  }

  // ==================== 客戶管理 ====================

  /// 獲取專案客戶
  Future<List<ProjectClient>> getClients(String projectId) async {
    try {
      final response = await _client
          .from('project_clients')
          .select()
          .eq('project_id', projectId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ProjectClient.fromJson(json))
          .toList();
    } catch (e) {
      print('獲取客戶列表失敗: $e');
      rethrow;
    }
  }

  /// 添加客戶
  Future<ProjectClient> addClient({
    required String projectId,
    required String name,
    String? company,
    String? email,
    String? phone,
    String? notes,
  }) async {
    try {
      final response = await _client
          .from('project_clients')
          .insert({
            'project_id': projectId,
            'name': name,
            'company': company,
            'email': email,
            'phone': phone,
            'notes': notes,
          })
          .select()
          .single();

      return ProjectClient.fromJson(response);
    } catch (e) {
      print('添加客戶失敗: $e');
      rethrow;
    }
  }

  /// 更新客戶
  Future<void> updateClient(
    String clientId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _client.from('project_clients').update(updates).eq('id', clientId);
    } catch (e) {
      print('更新客戶失敗: $e');
      rethrow;
    }
  }

  /// 刪除客戶
  Future<void> deleteClient(String clientId) async {
    try {
      await _client.from('project_clients').delete().eq('id', clientId);
    } catch (e) {
      print('刪除客戶失敗: $e');
      rethrow;
    }
  }

  // ==================== 時程管理 ====================

  /// 獲取專案時程
  Future<List<ProjectTimeline>> getTimeline(String projectId) async {
    try {
      final response = await _client
          .from('project_timeline')
          .select('''
            *,
            creator_email:profiles!project_timeline_created_by_fkey(email),
            creator_full_name:profiles!project_timeline_created_by_fkey(full_name)
          ''')
          .eq('project_id', projectId)
          .order('milestone_date');

      return (response as List).map((json) {
        final flatJson = Map<String, dynamic>.from(json);
        if (json['creator_email'] != null) {
          flatJson['creator_email'] = json['creator_email']['email'];
        }
        if (json['creator_full_name'] != null) {
          flatJson['creator_full_name'] =
              json['creator_full_name']['full_name'];
        }
        return ProjectTimeline.fromJson(flatJson);
      }).toList();
    } catch (e) {
      print('獲取時程失敗: $e');
      rethrow;
    }
  }

  /// 添加時程項目
  Future<ProjectTimeline> addTimelineItem({
    required String projectId,
    required String title,
    String? description,
    required DateTime milestoneDate,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('請先登入');

      final response = await _client
          .from('project_timeline')
          .insert({
            'project_id': projectId,
            'title': title,
            'description': description,
            'milestone_date': milestoneDate.toIso8601String().split('T')[0],
            'created_by': user.id,
          })
          .select()
          .single();

      return ProjectTimeline.fromJson(response);
    } catch (e) {
      print('添加時程項目失敗: $e');
      rethrow;
    }
  }

  /// 更新時程項目
  Future<void> updateTimelineItem(
    String itemId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _client.from('project_timeline').update(updates).eq('id', itemId);
    } catch (e) {
      print('更新時程項目失敗: $e');
      rethrow;
    }
  }

  /// 標記時程項目為完成/未完成
  Future<void> toggleTimelineCompletion(String itemId, bool isCompleted) async {
    try {
      await _client
          .from('project_timeline')
          .update({
            'is_completed': isCompleted,
            'completed_at': isCompleted
                ? DateTime.now().toIso8601String()
                : null,
          })
          .eq('id', itemId);
    } catch (e) {
      print('更新時程狀態失敗: $e');
      rethrow;
    }
  }

  /// 刪除時程項目
  Future<void> deleteTimelineItem(String itemId) async {
    try {
      await _client.from('project_timeline').delete().eq('id', itemId);
    } catch (e) {
      print('刪除時程項目失敗: $e');
      rethrow;
    }
  }

  // ==================== 留言板 ====================

  /// 獲取專案留言
  Future<List<ProjectComment>> getComments(String projectId) async {
    try {
      final response = await _client
          .from('project_comments')
          .select('''
            *,
            user_email:profiles!project_comments_user_id_fkey(email),
            user_full_name:profiles!project_comments_user_id_fkey(full_name)
          ''')
          .eq('project_id', projectId)
          .isFilter('parent_id', null)
          .order('created_at', ascending: false);

      return (response as List).map((json) {
        final flatJson = Map<String, dynamic>.from(json);
        if (json['user_email'] != null) {
          flatJson['user_email'] = json['user_email']['email'];
        }
        if (json['user_full_name'] != null) {
          flatJson['user_full_name'] = json['user_full_name']['full_name'];
        }
        return ProjectComment.fromJson(flatJson);
      }).toList();
    } catch (e) {
      print('獲取留言失敗: $e');
      rethrow;
    }
  }

  /// 獲取留言的回覆
  Future<List<ProjectComment>> getReplies(String commentId) async {
    try {
      final response = await _client
          .from('project_comments')
          .select('''
            *,
            user_email:profiles!project_comments_user_id_fkey(email),
            user_full_name:profiles!project_comments_user_id_fkey(full_name)
          ''')
          .eq('parent_id', commentId)
          .order('created_at');

      return (response as List).map((json) {
        final flatJson = Map<String, dynamic>.from(json);
        if (json['user_email'] != null) {
          flatJson['user_email'] = json['user_email']['email'];
        }
        if (json['user_full_name'] != null) {
          flatJson['user_full_name'] = json['user_full_name']['full_name'];
        }
        return ProjectComment.fromJson(flatJson);
      }).toList();
    } catch (e) {
      print('獲取回覆失敗: $e');
      rethrow;
    }
  }

  /// 添加留言
  Future<ProjectComment> addComment({
    required String projectId,
    required String content,
    String? parentId,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('請先登入');

      final response = await _client
          .from('project_comments')
          .insert({
            'project_id': projectId,
            'user_id': user.id,
            'content': content,
            'parent_id': parentId,
          })
          .select()
          .single();

      return ProjectComment.fromJson(response);
    } catch (e) {
      print('添加留言失敗: $e');
      rethrow;
    }
  }

  /// 更新留言
  Future<void> updateComment(String commentId, String content) async {
    try {
      await _client
          .from('project_comments')
          .update({'content': content})
          .eq('id', commentId);
    } catch (e) {
      print('更新留言失敗: $e');
      rethrow;
    }
  }

  /// 刪除留言
  Future<void> deleteComment(String commentId) async {
    try {
      await _client.from('project_comments').delete().eq('id', commentId);
    } catch (e) {
      print('刪除留言失敗: $e');
      rethrow;
    }
  }

  // ==================== 任務管理 ====================

  /// 獲取專案任務
  Future<List<ProjectTask>> getTasks(String projectId) async {
    try {
      final response = await _client
          .from('project_tasks')
          .select('''
            *,
            assignee_email:profiles!project_tasks_assigned_to_fkey(email),
            assignee_full_name:profiles!project_tasks_assigned_to_fkey(full_name),
            creator_email:profiles!project_tasks_created_by_fkey(email),
            creator_full_name:profiles!project_tasks_created_by_fkey(full_name)
          ''')
          .eq('project_id', projectId)
          .order('display_order');

      return (response as List).map((json) {
        final flatJson = Map<String, dynamic>.from(json);
        if (json['assignee_email'] != null) {
          flatJson['assignee_email'] = json['assignee_email']['email'];
        }
        if (json['assignee_full_name'] != null) {
          flatJson['assignee_full_name'] =
              json['assignee_full_name']['full_name'];
        }
        if (json['creator_email'] != null) {
          flatJson['creator_email'] = json['creator_email']['email'];
        }
        if (json['creator_full_name'] != null) {
          flatJson['creator_full_name'] =
              json['creator_full_name']['full_name'];
        }
        return ProjectTask.fromJson(flatJson);
      }).toList();
    } catch (e) {
      print('獲取任務列表失敗: $e');
      rethrow;
    }
  }

  /// 添加任務
  Future<ProjectTask> addTask({
    required String projectId,
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    String? assignedTo,
    DateTime? dueDate,
    String? previousTaskId,
    List<String>? tags,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('請先登入');

      final response = await _client
          .from('project_tasks')
          .insert({
            'project_id': projectId,
            'title': title,
            'description': description,
            'status': 'todo',
            'priority': priority.value,
            'assigned_to': assignedTo,
            'due_date': dueDate?.toIso8601String().split('T')[0],
            'created_by': user.id,
            'previous_task_id': previousTaskId,
            'tags': tags,
          })
          .select()
          .single();

      // 如果有前置任務，更新前置任務的 next_task_id
      if (previousTaskId != null) {
        await _client
            .from('project_tasks')
            .update({'next_task_id': response['id']})
            .eq('id', previousTaskId);
      }

      return ProjectTask.fromJson(response);
    } catch (e) {
      print('添加任務失敗: $e');
      rethrow;
    }
  }

  /// 更新任務
  Future<void> updateTask(String taskId, Map<String, dynamic> updates) async {
    try {
      // 如果狀態改為完成，設置完成時間
      if (updates['status'] == 'completed' &&
          !updates.containsKey('completed_at')) {
        updates['completed_at'] = DateTime.now().toIso8601String();
      }
      // 如果狀態從完成改為其他，清除完成時間
      if (updates['status'] != 'completed' && updates.containsKey('status')) {
        updates['completed_at'] = null;
      }

      await _client.from('project_tasks').update(updates).eq('id', taskId);
    } catch (e) {
      print('更新任務失敗: $e');
      rethrow;
    }
  }

  /// 刪除任務
  Future<void> deleteTask(String taskId) async {
    try {
      // 先獲取任務資訊
      final task = await _client
          .from('project_tasks')
          .select('previous_task_id, next_task_id')
          .eq('id', taskId)
          .single();

      // 更新相關任務的依賴關係
      if (task['previous_task_id'] != null && task['next_task_id'] != null) {
        // 將前置任務的 next 指向下一個任務
        await _client
            .from('project_tasks')
            .update({'next_task_id': task['next_task_id']})
            .eq('id', task['previous_task_id']);

        // 將下一個任務的 previous 指向前置任務
        await _client
            .from('project_tasks')
            .update({'previous_task_id': task['previous_task_id']})
            .eq('id', task['next_task_id']);
      } else if (task['previous_task_id'] != null) {
        // 只有前置任務，清除其 next
        await _client
            .from('project_tasks')
            .update({'next_task_id': null})
            .eq('id', task['previous_task_id']);
      } else if (task['next_task_id'] != null) {
        // 只有下一個任務，清除其 previous
        await _client
            .from('project_tasks')
            .update({'previous_task_id': null})
            .eq('id', task['next_task_id']);
      }

      // 刪除任務
      await _client.from('project_tasks').delete().eq('id', taskId);
    } catch (e) {
      print('刪除任務失敗: $e');
      rethrow;
    }
  }

  /// 搜尋用戶（用於分配任務和添加成員）
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final response = await _client
          .from('profiles')
          .select('id, email, full_name')
          .ilike('email', '%$query%')
          .limit(10);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('搜尋用戶失敗: $e');
      rethrow;
    }
  }
}
