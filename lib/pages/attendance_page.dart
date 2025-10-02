import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';
import '../services/attendance_service.dart';
import '../services/employee_service.dart';
import '../widgets/general_page.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({
    super.key,
    required this.title,
    required this.onThemeToggle,
    required this.currentThemeMode,
  });

  final String title;
  final VoidCallback onThemeToggle;
  final ThemeMode currentThemeMode;

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final supabase = Supabase.instance.client;
  late final AttendanceService _attendanceService;
  late final EmployeeService _employeeService;

  Employee? _currentEmployee;
  AttendanceRecord? _todayRecord;
  List<AttendanceRecord> _recentRecords = [];
  bool _isLoading = true;
  bool _isCheckingIn = false;
  
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _attendanceService = AttendanceService(supabase);
    _employeeService = EmployeeService(supabase);
    _loadData();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// 格式化時間為 HH:mm
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// 格式化日期為 MM/dd
  String _formatDate(DateTime dateTime) {
    return '${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}';
  }

  /// 格式化完整日期為 yyyy/MM/dd
  String _formatFullDate(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}';
  }

  /// 載入相關資料
  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      // 載入當前用戶的員工資料
      final user = supabase.auth.currentUser;
      if (user?.email != null) {
        final employees = await _employeeService.getAllEmployees();
        _currentEmployee = employees.where(
          (e) => e.email?.toLowerCase() == user!.email!.toLowerCase(),
        ).firstOrNull;

        if (_currentEmployee?.id != null) {
          // 載入今日打卡記錄
          _todayRecord = await _attendanceService.getTodayAttendance(_currentEmployee!.id!);
          
          // 載入最近的打卡記錄
          _recentRecords = await _attendanceService.getAllAttendanceRecords(
            employeeId: _currentEmployee!.id,
            limit: 10,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入資料失敗: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 打卡上班
  Future<void> _checkIn() async {
    if (_currentEmployee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請先設定員工資料')),
      );
      return;
    }

    try {
      setState(() => _isCheckingIn = true);

      final record = await _attendanceService.checkIn(
        employee: _currentEmployee!,
        location: _locationController.text.trim().isEmpty 
            ? null 
            : _locationController.text.trim(),
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
      );

      _locationController.clear();
      _notesController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('打卡成功！上班時間：${_formatTime(record.checkInTime)}')),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('打卡失敗: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingIn = false);
      }
    }
  }

  /// 打卡下班
  Future<void> _checkOut() async {
    if (_todayRecord == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請先打上班卡')),
      );
      return;
    }

    try {
      setState(() => _isCheckingIn = true);

      final record = await _attendanceService.checkOut(
        recordId: _todayRecord!.id,
        location: _locationController.text.trim().isEmpty 
            ? null 
            : _locationController.text.trim(),
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
      );

      _locationController.clear();
      _notesController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '打卡成功！下班時間：${_formatTime(record.checkOutTime!)} '
              '工作時數：${record.workHours?.toStringAsFixed(1)}小時'
            )
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('打卡失敗: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingIn = false);
      }
    }
  }

  /// 建構今日打卡狀態卡片
  Widget _buildTodayStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.today,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '今日打卡狀態',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_todayRecord != null) ...[
              _buildStatusRow(
                '上班時間',
                _formatTime(_todayRecord!.checkInTime),
                Icons.login,
                Colors.green,
              ),
              const SizedBox(height: 8),
              
              if (_todayRecord!.checkOutTime != null) ...[
                _buildStatusRow(
                  '下班時間',
                  _formatTime(_todayRecord!.checkOutTime!),
                  Icons.logout,
                  Colors.orange,
                ),
                const SizedBox(height: 8),
                _buildStatusRow(
                  '工作時數',
                  '${_todayRecord!.workHours?.toStringAsFixed(1)} 小時',
                  Icons.access_time,
                  Colors.blue,
                ),
              ] else ...[
                _buildStatusRow(
                  '狀態',
                  '工作中...',
                  Icons.work,
                  Colors.blue,
                ),
              ],
              
              if (_todayRecord!.location != null) ...[
                const SizedBox(height: 8),
                _buildStatusRow(
                  '地點',
                  _todayRecord!.location!,
                  Icons.location_on,
                  Colors.purple,
                ),
              ],
              
              if (_todayRecord!.notes != null && _todayRecord!.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildStatusRow(
                  '備註',
                  _todayRecord!.notes!,
                  Icons.note,
                  Colors.grey,
                ),
              ],
            ] else ...[
              Center(
                child: Text(
                  '今天還沒有打卡記錄',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 建構狀態行
  Widget _buildStatusRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: color),
          ),
        ),
      ],
    );
  }

  /// 建構打卡按鈕區域
  Widget _buildCheckInButtons() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '打卡操作',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 地點輸入
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: '地點 (選填)',
                hintText: '請輸入打卡地點',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 12),
            
            // 備註輸入
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: '備註 (選填)',
                hintText: '請輸入備註信息',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            
            // 打卡按鈕
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_todayRecord == null && !_isCheckingIn) ? _checkIn : null,
                    icon: _isCheckingIn
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.login),
                    label: Text(_todayRecord == null ? '打卡上班' : '已上班'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_todayRecord != null && 
                              _todayRecord!.checkOutTime == null && 
                              !_isCheckingIn) ? _checkOut : null,
                    icon: _isCheckingIn
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.logout),
                    label: Text(
                      _todayRecord?.checkOutTime != null 
                          ? '已下班' 
                          : '打卡下班'
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 建構最近記錄列表
  Widget _buildRecentRecords() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '最近記錄',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: 導航到完整的打卡記錄頁面
                  },
                  child: const Text('查看全部'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_recentRecords.isEmpty)
              const Center(
                child: Text('暫無打卡記錄'),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentRecords.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final record = _recentRecords[index];
                  return _buildRecordTile(record);
                },
              ),
          ],
        ),
      ),
    );
  }

  /// 建構記錄項目
  Widget _buildRecordTile(AttendanceRecord record) {
    final dateStr = _formatDate(record.checkInTime);
    final checkInStr = _formatTime(record.checkInTime);
    final checkOutStr = record.checkOutTime != null 
        ? _formatTime(record.checkOutTime!) 
        : '---';
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: record.isCheckedOut 
            ? Colors.green.shade100 
            : Colors.blue.shade100,
        child: Icon(
          record.isCheckedOut ? Icons.check : Icons.work,
          color: record.isCheckedOut ? Colors.green : Colors.blue,
        ),
      ),
      title: Text(
        dateStr,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text('$checkInStr - $checkOutStr'),
      trailing: record.workHours != null
          ? Text(
              '${record.workHours!.toStringAsFixed(1)}h',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).primaryColor,
              ),
            )
          : const Icon(Icons.more_time, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GeneralPage(
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadData,
          tooltip: '重新整理',
        ),
      ],
      children: _isLoading
          ? [const Center(child: CircularProgressIndicator())]
          : _currentEmployee == null
              ? [const Center(
                  child: Text(
                    '請先在員工管理中設定您的員工資料',
                    style: TextStyle(fontSize: 16),
                  ),
                )]
              : [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // 員工信息
                        Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(_currentEmployee!.name[0]),
                            ),
                            title: Text(_currentEmployee!.name),
                            subtitle: Text(_currentEmployee!.email ?? ''),
                            trailing: Text(
                              _formatFullDate(DateTime.now()),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // 今日狀態
                        _buildTodayStatusCard(),
                        const SizedBox(height: 16),
                        
                        // 打卡按鈕
                        _buildCheckInButtons(),
                        const SizedBox(height: 16),
                        
                        // 最近記錄
                        _buildRecentRecords(),
                      ],
                    ),
                  ),
                ],
    );
  }
}