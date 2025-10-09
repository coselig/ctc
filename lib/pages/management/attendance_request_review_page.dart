import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/models.dart'; // 統一匯入所有模型
import '../../services/services.dart'; // 統一匯入所有服務

/// 補打卡審核頁面 - HR/老闆審核申請
class AttendanceRequestReviewPage extends StatefulWidget {
  const AttendanceRequestReviewPage({
    super.key,
    required this.onThemeToggle,
    required this.currentThemeMode,
  });

  final VoidCallback onThemeToggle;
  final ThemeMode currentThemeMode;

  @override
  State<AttendanceRequestReviewPage> createState() => _AttendanceRequestReviewPageState();
}

class _AttendanceRequestReviewPageState extends State<AttendanceRequestReviewPage> {
  final supabase = Supabase.instance.client;
  late final AttendanceLeaveRequestService _requestService;
  late final AttendanceService _attendanceService;
  late final EmployeeService _employeeService;
  late final PermissionService _permissionService;

  List<AttendanceLeaveRequest> _requests = [];
  Employee? _currentEmployee;
  bool _isLoading = true;
  bool _canReview = false;
  int _pendingCount = 0;

  // 篩選條件
  AttendanceRequestStatus? _selectedStatus;
  String? _selectedEmployeeId;
  List<Employee> _allEmployees = [];

  @override
  void initState() {
    super.initState();
    _requestService = AttendanceLeaveRequestService(supabase);
    _attendanceService = AttendanceService(supabase);
    _employeeService = EmployeeService(supabase);
    _permissionService = PermissionService();
    _checkPermissions();
    _loadCurrentEmployee();
    _loadAllEmployees();
    _loadRequests();
  }

  /// 檢查審核權限
  Future<void> _checkPermissions() async {
    try {
      final canReview = await _permissionService.canViewAllAttendance();
      if (mounted) {
        setState(() {
          _canReview = canReview;
        });
        
        if (!canReview) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('您沒有審核權限')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print('檢查權限失敗: $e');
    }
  }

  /// 載入當前員工資料（審核人）
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

  /// 載入所有員工（用於篩選）
  Future<void> _loadAllEmployees() async {
    try {
      final employees = await _employeeService.getAllEmployees();
      if (mounted) {
        setState(() {
          _allEmployees = employees;
        });
      }
    } catch (e) {
      print('載入員工列表失敗: $e');
    }
  }

  /// 載入申請列表
  Future<void> _loadRequests() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final requests = await _requestService.getAllRequests(
        status: _selectedStatus,
        employeeId: _selectedEmployeeId,
      );

      final pendingCount = await _requestService.getPendingRequestCount();

      if (mounted) {
        setState(() {
          _requests = requests;
          _pendingCount = pendingCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入申請列表失敗：$e')),
        );
      }
    }
  }

