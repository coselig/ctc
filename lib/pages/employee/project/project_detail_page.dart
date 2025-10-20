import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/models.dart';
import '../../../services/project_service.dart';
import 'project_clients_tab.dart';
import 'project_comments_tab.dart';
import 'project_timeline_tab.dart';

/// 專案詳情頁面（包含所有子功能的標籤頁）
class ProjectDetailPage extends StatefulWidget {
  final String projectId;

  const ProjectDetailPage({super.key, required this.projectId});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage>
    with SingleTickerProviderStateMixin {
  final _projectService = ProjectService(Supabase.instance.client);
  late TabController _tabController;

  Project? _project;
  ProjectStatistics? _statistics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadProjectData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProjectData() async {
    try {
      setState(() => _isLoading = true);

      final project = await _projectService.getProject(widget.projectId);
      final stats = await _projectService.getProjectStatistics(
        widget.projectId,
      );

      setState(() {
        _project = project;
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('載入專案資料失敗: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_project?.name ?? '專案詳情'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: '概覽'),
            Tab(icon: Icon(Icons.people), text: '成員'),
            Tab(icon: Icon(Icons.business), text: '客戶'),
            Tab(icon: Icon(Icons.timeline), text: '時程'),
            Tab(icon: Icon(Icons.chat), text: '留言板'),
            Tab(icon: Icon(Icons.checklist), text: '任務'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _project == null
          ? const Center(child: Text('專案不存在'))
          : TabBarView(
              controller: _tabController,
              children: [
                _OverviewTab(project: _project!, statistics: _statistics!),
                _MembersTab(projectId: widget.projectId),
                _ClientsTab(projectId: widget.projectId),
                _TimelineTab(projectId: widget.projectId),
                _CommentsTab(projectId: widget.projectId),
                _TasksTab(projectId: widget.projectId),
              ],
            ),
    );
  }
}

// ==================== 概覽標籤 ====================
class _OverviewTab extends StatelessWidget {
  final Project project;
  final ProjectStatistics statistics;

  const _OverviewTab({required this.project, required this.statistics});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 專案資訊卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        '專案資訊',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        tooltip: '編輯專案',
                        onPressed: () async {
                          final nameController = TextEditingController(
                            text: project.name,
                          );
                          final descController = TextEditingController(
                            text: project.description ?? '',
                          );
                          DateTime? startDate = project.startDate;
                          DateTime? endDate = project.endDate;
                          final result = await showDialog<bool>(
                            context: context,
                            builder: (context) => StatefulBuilder(
                              builder: (context, setDialogState) => AlertDialog(
                                title: const Text('編輯專案'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: nameController,
                                        decoration: const InputDecoration(
                                          labelText: '專案名稱',
                                        ),
                                      ),
                                      TextField(
                                        controller: descController,
                                        decoration: const InputDecoration(
                                          labelText: '專案描述',
                                        ),
                                        minLines: 2,
                                        maxLines: 4,
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.play_arrow,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text('開始日期：'),
                                          TextButton(
                                            onPressed: () async {
                                              final picked =
                                                  await showDatePicker(
                                                    context: context,
                                                    initialDate:
                                                        startDate ??
                                                        DateTime.now(),
                                                    firstDate: DateTime(2000),
                                                    lastDate: DateTime(2100),
                                                  );
                                              if (picked != null) {
                                                setDialogState(
                                                  () => startDate = picked,
                                                );
                                              }
                                            },
                                            child: Text(
                                              startDate == null
                                                  ? '未設定'
                                                  : '${startDate!.year}/${startDate!.month}/${startDate!.day}',
                                            ),
                                          ),
                                          if (startDate != null)
                                            IconButton(
                                              icon: const Icon(
                                                Icons.clear,
                                                size: 18,
                                              ),
                                              tooltip: '清除',
                                              onPressed: () => setDialogState(
                                                () => startDate = null,
                                              ),
                                            ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.event, size: 20),
                                          const SizedBox(width: 8),
                                          const Text('結束日期：'),
                                          TextButton(
                                            onPressed: () async {
                                              final picked =
                                                  await showDatePicker(
                                                    context: context,
                                                    initialDate:
                                                        endDate ??
                                                        (startDate ??
                                                            DateTime.now()),
                                                    firstDate:
                                                        startDate ??
                                                        DateTime(2000),
                                                    lastDate: DateTime(2100),
                                                  );
                                              if (picked != null) {
                                                setDialogState(
                                                  () => endDate = picked,
                                                );
                                              }
                                            },
                                            child: Text(
                                              endDate == null
                                                  ? '未設定'
                                                  : '${endDate!.year}/${endDate!.month}/${endDate!.day}',
                                            ),
                                          ),
                                          if (endDate != null)
                                            IconButton(
                                              icon: const Icon(
                                                Icons.clear,
                                                size: 18,
                                              ),
                                              tooltip: '清除',
                                              onPressed: () => setDialogState(
                                                () => endDate = null,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('取消'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final newName = nameController.text
                                          .trim();
                                      final newDesc = descController.text
                                          .trim();
                                      if (newName.isEmpty) return;
                                      try {
                                        final projectService = ProjectService(
                                          Supabase.instance.client,
                                        );
                                        await projectService
                                            .updateProject(project.id, {
                                              'name': newName,
                                              'description': newDesc,
                                              'start_date': startDate
                                                  ?.toIso8601String()
                                                  .split('T')[0],
                                              'end_date': endDate
                                                  ?.toIso8601String()
                                                  .split('T')[0],
                                            });
                                        Navigator.of(context).pop(true);
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text('更新失敗: $e')),
                                        );
                                      }
                                    },
                                    child: const Text('儲存'),
                                  ),
                                ],
                              ),
                            ),
                          );
                          if (result == true) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('專案已更新')),
                              );
                              final state = context
                                  .findAncestorStateOfType<
                                    _ProjectDetailPageState
                                  >();
                              state?._loadProjectData();
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  if (project.description != null &&
                      project.description!.isNotEmpty) ...[
                    Text(
                      project.description!,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _InfoRow(
                    icon: Icons.flag,
                    label: '狀態',
                    value: project.status.label,
                  ),
                  if (project.startDate != null)
                    _InfoRow(
                      icon: Icons.play_arrow,
                      label: '開始日期',
                      value:
                          '${project.startDate!.year}/${project.startDate!.month}/${project.startDate!.day}',
                    ),
                  if (project.endDate != null)
                    _InfoRow(
                      icon: Icons.event,
                      label: '結束日期',
                      value:
                          '${project.endDate!.year}/${project.endDate!.month}/${project.endDate!.day}',
                    ),
                  if (project.budget != null)
                    _InfoRow(
                      icon: Icons.attach_money,
                      label: '預算',
                      value: 'NT\$ ${project.budget!.toStringAsFixed(0)}',
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 統計資訊
          const Text(
            '專案統計',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _StatCard(
                icon: Icons.people,
                label: '成員',
                value: '${statistics.totalMembers}',
                color: Colors.blue,
              ),
              _StatCard(
                icon: Icons.business,
                label: '客戶',
                value: '${statistics.totalClients}',
                color: Colors.green,
              ),
              _StatCard(
                icon: Icons.timeline,
                label: '時程項目',
                value:
                    '${statistics.completedTimelineItems}/${statistics.totalTimelineItems}',
                color: Colors.purple,
              ),
              _StatCard(
                icon: Icons.check_circle,
                label: '任務完成',
                value: '${statistics.completedTasks}/${statistics.totalTasks}',
                color: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 進度條
          if (statistics.totalTasks > 0) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '任務進度',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: statistics.taskProgress,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(statistics.taskProgress * 100).toStringAsFixed(0)}% 完成',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text('$label:', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 其他標籤（佔位符）====================
class _MembersTab extends StatefulWidget {
  final String projectId;

  const _MembersTab({required this.projectId});

  @override
  State<_MembersTab> createState() => _MembersTabState();
}

class _MembersTabState extends State<_MembersTab> {
  final _projectService = ProjectService(Supabase.instance.client);
  List<ProjectMember> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);
    try {
      final members = await _projectService.getMembers(widget.projectId);
      if (mounted) {
        setState(() {
          _members = members;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('載入成員失敗: $e')));
      }
    }
  }

  Future<void> _showAddMemberDialog() async {
    final searchController = TextEditingController();
    List<Map<String, dynamic>> availableUsers = [];
    bool isSearching = false;

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('添加成員'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: '搜尋用戶（郵箱）',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () async {
                        if (searchController.text.trim().isEmpty) return;

                        setDialogState(() => isSearching = true);
                        try {
                          final users = await _projectService.searchUsers(
                            searchController.text.trim(),
                          );
                          // 過濾掉已經是成員的用戶
                          final existingUserIds = _members
                              .map((m) => m.userId)
                              .toSet();
                          setDialogState(() {
                            availableUsers = users
                                .where(
                                  (u) => !existingUserIds.contains(u['id']),
                                )
                                .toList();
                            isSearching = false;
                          });
                        } catch (e) {
                          setDialogState(() => isSearching = false);
                          if (context.mounted) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text('搜尋失敗: $e')));
                          }
                        }
                      },
                    ),
                  ),
                  onSubmitted: (_) async {
                    // 按 Enter 也觸發搜尋
                    if (searchController.text.trim().isEmpty) return;

                    setDialogState(() => isSearching = true);
                    try {
                      final users = await _projectService.searchUsers(
                        searchController.text.trim(),
                      );
                      final existingUserIds = _members
                          .map((m) => m.userId)
                          .toSet();
                      setDialogState(() {
                        availableUsers = users
                            .where((u) => !existingUserIds.contains(u['id']))
                            .toList();
                        isSearching = false;
                      });
                    } catch (e) {
                      setDialogState(() => isSearching = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('搜尋失敗: $e')));
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
                if (isSearching)
                  const Center(child: CircularProgressIndicator())
                else if (availableUsers.isNotEmpty)
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: availableUsers.length,
                      itemBuilder: (context, index) {
                        final user = availableUsers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              (user['email'] as String)
                                  .substring(0, 1)
                                  .toUpperCase(),
                            ),
                          ),
                          title: Text(user['full_name'] ?? user['email']),
                          subtitle: Text(user['email']),
                          onTap: () => Navigator.pop(context, user),
                        );
                      },
                    ),
                  )
                else
                  const Center(child: Text('請搜尋用戶郵箱以添加成員')),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      // 顯示角色選擇對話框
      final selectedRole = await showDialog<ProjectMemberRole>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('選擇成員角色'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ProjectMemberRole.values
                .where(
                  (role) => role != ProjectMemberRole.owner,
                ) // 不能添加 owner 角色
                .map(
                  (role) => ListTile(
                    title: Text(role.label),
                    subtitle: Text(_getRoleDescription(role)),
                    onTap: () => Navigator.pop(context, role),
                  ),
                )
                .toList(),
          ),
        ),
      );

      if (selectedRole != null && mounted) {
        try {
          await _projectService.addMember(
            projectId: widget.projectId,
            userId: result['id'],
            role: selectedRole,
          );
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('成員已添加')));
            _loadMembers();
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('添加成員失敗: $e')));
          }
        }
      }
    }
  }

  Future<void> _updateMemberRole(
    ProjectMember member,
    ProjectMemberRole newRole,
  ) async {
    try {
      await _projectService.updateMemberRole(
        memberId: member.id,
        role: newRole,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('成員角色已更新')));
        _loadMembers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('更新失敗: $e')));
      }
    }
  }

  Future<void> _removeMember(ProjectMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認移除'),
        content: Text('確定要移除成員「${member.userFullName ?? member.userEmail}」嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('移除'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _projectService.removeMember(member.id);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('成員已移除')));
          _loadMembers();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('移除失敗: $e')));
        }
      }
    }
  }

  String _getRoleDescription(ProjectMemberRole role) {
    switch (role) {
      case ProjectMemberRole.owner:
        return '專案擁有者，擁有所有權限';
      case ProjectMemberRole.admin:
        return '管理員，可以管理成員和專案設置';
      case ProjectMemberRole.member:
        return '成員，可以編輯內容和創建任務';
      case ProjectMemberRole.viewer:
        return '檢視者，只能查看專案內容';
    }
  }

  Color _getRoleColor(ProjectMemberRole role) {
    switch (role) {
      case ProjectMemberRole.owner:
        return Colors.amber;
      case ProjectMemberRole.admin:
        return Colors.purple;
      case ProjectMemberRole.member:
        return Colors.blue;
      case ProjectMemberRole.viewer:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(ProjectMemberRole role) {
    switch (role) {
      case ProjectMemberRole.owner:
        return Icons.star;
      case ProjectMemberRole.admin:
        return Icons.admin_panel_settings;
      case ProjectMemberRole.member:
        return Icons.person;
      case ProjectMemberRole.viewer:
        return Icons.visibility;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // 工具欄
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '共 ${_members.length} 位成員',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              FilledButton.icon(
                onPressed: _showAddMemberDialog,
                icon: const Icon(Icons.person_add),
                label: const Text('添加成員'),
              ),
            ],
          ),
        ),

        // 成員列表
        Expanded(
          child: _members.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        '尚未添加成員',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _showAddMemberDialog,
                        icon: const Icon(Icons.person_add),
                        label: const Text('添加第一位成員'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _members.length,
                  itemBuilder: (context, index) {
                    final member = _members[index];
                    final isOwner = member.role == ProjectMemberRole.owner;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: _getRoleColor(member.role),
                          child: Icon(
                            _getRoleIcon(member.role),
                            color: Colors.white,
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              member.userFullName ??
                                  member.userEmail ??
                                  'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isOwner) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.amber),
                                ),
                                child: const Text(
                                  '擁有者',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (member.userFullName != null &&
                                member.userEmail != null)
                              Text(member.userEmail!),
                            const SizedBox(height: 8),
                            Chip(
                              label: Text(
                                member.role.label,
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: _getRoleColor(
                                member.role,
                              ).withAlpha(25),
                              side: BorderSide(
                                color: _getRoleColor(member.role),
                              ),
                              padding: EdgeInsets.zero,
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                          ],
                        ),
                        trailing: isOwner
                            ? null
                            : PopupMenuButton<String>(
                                onSelected: (value) async {
                                  switch (value) {
                                    case 'admin':
                                      await _updateMemberRole(
                                        member,
                                        ProjectMemberRole.admin,
                                      );
                                      break;
                                    case 'member':
                                      await _updateMemberRole(
                                        member,
                                        ProjectMemberRole.member,
                                      );
                                      break;
                                    case 'viewer':
                                      await _updateMemberRole(
                                        member,
                                        ProjectMemberRole.viewer,
                                      );
                                      break;
                                    case 'remove':
                                      await _removeMember(member);
                                      break;
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'admin',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.admin_panel_settings,
                                          size: 20,
                                          color: Colors.purple,
                                        ),
                                        SizedBox(width: 8),
                                        Text('設為管理員'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'member',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          size: 20,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(width: 8),
                                        Text('設為成員'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'viewer',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.visibility,
                                          size: 20,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 8),
                                        Text('設為檢視者'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuDivider(),
                                  const PopupMenuItem(
                                    value: 'remove',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.person_remove,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          '移除成員',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ClientsTab extends StatelessWidget {
  final String projectId;

  const _ClientsTab({required this.projectId});

  @override
  Widget build(BuildContext context) {
    return ProjectClientsTab(projectId: projectId);
  }
}

class _TimelineTab extends StatelessWidget {
  final String projectId;

  const _TimelineTab({required this.projectId});

  @override
  Widget build(BuildContext context) {
    return ProjectTimelineTab(projectId: projectId);
  }
}

class _CommentsTab extends StatelessWidget {
  final String projectId;

  const _CommentsTab({required this.projectId});

  @override
  Widget build(BuildContext context) {
    return ProjectCommentsTab(projectId: projectId);
  }
}

class _TasksTab extends StatefulWidget {
  final String projectId;

  const _TasksTab({required this.projectId});

  @override
  State<_TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<_TasksTab> {
  final _projectService = ProjectService(Supabase.instance.client);
  List<ProjectTask> _tasks = [];
  bool _isLoading = true;
  TaskStatus? _filterStatus;
  TaskPriority? _filterPriority;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      final tasks = await _projectService.getTasks(widget.projectId);
      if (mounted) {
        setState(() {
          _tasks = tasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('載入任務失敗: $e')));
      }
    }
  }

  Future<void> _showAddTaskDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    TaskPriority selectedPriority = TaskPriority.medium;
    DateTime? dueDate;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('新增任務'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: '任務標題',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: '任務描述',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // 優先級選擇
                const Text(
                  '優先級',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: TaskPriority.values.map((priority) {
                    final isSelected = priority == selectedPriority;
                    return ChoiceChip(
                      label: Text(priority.label),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setDialogState(() => selectedPriority = priority);
                        }
                      },
                      avatar: Icon(
                        _getPriorityIcon(priority),
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : _getPriorityColor(priority),
                      ),
                      selectedColor: _getPriorityColor(priority),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // 截止日期
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    dueDate == null
                        ? '設置截止日期（選填）'
                        : '截止日期: ${dueDate!.year}-${dueDate!.month.toString().padLeft(2, '0')}-${dueDate!.day.toString().padLeft(2, '0')}',
                  ),
                  trailing: dueDate != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setDialogState(() => dueDate = null),
                        )
                      : null,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: dueDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() => dueDate = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('請輸入任務標題')));
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('創建'),
            ),
          ],
        ),
      ),
    );

    if (result == true && mounted) {
      try {
        await _projectService.addTask(
          projectId: widget.projectId,
          title: titleController.text.trim(),
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
          priority: selectedPriority,
          dueDate: dueDate,
        );

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('任務已創建')));
          _loadTasks();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('創建任務失敗: $e')));
        }
      }
    }
  }

  Future<void> _updateTaskStatus(ProjectTask task, TaskStatus newStatus) async {
    try {
      await _projectService.updateTask(task.id, {
        'status': newStatus.value,
        if (newStatus == TaskStatus.completed)
          'completed_at': DateTime.now().toIso8601String(),
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('任務狀態已更新')));
        _loadTasks();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('更新失敗: $e')));
      }
    }
  }

  Future<void> _deleteTask(ProjectTask task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: Text('確定要刪除任務「${task.title}」嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('刪除'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _projectService.deleteTask(task.id);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('任務已刪除')));
          _loadTasks();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('刪除失敗: $e')));
        }
      }
    }
  }

  Future<void> _showEditTaskDialog(ProjectTask task) async {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description);
    DateTime? dueDate = task.dueDate;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('編輯任務'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: '任務標題'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: '任務描述'),
                  minLines: 2,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('到期日：'),
                    TextButton(
                      onPressed: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: dueDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          setDialogState(() => dueDate = selectedDate);
                        }
                      },
                      child: Text(
                        dueDate == null
                            ? '選擇日期'
                            : '${dueDate!.year}/${dueDate!.month}/${dueDate!.day}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('儲存'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      try {
        await _projectService.updateTask(task.id, {
          'title': titleController.text,
          'description': descriptionController.text,
          'due_date': dueDate?.toIso8601String(),
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('任務已更新')));
          _loadTasks();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('更新任務失敗: $e')));
        }
      }
    }
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Icons.arrow_downward;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.high:
        return Icons.arrow_upward;
      case TaskPriority.urgent:
        return Icons.priority_high;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.blue;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.deepOrange;
      case TaskPriority.urgent:
        return Colors.red;
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.blocked:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredTasks = _tasks.where((task) {
      if (_filterStatus != null && task.status != _filterStatus) return false;
      if (_filterPriority != null && task.priority != _filterPriority)
        return false;
      return true;
    }).toList();

    return Column(
      children: [
        // 工具欄
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 狀態篩選
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('全部'),
                        selected: _filterStatus == null,
                        onSelected: (selected) {
                          setState(() => _filterStatus = null);
                        },
                      ),
                      const SizedBox(width: 8),
                      ...TaskStatus.values.map(
                        (status) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(status.label),
                            selected: _filterStatus == status,
                            onSelected: (selected) {
                              setState(
                                () => _filterStatus = selected ? status : null,
                              );
                            },
                            avatar: Icon(
                              Icons.circle,
                              size: 12,
                              color: _getStatusColor(status),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _showAddTaskDialog,
                icon: const Icon(Icons.add),
                label: const Text('新增任務'),
              ),
            ],
          ),
        ),

        // 任務列表
        Expanded(
          child: filteredTasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.task_alt,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _tasks.isEmpty ? '尚未創建任務' : '無符合條件的任務',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      if (_tasks.isEmpty) ...[
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _showAddTaskDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('創建第一個任務'),
                        ),
                      ],
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Icon(
                          _getPriorityIcon(task.priority),
                          color: _getPriorityColor(task.priority),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: task.status == TaskStatus.completed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (task.description != null) ...[
                              const SizedBox(height: 4),
                              Text(task.description!),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Chip(
                                  label: Text(
                                    task.status.label,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor: _getStatusColor(
                                    task.status,
                                  ).withAlpha(25),
                                  side: BorderSide(
                                    color: _getStatusColor(task.status),
                                  ),
                                  padding: EdgeInsets.zero,
                                  labelPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Chip(
                                  label: Text(
                                    task.priority.label,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor: _getPriorityColor(
                                    task.priority,
                                  ).withAlpha(25),
                                  side: BorderSide(
                                    color: _getPriorityColor(task.priority),
                                  ),
                                  padding: EdgeInsets.zero,
                                  labelPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                                if (task.dueDate != null) ...[
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${task.dueDate!.year}-${task.dueDate!.month.toString().padLeft(2, '0')}-${task.dueDate!.day.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            switch (value) {
                              case 'edit':
                                await _showEditTaskDialog(task);
                                break;
                              case 'todo':
                                await _updateTaskStatus(task, TaskStatus.todo);
                                break;
                              case 'in_progress':
                                await _updateTaskStatus(
                                  task,
                                  TaskStatus.inProgress,
                                );
                                break;
                              case 'completed':
                                await _updateTaskStatus(
                                  task,
                                  TaskStatus.completed,
                                );
                                break;
                              case 'blocked':
                                await _updateTaskStatus(
                                  task,
                                  TaskStatus.blocked,
                                );
                                break;
                              case 'delete':
                                await _deleteTask(task);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('編輯任務'),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                              value: 'todo',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 12,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(width: 8),
                                  Text('標記為待辦'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'in_progress',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 12,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 8),
                                  Text('標記為進行中'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'completed',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 12,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 8),
                                  Text('標記為已完成'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'blocked',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 12,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text('標記為阻塞'),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text(
                                    '刪除任務',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
