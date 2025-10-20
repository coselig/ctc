import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/models.dart';
import '../../../services/project_service.dart';

/// 專案客戶管理標籤頁
class ProjectClientsTab extends StatefulWidget {
  final String projectId;

  const ProjectClientsTab({super.key, required this.projectId});

  @override
  State<ProjectClientsTab> createState() => _ProjectClientsTabState();
}

class _ProjectClientsTabState extends State<ProjectClientsTab> {
  final _projectService = ProjectService(Supabase.instance.client);
  List<ProjectClient> _clients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    setState(() => _isLoading = true);
    try {
      final clients = await _projectService.getClients(widget.projectId);
      if (mounted) {
        setState(() {
          _clients = clients;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入客戶失敗: $e')),
        );
      }
    }
  }

  Future<void> _showAddClientDialog({ProjectClient? editClient}) async {
    final nameController = TextEditingController(text: editClient?.name);
    final companyController = TextEditingController(text: editClient?.company);
    final emailController = TextEditingController(text: editClient?.email);
    final phoneController = TextEditingController(text: editClient?.phone);
    final notesController = TextEditingController(text: editClient?.notes);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(editClient == null ? '新增客戶' : '編輯客戶'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '姓名 *',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: companyController,
                decoration: const InputDecoration(
                  labelText: '公司名稱',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: '電子郵件',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: '電話',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: '備註',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
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
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('請輸入客戶姓名')),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            child: Text(editClient == null ? '創建' : '保存'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      try {
        if (editClient == null) {
          // 新增客戶
          await _projectService.addClient(
            projectId: widget.projectId,
            name: nameController.text.trim(),
            company: companyController.text.trim().isEmpty 
              ? null 
              : companyController.text.trim(),
            email: emailController.text.trim().isEmpty 
              ? null 
              : emailController.text.trim(),
            phone: phoneController.text.trim().isEmpty 
              ? null 
              : phoneController.text.trim(),
            notes: notesController.text.trim().isEmpty 
              ? null 
              : notesController.text.trim(),
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('客戶已創建')),
            );
          }
        } else {
          // 編輯客戶
          await _projectService.updateClient(editClient.id, {
            'name': nameController.text.trim(),
            'company': companyController.text.trim().isEmpty 
              ? null 
              : companyController.text.trim(),
            'email': emailController.text.trim().isEmpty 
              ? null 
              : emailController.text.trim(),
            'phone': phoneController.text.trim().isEmpty 
              ? null 
              : phoneController.text.trim(),
            'notes': notesController.text.trim().isEmpty 
              ? null 
              : notesController.text.trim(),
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('客戶已更新')),
            );
          }
        }
        
        _loadClients();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('操作失敗: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteClient(ProjectClient client) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: Text('確定要刪除客戶「${client.name}」嗎？'),
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
        await _projectService.deleteClient(client.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('客戶已刪除')),
          );
          _loadClients();
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
                '共 ${_clients.length} 位客戶',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              FilledButton.icon(
                onPressed: () => _showAddClientDialog(),
                icon: const Icon(Icons.person_add),
                label: const Text('新增客戶'),
              ),
            ],
          ),
        ),

        // 客戶列表
        Expanded(
          child: _clients.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.business, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      '尚未添加客戶',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _showAddClientDialog(),
                      icon: const Icon(Icons.person_add),
                      label: const Text('添加第一位客戶'),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _clients.length,
                itemBuilder: (context, index) {
                  final client = _clients[index];
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          client.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        client.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (client.company != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.business, size: 14),
                                const SizedBox(width: 4),
                                Text(client.company!),
                              ],
                            ),
                          ],
                          if (client.email != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.email, size: 14),
                                const SizedBox(width: 4),
                                Expanded(child: Text(client.email!)),
                              ],
                            ),
                          ],
                          if (client.phone != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.phone, size: 14),
                                const SizedBox(width: 4),
                                Text(client.phone!),
                              ],
                            ),
                          ],
                          if (client.notes != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              client.notes!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showAddClientDialog(editClient: client);
                          } else if (value == 'delete') {
                            _deleteClient(client);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('編輯'),
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
                  );
                },
              ),
        ),
      ],
    );
  }
}
