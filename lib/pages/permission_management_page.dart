import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/permission_service.dart';

/// 權限管理頁面
class PermissionManagementPage extends StatefulWidget {
  final String floorPlanUrl;
  final String floorPlanName;
  final PermissionService permissionService;

  const PermissionManagementPage({
    super.key,
    required this.floorPlanUrl,
    required this.floorPlanName,
    required this.permissionService,
  });

  @override
  State<PermissionManagementPage> createState() =>
      _PermissionManagementPageState();
}

class _PermissionManagementPageState extends State<PermissionManagementPage> {
  List<FloorPlanPermission> permissions = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final loadedPermissions = await widget.permissionService
          .getFloorPlanPermissions(widget.floorPlanUrl);

      setState(() {
        permissions = loadedPermissions;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _showAddUserDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) =>
          AddUserPermissionDialog(permissionService: widget.permissionService),
    );

    if (result != null) {
      try {
        await widget.permissionService.addUserPermission(
          floorPlanUrl: widget.floorPlanUrl,
          floorPlanName: widget.floorPlanName,
          userEmail: result['email'],
          permissionLevel: result['permissionLevel'],
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('成功添加用戶權限')));

        _loadPermissions();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('添加用戶權限失敗: $e')));
      }
    }
  }

  Future<void> _updatePermission(
    FloorPlanPermission permission,
    PermissionLevel newLevel,
  ) async {
    try {
      await widget.permissionService.updateUserPermission(
        floorPlanUrl: widget.floorPlanUrl,
        userId: permission.userId,
        permissionLevel: newLevel,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('權限更新成功')));

      _loadPermissions();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('權限更新失敗: $e')));
    }
  }

  Future<void> _removePermission(FloorPlanPermission permission) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認移除'),
        content: Text('確定要移除 ${permission.userEmail} 的權限嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('移除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.permissionService.removeUserPermission(
          floorPlanUrl: widget.floorPlanUrl,
          userId: permission.userId,
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('權限移除成功')));

        _loadPermissions();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('權限移除失敗: $e')));
      }
    }
  }

  Future<void> _transferOwnership(FloorPlanPermission permission) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認轉移管理權'),
        content: Text(
          '確定要將管理權轉移給 ${permission.userEmail} 嗎？\n\n'
          '轉移後，您將失去此設計圖的管理權。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('轉移'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.permissionService.transferOwnership(
          floorPlanUrl: widget.floorPlanUrl,
          newOwnerUserId: permission.userId,
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('管理權轉移成功')));

        Navigator.of(context).pop(); // 返回上一頁，因為當前用戶不再是擁有者
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('管理權轉移失敗: $e')));
      }
    }
  }

  Widget _buildPermissionCard(FloorPlanPermission permission) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: permission.isOwner
              ? Colors.amber
              : Theme.of(context).primaryColor.withValues(alpha: 0.1),
          child: Text(
            permission.isOwner ? '👑' : permission.permissionLevel.icon,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          permission.userEmail,
          style: TextStyle(
            fontWeight: permission.isOwner
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          permission.isOwner ? '擁有者' : permission.permissionLevel.displayName,
        ),
        trailing: permission.isOwner
            ? null
            : PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'level1':
                      _updatePermission(permission, PermissionLevel.level1);
                      break;
                    case 'level2':
                      _updatePermission(permission, PermissionLevel.level2);
                      break;
                    case 'level3':
                      _updatePermission(permission, PermissionLevel.level3);
                      break;
                    case 'transfer':
                      _transferOwnership(permission);
                      break;
                    case 'remove':
                      _removePermission(permission);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'level1',
                    child: Text('👤 設為一般用戶'),
                  ),
                  const PopupMenuItem(value: 'level2', child: Text('⭐ 設為進階用戶')),
                  const PopupMenuItem(value: 'level3', child: Text('👑 設為管理員')),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'transfer',
                    child: Text('🔄 轉移管理權'),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(value: 'remove', child: Text('🗑️ 移除權限')),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('權限管理'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 設計圖信息
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.floorPlanName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '設計圖權限管理',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),

          // 權限列表
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '載入失敗',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(errorMessage!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadPermissions,
                          child: const Text('重試'),
                        ),
                      ],
                    ),
                  )
                : permissions.isEmpty
                ? const Center(child: Text('沒有權限記錄'))
                : RefreshIndicator(
                    onRefresh: _loadPermissions,
                    child: ListView.builder(
                      itemCount: permissions.length,
                      itemBuilder: (context, index) {
                        return _buildPermissionCard(permissions[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        child: const Icon(Icons.person_add),
      ),
    );
  }
}

/// 添加用戶權限對話框
class AddUserPermissionDialog extends StatefulWidget {
  final PermissionService permissionService;

  const AddUserPermissionDialog({super.key, required this.permissionService});

  @override
  State<AddUserPermissionDialog> createState() =>
      _AddUserPermissionDialogState();
}

class _AddUserPermissionDialogState extends State<AddUserPermissionDialog> {
  final _filterController = TextEditingController();
  PermissionLevel _selectedLevel = PermissionLevel.level1;
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  Map<String, dynamic>? _selectedUser;
  bool _isLoadingUsers = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _filterController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      print('開始載入使用者清單...');
      final users = await widget.permissionService.getAllUsers();
      print('載入完成，獲得 ${users.length} 個使用者');
      print('使用者清單: $users');

      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        _isLoadingUsers = false;
      });

      print(
        '狀態更新完成 - _allUsers: ${_allUsers.length}, _filteredUsers: ${_filteredUsers.length}',
      );
    } catch (e) {
      print('載入使用者失敗: $e');
      setState(() {
        _isLoadingUsers = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('載入使用者列表失敗: $e')));
    }
  }

  void _filterUsers() {
    final query = _filterController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        final email = (user['email'] as String).toLowerCase();
        return email.contains(query);
      }).toList();
    });
  }

  void _selectUser(Map<String, dynamic> user) {
    setState(() {
      _selectedUser = user;
      _filterController.text = user['email'];
      _filteredUsers = []; // 隱藏列表
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedUser = null;
      _filterController.clear();
      _filteredUsers = _allUsers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加用戶權限'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 使用者搜尋輸入框
            TextField(
              controller: _filterController,
              decoration: InputDecoration(
                labelText: '搜尋使用者',
                hintText: '輸入電子郵件篩選',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _selectedUser != null
                    ? IconButton(
                        onPressed: _clearSelection,
                        icon: const Icon(Icons.clear),
                      )
                    : null,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // 使用者清單
            if (_isLoadingUsers)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_filteredUsers.isNotEmpty && _selectedUser == null)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _filteredUsers.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.1),
                          child: Text(
                            (user['email'] as String).isNotEmpty
                                ? (user['email'] as String)[0].toUpperCase()
                                : '?',
                          ),
                        ),
                        title: Text(user['email'] as String),
                        subtitle: Text(
                          '註冊時間: ${DateTime.parse(user['created_at']).toLocal().toString().split('.')[0]}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        onTap: () => _selectUser(user),
                      );
                    },
                  ),
                ),
              )
            else if (!_isLoadingUsers &&
                _filteredUsers.isEmpty &&
                _selectedUser == null)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '沒有找到使用者',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '調試資訊:\n'
                        '載入中: $_isLoadingUsers\n'
                        '所有使用者: ${_allUsers.length}\n'
                        '篩選使用者: ${_filteredUsers.length}\n'
                        '已選使用者: ${_selectedUser != null}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else if (_selectedUser != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.2),
                      child: Text(
                        (_selectedUser!['email'] as String)[0].toUpperCase(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedUser!['email'] as String,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '已選擇此使用者',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _clearSelection,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // 權限等級選擇
            DropdownButtonFormField<PermissionLevel>(
              initialValue: _selectedLevel,
              decoration: const InputDecoration(labelText: '權限等級'),
              items: PermissionLevel.values.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Row(
                    children: [
                      Text(level.icon),
                      const SizedBox(width: 8),
                      Text(level.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (level) {
                if (level != null) {
                  setState(() {
                    _selectedLevel = level;
                  });
                }
              },
            ),
            const SizedBox(height: 8),
            Text(
              _selectedLevel.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _selectedUser != null
              ? () {
                  Navigator.of(context).pop({
                    'email': _selectedUser!['email'],
                    'permissionLevel': _selectedLevel,
                  });
                }
              : null,
          child: const Text('添加'),
        ),
      ],
    );
  }
}
