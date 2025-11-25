import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/models.dart';
import '../../../services/employee/attendance/attendance_leave_request_service.dart';
import '../../../services/employee/attendance/attendance_service.dart';
import '../../../services/employee/employee_general_service.dart';

/// 補打卡申請表單頁面 - 使用與管理員相同的 UI，但提交為申請而非直接補打卡
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
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  late final AttendanceLeaveRequestService _requestService;
  late final AttendanceService _attendanceService;
  late final EmployeeService _employeeService;

  Employee? _currentEmployee;
  AttendanceRecord? _existingRecord;
  DateTime _selectedDate = DateTime.now();
  String _punchType = 'checkIn';
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 30);
  TimeOfDay _checkOutTime = const TimeOfDay(hour: 17, minute: 30);
  String _reasonType = '';
  String _notes = '';
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _requestService = AttendanceLeaveRequestService(_supabase);
    _attendanceService = AttendanceService(_supabase);
    _employeeService = EmployeeService(_supabase);
    _loadCurrentEmployee();

    if (widget.request != null) {
      _isEditing = true;
      _loadRequestData(widget.request!);
    }
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

  void _loadRequestData(AttendanceLeaveRequest request) {
    _selectedDate = request.requestDate;
    _notes = request.reason;

    if (request.requestType == AttendanceRequestType.checkIn) {
      _punchType = 'checkIn';
      final time = request.requestTime!;
      _selectedTime = TimeOfDay(hour: time.hour, minute: time.minute);
    } else if (request.requestType == AttendanceRequestType.checkOut) {
      _punchType = 'checkOut';
      final time = request.requestTime!;
      _selectedTime = TimeOfDay(hour: time.hour, minute: time.minute);
    } else {
      _punchType = 'fullDay';
      final checkIn = request.checkInTime!;
      final checkOut = request.checkOutTime!;
      _selectedTime = TimeOfDay(hour: checkIn.hour, minute: checkIn.minute);
      _checkOutTime = TimeOfDay(hour: checkOut.hour, minute: checkOut.minute);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _existingRecord = null;
      });
      await _checkExistingRecord();
    }
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
        final record = records.first;
        setState(() {
          _existingRecord = record;
          if (record.checkOutTime == null) {
            _punchType = 'checkOut';
            _selectedTime = const TimeOfDay(hour: 17, minute: 30);
          } else {
            _punchType = 'fullDay';
            _selectedTime = TimeOfDay(
              hour: record.checkInTime.hour,
              minute: record.checkInTime.minute,
            );
            _checkOutTime = TimeOfDay(
              hour: record.checkOutTime!.hour,
              minute: record.checkOutTime!.minute,
            );
          }
        });
      } else {
        setState(() {
          _existingRecord = null;
          _punchType = 'checkIn';
        });
      }
    } catch (e) {
      print('檢查打卡記錄失敗: $e');
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _selectCheckOutTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _checkOutTime,
    );
    if (picked != null) setState(() => _checkOutTime = picked);
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentEmployee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('找不到員工資料'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_reasonType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('請選擇補打卡原因'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_reasonType == '其他' && _notes.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('請填寫原因詳細說明'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final checkInDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      final checkOutDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _checkOutTime.hour,
        _checkOutTime.minute,
      );
      final reasonContent = _reasonType == '其他'
          ? '$_reasonType：${_notes.trim()}'
          : _reasonType;

      AttendanceLeaveRequest request;
      if (_punchType == 'checkIn') {
        request = AttendanceLeaveRequest(
          id: _isEditing ? widget.request!.id : null,
          employeeId: _currentEmployee!.id!,
          employeeName: _currentEmployee!.name,
          requestType: AttendanceRequestType.checkIn,
          requestDate: _selectedDate,
          requestTime: checkInDateTime,
          reason: reasonContent,
          status: AttendanceRequestStatus.pending,
        );
      } else if (_punchType == 'checkOut') {
        request = AttendanceLeaveRequest(
          id: _isEditing ? widget.request!.id : null,
          employeeId: _currentEmployee!.id!,
          employeeName: _currentEmployee!.name,
          requestType: AttendanceRequestType.checkOut,
          requestDate: _selectedDate,
          requestTime: checkOutDateTime,
          checkInTime: _existingRecord?.checkInTime,
          reason: reasonContent,
          status: AttendanceRequestStatus.pending,
        );
      } else {
        request = AttendanceLeaveRequest(
          id: _isEditing ? widget.request!.id : null,
          employeeId: _currentEmployee!.id!,
          employeeName: _currentEmployee!.name,
          requestType: AttendanceRequestType.fullDay,
          requestDate: _selectedDate,
          checkInTime: checkInDateTime,
          checkOutTime: checkOutDateTime,
          reason: reasonContent,
          status: AttendanceRequestStatus.pending,
        );
      }

      if (_isEditing) {
        await _requestService.updateRequest(request);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ 已更新申請'),
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
              content: Text('✓ 已提交補打卡申請，等待審核'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('提交失敗: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('補打卡申請')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentEmployee == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('補打卡申請')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('無法載入員工資料'),
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
      appBar: AppBar(title: Text(_isEditing ? '編輯補打卡申請' : '新增補打卡申請')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          _currentEmployee!.name[0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentEmployee!.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_currentEmployee!.department} - ${_currentEmployee!.position}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '此為員工補打卡申請，提交後需等待管理員審核',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('補打卡日期'),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.blue),
                  title: const Text('選擇日期'),
                  subtitle: Text(
                    DateFormat('yyyy年MM月dd日').format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _selectDate,
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('補打卡類型'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<String>(
                    initialValue: _punchType,
                    decoration: const InputDecoration(
                      labelText: '選擇補打卡類型',
                      prefixIcon: Icon(Icons.punch_clock),
                      border: OutlineInputBorder(),
                    ),
                    items:
                        _existingRecord == null ||
                            _existingRecord!.checkOutTime == null
                        ? [
                            const DropdownMenuItem(
                              value: 'checkIn',
                              child: Row(
                                children: [
                                  Icon(Icons.login, color: Colors.green),
                                  SizedBox(width: 12),
                                  Text('補上班'),
                                ],
                              ),
                            ),
                            if (_existingRecord != null)
                              const DropdownMenuItem(
                                value: 'checkOut',
                                child: Row(
                                  children: [
                                    Icon(Icons.logout, color: Colors.red),
                                    SizedBox(width: 12),
                                    Text('補下班'),
                                  ],
                                ),
                              ),
                            const DropdownMenuItem(
                              value: 'fullDay',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.event_available,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 12),
                                  Text('補全天'),
                                ],
                              ),
                            ),
                          ]
                        : [
                            const DropdownMenuItem(
                              value: 'checkOut',
                              child: Row(
                                children: [
                                  Icon(Icons.logout, color: Colors.red),
                                  SizedBox(width: 12),
                                  Text('補下班'),
                                ],
                              ),
                            ),
                            const DropdownMenuItem(
                              value: 'fullDay',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.event_available,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 12),
                                  Text('補全天'),
                                ],
                              ),
                            ),
                          ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _punchType = value;
                          if (value == 'checkIn')
                            _selectedTime = const TimeOfDay(
                              hour: 8,
                              minute: 30,
                            );
                          else if (value == 'checkOut')
                            _selectedTime = const TimeOfDay(
                              hour: 17,
                              minute: 30,
                            );
                          else {
                            _selectedTime = const TimeOfDay(
                              hour: 8,
                              minute: 30,
                            );
                            _checkOutTime = const TimeOfDay(
                              hour: 17,
                              minute: 30,
                            );
                          }
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_punchType != 'fullDay') ...[
                _buildSectionTitle('打卡時間'),
                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.access_time,
                      color: _punchType == 'checkIn'
                          ? Colors.green
                          : Colors.red,
                    ),
                    title: Text(_punchType == 'checkIn' ? '上班時間' : '下班時間'),
                    subtitle: Text(
                      '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _selectTime,
                  ),
                ),
              ] else ...[
                _buildSectionTitle('上班時間'),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.login, color: Colors.green),
                    title: const Text('上班時間'),
                    subtitle: Text(
                      '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _selectTime,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('下班時間'),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('下班時間'),
                    subtitle: Text(
                      '${_checkOutTime.hour.toString().padLeft(2, '0')}:${_checkOutTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _selectCheckOutTime,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              _buildSectionTitle('補打卡原因（必填）'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<String>(
                    initialValue: _reasonType.isEmpty ? null : _reasonType,
                    decoration: const InputDecoration(
                      labelText: '選擇原因',
                      prefixIcon: Icon(Icons.comment),
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('請選擇補打卡原因'),
                    items: const [
                      DropdownMenuItem(value: '時間更正', child: Text('時間更正')),
                      DropdownMenuItem(value: '忘記打卡', child: Text('忘記打卡')),
                      DropdownMenuItem(value: '系統錯誤', child: Text('系統錯誤')),
                      DropdownMenuItem(value: '其他', child: Text('其他')),
                    ],
                    onChanged: (value) => setState(() {
                      _reasonType = value ?? '';
                      if (value != '其他') _notes = '';
                    }),
                  ),
                ),
              ),
              if (_reasonType == '其他') ...[
                const SizedBox(height: 16),
                _buildSectionTitle('詳細說明（必填）'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        hintText: '請詳細說明補打卡原因...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.edit_note),
                      ),
                      maxLines: 4,
                      onChanged: (value) => _notes = value,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        _isEditing ? '更新申請' : '提交補打卡申請',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
