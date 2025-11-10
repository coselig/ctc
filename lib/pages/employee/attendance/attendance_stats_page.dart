import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/models.dart';
import '../../../services/employee/attendance/attendance_service.dart';
import '../../../services/employee/attendance/holiday_service.dart';
import '../../../services/employee/attendance/leave_request_service.dart';
import '../../../services/employee/employee_general_service.dart';
import '../../../widgets/dialogs/month_year_picker.dart';
import 'attendance_request_page.dart';
import 'leave_record_page.dart';

/// 個人出勤中心頁面 - 整合出勤統計、請假記錄和補打卡申請
class AttendanceStatsPage extends StatefulWidget {
  const AttendanceStatsPage({super.key});

  @override
  State<AttendanceStatsPage> createState() => _AttendanceStatsPageState();
}

class _AttendanceStatsPageState extends State<AttendanceStatsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('個人出勤中心'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: '出勤統計'),
            Tab(icon: Icon(Icons.event_available), text: '請假記錄'),
            Tab(icon: Icon(Icons.event_note), text: '補打卡申請'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const AttendanceStatsTab(),
          const LeaveRecordPage(),
          AttendanceRequestPage(
            onThemeToggle: () {}, // 不需要主題切換功能
            currentThemeMode: ThemeMode.system,
          ),
        ],
      ),
    );
  }
}

/// 出勤統計分頁
class AttendanceStatsTab extends StatefulWidget {
  const AttendanceStatsTab({super.key});

  @override
  State<AttendanceStatsTab> createState() => _AttendanceStatsTabState();
}

