import 'package:ctc/models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 專案管理服務
class ProjectService {
  final SupabaseClient _client;

  ProjectService(this._client);

  /// 獲取用戶的所有專案（包含自己的和被授權的）
  Future<List<Project>> getProjects() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('請先登入');

      // 方法 1: 獲取自己創建的專案
      final ownProjects = await _client
          .from('projects')
          .select()
          .eq('owner_id', user.id);

      print('獲取到 ${ownProjects.length} 個自己的專案');

      // 方法 2: 獲取被授權的專案ID列表
      final memberships = await _client
          .from('project_members')
          .select('project_id, role')
          .eq('user_id', user.id);

      print('獲取到 ${memberships.length} 個成員記錄');

      // 如果有被授權的專案，獲取它們的詳細資訊
      List<dynamic> sharedProjects = [];
      if (memberships.isNotEmpty) {
        final sharedProjectIds = memberships
            .map((m) => m['project_id'] as String)
            .toList();

        print('被授權的專案IDs: $sharedProjectIds');

        sharedProjects = await _client
            .from('projects')
            .select()
            .inFilter('id', sharedProjectIds);

        print('獲取到 ${sharedProjects.length} 個被授權的專案');

        // 為每個被授權的專案添加角色資訊
        for (var project in sharedProjects) {
          final membership = memberships.firstWhere(
            (m) => m['project_id'] == project['id'],
            orElse: () => {'role': 'viewer'},
          );
          project['member_role'] = membership['role'];
          project['is_owner'] = false; // 標記為非擁有者
        }
      }

      // 為自己的專案添加標記
      for (var project in ownProjects) {
        project['is_owner'] = true;
        project['member_role'] = 'owner'; // 擁有者角色
      }

      // 合併兩個列表並按創建時間排序
      final allProjects = [...ownProjects, ...sharedProjects];
      allProjects.sort((a, b) {
        final aTime = DateTime.parse(a['created_at'] as String);
        final bTime = DateTime.parse(b['created_at'] as String);
        return bTime.compareTo(aTime); // 降序排列
      });

      print('總共獲取到 ${allProjects.length} 個專案');

      return allProjects.map((json) => Project.fromJson(json)).toList();
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
      // 1. 先獲取專案成員列表
      final membersResponse = await _client
          .from('project_members')
          .select('*')
          .eq('project_id', projectId)
          .order('joined_at');

      final members = membersResponse as List;

      // 如果沒有成員，直接返回空列表
      if (members.isEmpty) {
        return [];
      }

      // 2. 獲取所有成員的 user_id
      final userIds = members.map((m) => m['user_id'] as String).toList();

      // 3. 批量查詢用戶資料
      final profilesResponse = await _client
          .from('profiles')
          .select('id, email, full_name')
          .inFilter('id', userIds);

      final profiles = profilesResponse as List;

      // 4. 建立 user_id 到用戶資料的映射
      final profileMap = <String, Map<String, dynamic>>{
        for (var profile in profiles) profile['id'] as String: profile,
      };

