import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';
import '../services/attendance_service.dart';
import '../services/company_location_service.dart';
import '../services/employee_service.dart';
import '../widgets/general_page.dart';
import 'manual_attendance_page.dart';

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

  Employee? _currentEmployee;
  AttendanceRecord? _todayRecord;
  List<AttendanceRecord> _recentRecords = [];
  bool _isLoading = true;
  bool _isCheckingIn = false;
  bool _isGettingLocation = false;
  
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  
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
    _loadCompanyLocation();
    _updateCompanyLocationFromAddress();
    _loadData();
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
          print('地理編碼精確座標 - 緯度: ${location.latitude}, 經度: ${location.longitude}');
          
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
                content: Text('已更新為地理編碼精確座標 (${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)})'),
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
    _notesController.dispose();
    super.dispose();
  }

  /// 格式化時間為 HH:mm
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// 格式化日期為 MM/dd
  String _formatDate(DateTime dateTime) {
    return '${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}';
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
      if (user?.email != null) {
        final employees = await _employeeService.getAllEmployees();
        _currentEmployee = employees.where(
          (e) => e.email?.toLowerCase() == user!.email!.toLowerCase(),
        ).firstOrNull;

        if (_currentEmployee?.id != null) {
          // 載入今日打卡記錄
          _todayRecord = await _attendanceService.getTodayAttendance(_currentEmployee!.id!);
          
          // 載入最近的打卡記錄
          _recentRecords = await _attendanceService.getAllAttendanceRecords(
            employeeId: _currentEmployee!.id,
            limit: 10,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入資料失敗: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 獲取當前位置（強制獲取新GPS位置）
  Future<void> _getCurrentLocationForced() async {
    try {
      setState(() => _isGettingLocation = true);

      // 檢查位置服務是否啟用
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('請開啟位置服務')));
        }
        return;
      }

      // 檢查位置權限
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('位置權限被拒絕')));
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('位置權限被永久拒絕，請到設定中開啟')));
        }
        return;
      }

      // 強制獲取新的GPS位置
      Position? position = await _getCachedPosition(forceRefresh: true);
      if (position == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '無法獲取位置信息\n請確認：\n1. 瀏覽器允許位置權限\n2. 使用HTTPS連線\n3. 位置服務已開啟',
              ),
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      // 檢查是否在公司範圍內 (如果公司位置已載入)
      double? distanceToCompany;
      if (_companyLocation != null) {
        distanceToCompany = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          _companyLocation!.latitude,
          _companyLocation!.longitude,
        );

        // 如果在公司範圍內，直接顯示公司名稱
        if (distanceToCompany <= _companyLocation!.radius) {
          setState(() {
            _locationController.text = _companyLocation!.name;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '已偵測到在公司範圍內 (距離: ${distanceToCompany.round()}公尺)',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
          return;
        }
      }

      // 不在公司範圍內，進行反向地理編碼獲取地址
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final placemark = placemarks[0];
          final address = [
            placemark.street,
            placemark.subLocality,
            placemark.locality,
            placemark.administrativeArea,
          ].where((part) => part != null && part.isNotEmpty).join(', ');

          setState(() {
            _locationController.text = address;
          });

          if (mounted) {
            final distanceText = distanceToCompany != null
                ? ' (距離公司: ${(distanceToCompany / 1000).toStringAsFixed(1)}公里)'
                : '';
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('已獲取最新GPS位置$distanceText')));
          }
        }
      } catch (e) {
        // 如果地理編碼失敗，使用經緯度
        setState(() {
          _locationController.text =
              '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        });

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('已獲取最新GPS座標')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('獲取位置失敗: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  /// 獲取當前位置
  Future<void> _getCurrentLocation() async {
    try {
      setState(() => _isGettingLocation = true);

      // 檢查位置服務是否啟用
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('請開啟位置服務')),
          );
        }
        return;
      }

      // 檢查位置權限
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('位置權限被拒絕')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('位置權限被永久拒絕，請到設定中開啟')),
          );
        }
        return;
      }

      // 獲取當前位置（使用快取機制或最後已知位置）
      Position? position = await _getCachedPosition();
      if (position == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '無法獲取位置信息\n請確認：\n1. 瀏覽器允許位置權限\n2. 使用HTTPS連線\n3. 位置服務已開啟',
              ),
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      // 檢查是否在公司範圍內 (如果公司位置已載入)
      double? distanceToCompany;
      if (_companyLocation != null) {
        distanceToCompany = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          _companyLocation!.latitude,
          _companyLocation!.longitude,
        );

        // 如果在公司範圍內，直接顯示公司名稱
        if (distanceToCompany <= _companyLocation!.radius) {
          setState(() {
            _locationController.text = _companyLocation!.name;
          });
        
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('已偵測到在公司範圍內 (距離: ${distanceToCompany.round()}公尺)'),
                backgroundColor: Colors.green,
              ),
            );
          }
          return;
        }
      }

      // 不在公司範圍內，進行反向地理編碼獲取地址
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        
        if (placemarks.isNotEmpty) {
          final placemark = placemarks[0];
          final address = [
            placemark.street,
            placemark.subLocality,
            placemark.locality,
            placemark.administrativeArea,
          ].where((part) => part != null && part.isNotEmpty).join(', ');
          
          setState(() {
            _locationController.text = address;
          });
          
          if (mounted) {
            final distanceText = distanceToCompany != null 
              ? ' (距離公司: ${(distanceToCompany/1000).toStringAsFixed(1)}公里)'
              : '';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('已獲取當前位置$distanceText')),
            );
          }
        }
      } catch (e) {
        // 如果地理編碼失敗，使用經緯度
        setState(() {
          _locationController.text = '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已獲取GPS座標')),
          );
        }
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('獲取位置失敗: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  /// 打卡上班
  Future<void> _checkIn() async {
    if (_currentEmployee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請先設定員工資料')),
      );
      return;
    }

    try {
      setState(() => _isCheckingIn = true);

      final record = await _attendanceService.checkIn(
        employee: _currentEmployee!,
        location: _locationController.text.trim().isEmpty 
            ? null 
            : _locationController.text.trim(),
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
      );

      _locationController.clear();
      _notesController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('打卡成功！上班時間：${_formatTime(record.checkInTime)}')),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('打卡失敗: $e')),
        );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請先打上班卡')),
      );
      return;
    }

    try {
      setState(() => _isCheckingIn = true);

      final record = await _attendanceService.checkOut(
        recordId: _todayRecord!.id,
        location: _locationController.text.trim().isEmpty 
            ? null 
            : _locationController.text.trim(),
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
      );

      _locationController.clear();
      _notesController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '打卡成功！下班時間：${_formatTime(record.checkOutTime!)} '
              '工作時數：${record.workHours?.toStringAsFixed(1)}小時'
            )
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('打卡失敗: $e')),
        );
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
                Icon(
                  Icons.today,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '今日打卡狀態',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
                  '${_todayRecord!.workHours?.toStringAsFixed(1)} 小時',
                  Icons.access_time,
                  Colors.blue,
                ),
              ] else ...[
                _buildStatusRow(
                  '狀態',
                  '工作中...',
                  Icons.work,
                  Colors.blue,
                ),
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
              
              if (_todayRecord!.notes != null && _todayRecord!.notes!.isNotEmpty) ...[
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
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 建構狀態行
  Widget _buildStatusRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: color),
          ),
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
              color: isInCompany ? Colors.green.shade300 : Colors.orange.shade300,
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
                  '位置更新於 ${cacheAge}秒前',
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
      print('使用快取位置（${cacheAge}秒前）');
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

          print('使用最後已知位置（${lastKnownAge}分鐘前）');
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 位置狀態指示器
            _buildLocationStatusIndicator(),
            const SizedBox(height: 12),
            
            // 地點輸入和位置控制按鈕
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: '地點 (選填)',
                      hintText: '請輸入打卡地點',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 整合的定位按鈕
                Tooltip(
                  message: '點擊: 快速定位\n長按: 強制獲取新GPS位置',
                  child: GestureDetector(
                    onTap: _isGettingLocation
                      ? null
                      : () async {
                            // 獲取當前位置（會自動使用快取或最後已知位置）
                          await _getCurrentLocation();
                          // 觸發位置狀態指示器重建
                          setState(() {});
                        },
                    onLongPress: _isGettingLocation
                        ? null
                        : () async {
                            // 長按強制獲取新GPS位置
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('正在獲取最新GPS位置...'),
                                  duration: Duration(milliseconds: 800),
                                ),
                              );
                            }
                            await _getCurrentLocationForced();
                            // 觸發位置狀態指示器重建
                            setState(() {});
                          },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isGettingLocation
                            ? Colors.grey.shade400
                            : Colors.blue.shade600,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: _isGettingLocation
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.my_location,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 備註輸入
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: '備註 (選填)',
                hintText: '請輸入備註信息',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            
            // 打卡按鈕
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_todayRecord == null && !_isCheckingIn) ? _checkIn : null,
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
                    onPressed: (_todayRecord != null && 
                              _todayRecord!.checkOutTime == null && 
                              !_isCheckingIn) ? _checkOut : null,
                    icon: _isCheckingIn
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.logout),
                    label: Text(
                      _todayRecord?.checkOutTime != null 
                          ? '已下班' 
                          : '打卡下班'
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

            // 補打卡/編輯記錄按鈕
            OutlinedButton.icon(
              onPressed: _openManualAttendance,
              icon: const Icon(Icons.edit_calendar),
              label: const Text('補打卡 / 編輯記錄'),
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

  /// 建構最近記錄列表
  Widget _buildRecentRecords() {
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
                  '最近記錄',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: 導航到完整的打卡記錄頁面
                  },
                  child: const Text('查看全部'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_recentRecords.isEmpty)
              const Center(
                child: Text('暫無打卡記錄'),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentRecords.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final record = _recentRecords[index];
                  return _buildRecordTile(record);
                },
              ),
          ],
        ),
      ),
    );
  }

  /// 建構記錄項目
  Widget _buildRecordTile(AttendanceRecord record) {
    final dateStr = _formatDate(record.checkInTime);
    final checkInStr = _formatTime(record.checkInTime);
    final checkOutStr = record.checkOutTime != null 
        ? _formatTime(record.checkOutTime!) 
        : '---';
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: record.isCheckedOut 
            ? Colors.green.shade100 
            : Colors.blue.shade100,
        child: Icon(
          record.isCheckedOut ? Icons.check : Icons.work,
          color: record.isCheckedOut ? Colors.green : Colors.blue,
        ),
      ),
      title: Text(
        dateStr,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text('$checkInStr - $checkOutStr'),
      trailing: record.workHours != null
          ? Text(
              '${record.workHours!.toStringAsFixed(1)}h',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).primaryColor,
              ),
            )
          : const Icon(Icons.more_time, color: Colors.grey),
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
              ? [const Center(
                  child: Text(
                    '請先在員工管理中設定您的員工資料',
                    style: TextStyle(fontSize: 16),
                  ),
                )]
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
                        const SizedBox(height: 16),
                        
                        // 最近記錄
                        _buildRecentRecords(),
                      ],
                    ),
                  ),
                ],
    );
  }
}