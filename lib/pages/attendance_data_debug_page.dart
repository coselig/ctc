import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';
import '../services/attendance_service.dart';
import '../services/employee_service.dart';
import '../widgets/general_page.dart';

/// 打卡資料調試頁面
class AttendanceDataDebugPage extends StatefulWidget {
  const AttendanceDataDebugPage({super.key});

  @override
  State<AttendanceDataDebugPage> createState() => _AttendanceDataDebugPageState();
}

class _AttendanceDataDebugPageState extends State<AttendanceDataDebugPage> {
  final supabase = Supabase.instance.client;
  late final AttendanceService _attendanceService;
  late final EmployeeService _employeeService;

  List<Employee> _employees = [];
  List<AttendanceRecord> _records = [];
  bool _isLoading = true;
  String _debugInfo = '';

  @override
  void initState() {
    super.initState();
    _attendanceService = AttendanceService(supabase);
    _employeeService = EmployeeService(supabase);
    _loadDebugData();
  }

  Future<void> _loadDebugData() async {
    setState(() {
      _isLoading = true;
      _debugInfo = '正在載入資料...\n';
    });

    try {
      // 獲取員工
      _employees = await _employeeService.getAllEmployees();
      _debugInfo += '✓ 找到 ${_employees.length} 位員工\n';
      
      for (var emp in _employees) {
        _debugInfo += '  - ${emp.name} (ID: ${emp.id})\n';
      }
      _debugInfo += '\n';

      // 獲取所有打卡記錄
      _records = await _attendanceService.getAllAttendanceRecords();
      _debugInfo += '✓ 找到 ${_records.length} 筆打卡記錄\n\n';

      // 按員工統計
      final recordsByEmployee = <String, List<AttendanceRecord>>{};
      for (var record in _records) {
        if (!recordsByEmployee.containsKey(record.employeeId)) {
          recordsByEmployee[record.employeeId] = [];
        }
        recordsByEmployee[record.employeeId]!.add(record);
      }

      _debugInfo += '各員工打卡記錄:\n';
      for (var emp in _employees) {
        final empRecords = recordsByEmployee[emp.id] ?? [];
        _debugInfo += '  ${emp.name}: ${empRecords.length} 筆\n';
        
        if (empRecords.isNotEmpty) {
          for (var record in empRecords.take(3)) {
            _debugInfo += '    - ${_formatDateTime(record.checkInTime)}';
            if (record.checkOutTime != null) {
              _debugInfo += ' → ${_formatDateTime(record.checkOutTime!)}';
              _debugInfo += ' (${record.workHours?.toStringAsFixed(1)}h)';
            } else {
              _debugInfo += ' (未打下班卡)';
            }
            _debugInfo += '\n';
          }
          if (empRecords.length > 3) {
            _debugInfo += '    ... 還有 ${empRecords.length - 3} 筆\n';
          }
        }
      }

      // 檢查資料庫直接查詢
      _debugInfo += '\n直接查詢資料庫:\n';
      try {
        final directQuery = await supabase
            .from('attendance_records')
            .select('*')
            .limit(5);
        _debugInfo += '✓ 資料庫查詢成功，返回 ${directQuery.length} 筆記錄\n';
      } catch (e) {
        _debugInfo += '❌ 資料庫查詢失敗: $e\n';
      }

    } catch (e) {
      _debugInfo += '\n❌ 錯誤: $e\n';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} '
           '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GeneralPage(
      title: '打卡資料調試',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadDebugData,
          tooltip: '重新載入',
        ),
      ],
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.bug_report, color: Theme.of(context).primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            '資料診斷報告',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: SelectableText(
                            _debugInfo,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 統計卡片
              if (!_isLoading)
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        color: Colors.blue.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                '${_employees.length}',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              const Text('員工總數'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        color: Colors.green.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                '${_records.length}',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              const Text('打卡記錄'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
