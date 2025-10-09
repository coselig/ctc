import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/models.dart';
import '../../services/services.dart';

/// HR/老闆請假審核頁面
class LeaveRequestReviewPage extends StatefulWidget {
  const LeaveRequestReviewPage({super.key});

  @override
  State<LeaveRequestReviewPage> createState() => _LeaveRequestReviewPageState();
}

class _LeaveRequestReviewPageState extends State<LeaveRequestReviewPage> {
  final _leaveRequestService = LeaveRequestService();
  
  bool _isLoading = false;
  List<LeaveRequest> _pendingRequests = [];
  Employee? _currentReviewer;

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

      setState(() {
        _currentReviewer = reviewer;
        _pendingRequests = requests;
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
      setState(() => _isLoading = false);
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
            Text(isApprove ? '確定要核准這個請假申請嗎？' : '確定要拒絕這個請假申請嗎？'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: isApprove ? '審核意見（選填）' : '拒絕原因（建議填寫）',
                border: const OutlineInputBorder(),
                hintText: '請輸入審核意見...',
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
            ),
            child: Text(isApprove ? '確認核准' : '確認拒絕'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('請假審核'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingRequests.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _pendingRequests.length,
                    itemBuilder: (context, index) {
                      return _buildRequestCard(_pendingRequests[index]);
                    },
                  ),
                ),
    );
  }

  /// 空狀態
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '目前沒有待審核的請假申請',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  /// 請假申請卡片
  Widget _buildRequestCard(LeaveRequest request) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 標題列
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    request.employeeName[0],
                    style: TextStyle(
                      color: Colors.blue[700],
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          request.leaveType.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pending, size: 16, color: Colors.orange[700]),
                      const SizedBox(width: 4),
                      Text(
                        '待審核',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            
            // 請假資訊
            _buildInfoRow(
              Icons.calendar_today,
              '請假日期',
              '${dateFormat.format(request.startDate)} - ${dateFormat.format(request.endDate)}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.access_time,
              '請假時段',
              '${request.startPeriod.displayName} - ${request.endPeriod.displayName}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.event_note,
              '請假天數',
              '${request.totalDays} 天',
              valueStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.description,
              '請假原因',
              request.reason,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.schedule,
              '申請時間',
              DateFormat('yyyy-MM-dd HH:mm').format(request.createdAt),
            ),
            
            const Divider(height: 24),
            
            // 審核按鈕
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _reviewRequest(request, false),
                    icon: const Icon(Icons.cancel),
                    label: const Text('拒絕'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _reviewRequest(request, true),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('核准'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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

  /// 資訊列
  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    TextStyle? valueStyle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: valueStyle ??
                const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}
