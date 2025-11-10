import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/employee.dart';
import '../../services/employee/employee_general_service.dart';
import '../../services/general/registered_user_service.dart';
import '../../widgets/widgets.dart';
import '../public/public_pages.dart';
import 'user_selection_page.dart';

class EmployeeFormPage extends StatefulWidget {
  const EmployeeFormPage({
    super.key,
    this.employee,
    required this.onThemeToggle,
    required this.currentThemeMode,
  });

  final Employee? employee;
  final VoidCallback onThemeToggle;
  final ThemeMode currentThemeMode;

  @override
  State<EmployeeFormPage> createState() => _EmployeeFormPageState();
}

class _EmployeeFormPageState extends State<EmployeeFormPage> {
  final supabase = Supabase.instance.client;
  late final EmployeeService _employeeService;
  late final RegisteredUserService _registeredUserService;
  
  final _formKey = GlobalKey<FormState>();
  final _employeeIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _departmentController = TextEditingController();
  final _positionController = TextEditingController();
  final _salaryController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _hireDate = DateTime.now();
  EmployeeStatus _status = EmployeeStatus.active;
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _employeeService = EmployeeService(supabase);
    _registeredUserService = RegisteredUserService(supabase);
    _isEditMode = widget.employee != null;
    _initializeForm();
  }

  @override
  void dispose() {
    _employeeIdController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _positionController.dispose();
    _salaryController.dispose();
    _addressController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initializeForm() async {
    if (_isEditMode && widget.employee != null) {
      final employee = widget.employee!;
      _employeeIdController.text = employee.employeeId;
      _nameController.text = employee.name;
      _emailController.text = employee.email ?? '';
      _phoneController.text = employee.phone ?? '';
      _departmentController.text = employee.department;
      _positionController.text = employee.position;
      _salaryController.text = employee.salary?.toString() ?? '';
      _addressController.text = employee.address ?? '';
      _emergencyNameController.text = employee.emergencyContactName ?? '';
      _emergencyPhoneController.text = employee.emergencyContactPhone ?? '';
      _notesController.text = employee.notes ?? '';
      _hireDate = employee.hireDate;
      _status = employee.status;
    } else {
      // 新增模式 - 生成員工編號
      try {
        final employeeId = await _employeeService.generateEmployeeId();
        _employeeIdController.text = employeeId;
      } catch (e) {
        print('生成員工編號失敗：$e');
      }
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

  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('請先登入');
      }

      if (_isEditMode) {
        // 編輯模式：使用現有 ID 更新
        final employee = Employee(
          id: widget.employee!.id,
          employeeId: _employeeIdController.text.trim(),
          name: _nameController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          department: _departmentController.text.trim(),
          position: _positionController.text.trim(),
          hireDate: _hireDate,
          salary: _salaryController.text.trim().isEmpty ? null : double.tryParse(_salaryController.text.trim()),
          status: _status,
          address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
          emergencyContactName: _emergencyNameController.text.trim().isEmpty ? null : _emergencyNameController.text.trim(),
          emergencyContactPhone: _emergencyPhoneController.text.trim().isEmpty ? null : _emergencyPhoneController.text.trim(),
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          createdBy: user.id,
          createdAt: widget.employee!.createdAt,
          updatedAt: DateTime.now(),
        );

        await _employeeService.updateEmployee(widget.employee!.id!, employee);
      } else {
        // 新增模式：不支持直接創建員工，必須從已註冊用戶創建
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('無法直接創建員工'),
              content: const Text(
                '為了確保系統安全性，員工記錄必須從已註冊的系統用戶創建。\n\n'
                '請按照以下步驟操作：\n'
                '1. 請用戶先註冊系統帳號\n'
                '2. 從「用戶管理」頁面選擇已註冊用戶\n'
                '3. 為選定用戶創建員工記錄',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('了解'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(); // 返回上一頁
                    // 導航到用戶選擇頁面
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => UserSelectionPage(
                          onThemeToggle: widget.onThemeToggle,
                          currentThemeMode: widget.currentThemeMode,
                        ),
                      ),
                    );
                  },
                  child: const Text('前往用戶管理'),
                ),
              ],
            ),
          );
        }
        return; // 不執行實際的保存操作
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('員工資料${_isEditMode ? '更新' : '創建'}成功')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('儲存失敗：$e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override

  /// 測試創建員工功能
  Future<void> _testCreateEmployee() async {
    setState(() => _isLoading = true);

    try {
      final testResult = await _registeredUserService.testCreateEmployee();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(testResult['success'] == true ? '測試成功' : '測試失敗'),
            content: SingleChildScrollView(
              child: Text(_formatDiagnosisResult(testResult)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('關閉'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('測試失敗：$e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 顯示員工創建工作流程說明
  Future<void> _showWorkflowInfo() async {
    final workflow = _registeredUserService.getEmployeeCreationWorkflow();

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(workflow['title']),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  workflow['description'],
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  '操作步驟：',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(workflow['steps'].length, (index) {
                  final step = workflow['steps'][index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          child: Text(
                            '${step['step']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step['title'],
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                step['description'],
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                '動作：${step['action']}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                Text(
                  '優點：',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(
                  workflow['benefits'].length,
                  (index) => Text(
                    '• ${workflow['benefits'][index]}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withAlpha(50),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(100),
                    ),
                  ),
                  child: Text(
                    workflow['note'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('關閉'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // 返回上一頁
                // 導航到用戶選擇頁面
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UserSelectionPage(
                      onThemeToggle: widget.onThemeToggle,
                      currentThemeMode: widget.currentThemeMode,
                    ),
                  ),
                );
              },
              child: const Text('前往用戶管理'),
            ),
          ],
        ),
      );
    }
  }

  /// 檢查認證問題
  Future<void> _checkAuthIssues() async {
    setState(() => _isLoading = true);

    try {
      final authCheck = await _registeredUserService.checkAuthIssues();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('認證問題檢查'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('認證問題分析：\n${_formatDiagnosisResult(authCheck)}'),
                  if (authCheck['solutions'] != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      '建議解決方案：',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(
                      authCheck['solutions'].length,
                      (index) => Text(
                        '${index + 1}. ${authCheck['solutions'][index]}',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('關閉'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('認證檢查失敗：$e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 測試用戶註冊功能
  Future<void> _testUserRegistration() async {
    setState(() => _isLoading = true);

    try {
      final testResult = await _registeredUserService.testUserRegistration();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              testResult['registration']?['success'] == true
                  ? '註冊測試成功'
                  : '註冊測試失敗',
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('註冊測試結果：\n${_formatDiagnosisResult(testResult)}'),
                  if (testResult['error_analysis'] != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      '錯誤分析：',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(_formatDiagnosisResult(testResult['error_analysis'])),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('關閉'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('註冊測試失敗：$e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 格式化診斷結果為可讀文本
  String _formatDiagnosisResult(Map<String, dynamic> result) {
    final buffer = StringBuffer();

    void formatValue(String key, dynamic value, [int indent = 0]) {
      final prefix = '  ' * indent;
      if (value is Map<String, dynamic>) {
        buffer.writeln('$prefix$key:');
        value.forEach((k, v) => formatValue(k, v, indent + 1));
      } else if (value is List) {
        buffer.writeln('$prefix$key: [${value.join(', ')}]');
      } else {
        buffer.writeln('$prefix$key: $value');
      }
    }

    result.forEach((key, value) => formatValue(key, value));
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return GeneralPage(
      actions: [
        // 工作流程說明按鈕（僅在新增模式顯示）
        if (!_isEditMode)
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showWorkflowInfo,
            tooltip: '查看員工創建工作流程',
          ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveEmployee,
            tooltip: '儲存',
          ),
        ThemeToggleButton(currentThemeMode: widget.currentThemeMode, onToggle: widget.onThemeToggle),
        const AuthActionButton(),
      ],
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '基本資訊',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _employeeIdController,
                              decoration: const InputDecoration(
                                labelText: '員工編號 *',
                                border: OutlineInputBorder(),
                              ),
                              enabled: !_isEditMode, // 編輯模式不能修改員工編號
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '請輸入員工編號';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: '姓名 *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '請輸入姓名';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: '電子郵件',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                  if (!emailRegex.hasMatch(value.trim())) {
                                    return '請輸入有效的電子郵件格式';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: '聯絡電話',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '職位資訊',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _departmentController,
                              decoration: const InputDecoration(
                                labelText: '部門 *',
                                border: OutlineInputBorder(),
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
                                border: OutlineInputBorder(),
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
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: '入職日期 *',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
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
                                border: OutlineInputBorder(),
                                prefixText: '\$ ',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  if (double.tryParse(value.trim()) == null) {
                                    return '請輸入有效的數字';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<EmployeeStatus>(
                        initialValue: _status,
                        decoration: const InputDecoration(
                          labelText: '狀態',
                          border: OutlineInputBorder(),
                        ),
                        items: EmployeeStatus.values.map((status) => 
                          DropdownMenuItem<EmployeeStatus>(
                            value: status,
                            child: Text(status.displayName),
                          ),
                        ).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _status = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '聯絡資訊',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: '住址',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _emergencyNameController,
                              decoration: const InputDecoration(
                                labelText: '緊急聯絡人',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _emergencyPhoneController,
                              decoration: const InputDecoration(
                                labelText: '緊急聯絡電話',
                                border: OutlineInputBorder(),
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
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveEmployee,
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isEditMode ? '更新' : '創建'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}