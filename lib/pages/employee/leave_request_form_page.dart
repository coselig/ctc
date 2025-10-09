import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/models.dart';
import '../../services/services.dart';

/// 員工請假申請表單頁面
class LeaveRequestFormPage extends StatefulWidget {
  const LeaveRequestFormPage({super.key});

  @override
  State<LeaveRequestFormPage> createState() => _LeaveRequestFormPageState();
}

class _LeaveRequestFormPageState extends State<LeaveRequestFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _leaveRequestService = LeaveRequestService();
  final _employeeService = EmployeeService(Supabase.instance.client);
  
  bool _isLoading = false;
  Employee? _currentEmployee;
  
  // 表單欄位
  LeaveType _selectedLeaveType = LeaveType.personal;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  LeavePeriod _startPeriod = LeavePeriod.fullDay;
  LeavePeriod _endPeriod = LeavePeriod.fullDay;
  final _reasonController = TextEditingController();
  double _calculatedDays = 1.0;
  
  // 假別額度
  Map<LeaveType, LeaveBalance> _balances = {};

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
    _calculateLeaveDays();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  /// 載入當前員工資料和假別額度
  Future<void> _loadEmployeeData() async {
    setState(() => _isLoading = true);
    
    try {
      // 取得當前登入使用者的 ID
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('請先登入');
      }
      
      // 使用 userId 取得員工資料
      final employee = await _employeeService.getEmployeeById(userId);
      if (employee == null) {
        throw Exception('無法取得員工資料');
      }
      
      setState(() => _currentEmployee = employee);
      
      await _loadLeaveBalances();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入資料失敗: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 載入假別額度
  Future<void> _loadLeaveBalances() async {
    if (_currentEmployee == null || _currentEmployee!.id == null) return;
    
    try {
      final balances = await _leaveRequestService.getEmployeeLeaveBalances(
        _currentEmployee!.id!,
      );
      
      setState(() {
        _balances = {
          for (var balance in balances) balance.leaveType: balance
        };
      });
    } catch (e) {
      debugPrint('載入假別額度失敗: $e');
    }
  }

  /// 計算請假天數
  void _calculateLeaveDays() {
    setState(() {
      _calculatedDays = LeaveRequest.calculateLeaveDays(
        startDate: _startDate,
        endDate: _endDate,
        startPeriod: _startPeriod,
        endPeriod: _endPeriod,
      );
    });
  }

  /// 選擇開始日期
  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked;
        // 確保結束日期不早於開始日期
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      });
      _calculateLeaveDays();
    }
  }

  /// 選擇結束日期
  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() => _endDate = picked);
      _calculateLeaveDays();
    }
  }

  /// 提交請假申請
  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentEmployee == null) return;

    // 檢查假別額度
    final balance = _balances[_selectedLeaveType];
    if (balance != null && balance.remainingDays < _calculatedDays) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '假別額度不足！剩餘 ${balance.remainingDays} 天，需要 $_calculatedDays 天',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = LeaveRequest(
        employeeId: _currentEmployee!.id!,
        employeeName: _currentEmployee!.name,
        leaveType: _selectedLeaveType,
        startDate: _startDate,
        endDate: _endDate,
        startPeriod: _startPeriod,
        endPeriod: _endPeriod,
        totalDays: _calculatedDays,
        reason: _reasonController.text.trim(),
      );

      // 除錯：印出要送出的資料
      debugPrint('準備提交請假申請: ${request.toJsonForInsert()}');
      
      await _leaveRequestService.createLeaveRequest(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('請假申請已提交，等待審核'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // 返回並刷新
      }
    } catch (e, stackTrace) {
      debugPrint('提交請假申請失敗: $e');
      debugPrint('Stack trace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('提交失敗: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('請假申請'),
        elevation: 0,
      ),
      body: _isLoading && _currentEmployee == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 假別選擇
                    _buildLeaveTypeSection(),
                    const SizedBox(height: 24),
                    
                    // 日期選擇
                    _buildDateSection(),
                    const SizedBox(height: 24),
                    
                    // 時段選擇
                    _buildPeriodSection(),
                    const SizedBox(height: 24),
                    
                    // 計算天數顯示
                    _buildCalculatedDaysCard(),
                    const SizedBox(height: 24),
                    
                    // 請假原因
                    _buildReasonSection(),
                    const SizedBox(height: 24),
                    
                    // 假別額度提示
                    if (_balances.containsKey(_selectedLeaveType))
                      _buildBalanceInfo(),
                    const SizedBox(height: 24),
                    
                    // 提交按鈕
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
    );
  }

  /// 假別選擇區塊
  Widget _buildLeaveTypeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '假別類型',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<LeaveType>(
              initialValue: _selectedLeaveType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: LeaveType.values.map((type) {
                final balance = _balances[type];
                final balanceText = balance != null 
                    ? ' (剩餘 ${balance.remainingDays} 天)'
                    : '';
                
                return DropdownMenuItem(
                  value: type,
                  child: Text('${type.displayName}$balanceText'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedLeaveType = value);
                }
              },
            ),
            const SizedBox(height: 8),
            Text(
              _selectedLeaveType.description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (_selectedLeaveType.requiresDocument)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.orange[700]),
                    const SizedBox(width: 4),
                    Text(
                      '此假別需要提供證明文件',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[700],
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

  /// 日期選擇區塊
  Widget _buildDateSection() {
    final dateFormat = DateFormat('yyyy-MM-dd (E)', 'zh_TW');
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '請假日期',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectStartDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '開始日期',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(dateFormat.format(_startDate)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _selectEndDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '結束日期',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(dateFormat.format(_endDate)),
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

  /// 時段選擇區塊
  Widget _buildPeriodSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '請假時段',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<LeavePeriod>(
                    initialValue: _startPeriod,
                    decoration: const InputDecoration(
                      labelText: '開始時段',
                      border: OutlineInputBorder(),
                    ),
                    items: LeavePeriod.values.map((period) {
                      return DropdownMenuItem(
                        value: period,
                        child: Text(period.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _startPeriod = value);
                        _calculateLeaveDays();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<LeavePeriod>(
                    initialValue: _endPeriod,
                    decoration: const InputDecoration(
                      labelText: '結束時段',
                      border: OutlineInputBorder(),
                    ),
                    items: LeavePeriod.values.map((period) {
                      return DropdownMenuItem(
                        value: period,
                        child: Text(period.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _endPeriod = value);
                        _calculateLeaveDays();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 計算天數顯示卡片
  Widget _buildCalculatedDaysCard() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.calculate, color: Colors.blue[700], size: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '請假天數',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  '$_calculatedDays 天',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 請假原因區塊
  Widget _buildReasonSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '請假原因',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(
                hintText: '請說明請假原因...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '請填寫請假原因';
                }
                if (value.trim().length < 5) {
                  return '請假原因至少需要 5 個字';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 假別額度資訊
  Widget _buildBalanceInfo() {
    final balance = _balances[_selectedLeaveType];
    if (balance == null) return const SizedBox.shrink();

    final isEnough = balance.remainingDays >= _calculatedDays;
    final color = isEnough ? Colors.green : Colors.red;

    return Card(
      color: color[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isEnough ? Icons.check_circle : Icons.warning,
                  color: color[700],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_selectedLeaveType.displayName}額度',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBalanceItem('總額度', balance.totalDays),
                _buildBalanceItem('已使用', balance.usedDays),
                _buildBalanceItem('審核中', balance.pendingDays),
                _buildBalanceItem('剩餘', balance.remainingDays, highlight: true),
              ],
            ),
            if (!isEnough) ...[
              const SizedBox(height: 8),
              Text(
                '⚠️ 額度不足！需要 $_calculatedDays 天，剩餘 ${balance.remainingDays} 天',
                style: TextStyle(
                  fontSize: 12,
                  color: color[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem(String label, double value, {bool highlight = false}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: TextStyle(
            fontSize: highlight ? 18 : 16,
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            color: highlight ? Colors.blue[700] : Colors.black87,
          ),
        ),
      ],
    );
  }

  /// 提交按鈕
  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _submitRequest,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text(
              '提交申請',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }
}