      // 5. 組合數據
      return members.map((json) {
        final profile = profileMap[json['user_id']];
        final flatJson = Map<String, dynamic>.from(json);
        flatJson['user_email'] = profile?['email'];
        flatJson['user_full_name'] = profile?['full_name'];
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
      // 1. 先獲取時程列表
      final timelineResponse = await _client
          .from('project_timeline')
          .select('*')
          .eq('project_id', projectId)
          .order('milestone_date');

      final timeline = timelineResponse as List;

      // 如果沒有時程項目，直接返回空列表
      if (timeline.isEmpty) {
        return [];
      }

      // 2. 獲取所有創建者的 user_id（過濾掉 null）
      final creatorIds = timeline
          .where((t) => t['created_by'] != null)
          .map((t) => t['created_by'] as String)
          .toSet()
          .toList();

      // 3. 如果有創建者，批量查詢用戶資料
      Map<String, Map<String, dynamic>> profileMap = {};
      if (creatorIds.isNotEmpty) {
        final profilesResponse = await _client
            .from('profiles')
            .select('id, email, full_name')
            .inFilter('id', creatorIds);

        final profiles = profilesResponse as List;
        profileMap = {
          for (var profile in profiles) profile['id'] as String: profile,
        };
      }

      // 4. 組合數據
      return timeline.map((json) {
        final flatJson = Map<String, dynamic>.from(json);
        if (json['created_by'] != null) {
          final profile = profileMap[json['created_by']];
          flatJson['creator_email'] = profile?['email'];
          flatJson['creator_full_name'] = profile?['full_name'];
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
      // 1. 先獲取留言列表
      final commentsResponse = await _client
          .from('project_comments')
          .select('*')
          .eq('project_id', projectId)
          .isFilter('parent_id', null)
          .order('created_at', ascending: false);

      final comments = commentsResponse as List;

      if (comments.isEmpty) {
        return [];
      }

      // 2. 獲取所有用戶 ID
      final userIds = comments
          .map((c) => c['user_id'] as String)
          .toSet()
          .toList();

      // 3. 批量查詢用戶資料
      final profilesResponse = await _client
          .from('profiles')
          .select('id, email, full_name')
          .inFilter('id', userIds);

      final profiles = profilesResponse as List;
      final profileMap = <String, Map<String, dynamic>>{
        for (var profile in profiles) profile['id'] as String: profile,
      };

      // 4. 組合數據
      return comments.map((json) {
        final flatJson = Map<String, dynamic>.from(json);
        final profile = profileMap[json['user_id']];
        flatJson['user_email'] = profile?['email'];
        flatJson['user_full_name'] = profile?['full_name'];
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
      // 1. 先獲取回覆列表
      final repliesResponse = await _client
          .from('project_comments')
          .select('*')
          .eq('parent_id', commentId)
          .order('created_at');

      final replies = repliesResponse as List;

      if (replies.isEmpty) {
        return [];
      }

      // 2. 獲取所有用戶 ID
      final userIds = replies
          .map((r) => r['user_id'] as String)
          .toSet()
          .toList();

      // 3. 批量查詢用戶資料
      final profilesResponse = await _client
          .from('profiles')
          .select('id, email, full_name')
          .inFilter('id', userIds);

      final profiles = profilesResponse as List;
      final profileMap = <String, Map<String, dynamic>>{
        for (var profile in profiles) profile['id'] as String: profile,
      };

      // 4. 組合數據
      return replies.map((json) {
        final flatJson = Map<String, dynamic>.from(json);
        final profile = profileMap[json['user_id']];
        flatJson['user_email'] = profile?['email'];
        flatJson['user_full_name'] = profile?['full_name'];
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
      // 1. 先獲取任務列表
      final tasksResponse = await _client
          .from('project_tasks')
          .select('*')
          .eq('project_id', projectId)
          .order('display_order');

      final tasks = tasksResponse as List;

      if (tasks.isEmpty) {
        return [];
      }

      // 2. 獲取所有相關的用戶 ID（assigned_to 和 created_by）
      final userIds = <String>{};
      for (var task in tasks) {
        if (task['assigned_to'] != null) {
          userIds.add(task['assigned_to'] as String);
        }
        if (task['created_by'] != null) {
          userIds.add(task['created_by'] as String);
        }
      }

      // 3. 如果有用戶 ID，批量查詢用戶資料
      Map<String, Map<String, dynamic>> profileMap = {};
      if (userIds.isNotEmpty) {
        final profilesResponse = await _client
            .from('profiles')
            .select('id, email, full_name')
            .inFilter('id', userIds.toList());

        final profiles = profilesResponse as List;
        profileMap = {
          for (var profile in profiles) profile['id'] as String: profile,
        };
      }

      // 4. 組合數據
      return tasks.map((json) {
        final flatJson = Map<String, dynamic>.from(json);

        // 處理 assigned_to
        if (json['assigned_to'] != null) {
          final assigneeProfile = profileMap[json['assigned_to']];
          flatJson['assignee_email'] = assigneeProfile?['email'];
          flatJson['assignee_full_name'] = assigneeProfile?['full_name'];
        }
        
        // 處理 created_by
        if (json['created_by'] != null) {
          final creatorProfile = profileMap[json['created_by']];
          flatJson['creator_email'] = creatorProfile?['email'];
          flatJson['creator_full_name'] = creatorProfile?['full_name'];
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
