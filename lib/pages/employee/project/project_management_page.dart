import 'package:ctc/models/models.dart';
import 'package:ctc/pages/employee/project/project_detail_page.dart';
import 'package:ctc/services/project_service.dart';
import 'package:ctc/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 專案管理列表頁面
class ProjectManagementPage extends StatefulWidget {
  const ProjectManagementPage({super.key});

  @override
  State<ProjectManagementPage> createState() => _ProjectManagementPageState();
}

class _ProjectManagementPageState extends State<ProjectManagementPage> {
  final _projectService = ProjectService(Supabase.instance.client);
  List<Project> _projects = [];
  bool _isLoading = true;
  String _filterStatus = 'all'; // all, active, completed, archived, on_hold

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      setState(() => _isLoading = true);
      final projects = await _projectService.getProjects();
      setState(() {
        _projects = projects;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('載入專案失敗: $e')));
      }
    }
  }

  List<Project> get _filteredProjects {
    if (_filterStatus == 'all') return _projects;
    return _projects.where((p) => p.status.value == _filterStatus).toList();
  }

  Future<void> _showCreateProjectDialog() async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('創建新專案'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '專案名稱 *',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: '專案描述',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setDialogState(() => startDate = date);
                          }
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          startDate == null
                              ? '開始日期'
                              : '${startDate!.year}/${startDate!.month}/${startDate!.day}',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: startDate ?? DateTime.now(),
                            firstDate: startDate ?? DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setDialogState(() => endDate = date);
                          }
                        },
                        icon: const Icon(Icons.event),
                        label: Text(
                          endDate == null
                              ? '結束日期'
                              : '${endDate!.year}/${endDate!.month}/${endDate!.day}',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('請輸入專案名稱')));
                  return;
                }

                try {
                  await _projectService.createProject(
                    name: nameController.text.trim(),
                    description: descController.text.trim().isEmpty
                        ? null
                        : descController.text.trim(),
                    startDate: startDate,
                    endDate: endDate,
                  );

                  if (context.mounted) {
                    Navigator.pop(context, true);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('創建失敗: $e')));
                  }
                }
              },
              child: const Text('創建'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      _loadProjects();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('專案已創建')));
      }
    }
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return Colors.blue;
      case ProjectStatus.completed:
        return Colors.green;
      case ProjectStatus.archived:
        return Colors.grey;
      case ProjectStatus.onHold:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return Icons.play_circle_outline;
      case ProjectStatus.completed:
        return Icons.check_circle_outline;
      case ProjectStatus.archived:
        return Icons.archive_outlined;
      case ProjectStatus.onHold:
        return Icons.pause_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GeneralPage(
      title: '專案管理',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _showCreateProjectDialog,
          tooltip: '創建專案',
        ),
      ],
      children: [
        // 篩選器
        Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('全部'),
                  selected: _filterStatus == 'all',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _filterStatus = 'all');
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('進行中'),
                  selected: _filterStatus == 'active',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _filterStatus = 'active');
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('已完成'),
                  selected: _filterStatus == 'completed',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _filterStatus = 'completed');
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('暫停中'),
                  selected: _filterStatus == 'on_hold',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _filterStatus = 'on_hold');
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('已封存'),
                  selected: _filterStatus == 'archived',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _filterStatus = 'archived');
                    }
                  },
                ),
              ],
            ),
          ),
        ),

        // 專案列表
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_filteredProjects.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _filterStatus == 'all' ? '尚未創建專案' : '沒有符合條件的專案',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  if (_filterStatus == 'all') ...[
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _showCreateProjectDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('創建第一個專案'),
                    ),
                  ],
                ],
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _filteredProjects.length,
              itemBuilder: (context, index) {
                final project = _filteredProjects[index];
                return _ProjectCard(
                  project: project,
                  statusColor: _getStatusColor(project.status),
                  statusIcon: _getStatusIcon(project.status),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProjectDetailPage(projectId: project.id),
                      ),
                    ).then((_) => _loadProjects());
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

/// 專案卡片組件
class _ProjectCard extends StatelessWidget {
  final Project project;
  final Color statusColor;
  final IconData statusIcon;
  final VoidCallback onTap;

  const _ProjectCard({
    required this.project,
    required this.statusColor,
    required this.statusIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final daysDiff = project.endDate != null
        ? project.endDate!.difference(DateTime.now()).inDays
        : null;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 標題和狀態
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    avatar: Icon(statusIcon, size: 16, color: statusColor),
                    label: Text(
                      project.status.label,
                      style: TextStyle(fontSize: 12, color: statusColor),
                    ),
                    backgroundColor: statusColor.withAlpha(25),
                    side: BorderSide.none,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 描述
              if (project.description != null) ...[
                Text(
                  project.description!,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ] else
                const Spacer(),

              // 日期資訊
              if (project.startDate != null || project.endDate != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${project.startDate != null ? "${project.startDate!.year}/${project.startDate!.month}/${project.startDate!.day}" : "?"} - ${project.endDate != null ? "${project.endDate!.year}/${project.endDate!.month}/${project.endDate!.day}" : "?"}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                if (daysDiff != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    daysDiff > 0
                        ? '剩餘 $daysDiff 天'
                        : daysDiff == 0
                        ? '今天到期'
                        : '已逾期 ${-daysDiff} 天',
                    style: TextStyle(
                      fontSize: 12,
                      color: daysDiff > 7
                          ? Colors.green
                          : daysDiff >= 0
                          ? Colors.orange
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],

              const Spacer(),

              // 底部資訊
              const Divider(height: 16),
              Row(
                children: [
                  Icon(Icons.update, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '更新於 ${project.updatedAt.month}/${project.updatedAt.day}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
