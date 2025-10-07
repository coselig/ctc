import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';
import '../services/attendance_service.dart';
import '../services/employee_service.dart';
import '../widgets/general_page.dart';

class AttendanceStatsPage extends StatefulWidget {
  const AttendanceStatsPage({super.key});

  @override
  State<AttendanceStatsPage> createState() => _AttendanceStatsPageState();
}

class _AttendanceStatsPageState extends State<AttendanceStatsPage> {
  final supabase = Supabase.instance.client;
  late final AttendanceService _attendanceService;
  late final EmployeeService _employeeService;

  Employee? _currentEmployee;
  AttendanceStats? _monthlyStats;
  List<AttendanceRecord> _monthlyRecords = [];
  bool _isLoading = true;

  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _attendanceService = AttendanceService(supabase);
    _employeeService = EmployeeService(supabase);
    _loadData();
  }

  /// 載入統計資料
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
          await _loadMonthlyData();
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

  /// 載入月度資料
  Future<void> _loadMonthlyData() async {
    if (_currentEmployee?.id == null) return;

    // 計算月度範圍
    final startOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final endOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59);

    // 載入月度記錄
    _monthlyRecords = await _attendanceService.getAllAttendanceRecords(
      employeeId: _currentEmployee!.id,
      startDate: startOfMonth,
      endDate: endOfMonth,
    );

    // 計算統計資料
    _monthlyStats = await _attendanceService.getAttendanceStats(
      employeeId: _currentEmployee!.id!,
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
  }

  /// 選擇月份
  Future<void> _selectMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    
    if (picked != null && picked != _selectedMonth) {
      setState(() {
        _selectedMonth = picked;
      });
      _loadData();
    }
  }

  /// 格式化月份
  String _formatMonth(DateTime date) {
    return '${date.year}年${date.month.toString().padLeft(2, '0')}月';
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  /// 格式化時間
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// 建構統計卡片
  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 建構統計概覽
  Widget _buildStatsOverview() {
    if (_monthlyStats == null) {
      return const SizedBox.shrink();
    }

    final stats = _monthlyStats!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '統計概覽',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildStatCard(
              title: '出勤天數',
              value: '${stats.workDays}',
              subtitle: '共 ${stats.totalDays} 天',
              icon: Icons.calendar_today,
              color: Colors.blue,
            ),
            _buildStatCard(
              title: '出勤率',
              value: '${stats.attendanceRate.toStringAsFixed(1)}%',
              subtitle: '本月平均',
              icon: Icons.trending_up,
              color: Colors.green,
            ),
            _buildStatCard(
              title: '總工時',
              value: '${stats.totalHours.toStringAsFixed(1)}h',
              subtitle: '本月累計',
              icon: Icons.access_time,
              color: Colors.orange,
            ),
            _buildStatCard(
              title: '平均工時',
              value: '${stats.averageHours.toStringAsFixed(1)}h',
              subtitle: '每日平均',
              icon: Icons.schedule,
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  /// 建構記錄列表
  Widget _buildRecordsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '打卡記錄',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        if (_monthlyRecords.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '本月暫無打卡記錄',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: _monthlyRecords.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final record = _monthlyRecords[index];
                return _buildRecordListTile(record);
              },
            ),
          ),
      ],
    );
  }

  /// 建構記錄列表項
  Widget _buildRecordListTile(AttendanceRecord record) {
    final dateStr = _formatDate(record.checkInTime);
    final checkInStr = _formatTime(record.checkInTime);
    final checkOutStr = record.checkOutTime != null 
        ? _formatTime(record.checkOutTime!) 
        : '--:--';
    final workHoursStr = record.workHours != null 
        ? '${record.workHours!.toStringAsFixed(1)}h'
        : '--';

    // 計算是否遲到或早退
    final isLate = record.checkInTime.hour > 9 || 
        (record.checkInTime.hour == 9 && record.checkInTime.minute > 0);
    final isEarlyLeave = record.checkOutTime != null &&
        (record.checkOutTime!.hour < 18 || 
         (record.checkOutTime!.hour == 18 && record.checkOutTime!.minute < 0));

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: CircleAvatar(
        backgroundColor: record.isCheckedOut 
            ? (isLate || isEarlyLeave ? Colors.orange.shade100 : Colors.green.shade100)
            : Colors.blue.shade100,
        child: Icon(
          record.isCheckedOut 
              ? (isLate || isEarlyLeave ? Icons.warning : Icons.check)
              : Icons.work,
          color: record.isCheckedOut 
              ? (isLate || isEarlyLeave ? Colors.orange : Colors.green)
              : Colors.blue,
        ),
      ),
      title: Text(
        dateStr,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('上班：$checkInStr  下班：$checkOutStr'),
          if (isLate || isEarlyLeave)
            Text(
              isLate ? '遲到' : '早退',
              style: const TextStyle(color: Colors.orange),
            ),
        ],
      ),
      trailing: Text(
        workHoursStr,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GeneralPage(
      title: '打卡統計',
      actions: [
        IconButton(
          icon: const Icon(Icons.date_range),
          onPressed: _selectMonth,
          tooltip: '選擇月份',
        ),
      ],
      children: [
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_currentEmployee == null)
          const Center(
            child: Text(
              '請先在員工管理中設定您的員工資料',
              style: TextStyle(fontSize: 16),
            ),
          )
        else
          RefreshIndicator(
            onRefresh: _loadData,
            child: Column(
              children: [
                // 月份選擇器
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_month),
                    title: const Text('統計月份'),
                    subtitle: Text(_formatMonth(_selectedMonth)),
                    trailing: const Icon(Icons.arrow_drop_down),
                    onTap: _selectMonth,
                  ),
                ),
                const SizedBox(height: 16),

                // 統計概覽
                _buildStatsOverview(),
                const SizedBox(height: 24),

                // 記錄列表
                _buildRecordsList(),
              ],
            ),
          ),
      ],
    );
  }
}