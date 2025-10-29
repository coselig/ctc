import 'package:ctc/widgets/general_components/auth_action_button.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/employee_service.dart';
import '../../services/registered_user_service.dart';
import '../../widgets/widgets.dart';

class UserSelectionPage extends StatefulWidget {
  const UserSelectionPage({
    super.key,
    required this.onThemeToggle,
    required this.currentThemeMode,
  });

  final VoidCallback onThemeToggle;
  final ThemeMode currentThemeMode;

  @override
  State<UserSelectionPage> createState() => _UserSelectionPageState();
}

class _UserSelectionPageState extends State<UserSelectionPage> {
  final supabase = Supabase.instance.client;
  late final RegisteredUserService _userService;

  List<RegisteredUser> _users = [];
  List<RegisteredUser> _filteredUsers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userService = RegisteredUserService(supabase);
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    try {
      final users = await _userService.getAvailableUsers();
      setState(() {
        _users = users;
        _filteredUsers = users;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入用戶失敗：$e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredUsers = _users;
      } else {
        _filteredUsers = _users.where((user) {
          final email = user.email?.toLowerCase() ?? '';
          final name = user.displayName?.toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          return email.contains(searchLower) || name.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> _selectUser(RegisteredUser user) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => CreateEmployeeFromUserPage(
          user: user,
          onThemeToggle: widget.onThemeToggle,
          currentThemeMode: widget.currentThemeMode,
        ),
      ),
    );

    if (result == true) {
      // 員工創建成功，重新載入用戶列表
      _loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return GeneralPage(
        actions: [
          ThemeToggleButton(currentThemeMode: widget.currentThemeMode, onToggle: widget.onThemeToggle),
          const AuthActionButton(),
        ],
        children: const [
          SizedBox(
            height: 400,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }

    return GeneralPage(
      actions: [
        ThemeToggleButton(currentThemeMode: widget.currentThemeMode, onToggle: widget.onThemeToggle),
        const AuthActionButton(),
      ],
      children: [
        // 標題和說明
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person_add,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '從已註冊用戶中新增員工',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '從下方列表中選擇已註冊的用戶來創建員工記錄。\n'
                  '只顯示尚未成為員工的用戶帳號。',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(200),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 搜尋框
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: '搜尋用戶',
                hintText: '輸入郵箱或姓名搜尋...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterUsers('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: _filterUsers,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 用戶列表
        if (_filteredUsers.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      _searchQuery.isNotEmpty ? Icons.search_off : Icons.people_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isNotEmpty 
                          ? '沒有找到符合搜尋條件的用戶'
                          : '沒有可用的已註冊用戶',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _searchQuery.isNotEmpty
                          ? '請嘗試其他搜尋關鍵字'
                          : '請等待用戶註冊後再來新增員工',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredUsers.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl == null
                        ? Text(
                            user.displayName?.substring(0, 1).toUpperCase() ??
                            user.email?.substring(0, 1).toUpperCase() ??
                            '?',
                          )
                        : null,
                  ),
                  title: Text(
                    user.displayName ?? '未設置姓名',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.email ?? '無郵箱'),
                      const SizedBox(height: 4),
                      Text(
                        '註冊時間：${user.createdAt.year}/${user.createdAt.month}/${user.createdAt.day}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                        ),
                      ),
                    ],
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () => _selectUser(user),
                );
              },
            ),
          ),

        const SizedBox(height: 16),

        // 統計資訊
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${_users.length}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '可用用戶',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Theme.of(context).dividerColor,
                ),
                Column(
                  children: [
                    Text(
                      '${_filteredUsers.length}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '搜尋結果',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 從用戶創建員工記錄的頁面
class CreateEmployeeFromUserPage extends StatefulWidget {
  const CreateEmployeeFromUserPage({
    super.key,
    required this.user,
    required this.onThemeToggle,
    required this.currentThemeMode,
  });

  final RegisteredUser user;
  final VoidCallback onThemeToggle;
  final ThemeMode currentThemeMode;

  @override
  State<CreateEmployeeFromUserPage> createState() => _CreateEmployeeFromUserPageState();
}

class _CreateEmployeeFromUserPageState extends State<CreateEmployeeFromUserPage> {
  final supabase = Supabase.instance.client;
  late final RegisteredUserService _userService;
  late final EmployeeService _employeeService;

  final _formKey = GlobalKey<FormState>();
  final _employeeIdController = TextEditingController();
  final _departmentController = TextEditingController();
  final _positionController = TextEditingController();
  final _salaryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _hireDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _userService = RegisteredUserService(supabase);
    _employeeService = EmployeeService(supabase);
    _generateEmployeeId();
  }

  @override
  void dispose() {
    _employeeIdController.dispose();
    _departmentController.dispose();
    _positionController.dispose();
    _salaryController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _generateEmployeeId() async {
    try {
      final employeeId = await _employeeService.generateEmployeeId();
      _employeeIdController.text = employeeId;
    } catch (e) {
      print('生成員工編號失敗：$e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _hireDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _hireDate) {
      setState(() {
        _hireDate = picked;
      });
    }
  }

  Future<void> _createEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _userService.createEmployeeFromUser(
        user: widget.user,
        employeeId: _employeeIdController.text.trim(),
        department: _departmentController.text.trim(),
        position: _positionController.text.trim(),
        hireDate: _hireDate,
        salary: _salaryController.text.trim().isEmpty 
            ? null 
            : double.tryParse(_salaryController.text.trim()),
        phone: _phoneController.text.trim().isEmpty 
            ? null 
            : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty 
            ? null 
            : _addressController.text.trim(),
        emergencyContactName: _emergencyNameController.text.trim().isEmpty 
            ? null 
            : _emergencyNameController.text.trim(),
        emergencyContactPhone: _emergencyPhoneController.text.trim().isEmpty 
            ? null 
            : _emergencyPhoneController.text.trim(),
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('員工 ${widget.user.displayName ?? widget.user.email} 創建成功！'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('創建員工失敗：$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GeneralPage(
      actions: [
        ThemeToggleButton(currentThemeMode: widget.currentThemeMode, onToggle: widget.onThemeToggle),
        const AuthActionButton(),
      ],
      children: [
        // 用戶資訊卡片
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: widget.user.avatarUrl != null
                          ? NetworkImage(widget.user.avatarUrl!)
                          : null,
                      child: widget.user.avatarUrl == null
                          ? Text(
                              widget.user.displayName?.substring(0, 1).toUpperCase() ??
                              widget.user.email?.substring(0, 1).toUpperCase() ??
                              '?',
                              style: const TextStyle(fontSize: 20),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '為用戶創建員工記錄',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.user.displayName ?? '未設置姓名',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Text(
                            widget.user.email ?? '無郵箱',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 員工資料表單
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '員工基本資料',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 員工編號
                  TextFormField(
                    controller: _employeeIdController,
                    decoration: const InputDecoration(
                      labelText: '員工編號 *',
                      hintText: '如：EMP001',
                      prefixIcon: Icon(Icons.badge),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '請輸入員工編號';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 部門和職位
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _departmentController,
                          decoration: const InputDecoration(
                            labelText: '部門 *',
                            hintText: '如：技術部',
                            prefixIcon: Icon(Icons.business),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '請輸入部門';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _positionController,
                          decoration: const InputDecoration(
                            labelText: '職位 *',
                            hintText: '如：軟體工程師',
                            prefixIcon: Icon(Icons.work),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '請輸入職位';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 入職日期和薪資
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: '入職日期 *',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              '${_hireDate.year}/${_hireDate.month}/${_hireDate.day}',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _salaryController,
                          decoration: const InputDecoration(
                            labelText: '薪資',
                            hintText: '如：50000',
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 聯絡資訊
                  Text(
                    '聯絡資訊',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: '聯絡電話',
                      hintText: '如：0912345678',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: '住址',
                      prefixIcon: Icon(Icons.home),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // 緊急聯絡人
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _emergencyNameController,
                          decoration: const InputDecoration(
                            labelText: '緊急聯絡人姓名',
                            prefixIcon: Icon(Icons.contact_emergency),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _emergencyPhoneController,
                          decoration: const InputDecoration(
                            labelText: '緊急聯絡人電話',
                            prefixIcon: Icon(Icons.phone_in_talk),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: '備註',
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // 按鈕
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
                          child: const Text('取消'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _createEmployee,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('創建員工'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}