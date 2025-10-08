import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/employee.dart';
import '../models/user_role.dart';
import '../services/employee_service.dart';
import '../services/permission_service.dart';
import '../widgets/general_page.dart';
import '../widgets/widgets.dart';
import 'employee_form_page.dart';

class EmployeeDetailPage extends StatefulWidget {
  const EmployeeDetailPage({
    super.key,
    required this.employee,
    required this.onThemeToggle,
    required this.currentThemeMode,
  });

  final Employee employee;
  final VoidCallback onThemeToggle;
  final ThemeMode currentThemeMode;

  @override
  State<EmployeeDetailPage> createState() => _EmployeeDetailPageState();
}

class _EmployeeDetailPageState extends State<EmployeeDetailPage> {
  final supabase = Supabase.instance.client;
  late final EmployeeService _employeeService;
  late final EmployeeSkillService _skillService;
  late final PermissionService _permissionService;
  
  Employee? currentEmployee;
  List<EmployeeSkill> skills = [];
  bool _isLoading = false;
  bool _isBoss = false; // 當前用戶是否為老闆

  @override
  void initState() {
    super.initState();
    _employeeService = EmployeeService(supabase);
    _skillService = EmployeeSkillService(supabase);
    _permissionService = PermissionService();
    currentEmployee = widget.employee;
    _loadPermissions();
    _loadSkills();
  }

  /// 載入當前用戶權限
  Future<void> _loadPermissions() async {
    try {
      final isBoss = await _permissionService.isBoss();
      if (mounted) {
        setState(() {
          _isBoss = isBoss;
        });
      }
    } catch (e) {
      print('載入權限失敗: $e');
    }
  }

