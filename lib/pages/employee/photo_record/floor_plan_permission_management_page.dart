import 'package:ctc/services/photo_record_system/floor_plan_permission_service.dart';
import 'package:ctc/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FloorPlanPermissionManagementPage extends StatefulWidget {
  final String floorPlanId;
  final String floorPlanName;

  const FloorPlanPermissionManagementPage({
    super.key,
    required this.floorPlanId,
    required this.floorPlanName,
  });

  @override
  State<FloorPlanPermissionManagementPage> createState() =>
      _FloorPlanPermissionManagementPageState();
}

class _FloorPlanPermissionManagementPageState
    extends State<FloorPlanPermissionManagementPage> {
  final _permissionService = FloorPlanPermissionService(
    Supabase.instance.client,
  );
  List<FloorPlanPermission> _permissions = [];
  bool _isLoading = true;
  bool _isOwner = false;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    try {
      setState(() => _isLoading = true);

      final isOwner = await _permissionService.isOwner(widget.floorPlanId);
      final permissions = await _permissionService.getPermissions(
        widget.floorPlanId,
      );

      setState(() {
        _isOwner = isOwner;
        _permissions = permissions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('載入權限列表失敗: $e')));
      }
    }
  }

  Future<void> _showAddMemberDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _UserSearchDialog(
        floorPlanId: widget.floorPlanId,
        permissionService: _permissionService,
        existingUserIds: _permissions.map((p) => p.userId).toSet(),
      ),
    );

    if (result == true) {
      _loadPermissions();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('成員已添加')));
      }
    }
  }

  Future<void> _updatePermission(
    FloorPlanPermission permission,
    PermissionLevel newLevel,
  ) async {
    try {
      await _permissionService.updatePermission(
        permissionId: permission.id,
        newLevel: newLevel,
      );

      _loadPermissions();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('權限已更新')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('更新失敗: $e')));
      }
    }
  }

  Future<void> _removePermission(FloorPlanPermission permission) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('移除成員'),
        content: Text(
          '確定要移除 ${permission.userEmail ?? permission.userId} 的權限嗎？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('移除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _permissionService.removePermission(permission.id);

      _loadPermissions();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('成員已移除')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('移除失敗: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GeneralPage(
      title: '權限管理',
      actions: [
        if (_isOwner)
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddMemberDialog,
            tooltip: '添加成員',
          ),
      ],
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 設計圖資訊
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.architecture, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.floorPlanName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isOwner ? '您是此設計圖的擁有者' : '共享設計圖',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 成員列表標題
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '成員列表',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_permissions.length} 位成員',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 成員列表
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_permissions.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.group_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '尚未添加成員',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (_isOwner) ...[
                          const SizedBox(height: 8),
                          FilledButton.icon(
                            onPressed: _showAddMemberDialog,
                            icon: const Icon(Icons.person_add),
                            label: const Text('添加第一位成員'),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _permissions.length,
                  itemBuilder: (context, index) {
                    final permission = _permissions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            (permission.userEmail ?? permission.userId)
                                .substring(0, 1)
                                .toUpperCase(),
                          ),
                        ),
                        title: Text(
                          permission.userFullName ??
                              permission.userEmail ??
                              permission.userId,
                        ),
                        subtitle: Text(
                          permission.userEmail ?? permission.userId,
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: _isOwner
                            ? PopupMenuButton<String>(
                                icon: Chip(
                                  label: Text(
                                    permission.permissionLevel.label,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  avatar: const Icon(
                                    Icons.arrow_drop_down,
                                    size: 16,
                                  ),
                                ),
                                onSelected: (value) {
                                  if (value == 'remove') {
                                    _removePermission(permission);
                                  } else {
                                    final newLevel = PermissionLevel.values
                                        .firstWhere((e) => e.label == value);
                                    _updatePermission(permission, newLevel);
                                  }
                                },
                                itemBuilder: (context) => [
                                  ...PermissionLevel.values.map((level) {
                                    return PopupMenuItem(
                                      value: level.label,
                                      child: Row(
                                        children: [
                                          if (permission.permissionLevel ==
                                              level)
                                            const Icon(Icons.check, size: 16),
                                          if (permission.permissionLevel !=
                                              level)
                                            const SizedBox(width: 16),
                                          const SizedBox(width: 8),
                                          Text(level.label),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  const PopupMenuDivider(),
                                  const PopupMenuItem(
                                    value: 'remove',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          size: 16,
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
                              )
                            : Chip(
                                label: Text(
                                  permission.permissionLevel.label,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 用戶搜尋與快速添加對話框
class _UserSearchDialog extends StatefulWidget {
  final String floorPlanId;
  final FloorPlanPermissionService permissionService;
  final Set<String> existingUserIds;

  const _UserSearchDialog({
    required this.floorPlanId,
    required this.permissionService,
    required this.existingUserIds,
  });

  @override
  State<_UserSearchDialog> createState() => _UserSearchDialogState();
}

class _UserSearchDialogState extends State<_UserSearchDialog> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _allUsers = []; // 所有用戶
  List<Map<String, dynamic>> _filteredUsers = []; // 篩選後的用戶
  bool _isLoading = false;
  String? _selectedUserId;
  PermissionLevel _selectedLevel = PermissionLevel.viewer;

  @override
  void initState() {
    super.initState();
    _loadAllUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 載入所有註冊用戶
  Future<void> _loadAllUsers() async {
    setState(() => _isLoading = true);

    try {
      // 使用空字串或 % 搜尋所有用戶
      final users = await widget.permissionService.searchUsersByEmail('%');

      // 過濾掉已經在權限列表中的用戶
      final availableUsers = users.where((user) {
        final userId = user['id'] as String;
        return !widget.existingUserIds.contains(userId);
      }).toList();

      setState(() {
        _allUsers = availableUsers;
        _filteredUsers = availableUsers; // 初始顯示所有用戶
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _allUsers = [];
        _filteredUsers = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('載入用戶列表失敗: $e')));
      }
    }
  }

  /// 篩選用戶（本地篩選）
  void _filterUsers(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        // 沒有輸入時顯示所有用戶
        _filteredUsers = _allUsers;
      } else {
        // 篩選包含查詢文字的用戶
        final lowerQuery = query.toLowerCase();
        _filteredUsers = _allUsers.where((user) {
          final email = (user['email'] as String? ?? '').toLowerCase();
          final fullName = (user['full_name'] as String? ?? '').toLowerCase();
          return email.contains(lowerQuery) || fullName.contains(lowerQuery);
        }).toList();
      }
    });
  }

  String _getPermissionDescription(PermissionLevel level) {
    switch (level) {
      case PermissionLevel.viewer:
        return '只能查看設計圖和照片記錄';
      case PermissionLevel.editor:
        return '可以查看和新增照片記錄';
      case PermissionLevel.admin:
        return '完整權限，包含管理成員';
    }
  }

  Widget _getPermissionIcon(
    PermissionLevel level,
    bool isSelected,
    ColorScheme colorScheme,
  ) {
    final color = isSelected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    switch (level) {
      case PermissionLevel.viewer:
        return Icon(Icons.visibility, size: 20, color: color);
      case PermissionLevel.editor:
        return Icon(Icons.edit, size: 20, color: color);
      case PermissionLevel.admin:
        return Icon(Icons.admin_panel_settings, size: 20, color: color);
    }
  }

  Future<void> _addMember() async {
    if (_selectedUserId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('請先選擇一位用戶')));
      return;
    }

    try {
      await widget.permissionService.addPermission(
        floorPlanId: widget.floorPlanId,
        targetUserId: _selectedUserId!,
        permissionLevel: _selectedLevel,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('添加失敗: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 標題欄
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(25),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person_add,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '添加成員',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
            ),

            // 搜尋欄
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: '篩選用戶',
                  hintText: '輸入姓名或 Email 篩選...',
                  prefixIcon: const Icon(Icons.filter_list),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterUsers('');
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _filterUsers(value);
                },
              ),
            ),

            // 用戶列表
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredUsers.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _searchController.text.isEmpty
                                  ? Icons.group_off
                                  : Icons.person_off,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? '沒有可添加的用戶'
                                  : '找不到匹配的用戶',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            if (_searchController.text.isEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                '所有用戶都已在權限列表中',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        // 用戶數量提示
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.people,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '共 ${_filteredUsers.length} 位可添加的用戶',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 用戶列表
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = _filteredUsers[index];
                              final userId = user['id'] as String;
                              final email = user['email'] as String;
                              final fullName = user['full_name'] as String?;
                              final isSelected = userId == _selectedUserId;

                              return Card(
                                elevation: isSelected ? 4 : 1,
                                color: isSelected
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.primary.withAlpha(25)
                                    : null,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                          )
                                        : Text(
                                            email.substring(0, 1).toUpperCase(),
                                          ),
                                  ),
                                  title: Text(
                                    fullName ?? email,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  subtitle: Text(email),
                                  trailing: isSelected
                                      ? Icon(
                                          Icons.check_circle,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        )
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      _selectedUserId = userId;
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),

            // 權限選擇
            if (_selectedUserId != null) ...[
              const Divider(height: 1),
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '選擇權限等級',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: PermissionLevel.values.map((level) {
                        final isSelected = level == _selectedLevel;
                        final colorScheme = Theme.of(context).colorScheme;

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedLevel = level;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colorScheme.primary.withAlpha(38)
                                      : colorScheme.surfaceContainerHighest
                                            .withAlpha(125),
                                  border: Border.all(
                                    color: isSelected
                                        ? colorScheme.primary
                                        : colorScheme.outline.withAlpha(125),
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    _getPermissionIcon(
                                      level,
                                      isSelected,
                                      colorScheme,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      level.label,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? colorScheme.primary
                                            : colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getPermissionDescription(_selectedLevel),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 底部按鈕
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _selectedUserId != null ? _addMember : null,
                    icon: const Icon(Icons.person_add),
                    label: const Text('添加成員'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
