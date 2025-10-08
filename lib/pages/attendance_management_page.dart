import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';
import '../services/attendance_service.dart';
import '../services/employee_service.dart';
import '../services/excel_export_service.dart';
import '../widgets/general_page.dart';

/// 出勤管理頁面（管理員使用）
class AttendanceManagementPage extends StatefulWidget {
  const AttendanceManagementPage({super.key});

  @override
  State<AttendanceManagementPage> createState() => _AttendanceManagementPageState();
}

class _AttendanceManagementPageState extends State<AttendanceManagementPage> {
  final supabase = Supabase.instance.client;
  late final AttendanceService _attendanceService;
  late final EmployeeService _employeeService;
  late final ExcelExportService _excelExportService;

  List<Employee> _allEmployees = [];
  Map<String, List<AttendanceRecord>> _employeeRecords = {};
  Map<String, AttendanceStats> _employeeStats = {};
  bool _isLoading = true;
  bool _isExporting = false;

  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _attendanceService = AttendanceService(supabase);
    _employeeService = EmployeeService(supabase);
    _excelExportService = ExcelExportService(supabase);
    _loadData();
  }

  /// 載入所有資料
  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      // 載入所有員工
      _allEmployees = await _employeeService.getAllEmployees();

      // 計算月度範圍
      final startOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      final endOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59);

      // 載入每個員工的記錄和統計
      _employeeRecords.clear();
      _employeeStats.clear();

      for (final employee in _allEmployees) {
        if (employee.id != null) {
          // 載入記錄
          final records = await _attendanceService.getAllAttendanceRecords(
            employeeId: employee.id!,
            startDate: startOfMonth,
            endDate: endOfMonth,
          );
          _employeeRecords[employee.id!] = records;

          // 載入統計
          final stats = await _attendanceService.getAttendanceStats(
            employeeId: employee.id!,
            startDate: startOfMonth,
            endDate: endOfMonth,
          );
          _employeeStats[employee.id!] = stats;
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

  /// 匯出所有員工打卡記錄
  Future<void> _exportAllRecords() async {
    try {
      setState(() => _isExporting = true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('正在準備匯出資料...'),
          duration: Duration(seconds: 2),
        ),
      );

      // 計算日期範圍
      final startOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      final endOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59);

      await _excelExportService.exportAllAttendanceRecords(
        startDate: startOfMonth,
        endDate: endOfMonth,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Excel 檔案已下載'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('匯出失敗: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  /// 匯出所有歷史記錄（不限日期）
  Future<void> _exportAllHistoryRecords() async {
    try {
      setState(() => _isExporting = true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('正在準備匯出所有歷史資料...'),
          duration: Duration(seconds: 2),
        ),
      );

      await _excelExportService.exportAllAttendanceRecords();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Excel 檔案已下載'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('匯出失敗: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
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

  /// 建構匯出功能區域
  Widget _buildExportSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.file_download, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  '資料匯出',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Text(
              '匯出所有員工的出勤資料為 Excel 檔案',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            
            // 匯出當月記錄按鈕
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isExporting ? null : _exportAllRecords,
                icon: _isExporting 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download),
                label: Text('匯出 ${_formatMonth(_selectedMonth)} 資料'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // 匯出所有歷史記錄按鈕
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isExporting ? null : _exportAllHistoryRecords,
                icon: _isExporting 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.history),
                label: const Text('匯出所有歷史資料'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 說明文字
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Excel 檔案包含：打卡記錄、統計摘要、員工列表三個工作表',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 建構統計卡片
  Widget _buildStatCard({
    required String title,
    required String value,
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
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 建構統計概覽
  Widget _buildOverviewSection() {
    // 計算總統計
    int totalWorkDays = 0;
    double totalHours = 0;
    int totalRecords = 0;

    for (final stats in _employeeStats.values) {
      totalWorkDays += stats.workDays;
      totalHours += stats.totalHours;
    }

    for (final records in _employeeRecords.values) {
      totalRecords += records.length;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '本月概覽',
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
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  title: '員工總數',
                  value: '${_allEmployees.length}',
                  icon: Icons.people,
                  color: Colors.blue,
                ),
                _buildStatCard(
                  title: '打卡記錄',
                  value: '$totalRecords',
                  icon: Icons.event_note,
                  color: Colors.green,
                ),
                _buildStatCard(
                  title: '總出勤天數',
                  value: '$totalWorkDays',
                  icon: Icons.calendar_today,
                  color: Colors.orange,
                ),
                _buildStatCard(
                  title: '總工時',
                  value: '${totalHours.toStringAsFixed(0)}h',
                  icon: Icons.access_time,
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 建構員工列表
  Widget _buildEmployeeList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '員工出勤詳情',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (_allEmployees.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('暫無員工資料'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _allEmployees.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final employee = _allEmployees[index];
                  final records = _employeeRecords[employee.id] ?? [];
                  final stats = _employeeStats[employee.id];
                  
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(employee.name[0]),
                    ),
                    title: Text(employee.name),
                    subtitle: Text(
                      '${employee.department} - ${employee.position}\n'
                      '打卡 ${records.length} 次 | '
                      '工時 ${stats?.totalHours.toStringAsFixed(1) ?? '0.0'}h',
                    ),
                    isThreeLine: true,
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${stats?.workDays ?? 0} 天',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '出勤率 ${stats?.attendanceRate.toStringAsFixed(0) ?? '0'}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GeneralPage(
      title: '出勤管理',
      actions: [
        IconButton(
          icon: const Icon(Icons.date_range),
          onPressed: _selectMonth,
          tooltip: '選擇月份',
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadData,
          tooltip: '重新整理',
        ),
      ],
      children: [
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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

                  // 匯出功能區域
                  _buildExportSection(),
                  const SizedBox(height: 16),

                  // 統計概覽
                  _buildOverviewSection(),
                  const SizedBox(height: 16),

                  // 員工列表
                  _buildEmployeeList(),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
