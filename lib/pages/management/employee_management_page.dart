import 'package:ctc/widgets/general_components/auth_action_button.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/models.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';
import '../public/public_pages.dart'; // UserSelectionPage 在 public/
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
  List<Employee> allEmployees = []; // 儲存所有員工資料
  List<String> departments = [];
  bool _isLoading = true;
  bool _hasCheckedSingleEmployee = false; // 是否已檢查過單一員工狀態
  String? _selectedDepartment;
  EmployeeStatus? _selectedStatus;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  // 分頁相關
  int _currentPage = 1;
  final int _itemsPerPage = 25;
  int get _totalPages => (allEmployees.length / _itemsPerPage).ceil().clamp(1, double.infinity).toInt();

  @override
  void initState() {
    super.initState();
    _employeeService = EmployeeService(supabase);
    _checkAndLoadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 檢查是否只有單一員工，如果是則直接跳轉到編輯頁面
  Future<void> _checkAndLoadData() async {
    if (_hasCheckedSingleEmployee) {
      // 已經檢查過，只載入資料
      await _loadData();
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      // 先載入員工列表
      final employeeList = await _employeeService.getAllEmployees();

      // 如果只有一個員工（一般員工只能看到自己）
      if (employeeList.length == 1 && mounted) {
        _hasCheckedSingleEmployee = true;
        final employee = employeeList.first;

        // 直接跳轉到編輯頁面（個人資料）
        // 使用 pushReplacement 因為對於一般員工，列表頁面沒有意義
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => EmployeeFormPage(
              employee: employee,
              onThemeToggle: widget.onThemeToggle,
              currentThemeMode: widget.currentThemeMode,
            ),
          ),
        );
        return;
      }

      // 多個員工，顯示列表
      _hasCheckedSingleEmployee = true;
      setState(() {
        allEmployees = employeeList;
        _currentPage = 1;
        _updateDisplayedEmployees();
        _isLoading = false;
      });

      // 繼續載入部門資料
      await _loadDepartments();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('載入員工資料失敗：$e')));
      }
    }
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
        allEmployees = employeeList;
        _currentPage = 1; // 重置到第一頁
        _updateDisplayedEmployees();
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

  void _updateDisplayedEmployees() {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, allEmployees.length);
    employees = allEmployees.sublist(startIndex, endIndex);
  }

  void _goToPage(int page) {
    if (page < 1 || page > _totalPages) return;
    setState(() {
      _currentPage = page;
      _updateDisplayedEmployees();
    });
  }

  void _previousPage() {
    if (_currentPage > 1) {
      _goToPage(_currentPage - 1);
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages) {
      _goToPage(_currentPage + 1);
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

  void _navigateToUserSelection() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserSelectionPage(
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
        IconButton(
          icon: const Icon(Icons.person_add),
          tooltip: '從已註冊用戶新增員工',
          onPressed: _navigateToUserSelection,
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadData,
          tooltip: '重新整理',
        ),
        ThemeToggleButton(currentThemeMode: widget.currentThemeMode, onToggle: widget.onThemeToggle),
        const AuthActionButton(),
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
                        initialValue: _selectedDepartment,
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
                        initialValue: _selectedStatus,
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
        // 分頁資訊和統計
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '共 ${allEmployees.length} 位員工',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (_totalPages > 1)
                  Text(
                    '第 $_currentPage / $_totalPages 頁 (每頁 $_itemsPerPage 筆)',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // 員工列表
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: allEmployees.isEmpty
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
                              case 'invite':
                                _sendInvitation(employee);
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
                            if (employee.email != null && employee.email!.isNotEmpty)
                              const PopupMenuItem(
                                value: 'invite',
                                child: Row(
                                  children: [
                                    Icon(Icons.mail, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text('發送邀請', style: TextStyle(color: Colors.blue)),
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
        // 分頁按鈕
        if (_totalPages > 1) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 第一頁按鈕
                  IconButton(
                    icon: const Icon(Icons.first_page),
                    onPressed: _currentPage > 1 ? () => _goToPage(1) : null,
                    tooltip: '第一頁',
                  ),
                  // 上一頁按鈕
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage > 1 ? _previousPage : null,
                    tooltip: '上一頁',
                  ),
                  const SizedBox(width: 16),
                  // 頁碼顯示和快速跳轉
                  ..._buildPageNumbers(),
                  const SizedBox(width: 16),
                  // 下一頁按鈕
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage < _totalPages ? _nextPage : null,
                    tooltip: '下一頁',
                  ),
                  // 最後一頁按鈕
                  IconButton(
                    icon: const Icon(Icons.last_page),
                    onPressed: _currentPage < _totalPages ? () => _goToPage(_totalPages) : null,
                    tooltip: '最後一頁',
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> pageButtons = [];
    
    // 計算顯示哪些頁碼
    int startPage = (_currentPage - 2).clamp(1, _totalPages);
    int endPage = (_currentPage + 2).clamp(1, _totalPages);
    
    // 確保至少顯示5個頁碼（如果總頁數允許）
    if (endPage - startPage < 4) {
      if (startPage == 1) {
        endPage = (startPage + 4).clamp(1, _totalPages);
      } else if (endPage == _totalPages) {
        startPage = (endPage - 4).clamp(1, _totalPages);
      }
    }
    
    // 如果起始頁不是第1頁，顯示省略號
    if (startPage > 1) {
      pageButtons.add(const Text('...', style: TextStyle(fontSize: 18)));
      pageButtons.add(const SizedBox(width: 4));
    }
    
    // 生成頁碼按鈕
    for (int i = startPage; i <= endPage; i++) {
      pageButtons.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _currentPage == i
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$i',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : TextButton(
                  onPressed: () => _goToPage(i),
                  child: Text('$i'),
                ),
        ),
      );
    }
    
    // 如果結束頁不是最後一頁，顯示省略號
    if (endPage < _totalPages) {
      pageButtons.add(const SizedBox(width: 4));
      pageButtons.add(const Text('...', style: TextStyle(fontSize: 18)));
    }
    
    return pageButtons;
  }

  Future<void> _sendInvitation(Employee employee) async {
    if (employee.email == null || employee.email!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('該員工沒有設置電子郵件地址'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('發送系統邀請'),
        content: Text(
          '確定要為員工 ${employee.name} 發送系統帳號邀請嗎？\n\n'
          '邀請將發送至：${employee.email}\n\n'
          '員工將收到：\n'
          '• 臨時登入密碼\n'
          '• 系統使用說明\n'
          '• 首次登入指引',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('發送邀請'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        // 模擬發送邀請
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✉️ 系統邀請已準備發送至 ${employee.email}\n'
              '🔐 臨時密碼：${_generateDisplayPassword()}\n'
              'ℹ️ 實際部署時需要設定郵件服務',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: '複製密碼',
              textColor: Colors.white,
              onPressed: () {
                // 這裡可以實現複製到剪貼板的功能
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('臨時密碼已複製'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        );

        // TODO: 實際發送邀請
        // final invitationService = EmployeeInvitationService(supabase);
        // await invitationService.inviteEmployee(
        //   email: employee.email!,
        //   employeeData: employee,
        // );

      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('發送邀請失敗：$e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _generateDisplayPassword() {
    // 生成顯示用的臨時密碼
    return 'Temp${DateTime.now().millisecondsSinceEpoch % 10000}';
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