  /// 審核申請
  Future<void> _reviewRequest(
    AttendanceLeaveRequest request,
    bool approve,
  ) async {
    if (_currentEmployee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('無法取得審核人資料')),
      );
      return;
    }

    // 如果拒絕，要求填寫原因
    String? comment;
    if (!approve) {
      final result = await _showRejectDialog();
      if (result == null || result.isEmpty) {
        return; // 取消拒絕
      }
      comment = result;
    } else {
      // 核准時可選填意見
      comment = await _showApproveDialog();
    }

    try {
      if (approve) {
        await _requestService.approveRequest(
          request.id!,
          _currentEmployee!.id!,
          _currentEmployee!.name,
          comment: comment,
        );

        // 核准後自動補打卡
        bool autoAttendanceSuccess = true;
        try {
          await _createAttendanceRecord(request);
        } catch (e) {
          autoAttendanceSuccess = false;
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                autoAttendanceSuccess ? '✅ 已核准申請並自動補打卡成功' : '✅ 已核准申請（請手動補打卡）',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        await _requestService.rejectRequest(
          request.id!,
          _currentEmployee!.id!,
          _currentEmployee!.name,
          comment: comment!,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('已拒絕申請'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      _loadRequests(); // 重新載入列表
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('審核失敗：$e')),
        );
      }
    }
  }

  /// 創建打卡記錄（核准後）
  Future<void> _createAttendanceRecord(AttendanceLeaveRequest request) async {
    try {
      // 獲取申請人的員工資料
      final employee = await _employeeService.getEmployeeById(
        request.employeeId,
      );
      if (employee == null) {
        throw Exception('找不到員工資料');
      }

      switch (request.requestType) {
        case AttendanceRequestType.checkIn:
          // 補上班打卡
          await _attendanceService.createManualCheckIn(
            employeeId: request.employeeId,
            employeeName: request.employeeName,
            employeeEmail: employee.email ?? '',
            checkInTime: request.requestTime!,
            location: '補打卡申請',
            notes: '補打卡申請已核准\n原因：${request.reason}',
          );
          print('✅ 已自動補上班打卡');
          break;

        case AttendanceRequestType.checkOut:
          // 補下班打卡（可能同時修改上班時間）
          await _attendanceService.createManualCheckOut(
            employeeId: request.employeeId,
            checkOutTime: request.requestTime!,
            checkInTime: request.checkInTime, // 傳入上班時間（如果有提供）
            location: '補打卡申請',
            notes: '補打卡申請已核准\n原因：${request.reason}',
          );
          print('✅ 已自動補下班打卡${request.checkInTime != null ? '（含上班時間修改）' : ''}');
          break;

        case AttendanceRequestType.fullDay:
          // 補整天打卡
          await _attendanceService.createManualFullDayRecord(
            employeeId: request.employeeId,
            employeeName: request.employeeName,
            employeeEmail: employee.email ?? '',
            checkInTime: request.checkInTime!,
            checkOutTime: request.checkOutTime!,
            location: '補打卡申請',
            notes: '補打卡申請已核准\n原因：${request.reason}',
          );
          print('✅ 已自動補整天打卡');
          break;
      }
    } catch (e) {
      print('❌ 自動補打卡失敗: $e');
      // 不拋出錯誤，因為申請已經核准了
      // 顯示警告訊息給審核者
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('申請已核准，但自動補打卡失敗：$e\n請手動到「手動補打卡」頁面補打卡'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: '知道了',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  /// 顯示核准對話框
  Future<String?> _showApproveDialog() async {
    final commentController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('核准申請'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('確定要核准此補打卡申請嗎？'),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              maxLines: 3,
              maxLength: 200,
              decoration: const InputDecoration(
                labelText: '審核意見（選填）',
                hintText: '可以填寫審核意見...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, commentController.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('確認核准'),
          ),
        ],
      ),
    );
  }

  /// 顯示拒絕對話框
  Future<String?> _showRejectDialog() async {
    final reasonController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.red),
            SizedBox(width: 8),
            Text('拒絕申請'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('請填寫拒絕原因：'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              maxLength: 200,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: '拒絕原因（必填）',
                hintText: '請說明拒絕的原因...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('請填寫拒絕原因')),
                );
                return;
              }
              if (reason.length < 5) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('拒絕原因至少需要 5 個字')),
                );
                return;
              }
              Navigator.pop(context, reason);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('確認拒絕'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_canReview) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('補打卡審核'),
            if (_pendingCount > 0)
              Text(
                '待審核：$_pendingCount 筆',
                style: const TextStyle(fontSize: 12, color: Colors.orange),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // 狀態篩選按鈕列
          _buildStatusFilterBar(),
          
          const SizedBox(height: 8),
          
          // 申請列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _requests.isEmpty
                    ? _buildEmptyState()
                    : _buildRequestList(),
          ),
        ],
      ),
    );
  }

  /// 狀態篩選按鈕列
  Widget _buildStatusFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('全部', null),
            const SizedBox(width: 8),
            _buildFilterChip(
              '待審核',
              AttendanceRequestStatus.pending,
              badge: _pendingCount > 0 ? _pendingCount : null,
            ),
            const SizedBox(width: 8),
            _buildFilterChip('已核准', AttendanceRequestStatus.approved),
            const SizedBox(width: 8),
            _buildFilterChip('已拒絕', AttendanceRequestStatus.rejected),
          ],
        ),
      ),
    );
  }

  /// 建立篩選按鈕
  Widget _buildFilterChip(String label, AttendanceRequestStatus? status, {int? badge}) {
    final isSelected = _selectedStatus == status;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (badge != null) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$badge',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = selected ? status : null;
        });
        _loadRequests();
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  /// 顯示篩選對話框
  Future<void> _showFilterDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('篩選條件'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('選擇員工：'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              initialValue: _selectedEmployeeId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '全部員工',
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('全部員工'),
                ),
                ..._allEmployees.map((employee) {
                  return DropdownMenuItem(
                    value: employee.id,
                    child: Text(employee.name),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedEmployeeId = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedEmployeeId = null;
                _selectedStatus = null;
              });
              Navigator.pop(context);
              _loadRequests();
            },
            child: const Text('清除篩選'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadRequests();
            },
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  /// 空狀態視圖
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _selectedStatus == AttendanceRequestStatus.pending
                ? Icons.check_circle_outline
                : Icons.event_busy,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _selectedStatus == AttendanceRequestStatus.pending
                ? '目前沒有待審核的申請'
                : '目前沒有符合條件的申請',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
        ],
      ),
    );
  }

  /// 申請列表
  Widget _buildRequestList() {
    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          return _buildRequestCard(_requests[index]);
        },
      ),
    );
  }

  /// 申請卡片
  Widget _buildRequestCard(AttendanceLeaveRequest request) {
    final isPending = request.status.isPending;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 第一行：員工姓名和狀態
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    request.employeeName.substring(0, 1),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                        request.employeeName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        _getRequestTypeName(request.requestType),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(request.status),
              ],
            ),
            
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            
            // 日期和時間
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  DateFormat('yyyy-MM-dd').format(request.requestDate),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _getRequestTimeText(request),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // 申請原因
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.edit_note, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      request.reason,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            
            // 如果已審核，顯示審核資訊
            if (!isPending) ...[
              const SizedBox(height: 12),
              _buildReviewInfo(request),
            ],
            
            // 如果待審核，顯示審核按鈕
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _reviewRequest(request, false),
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('拒絕'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _reviewRequest(request, true),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('核准'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 取得請假類型名稱
  String _getRequestTypeName(AttendanceRequestType type) {
    switch (type) {
      case AttendanceRequestType.checkIn:
        return '補上班打卡';
      case AttendanceRequestType.checkOut:
        return '補下班打卡';
      case AttendanceRequestType.fullDay:
        return '補整天打卡';
    }
  }

  /// 取得請假時間文字
  String _getRequestTimeText(AttendanceLeaveRequest request) {
    if (request.requestType == AttendanceRequestType.fullDay) {
      final checkIn = DateFormat('HH:mm').format(request.checkInTime!);
      final checkOut = DateFormat('HH:mm').format(request.checkOutTime!);
      return '$checkIn - $checkOut';
    } else {
      return DateFormat('HH:mm').format(request.requestTime!);
    }
  }

  /// 狀態徽章
  Widget _buildStatusBadge(AttendanceRequestStatus status) {
    Color color;
    String text;
    IconData icon;
    
    switch (status) {
      case AttendanceRequestStatus.pending:
        color = Colors.orange;
        text = '待審核';
        icon = Icons.schedule;
        break;
      case AttendanceRequestStatus.approved:
        color = Colors.green;
        text = '已核准';
        icon = Icons.check_circle;
        break;
      case AttendanceRequestStatus.rejected:
        color = Colors.red;
        text = '已拒絕';
        icon = Icons.cancel;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 審核資訊
  Widget _buildReviewInfo(AttendanceLeaveRequest request) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: request.status.isApproved
            ? Colors.green.withOpacity(0.05)
            : Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: request.status.isApproved
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                request.status.isApproved ? Icons.check_circle : Icons.cancel,
                size: 16,
                color: request.status.isApproved ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                '審核人：${request.reviewerName ?? '未知'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '審核時間：${request.reviewedAt != null ? DateFormat('yyyy-MM-dd HH:mm').format(request.reviewedAt!) : '未知'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
          ),
          if (request.reviewComment != null && request.reviewComment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '審核意見：${request.reviewComment}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
