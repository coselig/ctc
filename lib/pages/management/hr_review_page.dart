import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../widgets/dialogs/month_year_picker.dart';

/// 人事審核頁面 - 整合補打卡審核和請假審核
class HRReviewPage extends StatefulWidget {
  const HRReviewPage({super.key});

  @override
  State<HRReviewPage> createState() => _HRReviewPageState();
}

class _HRReviewPageState extends State<HRReviewPage>
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
        title: const Text('人事管理'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.event_busy), text: '請假審核'),
            Tab(icon: Icon(Icons.edit_calendar), text: '補打卡審核'),
            Tab(icon: Icon(Icons.admin_panel_settings), text: '出勤管理'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          LeaveReviewTab(),
          AttendanceReviewTab(),
          AttendanceManagementTab(),
        ],
      ),
    );
  }
}

/// 請假審核分頁
class LeaveReviewTab extends StatefulWidget {
  const LeaveReviewTab({super.key});

  @override
  State<LeaveReviewTab> createState() => _LeaveReviewTabState();
}

class _LeaveReviewTabState extends State<LeaveReviewTab>
    with AutomaticKeepAliveClientMixin {
  final _leaveRequestService = LeaveRequestService();

  bool _isLoading = false;
  List<LeaveRequest> _pendingRequests = [];
  Employee? _currentReviewer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// 載入資料
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('請先登入');

      final employeeService = EmployeeService(Supabase.instance.client);
      final reviewer = await employeeService.getEmployeeById(userId);

      final requests = await _leaveRequestService.getPendingLeaveRequests();

      if (mounted) {
        setState(() {
          _currentReviewer = reviewer;
          _pendingRequests = requests;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('載入失敗: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 審核請假申請
  Future<void> _reviewRequest(LeaveRequest request, bool approved) async {
    if (_currentReviewer == null || _currentReviewer!.id == null) return;

    // 顯示審核對話框
    final comment = await _showReviewDialog(approved);
    if (comment == null) return; // 用戶取消

    setState(() => _isLoading = true);

    try {
      await _leaveRequestService.reviewLeaveRequest(
        requestId: request.id!,
        reviewerId: _currentReviewer!.id!,
        reviewerName: _currentReviewer!.name,
        approved: approved,
        comment: comment.isEmpty ? null : comment,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approved ? '已核准請假申請' : '已拒絕請假申請'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('審核失敗: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 顯示審核對話框
  Future<String?> _showReviewDialog(bool isApprove) async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isApprove ? '核准請假' : '拒絕請假'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: '審核意見',
                hintText: isApprove ? '選填' : '請說明拒絕原因',
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(isApprove ? '核准' : '拒絕'),
          ),
        ],
      ),
    );
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_pendingRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '目前沒有待審核的請假申請',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingRequests.length,
        itemBuilder: (context, index) {
          final request = _pendingRequests[index];
          return _buildLeaveRequestCard(request);
        },
      ),
    );
  }

  /// 建構請假申請卡片
  Widget _buildLeaveRequestCard(LeaveRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 標題列
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getLeaveTypeColor(request.leaveType),
                  child: Icon(
                    _getLeaveTypeIcon(request.leaveType),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.employeeName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        request.leaveType.displayName,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '待審核',
                    style: TextStyle(
                      color: Colors.orange[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // 請假資訊
            _buildInfoRow(
              Icons.date_range,
              '請假期間',
              '${_formatDate(request.startDate)} ${request.startPeriod.displayName} ~ '
                  '${_formatDate(request.endDate)} ${request.endPeriod.displayName}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.calendar_today,
              '請假天數',
              '${request.totalDays} 天',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.note, '請假原因', request.reason),
            if (request.attachmentUrl != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.attach_file, '證明文件', '已上傳'),
            ],
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.access_time,
              '申請時間',
              DateFormat('yyyy-MM-dd HH:mm').format(request.createdAt),
            ),

            const SizedBox(height: 16),

            // 操作按鈕
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _reviewRequest(request, false),
                    icon: const Icon(Icons.close),
                    label: const Text('拒絕'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _reviewRequest(request, true),
                    icon: const Icon(Icons.check),
                    label: const Text('核准'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
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

  /// 建構資訊列
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(value, style: TextStyle(color: Colors.grey[700])),
        ),
      ],
    );
  }

  /// 取得請假類型顏色
  Color _getLeaveTypeColor(LeaveType type) {
    switch (type) {
      case LeaveType.sick:
        return Colors.red;
      case LeaveType.personal:
        return Colors.blue;
      case LeaveType.annual:
        return Colors.green;
      case LeaveType.parental:
        return Colors.purple;
      case LeaveType.marriage:
        return Colors.pink;
      case LeaveType.bereavement:
        return Colors.grey;
      case LeaveType.official:
        return Colors.orange;
      case LeaveType.maternity:
        return Colors.teal;
      case LeaveType.paternity:
        return Colors.cyan;
      case LeaveType.menstrual:
        return Colors.deepPurple;
    }
  }

  /// 取得請假類型圖示
  IconData _getLeaveTypeIcon(LeaveType type) {
    switch (type) {
      case LeaveType.sick:
        return Icons.medication;
      case LeaveType.personal:
        return Icons.person;
      case LeaveType.annual:
        return Icons.beach_access;
      case LeaveType.parental:
        return Icons.child_care;
      case LeaveType.marriage:
        return Icons.favorite;
      case LeaveType.bereavement:
        return Icons.sentiment_dissatisfied;
      case LeaveType.official:
        return Icons.business;
      case LeaveType.maternity:
        return Icons.pregnant_woman;
      case LeaveType.paternity:
        return Icons.family_restroom;
      case LeaveType.menstrual:
        return Icons.healing;
    }
  }
}

/// 補打卡審核分頁
class AttendanceReviewTab extends StatefulWidget {
  const AttendanceReviewTab({super.key});

  @override
  State<AttendanceReviewTab> createState() => _AttendanceReviewTabState();
}

class _AttendanceReviewTabState extends State<AttendanceReviewTab>
    with AutomaticKeepAliveClientMixin {
  final supabase = Supabase.instance.client;
  late final AttendanceLeaveRequestService _requestService;
  late final EmployeeService _employeeService;

  List<AttendanceLeaveRequest> _requests = [];
  Employee? _currentEmployee;
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _requestService = AttendanceLeaveRequestService(supabase);
    _employeeService = EmployeeService(supabase);
    _loadData();
  }

  /// 載入資料
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // 載入當前員工
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        _currentEmployee = await _employeeService.getEmployeeById(userId);
      }

      // 載入待審核的補打卡申請
      final requests = await _requestService.getAllRequests(
        status: AttendanceRequestStatus.pending,
      );

      if (mounted) {
        setState(() {
          _requests = requests;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('載入失敗: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 審核補打卡申請
  Future<void> _reviewRequest(
    AttendanceLeaveRequest request,
    bool approved,
  ) async {
    if (_currentEmployee == null || _currentEmployee!.id == null) return;

    // 顯示審核對話框
    final comment = await _showReviewDialog(approved);
    if (comment == null) return;

    setState(() => _isLoading = true);

    try {
      if (approved) {
        await _requestService.approveRequest(
          request.id!,
          _currentEmployee!.id!,
          _currentEmployee!.name,
          comment: comment.isEmpty ? null : comment,
        );
      } else {
        await _requestService.rejectRequest(
          request.id!,
          _currentEmployee!.id!,
          _currentEmployee!.name,
          comment: comment.isEmpty ? null : comment,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approved ? '已核准補打卡申請' : '已拒絕補打卡申請'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('審核失敗: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 顯示審核對話框
  Future<String?> _showReviewDialog(bool isApprove) async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isApprove ? '核准補打卡' : '拒絕補打卡'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: '審核意見',
                hintText: isApprove ? '選填' : '請說明拒絕原因',
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(isApprove ? '核准' : '拒絕'),
          ),
        ],
      ),
    );
  }

  /// 格式化日期時間
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '目前沒有待審核的補打卡申請',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final request = _requests[index];
          return _buildAttendanceRequestCard(request);
        },
      ),
    );
  }

  /// 建構補打卡申請卡片
  Widget _buildAttendanceRequestCard(AttendanceLeaveRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 標題列
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.edit_calendar, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.employeeName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '補打卡申請',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '待審核',
                    style: TextStyle(
                      color: Colors.orange[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // 補打卡資訊
            ..._buildAttendanceTimeRows(request),
            _buildInfoRow(Icons.note, '申請原因', request.reason),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.access_time,
              '申請時間',
              _formatDateTime(request.createdAt),
            ),

            const SizedBox(height: 16),

            // 操作按鈕
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _reviewRequest(request, false),
                    icon: const Icon(Icons.close),
                    label: const Text('拒絕'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _reviewRequest(request, true),
                    icon: const Icon(Icons.check),
                    label: const Text('核准'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
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

  /// 建構資訊列
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(value, style: TextStyle(color: Colors.grey[700])),
        ),
      ],
    );
  }

  /// 建立補打卡時間資訊行
  List<Widget> _buildAttendanceTimeRows(AttendanceLeaveRequest request) {
    final List<Widget> rows = [];

    switch (request.requestType) {
      case AttendanceRequestType.fullDay:
        // 補整天：顯示上班和下班時間
        rows.addAll([
          _buildInfoRow(
            Icons.login,
            '上班時間',
            _formatDateTime(request.checkInTime!),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.logout,
            '下班時間',
            _formatDateTime(request.checkOutTime!),
          ),
          const SizedBox(height: 8),
        ]);
        break;

      case AttendanceRequestType.checkOut:
        // 補下班打卡：檢查是否同時修改上班時間
        if (request.checkInTime != null) {
          // 有修改上班時間
          rows.addAll([
            _buildInfoRow(
              Icons.edit,
              '修改上班時間',
              _formatDateTime(request.checkInTime!),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.logout,
              '補下班時間',
              _formatDateTime(request.requestTime!),
            ),
            const SizedBox(height: 8),
          ]);
        } else {
          // 只補下班
          rows.addAll([
            _buildInfoRow(
              Icons.logout,
              '補下班時間',
              _formatDateTime(request.requestTime!),
            ),
            const SizedBox(height: 8),
          ]);
        }
        break;

      case AttendanceRequestType.checkIn:
        // 補上班打卡
        rows.addAll([
          _buildInfoRow(
            Icons.login,
            '補上班時間',
            _formatDateTime(request.requestTime!),
          ),
          const SizedBox(height: 8),
        ]);
        break;
    }

    return rows;
  }
}

