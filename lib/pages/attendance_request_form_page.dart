import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/attendance_leave_request.dart';
import '../models/employee.dart';
import '../services/attendance_leave_request_service.dart';
import '../services/employee_service.dart';
import '../widgets/general_page.dart';

/// 補打卡申請表單頁面 - 新增/編輯申請
class AttendanceRequestFormPage extends StatefulWidget {
  const AttendanceRequestFormPage({
    super.key,
    required this.onThemeToggle,
    required this.currentThemeMode,
    this.request, // null 表示新增，有值表示編輯
  });

  final VoidCallback onThemeToggle;
  final ThemeMode currentThemeMode;
  final AttendanceLeaveRequest? request;

  @override
  State<AttendanceRequestFormPage> createState() => _AttendanceRequestFormPageState();
}

class _AttendanceRequestFormPageState extends State<AttendanceRequestFormPage> {
  final supabase = Supabase.instance.client;
  late final AttendanceLeaveRequestService _requestService;
  late final EmployeeService _employeeService;

  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  AttendanceRequestType _requestType = AttendanceRequestType.checkIn;
  DateTime _requestDate = DateTime.now();
  TimeOfDay _requestTime = TimeOfDay.now();
  TimeOfDay _checkInTime = const TimeOfDay(hour: 8, minute: 30);
  TimeOfDay _checkOutTime = const TimeOfDay(hour: 17, minute: 30);

  Employee? _currentEmployee;
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _requestService = AttendanceLeaveRequestService(supabase);
    _employeeService = EmployeeService(supabase);
    _loadCurrentEmployee();
    
