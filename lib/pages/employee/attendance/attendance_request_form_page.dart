import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/models.dart';
import '../../../services/employee/attendance/attendance_leave_request_service.dart';
import '../../../services/employee/attendance/attendance_service.dart';
import '../../../services/employee/employee_general_service.dart';
import '../../../widgets/widgets.dart';

/// 補打卡申請表單頁面 - 員工提交申請等待審核
class AttendanceRequestFormPage extends StatefulWidget {
  const AttendanceRequestFormPage({
    super.key,
    required this.onThemeToggle,
    required this.currentThemeMode,
    this.request,
  });

  final VoidCallback onThemeToggle;
  final ThemeMode currentThemeMode;
  final AttendanceLeaveRequest? request;

  @override
  State<AttendanceRequestFormPage> createState() =>
      _AttendanceRequestFormPageState();
}

class _AttendanceRequestFormPageState extends State<AttendanceRequestFormPage> {
  final _supabase = Supabase.instance.client;
  late final AttendanceLeaveRequestService _requestService;
  late final AttendanceService _attendanceService;
  late final EmployeeService _employeeService;

  Employee? _currentEmployee;
  AttendanceRecord? _existingRecord;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _requestService = AttendanceLeaveRequestService(_supabase);
    _attendanceService = AttendanceService(_supabase);
    _employeeService = EmployeeService(_supabase);
    
    if (widget.request != null) {
      _isEditing = true;
      _selectedDate = widget.request!.requestDate;
    }
    
    _loadCurrentEmployee();
  }

  Future<void> _loadCurrentEmployee() async {
    setState(() => _isLoading = true);
    try {
      final employee = await _employeeService.getCurrentEmployee();
      if (employee == null) throw Exception('找不到員工資料');
      setState(() => _currentEmployee = employee);
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

  Future<void> _onDateChanged(DateTime date) async {
    setState(() {
      _selectedDate = date;
      _existingRecord = null;
    });
    await _checkExistingRecord();
  }

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

  Future<void> _handleSubmit(AttendanceFormData formData) async {
    try {
      // 構建申請對象
      final request = AttendanceLeaveRequest(
        id: _isEditing ? widget.request!.id : null,
        employeeId: _currentEmployee!.id!,
        employeeName: _currentEmployee!.name,
        requestType: _getRequestType(formData.punchType),
        requestDate: formData.date,
        requestTime: formData.punchType != 'fullDay'
            ? (formData.punchType == 'checkIn'
                  ? formData.checkInTime
                  : formData.checkOutTime)
            : null,
        checkInTime: formData.punchType == 'fullDay'
            ? formData.checkInTime
            : null,
        checkOutTime: formData.punchType == 'fullDay'
            ? formData.checkOutTime
            : null,
        reason: formData.reason,
        status: _isEditing
            ? widget.request!.status
            : AttendanceRequestStatus.pending,
      );

      if (_isEditing) {
        await _requestService.updateRequest(request);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ 申請已更新'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        await _requestService.createRequest(request);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ 申請已提交，等待審核'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('提交失敗: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      rethrow;
    }
  }

  AttendanceRequestType _getRequestType(String punchType) {
    switch (punchType) {
      case 'checkIn':
        return AttendanceRequestType.checkIn;
      case 'checkOut':
        return AttendanceRequestType.checkOut;
      case 'fullDay':
        return AttendanceRequestType.fullDay;
      default:
        return AttendanceRequestType.checkIn;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(_isEditing ? '編輯補打卡申請' : '補打卡申請')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentEmployee == null) {
      return Scaffold(
        appBar: AppBar(title: Text(_isEditing ? '編輯補打卡申請' : '補打卡申請')),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '編輯補打卡申請' : '補打卡申請'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AttendanceFormWidget(
          config: AttendanceFormConfig(
            mode: AttendanceFormMode.employeeRequest,
            targetEmployee: _currentEmployee!,
            existingRecord: _existingRecord,
            editingRequest: widget.request,
            onSubmit: _handleSubmit,
            onCancel: () => Navigator.of(context).pop(),
          ),
          onDateChanged: _onDateChanged,
        ),
      ),
    );
  }
}
