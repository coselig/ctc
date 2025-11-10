import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/models.dart';
import '../../../services/services.dart'; // 統一匯入所有服務
import '../../../widgets/widgets.dart'; // 統一匯入所有元件
import '../../pages.dart'; // 統一匯入管理頁面

class AttendancePage extends StatefulWidget {
  const AttendancePage({
    super.key,
    required this.title,
    required this.onThemeToggle,
    required this.currentThemeMode,
  });

  final String title;
  final VoidCallback onThemeToggle;
  final ThemeMode currentThemeMode;

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final supabase = Supabase.instance.client;
  late final AttendanceService _attendanceService;
  late final EmployeeService _employeeService;
  late final PermissionService _permissionService;

  Employee? _currentEmployee;
  AttendanceRecord? _todayRecord;
  bool _isLoading = true;
  bool _isCheckingIn = false;
  bool _canManualAttendance = false; // 是否可以手動補打卡（HR/老闆）

  final _locationController = TextEditingController();
  final _otherLocationController = TextEditingController(); // 其他地點說明

  // 地點類型選擇
  String _selectedLocationType = '辦公室';
  final List<String> _locationTypes = ['辦公室', '出差', '其他'];

  // 公司位置設定 (從本地存儲讀取)
  CompanyLocation? _companyLocation;

  // 位置快取機制
  Position? _cachedPosition;
  DateTime? _cachedPositionTime;

  @override
  void initState() {
    super.initState();
    _attendanceService = AttendanceService(supabase);
    _employeeService = EmployeeService(supabase);
    _permissionService = PermissionService();
    _loadCompanyLocation();
    _updateCompanyLocationFromAddress();
    _loadData();
    _checkPermissions();
  }

  /// 檢查權限
  Future<void> _checkPermissions() async {
    try {
      final canManual = await _permissionService.canViewAllAttendance();
      if (mounted) {
        setState(() {
          _canManualAttendance = canManual;
        });
      }
    } catch (e) {
      print('檢查權限失敗: $e');
    }
  }

