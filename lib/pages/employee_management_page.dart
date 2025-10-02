import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/employee.dart';
import '../services/employee_service.dart';
import '../widgets/general_page.dart';
import '../widgets/widgets.dart';
import 'employee_detail_page.dart';
import 'employee_form_page.dart';

class EmployeeManagementPage extends StatefulWidget {
  const EmployeeManagementPage({
    super.key,
    required this.title,
    required this.onThemeToggle,
    required this.currentThemeMode,
  });

  final String title;
  final VoidCallback onThemeToggle;
  final ThemeMode currentThemeMode;

  @override
  State<EmployeeManagementPage> createState() => _EmployeeManagementPageState();
}

class _EmployeeManagementPageState extends State<EmployeeManagementPage> {
  final supabase = Supabase.instance.client;
  late final EmployeeService _employeeService;
  
  List<Employee> employees = [];
  List<String> departments = [];
  bool _isLoading = true;
  String? _selectedDepartment;
  EmployeeStatus? _selectedStatus;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _employeeService = EmployeeService(supabase);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadEmployees(),
      _loadDepartments(),
    ]);
  }

  Future<void> _loadEmployees() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final employeeList = await _employeeService.getAllEmployees(
        department: _selectedDepartment,
        status: _selectedStatus,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      setState(() {
        employees = employeeList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入員工資料失敗：$e')),
        );
      }
    }
  }

  Future<void> _loadDepartments() async {
    try {
      final departmentList = await _employeeService.getDepartments();
      setState(() {
        departments = departmentList;
      });
    } catch (e) {
      print('載入部門列表失敗：$e');
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadEmployees();
  }

  void _onFilterChanged() {
    _loadEmployees();
  }

  void _navigateToEmployeeForm([Employee? employee]) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EmployeeFormPage(
          employee: employee,
          onThemeToggle: widget.onThemeToggle,
          currentThemeMode: widget.currentThemeMode,
        ),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  void _navigateToEmployeeDetail(Employee employee) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EmployeeDetailPage(
          employee: employee,
          onThemeToggle: widget.onThemeToggle,
          currentThemeMode: widget.currentThemeMode,
        ),
      ),
    );
  }

  Future<void> _deleteEmployee(Employee employee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('刪除員工'),
        content: Text('確定要將員工 ${employee.name} 設為離職狀態嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('確定'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _employeeService.deleteEmployee(employee.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('員工 ${employee.name} 已設為離職狀態')),
          );
        }
        _loadEmployees();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('刪除失敗：$e')),
          );
        }
      }
    }
  }

  IconData _getThemeIcon() {
    switch (widget.currentThemeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.auto_awesome;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return GeneralPage(
        actions: [
          IconButton(
            icon: Icon(_getThemeIcon()),
            onPressed: widget.onThemeToggle,
            tooltip: '切換主題',
          ),
          const LogoutButton(),
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
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _navigateToEmployeeForm(),
          tooltip: '新增員工',
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadData,
          tooltip: '重新整理',
        ),
        IconButton(
          icon: Icon(_getThemeIcon()),
          onPressed: widget.onThemeToggle,
          tooltip: '切換主題',
        ),
        const LogoutButton(),
      ],
      children: [
        // 搜尋和篩選區域
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 搜尋欄
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: '搜尋員工',
                    hintText: '輸入姓名或員工編號',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 16),
                // 篩選器
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedDepartment,
                        decoration: const InputDecoration(
                          labelText: '部門',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('全部部門'),
                          ),
                          ...departments.map((dept) => DropdownMenuItem<String>(
                            value: dept,
                            child: Text(dept),
                          )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedDepartment = value;
                          });
                          _onFilterChanged();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<EmployeeStatus>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: '狀態',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<EmployeeStatus>(
                            value: null,
                            child: Text('全部狀態'),
                          ),
                          ...EmployeeStatus.values.map((status) => 
                            DropdownMenuItem<EmployeeStatus>(
                              value: status,
                              child: Text(status.displayName),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                          _onFilterChanged();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 員工列表
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: employees.isEmpty
              ? const Center(
                  child: Text(
                    '沒有找到員工資料',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: employee.avatarUrl != null
                              ? NetworkImage(employee.avatarUrl!)
                              : null,
                          child: employee.avatarUrl == null
                              ? Text(employee.name.substring(0, 1))
                              : null,
                        ),
                        title: Text(
                          '${employee.name} (${employee.employeeId})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${employee.department} - ${employee.position}'),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(employee.status),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    employee.status.displayName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '入職：${employee.hireDate.year}/${employee.hireDate.month}/${employee.hireDate.day}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (action) {
                            switch (action) {
                              case 'view':
                                _navigateToEmployeeDetail(employee);
                                break;
                              case 'edit':
                                _navigateToEmployeeForm(employee);
                                break;
                              case 'delete':
                                _deleteEmployee(employee);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(Icons.visibility),
                                  SizedBox(width: 8),
                                  Text('查看'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('編輯'),
                                ],
                              ),
                            ),
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
                        onTap: () => _navigateToEmployeeDetail(employee),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Color _getStatusColor(EmployeeStatus status) {
    switch (status) {
      case EmployeeStatus.active:
        return Colors.green;
      case EmployeeStatus.inactive:
        return Colors.orange;
      case EmployeeStatus.resigned:
        return Colors.red;
      case EmployeeStatus.terminated:
        return Colors.red.shade800;
    }
  }
}