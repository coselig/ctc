import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/attendance_leave_request.dart';
import '../../../services/employee/attendance/attendance_leave_request_service.dart';
import '../../../services/general/permission_service.dart';
import 'attendance_request_form_page.dart';

/// 補打卡申請頁面 - 顯示我的申請列表
class AttendanceRequestPage extends StatefulWidget {
  const AttendanceRequestPage({
    super.key,
    required this.onThemeToggle,
    required this.currentThemeMode,
  });

  final VoidCallback onThemeToggle;
  final ThemeMode currentThemeMode;

  @override
  State<AttendanceRequestPage> createState() => _AttendanceRequestPageState();
}

class _AttendanceRequestPageState extends State<AttendanceRequestPage> {
  final supabase = Supabase.instance.client;
  late final AttendanceLeaveRequestService _requestService;
  late final PermissionService _permissionService;

  List<AttendanceLeaveRequest> _requests = [];
  bool _isLoading = true;
  AttendanceRequestStatus? _selectedStatus; // 篩選狀態
  bool _canManageRequests = false; // 是否可管理所有申請 (HR/Boss)

  @override
  void initState() {
    super.initState();
    _requestService = AttendanceLeaveRequestService(supabase);
    _permissionService = PermissionService();
    _checkPermissions();
    _loadRequests();
  }

  /// 檢查權限
  Future<void> _checkPermissions() async {
    try {
      final canManage = await _permissionService.canViewAllAttendance();
      if (mounted) {
        setState(() {
          _canManageRequests = canManage;
        });
      }
    } catch (e) {
      print('檢查權限失敗: $e');
    }
  }

  /// 載入申請列表
  Future<void> _loadRequests() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final List<AttendanceLeaveRequest> requests;
      
      if (_canManageRequests) {
        // HR/Boss 可查看所有申請
        requests = await _requestService.getAllRequests(
          status: _selectedStatus,
        );
      } else {
        // 一般員工只查看自己的申請
        requests = await _requestService.getMyRequests(
          status: _selectedStatus,
        );
      }

      if (mounted) {
        setState(() {
          _requests = requests;
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

  /// 刪除申請
  Future<void> _deleteRequest(String requestId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: const Text('確定要刪除此補打卡申請嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('刪除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _requestService.deleteRequest(requestId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已刪除申請')),
        );
        _loadRequests(); // 重新載入列表
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('刪除失敗：$e')),
        );
      }
    }
  }