class _AttendanceStatsTabState extends State<AttendanceStatsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final supabase = Supabase.instance.client;
  late final AttendanceService _attendanceService;
  late final EmployeeService _employeeService;
  late final LeaveRequestService _leaveRequestService;
  late final HolidayService _holidayService;

  Employee? _currentEmployee;
  AttendanceStats? _monthlyStats;
  List<AttendanceRecord> _monthlyRecords = [];
  List<LeaveRequest> _monthlyLeaveRequests = [];
  bool _isLoading = true;

  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _attendanceService = AttendanceService(supabase);
    _employeeService = EmployeeService(supabase);
    _leaveRequestService = LeaveRequestService();
    _holidayService = HolidayService(supabase);
    _initializeHolidays();
    _loadData();
  }

  /// 初始化假日資料
  Future<void> _initializeHolidays() async {
    await _holidayService.loadFromDatabase();
  }

  /// 載入統計資料
  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      // 載入當前用戶的員工資料
      final user = supabase.auth.currentUser;
      if (user != null) {
        // 直接用當前用戶的 ID 查詢自己的員工資料（避免 RLS 權限問題）
        _currentEmployee = await _employeeService.getEmployeeById(user.id);

        if (_currentEmployee?.id != null) {
          await _loadMonthlyData();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('找不到員工資料，請聯絡管理員'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      print('載入資料失敗: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('載入資料失敗: $e')));
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
    final endOfMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
      23,
      59,
      59,
    );

    // 載入月度記錄
    _monthlyRecords = await _attendanceService.getAllAttendanceRecords(
      employeeId: _currentEmployee!.id,
      startDate: startOfMonth,
      endDate: endOfMonth,
    );

    // 載入月度請假記錄（只顯示已核准的）
    _monthlyLeaveRequests = await _leaveRequestService.getEmployeeLeaveRequests(
      _currentEmployee!.id!,
      status: LeaveRequestStatus.approved,
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
    final currentYear = _selectedMonth.year;
    final currentMonth = _selectedMonth.month;

    // 顯示年份和月份選擇對話框
    final result = await showMonthYearPicker(
      context: context,
      initialYear: currentYear,
      initialMonth: currentMonth,
    );

    if (result != null && result != _selectedMonth) {
      setState(() {
        _selectedMonth = result;
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // 根據可用寬度和高度動態調整大小，使用較小的值作為基準
        final cardWidth = constraints.maxWidth;
        final cardHeight = constraints.maxHeight;
        final baseSize = cardWidth < cardHeight ? cardWidth : cardHeight;

        // 調整比例，確保內容不會超出卡片
        final iconSize = (baseSize * 0.20).clamp(16.0, 32.0);
        final valueSize = (baseSize * 0.15).clamp(14.0, 24.0);
        final titleSize = (baseSize * 0.10).clamp(11.0, 14.0);
        final subtitleSize = (baseSize * 0.08).clamp(9.0, 12.0);
        final padding = (baseSize * 0.06).clamp(8.0, 12.0);

        return Card(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: iconSize, color: color),
                SizedBox(height: padding * 0.3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: valueSize,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    maxLines: 1,
                  ),
                ),
                SizedBox(height: padding * 0.2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                  ),
                ),
                SizedBox(height: padding * 0.2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: subtitleSize,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 建構月曆視圖
  Widget _buildCalendarView() {
    // 計算本月第一天是星期幾
    final firstDayOfMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
    );
    // Dart: 1=Monday, 7=Sunday
    // 我們的月曆: 0=Sunday, 1=Monday, ..., 6=Saturday
    // 轉換: weekday==7 -> 0, weekday==1 -> 1, ..., weekday==6 -> 6
    final firstWeekday = firstDayOfMonth.weekday % 7; // 轉換為從週日開始的索引
    final daysInMonth = lastDayOfMonth.day;

    // 建立打卡記錄對應表
    final recordsMap = <int, AttendanceRecord>{};
    for (final record in _monthlyRecords) {
      recordsMap[record.checkInTime.day] = record;
    }

    // 建立請假記錄對應表（一個日期可能對應多筆請假）
    final leaveDaysMap = <int, List<LeaveRequest>>{};
    for (final leave in _monthlyLeaveRequests) {
      // 計算請假期間的所有日期
      for (
        var date = leave.startDate;
        date.isBefore(leave.endDate) || date.isAtSameMomentAs(leave.endDate);
        date = date.add(const Duration(days: 1))
      ) {
        if (date.year == _selectedMonth.year &&
            date.month == _selectedMonth.month) {
          leaveDaysMap.putIfAbsent(date.day, () => []).add(leave);
        }
      }
    }

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
                  '月曆視圖',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLegendItem(Colors.green, '正常'),
                    const SizedBox(width: 8),
                    _buildLegendItem(Colors.orange, '異常'),
                    const SizedBox(width: 8),
                    _buildLegendItem(Colors.pink, '請假'),
                    const SizedBox(width: 8),
                    _buildLegendItem(Colors.red.shade50, '國定假日'),
                    const SizedBox(width: 8),
                    _buildLegendItem(Colors.grey.shade300, '未打卡'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 星期標題
            Row(
              children: ['日', '一', '二', '三', '四', '五', '六'].asMap().entries.map(
                (entry) {
                  final index = entry.key;
                  final day = entry.value;
                  // 週日(index=0)和週六(index=6)用紅色
                  final isWeekend = index == 0 || index == 6;
                  return Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isWeekend ? Colors.red : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
            const SizedBox(height: 8),

            // 日期網格
            ...List.generate((daysInMonth + firstWeekday) ~/ 7 + 1, (
              weekIndex,
            ) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: List.generate(7, (dayIndex) {
                    final dayNumber =
                        weekIndex * 7 + dayIndex + 1 - firstWeekday;

                    if (dayNumber < 1 || dayNumber > daysInMonth) {
                      return const Expanded(child: SizedBox(height: 48));
                    }

                    final date = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month,
                      dayNumber,
                    );
                    final record = recordsMap[dayNumber];
                    final leaveRequests = leaveDaysMap[dayNumber];
                    final isToday =
                        DateTime.now().year == date.year &&
                        DateTime.now().month == date.month &&
                        DateTime.now().day == date.day;

                    // 檢查是否為國定假日
                    final holiday = _holidayService.isHoliday(date);
                    // 檢查是否為週末
                    final isWeekend = date.weekday == 6 || date.weekday == 7;

                    return Expanded(
                      child: _buildCalendarDay(
                        dayNumber,
                        record,
                        leaveRequests,
                        isToday,
                        holiday,
                        isWeekend,
                      ),
                    );
                  }),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 建構日曆日期格子
  Widget _buildCalendarDay(
    int day,
    AttendanceRecord? record,
    List<LeaveRequest>? leaveRequests,
    bool isToday,
    Holiday? holiday,
    bool isWeekend,
  ) {
    Color backgroundColor;
    Color textColor = Colors.black87;
    IconData? icon;

    // 優先顯示國定假日
    if (holiday != null) {
      backgroundColor = Colors.red.shade50;
      textColor = Colors.red;
      icon = Icons.celebration;
    }
    // 其次顯示請假狀態
    else if (leaveRequests != null && leaveRequests.isNotEmpty) {
      backgroundColor = Colors.pink.shade100;
      textColor = Colors.pink.shade900;
      icon = Icons.event_busy;
    } else if (record != null) {
      // 有打卡記錄
      // 標準上班時間 8:30-17:30，寬限時間 ±5 分鐘
      // 上班寬限到 8:35，下班寬限到 17:25
      final isLate =
          record.checkInTime.hour > 8 ||
          (record.checkInTime.hour == 8 && record.checkInTime.minute > 40);
      final isEarlyLeave =
          record.checkOutTime != null &&
          (record.checkOutTime!.hour < 17 ||
              (record.checkOutTime!.hour == 17 &&
                  record.checkOutTime!.minute < 20));
      final isIncomplete = record.checkOutTime == null;

      if (isIncomplete || isLate || isEarlyLeave) {
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade900;
        icon = Icons.warning_amber;
      } else {
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        icon = Icons.check_circle;
      }
    } else {
      // 沒有打卡記錄
      backgroundColor = Colors.grey.shade100;
      textColor = Colors.grey.shade600;
    }

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: isToday ? Border.all(color: Colors.blue, width: 2) : null,
      ),
      child: InkWell(
        onTap: (record != null || leaveRequests != null || holiday != null)
            ? () => _showDayDetail(day, record, leaveRequests, holiday)
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 48,
          child: Stack(
            children: [
              Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                    // 週末或國定假日用紅色，否則用原本的 textColor
                    color:
                        (isWeekend &&
                            holiday == null &&
                            record == null &&
                            leaveRequests == null)
                        ? Colors.red
                        : textColor,
                    fontSize: 16,
                  ),
                ),
              ),
              if (icon != null)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Icon(icon, size: 12, color: textColor),
                ),
              if (record?.isManualEntry == true)
                Positioned(
                  bottom: 2,
                  left: 4,
                  child: Icon(
                    Icons.edit,
                    size: 10,
                    color: textColor.withAlpha(179),
                  ),
                ),
              // 顯示請假數量
              if (leaveRequests != null && leaveRequests.length > 1)
                Positioned(
                  bottom: 2,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: textColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '${leaveRequests.length}',
                      style: TextStyle(
                        color: backgroundColor,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 建構圖例項目
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  /// 顯示日期詳情
  void _showDayDetail(
    int day,
    AttendanceRecord? record,
    List<LeaveRequest>? leaveRequests,
    Holiday? holiday,
  ) {
    final dateStr = '${_selectedMonth.year}年${_selectedMonth.month}月$day日';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dateStr),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 國定假日資訊
              if (holiday != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.celebration,
                        size: 24,
                        color: Colors.red.shade700,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '國定假日',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              holiday.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // 請假資訊
              if (leaveRequests != null && leaveRequests.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.pink.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 20,
                            color: Colors.pink.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '請假記錄',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.pink.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...leaveRequests.map(
                        (leave) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                leave.leaveType.displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_formatDate(leave.startDate)} ${leave.startPeriod.displayName} ~ '
                                '${_formatDate(leave.endDate)} ${leave.endPeriod.displayName}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              Text(
                                '共 ${leave.totalDays} 天',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              if (leave.reason.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '原因：${leave.reason}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // 打卡資訊
              if (record != null) ...[
                if (leaveRequests != null && leaveRequests.isNotEmpty)
                  const Divider(),
                _buildDetailRow(
                  '上班時間',
                  _formatTime(record.checkInTime),
                  Icons.login,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  '下班時間',
                  record.checkOutTime != null
                      ? _formatTime(record.checkOutTime!)
                      : '未打卡',
                  Icons.logout,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  '工作時數',
                  record.calculatedWorkHours != null
                      ? '${record.calculatedWorkHours!.toStringAsFixed(1)}小時'
                      : '--',
                  Icons.access_time,
                ),
                if (record.location != null) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow('打卡地點', record.location!, Icons.location_on),
                ],
                if (record.notes != null) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow('備註', record.notes!, Icons.note),
                ],
                if (record.isManualEntry) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '補打卡記錄',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ] else if (leaveRequests == null || leaveRequests.isEmpty) ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '當日無打卡及請假記錄',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('關閉'),
          ),
        ],
      ),
    );
  }

  /// 建構詳情行
  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
        Expanded(child: Text(value)),
      ],
    );
  }

  /// 建構統計概覽
  Widget _buildStatsOverview() {
    if (_monthlyStats == null) {
      return const SizedBox.shrink();
    }

    final stats = _monthlyStats!;
    final screenWidth = MediaQuery.of(context).size.width;

    // 計算請假總天數
    final totalLeaveDays = _monthlyLeaveRequests.fold<double>(
      0,
      (sum, leave) => sum + leave.totalDays,
    );

    // 根據螢幕寬度動態計算列數
    int crossAxisCount;
    double cardHeight;
    double spacing;

    if (screenWidth > 1200) {
      // 大螢幕：5列（加入請假統計）
      crossAxisCount = 5;
      cardHeight = 140;
      spacing = 16;
    } else if (screenWidth > 800) {
      // 平板：3列
      crossAxisCount = 3;
      cardHeight = 130;
      spacing = 14;
    } else if (screenWidth > 600) {
      // 小平板：2列
      crossAxisCount = 2;
      cardHeight = 120;
      spacing = 12;
    } else {
      // 手機：2列（較小）
      crossAxisCount = 2;
      cardHeight = 110;
      spacing = 10;
    }

    // 計算卡片寬度
    final totalSpacing = spacing * (crossAxisCount - 1);
    final availableWidth = screenWidth - 32 - totalSpacing; // 32 是頁面左右 padding
    final cardWidth = availableWidth / crossAxisCount;
    final childAspectRatio = cardWidth / cardHeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '統計概覽',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: childAspectRatio,
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
            _buildStatCard(
              title: '請假天數',
              value: '${totalLeaveDays.toStringAsFixed(1)}',
              subtitle: '${_monthlyLeaveRequests.length} 筆請假',
              icon: Icons.event_busy,
              color: Colors.pink,
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
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
    final workHoursStr = record.calculatedWorkHours != null
        ? '${record.calculatedWorkHours!.toStringAsFixed(1)}h'
        : '--';

    // 計算是否遲到或早退 (標準上班時間 8:30-17:30，寬限時間 ±5 分鐘)
    // 上班寬限到 8:35，下班寬限到 17:25
    final isLate =
        record.checkInTime.hour > 8 ||
        (record.checkInTime.hour == 8 && record.checkInTime.minute > 40);
    final isEarlyLeave =
        record.checkOutTime != null &&
        (record.checkOutTime!.hour < 17 ||
            (record.checkOutTime!.hour == 17 &&
                record.checkOutTime!.minute < 20));

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: CircleAvatar(
        backgroundColor: record.isCheckedOut
            ? (isLate || isEarlyLeave
                  ? Colors.orange.shade100
                  : Colors.green.shade100)
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
      title: Text(dateStr, style: const TextStyle(fontWeight: FontWeight.w500)),
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
    super.build(context); // 必須調用以支持 AutomaticKeepAliveClientMixin

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentEmployee == null) {
      return const Center(
        child: Text('請先在員工管理中設定您的員工資料', style: TextStyle(fontSize: 16)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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

            // 月曆視圖
            _buildCalendarView(),
            const SizedBox(height: 24),

            // 統計概覽
            _buildStatsOverview(),
            const SizedBox(height: 24),

            // 記錄列表
            _buildRecordsList(),
          ],
        ),
      ),
    );
  }
}
