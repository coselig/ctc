import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/models.dart';
import '../../../services/services.dart';
import 'leave_request_form_page.dart';

/// 員工請假記錄頁面
class LeaveRecordPage extends StatefulWidget {
  const LeaveRecordPage({super.key});

  @override
  State<LeaveRecordPage> createState() => _LeaveRecordPageState();
}

class _LeaveRecordPageState extends State<LeaveRecordPage> with SingleTickerProviderStateMixin {
  final _leaveRequestService = LeaveRequestService();
  late TabController _tabController;
  
  bool _isLoading = false;
  List<LeaveRequest> _allRequests = [];
  Map<LeaveType, LeaveBalance> _balances = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 載入資料
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('請先登入');

      final employeeService = EmployeeService(Supabase.instance.client);
      final employee = await employeeService.getEmployeeById(userId);
      if (employee == null || employee.id == null) {
        throw Exception('無法取得員工資料');
      }

      final requests = await _leaveRequestService.getEmployeeLeaveRequests(employee.id!);
      final balances = await _leaveRequestService.getEmployeeLeaveBalances(employee.id!);

      setState(() {
        _allRequests = requests;
        _balances = {for (var b in balances) b.leaveType: b};
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入失敗: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 前往新增請假頁面
  Future<void> _goToAddLeave() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const LeaveRequestFormPage()),
    );
    
    if (result == true) {
      _loadData(); // 重新載入
    }
  }

  /// 取消請假
  Future<void> _cancelRequest(LeaveRequest request) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認取消'),
        content: const Text('確定要取消這個請假申請嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('否'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('是'),
          ),
        ],
      ),
    );

    if (confirm != true || request.id == null) return;

    try {
      await _leaveRequestService.cancelLeaveRequest(request.id!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已取消請假申請'), backgroundColor: Colors.green),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('取消失敗: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('請假記錄'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '請假記錄'),
            Tab(text: '假別額度'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRequestsTab(),
                _buildBalancesTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToAddLeave,
        icon: const Icon(Icons.add),
        label: const Text('申請請假'),
      ),
    );
  }

  /// 請假記錄分頁
  Widget _buildRequestsTab() {
    if (_allRequests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('尚無請假記錄', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _allRequests.length,
        itemBuilder: (context, index) {
          final request = _allRequests[index];
          return _buildRequestCard(request);
        },
      ),
    );
  }

  /// 請假申請卡片
  Widget _buildRequestCard(LeaveRequest request) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    
    Color statusColor;
    IconData statusIcon;
    
    switch (request.status) {
      case LeaveRequestStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case LeaveRequestStatus.approved:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case LeaveRequestStatus.rejected:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case LeaveRequestStatus.cancelled:
        statusColor = Colors.grey;
        statusIcon = Icons.block;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showRequestDetail(request),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      request.leaveType.displayName,
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(statusIcon, color: statusColor, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    request.status.displayName,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${dateFormat.format(request.startDate)} - ${dateFormat.format(request.endDate)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${request.totalDays} 天',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (request.reason.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  request.reason,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (request.status.isPending) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => _cancelRequest(request),
                  icon: const Icon(Icons.cancel, size: 16),
                  label: const Text('取消申請'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 假別額度分頁
  Widget _buildBalancesTab() {
    if (_balances.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('尚未設定假別額度', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: LeaveType.values.length,
        itemBuilder: (context, index) {
          final leaveType = LeaveType.values[index];
          final balance = _balances[leaveType];
          return _buildBalanceCard(leaveType, balance);
        },
      ),
    );
  }

  /// 假別額度卡片
  Widget _buildBalanceCard(LeaveType leaveType, LeaveBalance? balance) {
    final hasBalance = balance != null;
    final totalDays = balance?.totalDays ?? 0;
    final usedDays = balance?.usedDays ?? 0;
    final pendingDays = balance?.pendingDays ?? 0;
    final remainingDays = balance?.remainingDays ?? 0;
    
    final usagePercent = totalDays > 0 ? (usedDays + pendingDays) / totalDays : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  leaveType.displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (hasBalance)
                  Text(
                    '剩餘 $remainingDays 天',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: remainingDays > 0 ? Colors.green[700] : Colors.red[700],
                    ),
                  )
                else
                  const Text(
                    '未設定',
                    style: TextStyle(color: Colors.grey),
                  ),
              ],
            ),
            if (hasBalance) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBalanceItem('總額度', totalDays, Colors.blue),
                  _buildBalanceItem('已使用', usedDays, Colors.red),
                  _buildBalanceItem('審核中', pendingDays, Colors.orange),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: usagePercent.clamp(0.0, 1.0),
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  usagePercent > 0.8 ? Colors.red : Colors.blue,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              leaveType.description,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// 顯示請假詳情
  void _showRequestDetail(LeaveRequest request) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '請假詳情',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              _buildDetailRow('假別', request.leaveType.displayName),
              _buildDetailRow('開始日期', '${dateFormat.format(request.startDate)} (${request.startPeriod.displayName})'),
              _buildDetailRow('結束日期', '${dateFormat.format(request.endDate)} (${request.endPeriod.displayName})'),
              _buildDetailRow('天數', '${request.totalDays} 天'),
              _buildDetailRow('狀態', request.status.displayName),
              _buildDetailRow('申請時間', DateFormat('yyyy-MM-dd HH:mm').format(request.createdAt)),
              const Divider(height: 32),
              const Text('請假原因', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(request.reason),
              if (request.reviewerName != null) ...[
                const Divider(height: 32),
                _buildDetailRow('審核人', request.reviewerName!),
                if (request.reviewComment != null)
                  _buildDetailRow('審核意見', request.reviewComment!),
                if (request.reviewedAt != null)
                  _buildDetailRow('審核時間', DateFormat('yyyy-MM-dd HH:mm').format(request.reviewedAt!)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