  /// 導航到新增/編輯表單
  Future<void> _navigateToForm([AttendanceLeaveRequest? request]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendanceRequestFormPage(
          onThemeToggle: widget.onThemeToggle,
          currentThemeMode: widget.currentThemeMode,
          request: request, // null 表示新增，有值表示編輯
        ),
      ),
    );

    // 如果有返回結果，重新載入列表
    if (result == true) {
      _loadRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的補打卡申請'),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(),
        icon: const Icon(Icons.add),
        label: const Text('新增申請'),
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
            _buildFilterChip('待審核', AttendanceRequestStatus.pending),
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
  Widget _buildFilterChip(String label, AttendanceRequestStatus? status) {
    final isSelected = _selectedStatus == status;
    return FilterChip(
      label: Text(label),
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

  /// 空狀態視圖
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '尚無補打卡申請',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '點擊下方按鈕新增補打卡申請',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // 只有待審核的可以編輯
          if (request.status.isPending) {
            _navigateToForm(request);
          } else {
            _showRequestDetail(request);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 第一行：類型和狀態
              Row(
                children: [
                  _buildRequestTypeIcon(request.requestType),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getRequestTypeName(request.requestType),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  _buildStatusBadge(request.status),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 如果是管理員視角，顯示員工姓名
              if (_canManageRequests) ...[
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      request.employeeName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.edit_note, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      request.reason,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              // 如果已審核，顯示審核資訊
              if (!request.status.isPending) ...[
                const Divider(height: 24),
                _buildReviewInfo(request),
              ],
              
              // 如果是待審核且是自己的申請，顯示操作按鈕
              if (request.status.isPending && !_canManageRequests) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _navigateToForm(request),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('編輯'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _deleteRequest(request.id!),
                      icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                      label: const Text('刪除', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 請假類型圖示
  Widget _buildRequestTypeIcon(AttendanceRequestType type) {
    IconData icon;
    Color color;
    
    switch (type) {
      case AttendanceRequestType.checkIn:
        icon = Icons.login;
        color = Colors.green;
        break;
      case AttendanceRequestType.checkOut:
        icon = Icons.logout;
        color = Colors.orange;
        break;
      case AttendanceRequestType.fullDay:
        icon = Icons.event_available;
        color = Colors.blue;
        break;
    }
    
    return Icon(icon, color: color, size: 24);
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
    switch (request.requestType) {
      case AttendanceRequestType.fullDay:
        // 補整天：顯示上班時間 - 下班時間
        final checkIn = DateFormat('HH:mm').format(request.checkInTime!);
        final checkOut = DateFormat('HH:mm').format(request.checkOutTime!);
        return '$checkIn - $checkOut';
        
      case AttendanceRequestType.checkOut:
        // 補下班打卡：檢查是否同時修改上班時間
        if (request.checkInTime != null) {
          // 有修改上班時間：顯示修改的上班時間 - 下班時間
          final checkIn = DateFormat('HH:mm').format(request.checkInTime!);
          final checkOut = DateFormat('HH:mm').format(request.requestTime!);
          return '$checkIn - $checkOut';
        } else {
          // 只補下班：顯示下班時間
          return '下班: ${DateFormat('HH:mm').format(request.requestTime!)}';
        }

      case AttendanceRequestType.checkIn:
        // 補上班打卡：只顯示上班時間
        return '上班: ${DateFormat('HH:mm').format(request.requestTime!)}';
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
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(125)),
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
            ? Colors.green.withAlpha(15)
            : Colors.red.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
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

  /// 顯示申請詳情對話框（用於已審核的申請）
  void _showRequestDetail(AttendanceLeaveRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getRequestTypeName(request.requestType)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_canManageRequests) ...[
                _buildDetailRow('申請人', request.employeeName),
                const SizedBox(height: 8),
              ],
              _buildDetailRow('日期', DateFormat('yyyy-MM-dd').format(request.requestDate)),
              const SizedBox(height: 8),
              ..._buildTimeDetailsRows(request),
              const SizedBox(height: 8),
              _buildDetailRow('原因', request.reason),
              const Divider(height: 24),
              _buildDetailRow('狀態', request.status.isApproved ? '已核准' : '已拒絕'),
              const SizedBox(height: 8),
              _buildDetailRow('審核人', request.reviewerName ?? '未知'),
              const SizedBox(height: 8),
              _buildDetailRow(
                '審核時間',
                request.reviewedAt != null
                    ? DateFormat('yyyy-MM-dd HH:mm').format(request.reviewedAt!)
                    : '未知',
              ),
              if (request.reviewComment != null && request.reviewComment!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDetailRow('審核意見', request.reviewComment!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('關閉'),
          ),
        ],
      ),
    );
  }

  /// 建立時間詳情行列
  List<Widget> _buildTimeDetailsRows(AttendanceLeaveRequest request) {
    final List<Widget> rows = [];

    switch (request.requestType) {
      case AttendanceRequestType.fullDay:
        // 補整天：顯示上班和下班時間
        rows.addAll([
          _buildDetailRow(
            '上班時間',
            DateFormat('HH:mm').format(request.checkInTime!),
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            '下班時間',
            DateFormat('HH:mm').format(request.checkOutTime!),
          ),
        ]);
        break;

      case AttendanceRequestType.checkOut:
        // 補下班打卡：檢查是否同時修改上班時間
        if (request.checkInTime != null) {
          // 有修改上班時間
          rows.addAll([
            _buildDetailRow(
              '修改上班時間',
              DateFormat('HH:mm').format(request.checkInTime!),
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              '補下班時間',
              DateFormat('HH:mm').format(request.requestTime!),
            ),
          ]);
        } else {
          // 只補下班
          rows.add(
            _buildDetailRow(
              '補下班時間',
              DateFormat('HH:mm').format(request.requestTime!),
            ),
          );
        }
        break;

      case AttendanceRequestType.checkIn:
        // 補上班打卡
        rows.add(
          _buildDetailRow(
            '補上班時間',
            DateFormat('HH:mm').format(request.requestTime!),
          ),
        );
        break;
    }

    return rows;
  }

  /// 詳情行
  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
