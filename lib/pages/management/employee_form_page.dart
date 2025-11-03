import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/employee.dart';
import '../../services/employee/employee_general_service.dart';
import '../../widgets/widgets.dart';

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
        // 新增模式：不再支持直接創建員工，必須從已註冊用戶創建
        throw Exception('請從「用戶管理」頁面選擇已註冊用戶來創建員工記錄');
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

  Future<bool?> _showInviteDialog(String email) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('創建系統帳號'),
        content: Text(
          '是否為 $email 創建系統登入帳號？\n\n'
          '• 系統會自動生成臨時密碼\n'
          '• 員工會收到歡迎郵件\n'
          '• 員工可立即開始使用系統',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('稍後處理'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('立即創建'),
          ),
        ],
      ),
    );
  }

  Future<void> _inviteEmployee(Employee employee) async {
    try {
      // 這裡先模擬邀請功能，實際部署時需要完整的邀請服務
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('💌 系統帳號邀請已準備發送至 ${employee.email}\n\n'
                'ℹ️ 實際部署時需要設定郵件服務來自動發送邀請郵件'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      
      // TODO: 使用 EmployeeInvitationService 發送真正的邀請
      // final invitationService = EmployeeInvitationService(supabase);
      // await invitationService.inviteEmployee(
      //   email: employee.email!,
      //   employeeData: employee,
      // );
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('發送邀請失敗: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GeneralPage(
      actions: [
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