  /// 從地址獲取精確座標並更新公司位置
  Future<void> _updateCompanyLocationFromAddress() async {
    try {
      const address = '406台中市北屯區后庄七街215號';

      // 先使用實際測試修正的精確座標
      const preciseLocation = CompanyLocation(
        name: '光悅科技股份有限公司',
        address: address,
        latitude: 24.1925295, // 根據實際手機測試修正的GPS座標
        longitude: 120.6648565,
        radius: 80.0, // 80公尺範圍，涵蓋WiFi和手機網路誤差
      );

      // 保存座標
      await CompanyLocationService.saveCompanyLocation(preciseLocation);
      await _loadCompanyLocation();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已設定公司位置: 光悅科技股份有限公司 (24.202445, 120.655053)'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // 嘗試使用地理編碼獲得更精確的座標
      try {
        List<Location> locations = await locationFromAddress(address);

        if (locations.isNotEmpty) {
          final location = locations[0];
          print(
            '地理編碼精確座標 - 緯度: ${location.latitude}, 經度: ${location.longitude}',
          );

          // 如果獲得的座標與預設座標差異不大，則更新
          final morePreciseLocation = CompanyLocation(
            name: '光悅科技股份有限公司',
            address: address,
            latitude: location.latitude,
            longitude: location.longitude,
            radius: 100.0,
          );

          await CompanyLocationService.saveCompanyLocation(morePreciseLocation);
          await _loadCompanyLocation();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '已更新為地理編碼精確座標 (${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)})',
                ),
                backgroundColor: Colors.blue,
              ),
            );
          }
        }
      } catch (geocodingError) {
        print('地理編碼失敗，使用預設座標: $geocodingError');
      }
    } catch (e) {
      print('設定公司位置失敗: $e');
    }
  }

  /// 載入公司位置設定
  Future<void> _loadCompanyLocation() async {
    _companyLocation = await CompanyLocationService.getCurrentCompanyLocation();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _otherLocationController.dispose();
    super.dispose();
  }

  /// 格式化時間為 HH:mm
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// 格式化完整日期為 yyyy/MM/dd
  String _formatFullDate(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}';
  }

  /// 載入相關資料
  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      // 載入當前用戶的員工資料
      final user = supabase.auth.currentUser;
      if (user != null) {
        // 直接用當前用戶的 ID 查詢自己的員工資料（避免 RLS 權限問題）
        _currentEmployee = await _employeeService.getEmployeeById(user.id);

        if (_currentEmployee?.id != null) {
          // 載入今日打卡記錄
          _todayRecord = await _attendanceService.getTodayAttendance(
            _currentEmployee!.id!,
          );
        } else {
          // 如果找不到員工資料，顯示提示
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

  /// 打卡上班
  Future<void> _checkIn() async {
    if (_currentEmployee == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('請先設定員工資料')));
      return;
    }

    // 驗證其他地點說明
    if (_selectedLocationType == '其他' &&
        _otherLocationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('請填寫地點說明'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      setState(() => _isCheckingIn = true);

      // 組合地點內容
      final locationContent = _selectedLocationType == '其他'
          ? _otherLocationController.text.trim()
          : _selectedLocationType;

      final record = await _attendanceService.checkIn(
        employee: _currentEmployee!,
        location: locationContent,
        notes: null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '打卡成功！上班時間：${_formatTime(record.checkInTime)} 地點：$locationContent',
            ),
          ),
        );
        
        _otherLocationController.clear();
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('打卡失敗: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingIn = false);
      }
    }
  }

  /// 打卡下班
  Future<void> _checkOut() async {
    if (_todayRecord == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('請先打上班卡')));
      return;
    }

    // 驗證其他地點說明
    if (_selectedLocationType == '其他' &&
        _otherLocationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('請填寫地點說明'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      setState(() => _isCheckingIn = true);

      // 組合地點內容
      final locationContent = _selectedLocationType == '其他'
          ? _otherLocationController.text.trim()
          : _selectedLocationType;

      final record = await _attendanceService.checkOut(
        recordId: _todayRecord!.id,
        location: locationContent,
        notes: null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '打卡成功！下班時間：${_formatTime(record.checkOutTime!)} '
              '地點：$locationContent '
              '工作時數：${record.calculatedWorkHours?.toStringAsFixed(1)}小時',
            ),
          ),
        );
        
        _otherLocationController.clear();
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('打卡失敗: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingIn = false);
      }
    }
  }

  /// 打開補打卡/編輯記錄頁面
  Future<void> _openManualAttendance() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ManualAttendancePage()),
    );

    // 如果補打卡成功,重新載入資料
    if (result == true) {
      _loadData();
    }
  }

  /// 建構今日打卡狀態卡片
  Widget _buildTodayStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.today, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  '今日打卡狀態',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_todayRecord != null) ...[
              _buildStatusRow(
                '上班時間',
                _formatTime(_todayRecord!.checkInTime),
                Icons.login,
                Colors.green,
              ),
              const SizedBox(height: 8),

              if (_todayRecord!.checkOutTime != null) ...[
                _buildStatusRow(
                  '下班時間',
                  _formatTime(_todayRecord!.checkOutTime!),
                  Icons.logout,
                  Colors.orange,
                ),
                const SizedBox(height: 8),
                _buildStatusRow(
                  '工作時數',
                  '${_todayRecord!.calculatedWorkHours?.toStringAsFixed(1)} 小時',
                  Icons.access_time,
                  Colors.blue,
                ),
              ] else ...[
                _buildStatusRow('狀態', '工作中...', Icons.work, Colors.blue),
              ],

              if (_todayRecord!.location != null) ...[
                const SizedBox(height: 8),
                _buildStatusRow(
                  '地點',
                  _todayRecord!.location!,
                  Icons.location_on,
                  Colors.purple,
                ),
              ],

              if (_todayRecord!.notes != null &&
                  _todayRecord!.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildStatusRow(
                  '備註',
                  _todayRecord!.notes!,
                  Icons.note,
                  Colors.grey,
                ),
              ],
            ] else ...[
              Center(
                child: Text(
                  '今天還沒有打卡記錄',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 建構狀態行
  Widget _buildStatusRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(value, style: TextStyle(color: color)),
        ),
      ],
    );
  }

  /// 建構位置狀態指示器
  Widget _buildLocationStatusIndicator() {
    return FutureBuilder<bool>(
      future: _isCurrentLocationInCompany(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('檢查位置中...'),
              ],
            ),
          );
        }

        final isInCompany = snapshot.data ?? false;
        final now = DateTime.now();
        final cacheAge = _cachedPositionTime != null
            ? now.difference(_cachedPositionTime!).inSeconds
            : 0;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isInCompany ? Colors.green.shade50 : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isInCompany
                  ? Colors.green.shade300
                  : Colors.orange.shade300,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isInCompany ? Icons.business : Icons.location_on,
                    size: 16,
                    color: isInCompany
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isInCompany ? '✓ 您目前在公司範圍內' : '⚠ 您目前不在公司範圍內',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isInCompany
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                      ),
                    ),
                  ),
                  if (!isInCompany)
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: Colors.orange.shade700,
                    ),
                ],
              ),
              if (cacheAge > 0) ...[
                const SizedBox(height: 4),
                Text(
                  '位置更新於 $cacheAge秒前',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// 獲取位置（使用快取機制）
  Future<Position?> _getCachedPosition({bool forceRefresh = false}) async {
    final now = DateTime.now();

    // 如果不是強制刷新且快取存在且不超過 30 秒，使用快取
    if (!forceRefresh &&
        _cachedPosition != null &&
        _cachedPositionTime != null &&
        now.difference(_cachedPositionTime!).inSeconds < 30) {
      final cacheAge = now.difference(_cachedPositionTime!).inSeconds;
      print('使用快取位置（$cacheAge秒前）');
      return _cachedPosition;
    }

    try {
      // 檢查位置權限
      LocationPermission permission = await Geolocator.checkPermission();
      print('位置權限狀態: $permission');

      if (permission == LocationPermission.denied) {
        print('請求位置權限...');
        permission = await Geolocator.requestPermission();
        print('權限請求結果: $permission');
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print('位置權限被拒絕');
        return null;
      }

      // 先嘗試獲取最後已知位置（非常快速）
      Position? lastKnownPosition;
      try {
        lastKnownPosition = await Geolocator.getLastKnownPosition();
        print('最後已知位置: ${lastKnownPosition != null ? "找到" : "無"}');
      } catch (e) {
        print('獲取最後已知位置失敗: $e');
      }

      // 如果有最後已知位置且不是太舊（5分鐘內），先使用它
      if (lastKnownPosition != null && !forceRefresh) {
        final lastKnownAge = now
            .difference(lastKnownPosition.timestamp)
            .inMinutes;
        if (lastKnownAge < 5) {
          // 更新快取
          _cachedPosition = lastKnownPosition;
          _cachedPositionTime = now;

          print('使用最後已知位置（$lastKnownAge分鐘前）');
          return lastKnownPosition;
        }
      }

      // 獲取新位置 - 使用平衡精度以提升速度
      print('正在獲取新GPS位置...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10), // Web環境延長超時
      );

      print('成功獲取GPS位置: ${position.latitude}, ${position.longitude}');

      // 更新快取
      _cachedPosition = position;
      _cachedPositionTime = now;

      return position;
    } catch (e) {
      print('獲取位置失敗: $e');
      print('錯誤類型: ${e.runtimeType}');

      // 如果獲取失敗，嘗試使用最後已知位置作為後備
      try {
        print('嘗試使用最後已知位置作為後備...');
        Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
        if (lastKnownPosition != null) {
          print('使用最後已知位置作為後備');
          _cachedPosition = lastKnownPosition;
          _cachedPositionTime = now;
          return lastKnownPosition;
        }
        print('沒有最後已知位置');
      } catch (e2) {
        print('獲取最後已知位置也失敗: $e2');
      }

      return null;
    }
  }

  /// 檢查當前位置是否在公司範圍內
  Future<bool> _isCurrentLocationInCompany() async {
    try {
      if (_companyLocation == null) return false;

      // 獲取位置（使用快取）
      Position? position = await _getCachedPosition();
      if (position == null) return false;

      // 計算距離
      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        _companyLocation!.latitude,
        _companyLocation!.longitude,
      );

      // 記錄調試信息
      print(
        '位置檢查 - 當前座標: (${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)})',
      );
      print(
        '位置檢查 - 公司座標: (${_companyLocation!.latitude.toStringAsFixed(6)}, ${_companyLocation!.longitude.toStringAsFixed(6)})',
      );
      print(
        '位置檢查 - 距離公司: ${distance.round()}公尺, 範圍: ${_companyLocation!.radius}公尺',
      );

      return distance <= _companyLocation!.radius;
    } catch (e) {
      print('位置檢查失敗: $e');
      return false;
    }
  }

  /// 建構打卡按鈕區域
  Widget _buildCheckInButtons() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '打卡操作',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 位置狀態指示器
            _buildLocationStatusIndicator(),
            const SizedBox(height: 12),

            // 地點類型下拉選單
            DropdownButtonFormField<String>(
              value: _selectedLocationType,
              decoration: const InputDecoration(
                labelText: '地點類型',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              items: _locationTypes.map((String type) {
                return DropdownMenuItem<String>(value: type, child: Text(type));
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLocationType = newValue;
                    // 切換地點類型時清空其他地點說明
                    if (newValue != '其他') {
                      _otherLocationController.clear();
                    }
                  });
                }
              },
            ),
            const SizedBox(height: 12),

            // 其他地點詳細說明
            if (_selectedLocationType == '其他') ...[
              TextField(
                controller: _otherLocationController,
                decoration: const InputDecoration(
                  labelText: '地點說明',
                  hintText: '例如：客戶公司、展場等',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit_location),
                ),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 16),

            // 打卡按鈕
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_todayRecord == null && !_isCheckingIn)
                        ? _checkIn
                        : null,
                    icon: _isCheckingIn
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.login),
                    label: Text(_todayRecord == null ? '打卡上班' : '已上班'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        (_todayRecord != null &&
                            _todayRecord!.checkOutTime == null &&
                            !_isCheckingIn)
                        ? _checkOut
                        : null,
                    icon: _isCheckingIn
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.logout),
                    label: Text(
                      _todayRecord?.checkOutTime != null ? '已下班' : '打卡下班',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 補打卡/編輯記錄按鈕（僅 HR/老闆可見）
            if (_canManualAttendance)
              OutlinedButton.icon(
                onPressed: _openManualAttendance,
                icon: const Icon(Icons.edit_calendar),
                label: const Text('手動補打卡 / 編輯記錄'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Colors.blue.shade300),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GeneralPage(
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadData,
          tooltip: '重新整理',
        ),
      ],
      children: _isLoading
          ? [const Center(child: CircularProgressIndicator())]
          : _currentEmployee == null
          ? [
              const Center(
                child: Text('請先在員工管理中設定您的員工資料', style: TextStyle(fontSize: 16)),
              ),
            ]
          : [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 員工信息
                    Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(_currentEmployee!.name[0]),
                        ),
                        title: Text(_currentEmployee!.name),
                        subtitle: Text(_currentEmployee!.email ?? ''),
                        trailing: Text(
                          _formatFullDate(DateTime.now()),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 今日狀態
                    _buildTodayStatusCard(),
                    const SizedBox(height: 16),

                    // 打卡按鈕
                    _buildCheckInButtons(),
                  ],
                ),
              ),
            ],
    );
  }
}