    // 如果是編輯模式，載入現有資料
    if (widget.request != null) {
      _isEditing = true;
      _loadRequestData(widget.request!);
    }
  }

  /// 載入當前員工資料
  Future<void> _loadCurrentEmployee() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final employee = await _employeeService.getEmployeeById(userId);
      if (mounted) {
        setState(() {
          _currentEmployee = employee;
        });
      }
    } catch (e) {
      print('載入員工資料失敗: $e');
    }
  }

  /// 載入申請資料（編輯模式）
  void _loadRequestData(AttendanceLeaveRequest request) {
    _requestType = request.requestType;
    _requestDate = request.requestDate;
    _reasonController.text = request.reason;

    if (request.requestType == AttendanceRequestType.fullDay) {
      final checkIn = request.checkInTime!;
      final checkOut = request.checkOutTime!;
      _checkInTime = TimeOfDay(hour: checkIn.hour, minute: checkIn.minute);
      _checkOutTime = TimeOfDay(hour: checkOut.hour, minute: checkOut.minute);
    } else {
      final time = request.requestTime!;
      _requestTime = TimeOfDay(hour: time.hour, minute: time.minute);
    }
  }

  /// 提交表單
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_currentEmployee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('無法取得員工資料，請重新登入')),
      );
      return;
    }

    // 檢查日期不能是未來
    if (_requestDate.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('不能申請未來日期的補打卡')),
      );
      return;
    }

    // 檢查日期不能超過 30 天前
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    if (_requestDate.isBefore(thirtyDaysAgo)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('只能申請 30 天內的補打卡')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 建立申請物件
      final request = AttendanceLeaveRequest(
        id: _isEditing ? widget.request!.id : null,
        employeeId: _currentEmployee!.id!,
        employeeName: _currentEmployee!.name,
        requestType: _requestType,
        requestDate: _requestDate,
        requestTime: _requestType != AttendanceRequestType.fullDay
            ? _combineDateAndTime(_requestDate, _requestTime)
            : null,
        checkInTime: _requestType == AttendanceRequestType.fullDay
            ? _combineDateAndTime(_requestDate, _checkInTime)
            : null,
        checkOutTime: _requestType == AttendanceRequestType.fullDay
            ? _combineDateAndTime(_requestDate, _checkOutTime)
            : null,
        reason: _reasonController.text.trim(),
        status: AttendanceRequestStatus.pending,
      );

      if (_isEditing) {
        // 更新現有申請
        await _requestService.updateRequest(request);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已更新申請')),
          );
        }
      } else {
        // 創建新申請
        await _requestService.createRequest(request);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已提交申請')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true); // 返回 true 表示成功
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('提交失敗：$e')),
        );
      }
    }
  }

  /// 合併日期和時間
  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GeneralPage(
      title: _isEditing ? '編輯補打卡申請' : '新增補打卡申請',
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 申請類型選擇
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '申請類型',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _buildRequestTypeRadio(
                        AttendanceRequestType.checkIn,
                        '補上班打卡',
                        Icons.login,
                        Colors.green,
                      ),
                      _buildRequestTypeRadio(
                        AttendanceRequestType.checkOut,
                        '補下班打卡',
                        Icons.logout,
                        Colors.orange,
                      ),
                      _buildRequestTypeRadio(
                        AttendanceRequestType.fullDay,
                        '補整天打卡',
                        Icons.event_available,
                        Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 日期和時間選擇
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '日期與時間',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      
                      // 日期選擇
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('補打卡日期'),
                        subtitle: Text(DateFormat('yyyy-MM-dd').format(_requestDate)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: _selectDate,
                      ),

                      const Divider(),

                      // 根據申請類型顯示不同的時間選擇器
                      if (_requestType == AttendanceRequestType.fullDay) ...[
                        // 整天：上班時間
                        ListTile(
                          leading: const Icon(Icons.login),
                          title: const Text('上班時間'),
                          subtitle: Text(_checkInTime.format(context)),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _selectTime(true),
                        ),
                        const Divider(),
                        // 整天：下班時間
                        ListTile(
                          leading: const Icon(Icons.logout),
                          title: const Text('下班時間'),
                          subtitle: Text(_checkOutTime.format(context)),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _selectTime(false),
                        ),
                      ] else ...[
                        // 單次打卡：時間
                        ListTile(
                          leading: Icon(
                            _requestType == AttendanceRequestType.checkIn
                                ? Icons.login
                                : Icons.logout,
                          ),
                          title: Text(
                            _requestType == AttendanceRequestType.checkIn
                                ? '上班時間'
                                : '下班時間',
                          ),
                          subtitle: Text(_requestTime.format(context)),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _selectTime(null),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 申請原因
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '申請原因',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _reasonController,
                        maxLines: 4,
                        maxLength: 500,
                        decoration: const InputDecoration(
                          hintText: '請詳細說明補打卡的原因...',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '請填寫申請原因';
                          }
                          if (value.trim().length < 10) {
                            return '申請原因至少需要 10 個字';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 提交按鈕
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEditing ? '更新申請' : '提交申請'),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  /// 建立申請類型單選按鈕
  Widget _buildRequestTypeRadio(
    AttendanceRequestType type,
    String label,
    IconData icon,
    Color color,
  ) {
    return RadioListTile<AttendanceRequestType>(
      value: type,
      groupValue: _requestType,
      onChanged: (value) {
        setState(() {
          _requestType = value!;
        });
      },
      title: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  /// 選擇日期
  Future<void> _selectDate() async {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final picked = await showDatePicker(
      context: context,
      initialDate: _requestDate,
      firstDate: thirtyDaysAgo,
      lastDate: now,
      locale: const Locale('zh', 'TW'),
      helpText: '選擇補打卡日期',
      cancelText: '取消',
      confirmText: '確定',
    );

    if (picked != null && picked != _requestDate) {
      setState(() {
        _requestDate = picked;
      });
    }
  }

  /// 選擇時間
  /// [isCheckIn] - null: 單次打卡時間, true: 上班時間, false: 下班時間
  Future<void> _selectTime(bool? isCheckIn) async {
    final initialTime = isCheckIn == null
        ? _requestTime
        : (isCheckIn ? _checkInTime : _checkOutTime);

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: isCheckIn == null
          ? '選擇打卡時間'
          : (isCheckIn ? '選擇上班時間' : '選擇下班時間'),
      cancelText: '取消',
      confirmText: '確定',
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn == null) {
          _requestTime = picked;
        } else if (isCheckIn) {
          _checkInTime = picked;
        } else {
          _checkOutTime = picked;
        }
      });
    }
  }
}
