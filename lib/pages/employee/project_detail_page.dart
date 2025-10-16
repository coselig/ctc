import 'package:ctc/models/models.dart';
import 'package:ctc/services/project_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
                    ],
                  ),
                  const Divider(height: 24),
                  if (project.description != null) ...[
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
              _StatCard(
                icon: Icons.chat,
                label: '留言',
                value: '${statistics.totalComments}',
                color: Colors.teal,
              ),
              _StatCard(
                icon: Icons.architecture,
                label: '設計圖',
                value: '${statistics.totalFloorPlans}',
                color: Colors.indigo,
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
class _MembersTab extends StatelessWidget {
  final String projectId;

  const _MembersTab({required this.projectId});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('成員管理功能開發中...'));
  }
}

class _ClientsTab extends StatelessWidget {
  final String projectId;

  const _ClientsTab({required this.projectId});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('客戶管理功能開發中...'));
  }
}

class _TimelineTab extends StatelessWidget {
  final String projectId;

  const _TimelineTab({required this.projectId});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('時程管理功能開發中...'));
  }
}

class _CommentsTab extends StatelessWidget {
  final String projectId;

  const _CommentsTab({required this.projectId});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('留言板功能開發中...'));
  }
}

class _TasksTab extends StatelessWidget {
  final String projectId;

  const _TasksTab({required this.projectId});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('任務管理功能開發中...'));
  }
}
