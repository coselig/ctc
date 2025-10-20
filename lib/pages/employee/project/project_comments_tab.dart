import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/models.dart';
import '../../../services/project_service.dart';

/// 專案留言板標籤頁
class ProjectCommentsTab extends StatefulWidget {
  final String projectId;

  const ProjectCommentsTab({super.key, required this.projectId});

  @override
  State<ProjectCommentsTab> createState() => _ProjectCommentsTabState();
}

class _ProjectCommentsTabState extends State<ProjectCommentsTab> {
  final _projectService = ProjectService(Supabase.instance.client);
  final _commentController = TextEditingController();
  List<ProjectComment> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoading = true);
    try {
      final comments = await _projectService.getComments(widget.projectId);
      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入留言失敗: $e')),
        );
      }
    }
  }

  Future<void> _sendComment({String? parentId}) async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSending = true);
    try {
      await _projectService.addComment(
        projectId: widget.projectId,
        content: content,
        parentId: parentId,
      );
      
      _commentController.clear();
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('留言已發表')),
        );
        _loadComments();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('發表失敗: $e')),
        );
      }
    }
  }

  Future<void> _showReplyDialog(ProjectComment parentComment) async {
    final replyController = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('回覆 ${parentComment.userFullName ?? parentComment.userEmail}'),
        content: TextField(
          controller: replyController,
          decoration: const InputDecoration(
            hintText: '輸入回覆內容...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, replyController.text.trim()),
            child: const Text('回覆'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      try {
        await _projectService.addComment(
          projectId: widget.projectId,
          content: result,
          parentId: parentComment.id,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('回覆已發表')),
          );
          _loadComments();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('回覆失敗: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteComment(ProjectComment comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: const Text('確定要刪除這則留言嗎？'),
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
        await _projectService.deleteComment(comment.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('留言已刪除')),
          );
          _loadComments();
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

  Widget _buildCommentCard(ProjectComment comment, {bool isReply = false}) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isOwnComment = comment.userId == currentUserId;
    
    // 獲取這則留言的回覆
    final replies = _comments.where((c) => c.parentId == comment.id).toList();

    return Card(
      margin: EdgeInsets.only(
        left: isReply ? 40 : 16,
        right: 16,
        bottom: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用戶資訊
            Row(
              children: [
                CircleAvatar(
                  radius: isReply ? 16 : 20,
                  child: Text(
                    (comment.userFullName ?? comment.userEmail ?? 'U')
                        .substring(0, 1)
                        .toUpperCase(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.userFullName ?? comment.userEmail ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatDateTime(comment.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isOwnComment)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteComment(comment);
                      }
                    },
                    itemBuilder: (context) => [
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
              ],
            ),
            const SizedBox(height: 12),
            
            // 留言內容
            Text(comment.content),
            
            const SizedBox(height: 8),
            
            // 回覆按鈕
            if (!isReply)
              TextButton.icon(
                onPressed: () => _showReplyDialog(comment),
                icon: const Icon(Icons.reply, size: 16),
                label: Text(
                  replies.isEmpty ? '回覆' : '回覆 (${replies.length})',
                  style: const TextStyle(fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            
            // 顯示回覆
            if (replies.isNotEmpty) ...[
              const Divider(),
              ...replies.map((reply) => _buildCommentCard(reply, isReply: true)),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '剛剛';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} 分鐘前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} 小時前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} 天前';
    } else {
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 只顯示頂層留言（沒有 parent_id 的）
    final topLevelComments = _comments.where((c) => c.parentId == null).toList();

    return Column(
      children: [
        // 留言列表
        Expanded(
          child: topLevelComments.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      '尚無留言',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '成為第一個留言的人！',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: topLevelComments.length,
                itemBuilder: (context, index) {
                  return _buildCommentCard(topLevelComments[index]);
                },
              ),
        ),

        // 輸入框
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: '輸入留言...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  enabled: !_isSending,
                  onSubmitted: (_) => _sendComment(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _isSending ? null : _sendComment,
                icon: _isSending 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
