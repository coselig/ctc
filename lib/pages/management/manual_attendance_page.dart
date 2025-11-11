import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/models.dart';
import '../../services/employee/attendance/attendance_service.dart';
import '../../services/employee/employee_general_service.dart';
import '../../services/general/permission_service.dart';

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
  String _punchType = 'checkIn'; // 'checkIn'、'checkOut' 或 'fullDay'
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 30);
  TimeOfDay _checkOutTime = const TimeOfDay(hour: 17, minute: 30); // 補全天用的下班時間
  String _location = '';
  String _otherLocation = ''; // 其他地點的詳細說明
  String _reasonType = ''; // 原因類型
  String _notes = ''; // 其他原因的詳細說明
  bool _isLoading = true; // 初始化時應該是 true，表示正在載入
  bool _isSubmitting = false;
// 是否正在檢查記錄
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
      final employee = await _employeeService.getCurrentEmployee();
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
          _location = record.location ?? '';
          _notes = record.notes?.replaceAll('【補打卡】', '') ?? '';

          // 根據現有記錄設定預設值
          if (record.checkOutTime == null) {
            // 有上班記錄，預設補下班
            _punchType = 'checkOut';
            _selectedTime = const TimeOfDay(hour: 17, minute: 30);
          } else {
            // 已有完整記錄，預設補全天（修改整天）
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

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                record.checkOutTime == null
                    ? '⚠️ 該日期已有上班打卡記錄，您可以補登下班時間或補全天'
                    : '⚠️ 該日期已有完整打卡記錄，您可以修改整天的打卡時間',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else {
        // 沒有記錄，預設補上班
        setState(() {
          _existingRecord = null;
          _punchType = 'checkIn';
          _selectedTime = const TimeOfDay(hour: 8, minute: 30);
          _checkOutTime = const TimeOfDay(hour: 17, minute: 30);
          _location = '';
          _notes = '';
        });
      }
    } catch (e) {
      print('檢查打卡記錄失敗: $e');
    } finally {
    }
  }

  /// 選擇上班時間
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      helpText: '選擇上班時間',
      cancelText: '取消',
      confirmText: '確定',
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  /// 選擇下班時間
  Future<void> _selectCheckOutTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _checkOutTime,
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

    // 驗證原因類型
    if (_reasonType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('請選擇補打卡原因'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 如果選擇「其他」，必須填寫詳細說明
    if (_reasonType == '其他' && _notes.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('請填寫原因詳細說明'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 驗證打卡地點
    if (_location == '其他' && _otherLocation.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('請填寫地點說明'),
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

      // 判斷是更新現有記錄還是創建新記錄
      if (_existingRecord != null) {
        // 更新現有記錄
        DateTime? newCheckInTime;
        DateTime? newCheckOutTime;

        if (_punchType == 'checkIn') {
          // 補上班時間
          newCheckInTime = checkInDateTime;
          newCheckOutTime = _existingRecord!.checkOutTime;

          // 如果已有下班時間，檢查上班時間不能晚於下班時間
          if (newCheckOutTime != null &&
              checkInDateTime.isAfter(newCheckOutTime)) {
            throw Exception('上班時間不能晚於下班時間');
          }
        } else if (_punchType == 'checkOut') {
          // 補下班時間
          newCheckInTime = _existingRecord!.checkInTime;
          newCheckOutTime = checkOutDateTime;

          // 檢查下班時間不能早於上班時間
          if (checkOutDateTime.isBefore(newCheckInTime)) {
            throw Exception('下班時間不能早於上班時間');
          }
        } else {
          // 補全天
          newCheckInTime = checkInDateTime;
          newCheckOutTime = checkOutDateTime;

          // 檢查下班時間不能早於上班時間
          if (checkOutDateTime.isBefore(checkInDateTime)) {
            throw Exception('下班時間不能早於上班時間');
          }
        }
        
        // 組合備註內容
        final noteContent = _reasonType == '其他'
            ? '【補打卡】$_reasonType：${_notes.trim()}'
            : '【補打卡】$_reasonType';

        // 組合地點內容
        final locationContent = _location == '其他'
            ? _otherLocation.trim()
            : _location.trim();
        
        await _attendanceService.updateAttendanceRecord(
          id: _existingRecord!.id,
          checkInTime: newCheckInTime,
          checkOutTime: newCheckOutTime,
          location: locationContent.isEmpty ? null : locationContent,
          notes: noteContent,
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
        final noteContent = _reasonType == '其他'
            ? '【補打卡】$_reasonType：${_notes.trim()}'
            : '【補打卡】$_reasonType';

        // 組合地點內容
        final locationContent = _location == '其他'
            ? _otherLocation.trim()
            : _location.trim();

        if (_punchType == 'checkIn') {
          // 只補上班
          await _attendanceService.createManualAttendance(
            employee: _currentEmployee!,
            checkInTime: checkInDateTime,
            checkOutTime: null,
            location: locationContent.isEmpty ? null : locationContent,
            notes: noteContent,
          );
        } else if (_punchType == 'fullDay') {
          // 補全天
          if (checkOutDateTime.isBefore(checkInDateTime)) {
            throw Exception('下班時間不能早於上班時間');
          }
          await _attendanceService.createManualAttendance(
            employee: _currentEmployee!,
            checkInTime: checkInDateTime,
            checkOutTime: checkOutDateTime,
            location: locationContent.isEmpty ? null : locationContent,
            notes: noteContent,
          );
        } else {
          // 補下班時必須有上班時間，這種情況不應該發生
          throw Exception('補下班時間需要先有上班打卡記錄');
        }

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

              // 補打卡類型選擇
              _buildSectionTitle('補打卡類型'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
                            // 沒有記錄或只有上班記錄：顯示「補上班」和「補全天」
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
                            // 已有完整記錄：顯示「補下班」和「補全天」
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
                          // 根據類型設定預設時間
                          if (value == 'checkIn') {
                            _selectedTime = const TimeOfDay(
                              hour: 8,
                              minute: 30,
                            );
                          } else if (value == 'checkOut') {
                            _selectedTime = const TimeOfDay(
                              hour: 17,
                              minute: 30,
                            );
                          } else {
                            // fullDay
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

              // 時間選擇
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
                        color: Colors.black87,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _selectTime,
                  ),
                ),
              ] else ...[
                // 補全天：顯示上班和下班時間
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
                        color: Colors.black87,
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
                        color: Colors.black87,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _selectCheckOutTime,
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // 打卡地點
              _buildSectionTitle('打卡地點'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: _location.isEmpty ? null : _location,
                    decoration: const InputDecoration(
                      labelText: '選擇打卡地點',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('請選擇地點'),
                    items: const [
                      DropdownMenuItem(value: '辦公室', child: Text('辦公室')),
                      DropdownMenuItem(value: '出差', child: Text('出差')),
                      DropdownMenuItem(value: '其他', child: Text('其他')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _location = value ?? '';
                      });
                    },
                  ),
                ),
              ),

              // 其他地點詳細說明
              if (_location == '其他') ...[
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: '請輸入地點說明',
                        prefixIcon: Icon(Icons.edit_location),
                        border: OutlineInputBorder(),
                        hintText: '例如：客戶公司、展場等',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _otherLocation = value;
                        });
                      },
                      validator: (value) {
                        if (_location == '其他' &&
                            (value == null || value.trim().isEmpty)) {
                          return '請輸入地點說明';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // 補打卡原因
              _buildSectionTitle('補打卡原因（必填）'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '請選擇補打卡原因';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _reasonType = value ?? '';
                        // 如果不是選擇「其他」，清空詳細說明
                        if (value != '其他') {
                          _notes = '';
                        }
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 如果選擇「其他」，顯示詳細說明欄位
              if (_reasonType == '其他') ...[
                _buildSectionTitle('詳細說明（必填）'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        hintText: '請詳細說明補打卡原因...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.edit_note),
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (_reasonType == '其他' &&
                            (value == null || value.trim().isEmpty)) {
                          return '請填寫詳細說明';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _notes = value;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 16),

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

}
