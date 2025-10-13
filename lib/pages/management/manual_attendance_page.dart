import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/models.dart';
import '../../services/attendance_service.dart';
import '../../services/employee_service.dart';
import '../../services/permission_service.dart';

/// 手動補打卡頁面（僅 HR/老闆可用）
class ManualAttendancePage extends StatefulWidget {
  const ManualAttendancePage({super.key});

  @override
  State<ManualAttendancePage> createState() => _ManualAttendancePageState();
}

class _ManualAttendancePageState extends State<ManualAttendancePage> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  late final AttendanceService _attendanceService;
  late final EmployeeService _employeeService;
  late final PermissionService _permissionService;

  Employee? _currentEmployee;
  AttendanceRecord? _existingRecord; // 當天是否已有打卡記錄
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _checkInTime = const TimeOfDay(hour: 8, minute: 30);
  TimeOfDay? _checkOutTime;
  bool _hasCheckOut = false;
  String _location = '';
  String _notes = '';
  bool _isLoading = true; // 初始化時應該是 true，表示正在載入
  bool _isSubmitting = false;
  bool _isCheckingRecord = false; // 是否正在檢查記錄
  bool _canManualAttendance = false; // 是否有手動補打卡權限

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

        // 如果有權限才載入員工資料
        if (canManual) {
          _loadCurrentEmployee();
        } else {
          // 沒有權限時，也要停止載入狀態
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
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('用戶未登入');
      }

      final employee = await _employeeService.getEmployeeByEmail(user.email!);
      if (employee == null) {
        throw Exception('找不到員工資料');
      }

      setState(() {
        _currentEmployee = employee;
      });

      // 載入完員工資料後,檢查今天是否已有打卡記錄
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

  /// 選擇日期
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      helpText: '選擇補打卡日期',
      cancelText: '取消',
      confirmText: '確定',
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _existingRecord = null; // 清除舊的記錄
      });
      // 檢查該日期是否已有打卡記錄
      await _checkExistingRecord();
    }
  }

  /// 檢查選定日期是否已有打卡記錄
  Future<void> _checkExistingRecord() async {
    if (_currentEmployee?.id == null) return;

    setState(() => _isCheckingRecord = true);

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
          // 載入現有資料
          _checkInTime = TimeOfDay(
            hour: record.checkInTime.hour,
            minute: record.checkInTime.minute,
          );
          if (record.checkOutTime != null) {
            _checkOutTime = TimeOfDay(
              hour: record.checkOutTime!.hour,
              minute: record.checkOutTime!.minute,
            );
            _hasCheckOut = true;
          } else {
            _checkOutTime = null;
            _hasCheckOut = false;
          }
          _location = record.location ?? '';
          _notes = record.notes?.replaceAll('【補打卡】', '') ?? '';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                record.checkOutTime == null
                    ? '⚠️ 該日期已有上班打卡記錄，您可以補登下班時間'
                    : '⚠️ 該日期已有完整打卡記錄，您可以編輯修改',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else {
        setState(() {
          _existingRecord = null;
          // 重置為預設值
          _checkInTime = const TimeOfDay(hour: 8, minute: 30);
          _checkOutTime = null;
          _hasCheckOut = false;
          _location = '';
          _notes = '';
        });
      }
    } catch (e) {
      print('檢查打卡記錄失敗: $e');
    } finally {
      setState(() => _isCheckingRecord = false);
    }
  }

  /// 選擇上班時間
  Future<void> _selectCheckInTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _checkInTime,
      helpText: '選擇上班時間',
      cancelText: '取消',
      confirmText: '確定',
    );

    if (picked != null) {
      setState(() {
        _checkInTime = picked;
      });
    }
  }

  /// 選擇下班時間
  Future<void> _selectCheckOutTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _checkOutTime ?? const TimeOfDay(hour: 17, minute: 30),
      helpText: '選擇下班時間',
      cancelText: '取消',
      confirmText: '確定',
    );

    if (picked != null) {
      setState(() {
        _checkOutTime = picked;
      });
    }
  }

  /// 提交補打卡
  Future<void> _submitManualAttendance() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_currentEmployee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('找不到員工資料'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_notes.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('請填寫補打卡原因'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 組合日期和時間
      final checkInDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _checkInTime.hour,
        _checkInTime.minute,
      );

      DateTime? checkOutDateTime;
      if (_hasCheckOut && _checkOutTime != null) {
        checkOutDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _checkOutTime!.hour,
          _checkOutTime!.minute,
        );

        // 檢查下班時間是否早於上班時間
        if (checkOutDateTime.isBefore(checkInDateTime)) {
          throw Exception('下班時間不能早於上班時間');
        }
      }

      // 判斷是更新現有記錄還是創建新記錄
      if (_existingRecord != null) {
        // 更新現有記錄
        await _attendanceService.updateAttendanceRecord(
          id: _existingRecord!.id,
          checkInTime: checkInDateTime,
          checkOutTime: checkOutDateTime,
          location: _location.trim().isEmpty ? null : _location.trim(),
          notes: '【補打卡】${_notes.trim()}',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ 打卡記錄已更新'),
              backgroundColor: Colors.green,
            ),
          );

          // 返回上一頁
          Navigator.of(context).pop(true);
        }
      } else {
        // 創建新的補打卡記錄
        await _attendanceService.createManualAttendance(
          employee: _currentEmployee!,
          checkInTime: checkInDateTime,
          checkOutTime: checkOutDateTime,
          location: _location.trim().isEmpty ? null : _location.trim(),
          notes: _notes.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ 補打卡成功'),
              backgroundColor: Colors.green,
            ),
          );

          // 返回上一頁
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('補打卡失敗: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
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

    return Scaffold(
      appBar: AppBar(title: const Text('手動補打卡（管理員）'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 員工資訊卡片
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                                const SizedBox(height: 4),
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 提示訊息
              if (_existingRecord != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit_note, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _existingRecord!.checkOutTime == null
                              ? '✏️ 編輯模式：該日期已有上班打卡記錄\n您可以補登下班時間或修改打卡資料'
                              : '✏️ 編輯模式：該日期已有完整打卡記錄\n您可以修改上下班時間',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '補打卡功能用於補登忘記打卡的記錄\n請如實填寫並說明原因',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // 選擇日期
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
                      color: Colors.black87,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _selectDate,
                ),
              ),
              const SizedBox(height: 24),

              // 上班時間
              _buildSectionTitle('上班時間'),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.login, color: Colors.green),
                  title: const Text('上班打卡時間'),
                  subtitle: Text(
                    '${_checkInTime.hour.toString().padLeft(2, '0')}:${_checkInTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _selectCheckInTime,
                ),
              ),
              const SizedBox(height: 16),

              // 是否補登下班時間
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.logout, color: Colors.orange),
                  title: const Text('同時補登下班時間'),
                  subtitle: Text(
                    _hasCheckOut ? '已啟用' : '未啟用',
                    style: TextStyle(
                      color: _hasCheckOut ? Colors.green : Colors.grey,
                    ),
                  ),
                  value: _hasCheckOut,
                  onChanged: (bool value) {
                    setState(() {
                      _hasCheckOut = value;
                      if (value && _checkOutTime == null) {
                        _checkOutTime = const TimeOfDay(hour: 17, minute: 30);
                      }
                    });
                  },
                ),
              ),

              // 下班時間選擇
              if (_hasCheckOut) ...[
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('下班打卡時間'),
                    subtitle: Text(
                      _checkOutTime != null
                          ? '${_checkOutTime!.hour.toString().padLeft(2, '0')}:${_checkOutTime!.minute.toString().padLeft(2, '0')}'
                          : '未設定',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _selectCheckOutTime,
                  ),
                ),
                if (_checkOutTime != null) _buildWorkHoursInfo(),
              ],
              const SizedBox(height: 24),

              // 打卡地點
              _buildSectionTitle('打卡地點（選填）'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: '例如：公司、居家辦公、出差等',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    maxLength: 100,
                    onChanged: (value) {
                      _location = value;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 補打卡原因
              _buildSectionTitle('補打卡原因（必填）'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: '請說明為何需要補打卡...\n例如：忘記打卡、系統故障、外出辦公等',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.comment),
                    ),
                    maxLines: 4,
                    maxLength: 500,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '請填寫補打卡原因';
                      }
                      if (value.trim().length < 5) {
                        return '請詳細說明原因（至少5個字）';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _notes = value;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 提交按鈕
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitManualAttendance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
                        _existingRecord != null ? '更新打卡記錄' : '提交補打卡申請',
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
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildWorkHoursInfo() {
    if (_checkOutTime == null) return const SizedBox.shrink();

    final checkInMinutes = _checkInTime.hour * 60 + _checkInTime.minute;
    final checkOutMinutes = _checkOutTime!.hour * 60 + _checkOutTime!.minute;
    final workMinutes = checkOutMinutes - checkInMinutes;
    final workHours = workMinutes / 60.0;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        color: Colors.blue.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(Icons.access_time, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '預計工作時數',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      workHours > 0
                          ? '${workHours.toStringAsFixed(1)} 小時'
                          : '時間設定有誤',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: workHours > 0
                            ? Colors.blue.shade900
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              if (workHours > 9)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '加班 ${(workHours - 9).toStringAsFixed(1)}h',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