  Future<void> _loadSkills() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final skillList = await _skillService.getEmployeeSkills(currentEmployee!.id!);
      setState(() {
        skills = skillList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入技能資料失敗：$e')),
        );
      }
    }
  }

  void _navigateToEditForm() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EmployeeFormPage(
          employee: currentEmployee,
          onThemeToggle: widget.onThemeToggle,
          currentThemeMode: widget.currentThemeMode,
        ),
      ),
    );

    if (result == true && currentEmployee != null) {
      // 重新載入員工資料
      final updatedEmployee = await _employeeService.getEmployeeById(currentEmployee!.id!);
      if (updatedEmployee != null) {
        setState(() {
          currentEmployee = updatedEmployee;
        });
      }
    }
  }

  Future<void> _addSkill() async {
    final skillController = TextEditingController();
    int proficiencyLevel = 1;

    final result = await showDialog<EmployeeSkill>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('新增技能'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: skillController,
                decoration: const InputDecoration(
                  labelText: '技能名稱',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: proficiencyLevel,
                decoration: const InputDecoration(
                  labelText: '熟練度',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(5, (index) => 
                  DropdownMenuItem<int>(
                    value: index + 1,
                    child: Text('${index + 1} 級'),
                  ),
                ),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      proficiencyLevel = value;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                if (skillController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop(
                    EmployeeSkill(
                      employeeId: currentEmployee!.id!,
                      skillName: skillController.text.trim(),
                      proficiencyLevel: proficiencyLevel,
                      createdAt: DateTime.now(),
                    ),
                  );
                }
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      try {
        await _skillService.addEmployeeSkill(result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('技能已添加')),
          );
        }
        _loadSkills();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('添加技能失敗：$e')),
          );
        }
      }
    }
  }

  Future<void> _deleteSkill(EmployeeSkill skill) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('刪除技能'),
        content: Text('確定要刪除技能「${skill.skillName}」嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('刪除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _skillService.deleteEmployeeSkill(skill.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已刪除技能「${skill.skillName}」')),
          );
        }
        _loadSkills();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('刪除技能失敗：$e')),
          );
        }
      }
    }
  }

  /// 變更員工角色（僅老闆可用）
  Future<void> _changeEmployeeRole() async {
    if (!_isBoss) return;

    final employee = currentEmployee!;
    UserRole? selectedRole = employee.role;

    final result = await showDialog<UserRole>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('變更員工角色'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('員工：${employee.name}'),
              Text('當前角色：${employee.role.displayName}'),
              const SizedBox(height: 16),
              const Text(
                '選擇新角色：',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...UserRole.values.map(
                (role) => RadioListTile<UserRole>(
                  title: Text(role.displayName),
                  subtitle: Text(_getRoleDescription(role)),
                  value: role,
                  groupValue: selectedRole,
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value;
                    });
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: selectedRole != null && selectedRole != employee.role
                  ? () => Navigator.of(context).pop(selectedRole)
                  : null,
              child: const Text('確定變更'),
            ),
          ],
        ),
      ),
    );

    if (result != null && result != employee.role) {
      try {
        final success = await _permissionService.updateEmployeeRole(
          employee.id!,
          result,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已將 ${employee.name} 的角色變更為 ${result.displayName}'),
              backgroundColor: Colors.green,
            ),
          );

          // 重新載入員工資料
          final updatedEmployee = await _employeeService.getEmployeeById(
            employee.id!,
          );
          if (updatedEmployee != null) {
            setState(() {
              currentEmployee = updatedEmployee;
            });
          }
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('變更角色失敗'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('變更角色失敗：$e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  /// 獲取角色說明
  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.boss:
        return '最高權限，可管理所有功能和人員';
      case UserRole.hr:
        return '人事權限，可管理員工和出勤資料';
      case UserRole.employee:
        return '一般員工，僅能查看和編輯自己的資料';
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

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.boss:
        return Colors.purple;
      case UserRole.hr:
        return Colors.blue;
      case UserRole.employee:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentEmployee == null) {
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
          Expanded(
            child: Center(
              child: Text('員工資料載入失敗'),
            ),
          ),
        ],
      );
    }

    final employee = currentEmployee!;

    return GeneralPage(
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: _navigateToEditForm,
          tooltip: '編輯員工資料',
        ),
        IconButton(
          icon: Icon(_getThemeIcon()),
          onPressed: widget.onThemeToggle,
          tooltip: '切換主題',
        ),
        const LogoutButton(),
      ],
      children: [
        // 員工基本資訊
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: employee.avatarUrl != null
                          ? NetworkImage(employee.avatarUrl!)
                          : null,
                      child: employee.avatarUrl == null
                          ? Text(
                              employee.name.substring(0, 1),
                              style: const TextStyle(fontSize: 24),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employee.name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '員工編號：${employee.employeeId}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(employee.status),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              employee.status.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
        // 職位資訊
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
                _buildInfoRow('部門', employee.department),
                _buildInfoRow('職位', employee.position),
                _buildInfoRow('入職日期', '${employee.hireDate.year}/${employee.hireDate.month}/${employee.hireDate.day}'),
                if (employee.salary != null)
                  _buildInfoRow('薪資', '\$${employee.salary!.toStringAsFixed(0)}'),
                // 角色權限資訊
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 100,
                        child: Text(
                          '權限角色：',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getRoleColor(employee.role),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                employee.role.displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            if (_isBoss) ...[
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: _changeEmployeeRole,
                                icon: const Icon(
                                  Icons.admin_panel_settings,
                                  size: 16,
                                ),
                                label: const Text('變更角色'),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                ),
                              ),
                            ],
                          ],
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
        // 聯絡資訊
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
                if (employee.email != null)
                  _buildInfoRow('電子郵件', employee.email!),
                if (employee.phone != null)
                  _buildInfoRow('電話', employee.phone!),
                if (employee.address != null)
                  _buildInfoRow('住址', employee.address!),
                if (employee.emergencyContactName != null)
                  _buildInfoRow('緊急聯絡人', employee.emergencyContactName!),
                if (employee.emergencyContactPhone != null)
                  _buildInfoRow('緊急聯絡電話', employee.emergencyContactPhone!),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 技能資訊
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '技能',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addSkill,
                      tooltip: '新增技能',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (skills.isEmpty)
                  const Text('尚未添加技能')
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: skills.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final skill = skills[index];
                      return ListTile(
                        title: Text(skill.skillName),
                        subtitle: Row(
                          children: List.generate(5, (starIndex) =>
                            Icon(
                              Icons.star,
                              size: 16,
                              color: starIndex < skill.proficiencyLevel
                                  ? Colors.amber
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteSkill(skill),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
        if (employee.notes != null) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '備註',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(employee.notes!),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label：',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}