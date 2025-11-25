import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../models/attendance_form_models.dart';

/// 統一的補打卡表單元件
class AttendanceFormWidget extends StatefulWidget {
  final AttendanceFormConfig config;
  final Function(DateTime)? onDateChanged; // 日期變更時的回調（用於查詢該日期的記錄）

  const AttendanceFormWidget({
    super.key,
    required this.config,
    this.onDateChanged,
  });

  @override
  State<AttendanceFormWidget> createState() => _AttendanceFormWidgetState();
}

class _AttendanceFormWidgetState extends State<AttendanceFormWidget> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _selectedDate;
  late String _punchType;
  late TimeOfDay _checkInTime;
  late TimeOfDay _checkOutTime;
  String _location = '辦公室';
  String _otherLocation = '';
  String _reasonType = '';
  String _reasonNotes = '';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeFormData();
  }

  @override
  void didUpdateWidget(AttendanceFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果配置改變（例如現有記錄更新），重新初始化
    if (oldWidget.config.existingRecord != widget.config.existingRecord) {
      _initializeFormData();
    }
  }

  void _initializeFormData() {
    final config = widget.config;
    final record = config.existingRecord;
    final request = config.editingRequest;

    // 初始化日期
    if (request != null) {
      _selectedDate = request.requestDate;
    } else if (record != null) {
      _selectedDate = DateTime(
        record.checkInTime.year,
        record.checkInTime.month,
        record.checkInTime.day,
      );
    } else {
      _selectedDate = DateTime.now();
    }

    // 初始化打卡類型和時間
    if (request != null) {
      // 從申請記錄載入
      if (request.requestType == AttendanceRequestType.checkIn) {
        _punchType = 'checkIn';
        final time = request.requestTime!;
        _checkInTime = TimeOfDay(hour: time.hour, minute: time.minute);
        _checkOutTime = const TimeOfDay(hour: 17, minute: 30);
      } else if (request.requestType == AttendanceRequestType.checkOut) {
        _punchType = 'checkOut';
        final time = request.requestTime!;
        _checkInTime = const TimeOfDay(hour: 8, minute: 30);
        _checkOutTime = TimeOfDay(hour: time.hour, minute: time.minute);
      } else {
        _punchType = 'fullDay';
        final checkIn = request.checkInTime!;
        final checkOut = request.checkOutTime!;
        _checkInTime = TimeOfDay(hour: checkIn.hour, minute: checkIn.minute);
        _checkOutTime = TimeOfDay(hour: checkOut.hour, minute: checkOut.minute);
      }
      _reasonNotes = request.reason;
    } else if (record != null) {
      // 從現有記錄載入
      _checkInTime = TimeOfDay(
        hour: record.checkInTime.hour,
        minute: record.checkInTime.minute,
      );
      if (record.checkOutTime != null) {
        _punchType = 'fullDay';
        _checkOutTime = TimeOfDay(
          hour: record.checkOutTime!.hour,
          minute: record.checkOutTime!.minute,
        );
      } else {
        _punchType = 'checkOut';
        _checkOutTime = const TimeOfDay(hour: 17, minute: 30);
      }
      _location = record.location ?? '辦公室';
    } else {
      // 預設值
      _punchType = 'checkIn';
      _checkInTime = const TimeOfDay(hour: 8, minute: 30);
      _checkOutTime = const TimeOfDay(hour: 17, minute: 30);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      // 通知父組件日期已變更
      widget.onDateChanged?.call(picked);
    }
  }

  Future<void> _selectCheckInTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _checkInTime,
    );
    if (picked != null) {
      setState(() => _checkInTime = picked);
    }
  }

  Future<void> _selectCheckOutTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _checkOutTime,
    );
    if (picked != null) {
      setState(() => _checkOutTime = picked);
    }
  }

  Future<void> _submitForm() async {
    if (_isSubmitting) return;
    
    if (!_formKey.currentState!.validate()) return;

    // 驗證原因
    if (_reasonType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('請選擇補打卡原因'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_reasonType == '其他' && _reasonNotes.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('請填寫原因詳細說明'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 驗證地點
    if (_location == '其他' && _otherLocation.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('請填寫地點說明'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 構建表單數據
      final checkInDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _checkInTime.hour,
        _checkInTime.minute,
      );

      final checkOutDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _checkOutTime.hour,
        _checkOutTime.minute,
      );

      final locationText = _location == '其他' ? _otherLocation.trim() : _location;
      final reasonText = _reasonType == '其他'
          ? '$_reasonType：${_reasonNotes.trim()}'
          : _reasonType;

      final formData = AttendanceFormData(
        date: _selectedDate,
        punchType: _punchType,
        checkInTime: _punchType != 'checkOut' ? checkInDateTime : null,
        checkOutTime: _punchType != 'checkIn' ? checkOutDateTime : null,
        location: locationText,
        reason: reasonText,
        notes: _reasonNotes.trim().isEmpty ? null : _reasonNotes.trim(),
      );

      await widget.config.onSubmit(formData);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final hasExistingRecord = config.existingRecord != null;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 員工信息卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        config.targetEmployee.name[0],
                        style: const TextStyle(
                          color: Colors.white,
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
                            config.targetEmployee.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${config.targetEmployee.department} - ${config.targetEmployee.position}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 模式提示
            if (config.showModeHint) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        config.modeHintText,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 現有記錄提示
            if (hasExistingRecord) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '該日期已有打卡記錄，提交將覆蓋原記錄',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 日期選擇
            _buildSectionTitle('補打卡日期'),
            Card(
              child: InkWell(
                onTap: _selectDate,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '選擇日期',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('yyyy年MM月dd日 (E)', 'zh_TW')
                                  .format(_selectedDate),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 打卡類型
            _buildSectionTitle('補打卡類型'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<String>(
                  value: _punchType,
                  decoration: const InputDecoration(
                    labelText: '選擇補打卡類型',
                    prefixIcon: Icon(Icons.punch_clock),
                    border: OutlineInputBorder(),
                  ),
                  items: _buildPunchTypeItems(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _punchType = value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 時間選擇
            if (_punchType != 'fullDay') ...[
              _buildSectionTitle('打卡時間'),
              Card(
                child: InkWell(
                  onTap: _punchType == 'checkIn'
                      ? _selectCheckInTime
                      : _selectCheckOutTime,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          _punchType == 'checkIn'
                              ? Icons.login
                              : Icons.logout,
                          color: _punchType == 'checkIn'
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _punchType == 'checkIn' ? '上班時間' : '下班時間',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _punchType == 'checkIn'
                                    ? '${_checkInTime.hour.toString().padLeft(2, '0')}:${_checkInTime.minute.toString().padLeft(2, '0')}'
                                    : '${_checkOutTime.hour.toString().padLeft(2, '0')}:${_checkOutTime.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ] else ...[
              _buildSectionTitle('上班時間'),
              Card(
                child: InkWell(
                  onTap: _selectCheckInTime,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.login, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '上班時間',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_checkInTime.hour.toString().padLeft(2, '0')}:${_checkInTime.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('下班時間'),
              Card(
                child: InkWell(
                  onTap: _selectCheckOutTime,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.logout, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '下班時間',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_checkOutTime.hour.toString().padLeft(2, '0')}:${_checkOutTime.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),

            // 地點選擇
            _buildSectionTitle('地點'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<String>(
                  value: _location,
                  decoration: const InputDecoration(
                    labelText: '選擇地點',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: '辦公室', child: Text('辦公室')),
                    DropdownMenuItem(value: '出差', child: Text('出差')),
                    DropdownMenuItem(value: '其他', child: Text('其他')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _location = value);
                    }
                  },
                ),
              ),
            ),
            if (_location == '其他') ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: '請輸入具體地點',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.edit_location),
                    ),
                    onChanged: (value) => _otherLocation = value,
                    initialValue: _otherLocation,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),

            // 補打卡原因
            _buildSectionTitle('補打卡原因（必填）'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<String>(
                  value: _reasonType.isEmpty ? null : _reasonType,
                  decoration: const InputDecoration(
                    labelText: '選擇原因',
                    prefixIcon: Icon(Icons.comment),
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('請選擇補打卡原因'),
                  items: const [
                    DropdownMenuItem(value: '時間更正', child: Text('時間更正')),
                    DropdownMenuItem(value: '忘記打卡', child: Text('忘記打卡')),
                    DropdownMenuItem(value: '系統錯誤', child: Text('系統錯誤')),
                    DropdownMenuItem(value: '其他', child: Text('其他')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _reasonType = value ?? '';
                      if (value != '其他') _reasonNotes = '';
                    });
                  },
                ),
              ),
            ),
            if (_reasonType == '其他') ...[
              const SizedBox(height: 16),
              _buildSectionTitle('詳細說明（必填）'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: '請詳細說明補打卡原因...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.edit_note),
                    ),
                    maxLines: 4,
                    onChanged: (value) => _reasonNotes = value,
                    initialValue: _reasonNotes,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),

            // 提交按鈕
            Row(
              children: [
                if (widget.config.onCancel != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : widget.config.onCancel,
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            config.submitButtonText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildPunchTypeItems() {
    final hasRecord = widget.config.existingRecord != null;
    final record = widget.config.existingRecord;

    if (!hasRecord) {
      // 沒有記錄：可以補上班、補全天
      return const [
        DropdownMenuItem(
          value: 'checkIn',
          child: Row(
            children: [
              Icon(Icons.login, color: Colors.green),
              SizedBox(width: 12),
              Text('補上班'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'fullDay',
          child: Row(
            children: [
              Icon(Icons.event_available, color: Colors.blue),
              SizedBox(width: 12),
              Text('補全天'),
            ],
          ),
        ),
      ];
    } else if (record!.checkOutTime == null) {
      // 有上班記錄但沒下班：可以補下班、補全天
      return const [
        DropdownMenuItem(
          value: 'checkOut',
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 12),
              Text('補下班'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'fullDay',
          child: Row(
            children: [
              Icon(Icons.event_available, color: Colors.blue),
              SizedBox(width: 12),
              Text('補全天'),
            ],
          ),
        ),
      ];
    } else {
      // 已有完整記錄：只能補全天（覆蓋）
      return const [
        DropdownMenuItem(
          value: 'fullDay',
          child: Row(
            children: [
              Icon(Icons.event_available, color: Colors.blue),
              SizedBox(width: 12),
              Text('補全天'),
            ],
          ),
        ),
      ];
    }
  }
}