/// 出勤管理分頁
class AttendanceManagementTab extends StatefulWidget {
  const AttendanceManagementTab({super.key});

  @override
  State<AttendanceManagementTab> createState() =>
      _AttendanceManagementTabState();
}

class _AttendanceManagementTabState extends State<AttendanceManagementTab>
    with AutomaticKeepAliveClientMixin {
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
  bool get wantKeepAlive => true;

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
      final startOfMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month,
        1,
      );
      final endOfMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        0,
        23,
        59,
        59,
      );

      // 載入每個員工的記錄和統計
      _employeeRecords.clear();
      _employeeStats.clear();

      for (final employee in _allEmployees) {
        if (employee.id != null) {
          final records = await _attendanceService.getAllAttendanceRecords(
            employeeId: employee.id!,
            startDate: startOfMonth,
            endDate: endOfMonth,
          );
          _employeeRecords[employee.id!] = records;

          final stats = await _attendanceService.getAttendanceStats(
            employeeId: employee.id!,
            startDate: startOfMonth,
            endDate: endOfMonth,
          );
          _employeeStats[employee.id!] = stats;
        }
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
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

  /// 匯出所有員工打卡記錄
  Future<void> _exportAllRecords() async {
    try {
      setState(() => _isExporting = true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('正在準備匯出資料...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      final startOfMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month,
        1,
      );
      final endOfMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        0,
        23,
        59,
        59,
      );

      await _excelExportService.exportAllAttendanceRecords(
        startDate: startOfMonth,
        endDate: endOfMonth,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('匯出成功！檔案已儲存到下載資料夾'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('匯出失敗: $e'), backgroundColor: Colors.red),
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

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        // 頂部工具列
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).cardColor,
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _selectMonth,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month),
                        const SizedBox(width: 8),
                        Text(_formatMonth(_selectedMonth)),
                        const Spacer(),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _isExporting ? null : _exportAllRecords,
                icon: _isExporting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download),
                label: Text(_isExporting ? '匯出中...' : '匯出 Excel'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 統計概覽
        if (!_isLoading && _allEmployees.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            child: _buildStatsOverview(),
          ),

        // 員工列表
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _allEmployees.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '暫無員工資料',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _allEmployees.length,
                    itemBuilder: (context, index) {
                      final employee = _allEmployees[index];
                      return _buildEmployeeCard(employee);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  /// 建構統計概覽
  Widget _buildStatsOverview() {
    int totalWorkDays = 0;
    double totalHours = 0;
    int totalEmployees = _allEmployees.length;

    for (final stats in _employeeStats.values) {
      totalWorkDays += stats.workDays;
      totalHours += stats.totalHours;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '統計概覽',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '總員工數',
                    '$totalEmployees',
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '總出勤天數',
                    '$totalWorkDays',
                    Icons.calendar_today,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '總工時',
                    '${totalHours.toStringAsFixed(1)}h',
                    Icons.access_time,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 建構統計項目
  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  /// 建構員工卡片
  Widget _buildEmployeeCard(Employee employee) {
    final records = _employeeRecords[employee.id] ?? [];
    final stats = _employeeStats[employee.id];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            employee.name.isNotEmpty ? employee.name[0] : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          employee.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: stats != null
            ? Text(
                '出勤 ${stats.workDays} 天 • 工時 ${stats.totalHours.toStringAsFixed(1)}h • '
                '出勤率 ${stats.attendanceRate.toStringAsFixed(1)}%',
              )
            : const Text('暫無資料'),
        children: [
          if (records.isEmpty)
            const Padding(padding: EdgeInsets.all(16), child: Text('本月暫無打卡記錄'))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return _buildRecordListTile(record);
              },
            ),
        ],
      ),
    );
  }

  /// 建構記錄列表項
  Widget _buildRecordListTile(AttendanceRecord record) {
    final dateStr = DateFormat('MM/dd').format(record.checkInTime);
    final checkInStr = DateFormat('HH:mm').format(record.checkInTime);
    final checkOutStr = record.checkOutTime != null
        ? DateFormat('HH:mm').format(record.checkOutTime!)
        : '--:--';
    final workHoursStr = record.calculatedWorkHours != null
        ? '${record.calculatedWorkHours!.toStringAsFixed(1)}h'
        : '--';

    return ListTile(
      dense: true,
      leading: Text(
        dateStr,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      title: Text('$checkInStr ~ $checkOutStr'),
      trailing: Text(
        workHoursStr,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
