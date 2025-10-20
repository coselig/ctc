import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/models.dart';
import '../../../services/project_service.dart';

/// 專案時程管理標籤頁
class ProjectTimelineTab extends StatefulWidget {
  final String projectId;

  const ProjectTimelineTab({super.key, required this.projectId});

  @override
  State<ProjectTimelineTab> createState() => _ProjectTimelineTabState();
}

class _ProjectTimelineTabState extends State<ProjectTimelineTab> {
  final _projectService = ProjectService(Supabase.instance.client);
  List<ProjectTimeline> _timeline = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTimeline();
  }

  Future<void> _loadTimeline() async {
    setState(() => _isLoading = true);
    try {
      final timeline = await _projectService.getTimeline(widget.projectId);
      if (mounted) {
        setState(() {
          _timeline = timeline;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入時程失敗: $e')),
        );
      }
    }
  }

  Future<void> _showAddTimelineDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? selectedDate;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('新增里程碑'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: '里程碑標題',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: '描述（選填）',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                
                // 日期選擇
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(selectedDate == null 
                    ? '選擇日期' 
                    : '日期: ${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}'),
                  trailing: selectedDate != null 
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setDialogState(() => selectedDate = null),
                      )
                    : null,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
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
              onPressed: () {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('請輸入標題')),
                  );
                  return;
                }
                if (selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('請選擇日期')),
                  );
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

    if (result == true && selectedDate != null && mounted) {
      try {
        await _projectService.addTimelineItem(
          projectId: widget.projectId,
          title: titleController.text.trim(),
          description: descriptionController.text.trim().isEmpty 
            ? null 
            : descriptionController.text.trim(),
          milestoneDate: selectedDate!,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('里程碑已創建')),
          );
          _loadTimeline();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('創建失敗: $e')),
          );
        }
      }
    }
  }

  Future<void> _toggleCompletion(ProjectTimeline item) async {
    try {
      await _projectService.toggleTimelineCompletion(item.id, !item.isCompleted);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(item.isCompleted ? '已標記為未完成' : '已標記為完成'),
          ),
        );
        _loadTimeline();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失敗: $e')),
        );
      }
    }
  }

  Future<void> _deleteTimelineItem(ProjectTimeline item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: Text('確定要刪除里程碑「${item.title}」嗎？'),
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
        await _projectService.deleteTimelineItem(item.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('里程碑已刪除')),
          );
          _loadTimeline();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('刪除失敗: $e')),
          );
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  int _getDaysDifference(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(DateTime(now.year, now.month, now.day)).inDays;
    return difference;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 按日期排序
    _timeline.sort((a, b) => a.milestoneDate.compareTo(b.milestoneDate));

    return Column(
      children: [
        // 工具欄
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '共 ${_timeline.length} 個里程碑',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              FilledButton.icon(
                onPressed: _showAddTimelineDialog,
                icon: const Icon(Icons.add),
                label: const Text('新增里程碑'),
              ),
            ],
          ),
        ),

        // 時間軸列表
        Expanded(
          child: _timeline.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timeline, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      '尚未設置里程碑',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _showAddTimelineDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('創建第一個里程碑'),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _timeline.length,
                itemBuilder: (context, index) {
                  final item = _timeline[index];
                  final daysDiff = _getDaysDifference(item.milestoneDate);
                  final isPast = daysDiff < 0;
                  final isToday = daysDiff == 0;
                  
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 時間軸線
                        Column(
                          children: [
                            if (index > 0)
                              Container(
                                width: 2,
                                height: 20,
                                color: Colors.grey.shade300,
                              ),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: item.isCompleted 
                                  ? Colors.green 
                                  : (isPast ? Colors.red : Colors.blue),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: item.isCompleted
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                            ),
                            if (index < _timeline.length - 1)
                              Expanded(
                                child: Container(
                                  width: 2,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        
                        // 內容卡片
                        Expanded(
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 20),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        decoration: item.isCompleted 
                                          ? TextDecoration.lineThrough 
                                          : null,
                                      ),
                                    ),
                                  ),
                                  if (isToday)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.orange),
                                      ),
                                      child: const Text(
                                        '今天',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (item.description != null) ...[
                                    const SizedBox(height: 4),
                                    Text(item.description!),
                                  ],
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 14,
                                        color: isPast && !item.isCompleted 
                                          ? Colors.red 
                                          : Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDate(item.milestoneDate),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isPast && !item.isCompleted 
                                            ? Colors.red 
                                            : Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (!item.isCompleted)
                                        Text(
                                          daysDiff == 0 
                                            ? '今天' 
                                            : daysDiff > 0 
                                              ? '還有 $daysDiff 天'
                                              : '逾期 ${-daysDiff} 天',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isPast ? Colors.red : Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'toggle') {
                                    _toggleCompletion(item);
                                  } else if (value == 'delete') {
                                    _deleteTimelineItem(item);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'toggle',
                                    child: Row(
                                      children: [
                                        Icon(
                                          item.isCompleted 
                                            ? Icons.radio_button_unchecked 
                                            : Icons.check_circle,
                                          color: item.isCompleted ? Colors.grey : Colors.green,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(item.isCompleted ? '標記為未完成' : '標記為完成'),
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
                                        Text('刪除', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }
}
