import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/models.dart';
import '../../services/employee/attendance/attendance_service.dart';
import '../../services/employee/employee_general_service.dart';
import '../../services/general/permission_service.dart';
import '../../widgets/widgets.dart';

/// 手動補打卡頁面（僅 HR/老闆可用）
class ManualAttendancePage extends StatefulWidget {
  const ManualAttendancePage({super.key});

  @override
  State<ManualAttendancePage> createState() => _ManualAttendancePageState();
}

class _ManualAttendancePageState extends State<ManualAttendancePage> {
  final _supabase = Supabase.instance.client;
  late final AttendanceService _attendanceService;
  late final EmployeeService _employeeService;
  late final PermissionService _permissionService;

  Employee? _currentEmployee;
  AttendanceRecord? _existingRecord;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  bool _canManualAttendance = false;

  @override
  void initState() {
    super.initState();
    _attendanceService = AttendanceService(_supabase);
    _employeeService = EmployeeService(_supabase);
    _permissionService = PermissionService();
    _checkPermissions();
  }

  /// 檢查權限
  Future<void> _checkPermissions() async {
    try {
      final canManual = await _permissionService.canViewAllAttendance();
      if (mounted) {
        setState(() {
          _canManualAttendance = canManual;
        });

        if (canManual) {
          _loadCurrentEmployee();
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('檢查權限失敗: $e');
      if (mounted) {
        setState(() {
          _canManualAttendance = false;
          _isLoading = false;
        });
      }
    }
  }

  /// 載入當前用戶的員工資料
  Future<void> _loadCurrentEmployee() async {
    setState(() => _isLoading = true);
    try {
      final employee = await _employeeService.getCurrentEmployee();
      if (employee == null) {
        throw Exception('找不到員工資料');
      }
      setState(() {
        _currentEmployee = employee;
      });
      await _checkExistingRecord();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入員工資料失敗: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 日期變更時重新檢查記錄
  Future<void> _onDateChanged(DateTime date) async {
    setState(() {
      _selectedDate = date;
      _existingRecord = null;
    });
    await _checkExistingRecord();
  }

  /// 檢查選定日期是否已有打卡記錄
  Future<void> _checkExistingRecord() async {
    if (_currentEmployee?.id == null) return;

    try {
      final targetDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );

      final records = await _attendanceService.getAllAttendanceRecords(
        employeeId: _currentEmployee!.id!,
        startDate: targetDate,
        endDate: targetDate.add(const Duration(days: 1)),
      );

      if (records.isNotEmpty) {
        setState(() {
          _existingRecord = records.first;
        });
      } else {
        setState(() {
          _existingRecord = null;
        });
      }
    } catch (e) {
      print('檢查打卡記錄失敗: $e');
    }
  }

  /// 提交表單
  Future<void> _handleSubmit(AttendanceFormData formData) async {
    try {
      if (_existingRecord != null) {
        // 更新現有記錄
        await _attendanceService.updateAttendanceRecord(
          id: _existingRecord!.id,
          checkInTime: formData.checkInTime ?? _existingRecord!.checkInTime,
          checkOutTime: formData.checkOutTime,
          location: formData.location,
          notes: formData.reason,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ 打卡記錄已更新'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        // 創建新記錄
        await _attendanceService.createManualAttendance(
          employee: _currentEmployee!,
          checkInTime: formData.checkInTime!,
          checkOutTime: formData.checkOutTime,
          location: formData.location,
          notes: formData.reason,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ 補打卡成功'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('操作失敗: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 權限檢查
    if (!_canManualAttendance) {
      return Scaffold(
        appBar: AppBar(title: const Text('手動補打卡')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 80, color: Colors.orange),
              const SizedBox(height: 24),
              const Text(
                '權限不足',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  '此功能僅限 HR 和老闆使用\n\n一般員工請使用「補打卡申請」功能\n提交申請後等待審核',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('返回'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('手動補打卡')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentEmployee == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('手動補打卡')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('無法載入員工資料', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadCurrentEmployee,
                icon: const Icon(Icons.refresh),
                label: const Text('重新載入'),
              ),
            ],
          ),
        ),
      );
    }

    // 使用統一表單元件
    return Scaffold(
      appBar: AppBar(
        title: const Text('手動補打卡（管理員）'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AttendanceFormWidget(
          config: AttendanceFormConfig(
            mode: AttendanceFormMode.managerDirect,
            targetEmployee: _currentEmployee!,
            existingRecord: _existingRecord,
            onSubmit: _handleSubmit,
            onCancel: () => Navigator.of(context).pop(),
          ),
          onDateChanged: _onDateChanged,
        ),
      ),
    );
  }
}
