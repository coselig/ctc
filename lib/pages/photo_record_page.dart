import 'package:ctc/models/photo_record.dart';
import 'package:ctc/services/photo_record_service.dart';
import 'package:ctc/services/floor_plans_service.dart';
import 'package:ctc/services/photo_upload_service.dart';
import 'package:ctc/widgets/general_page.dart';
import 'package:ctc/widgets/widgets.dart';
import 'package:ctc/widgets/empty_state.dart';
import 'package:ctc/widgets/floor_plan_upload_widget.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PhotoRecordPage extends StatefulWidget {
  const PhotoRecordPage({
    super.key,
    required this.title,
    required this.onThemeToggle,
    required this.currentThemeMode,
  });
  final String title;
  final VoidCallback onThemeToggle;
  final ThemeMode currentThemeMode;
  @override
  State<PhotoRecordPage> createState() => _PhotoRecordPageState();
}

class _PhotoRecordPageState extends State<PhotoRecordPage> {
  final List<PhotoRecord> records = [];
  final supabase = Supabase.instance.client;
  late final FloorPlansService _floorPlansService;
  late final PhotoUploadService _photoUploadService;
  
  bool _isRecordMode = false;
  bool _isLoading = true;
  Offset? selectedPoint;
  PhotoRecord? selectedRecord;
  
  // 設計圖相關
  List<Map<String, dynamic>> _floorPlans = [];
  String? _currentFloorPlanId;
  String? _currentFloorPlanUrl;
  String? _currentFloorPlanName;

  @override
  void initState() {
    super.initState();
    _floorPlansService = FloorPlansService(supabase);
    _photoUploadService = PhotoUploadService(supabase);
    _loadFloorPlans();
  }

  /// 載入用戶的設計圖列表
  Future<void> _loadFloorPlans() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final floorPlans = await _floorPlansService.getUserFloorPlans();
      
      setState(() {
        _floorPlans = floorPlans;
        _isLoading = false;
        
        // 如果有設計圖，選擇第一個
        if (_floorPlans.isNotEmpty) {
          final firstPlan = _floorPlans.first;
          _currentFloorPlanId = firstPlan['id'] as String;
          _currentFloorPlanUrl = firstPlan['image_url'] as String;
          _currentFloorPlanName = firstPlan['name'] as String;
          
          // 載入這個設計圖的記錄
          _loadRecords();
        }
      });

      print('載入了 ${_floorPlans.length} 個設計圖');
    } catch (e) {
      print('載入設計圖失敗: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('載入設計圖失敗: $e')));
      }
    }
  }

  /// 載入當前設計圖的照片記錄
  Future<void> _loadRecords() async {
    if (_currentFloorPlanId == null) return;
    
    try {
      final response = await supabase
          .from('photo_records')
          .select()
          .eq('floor_plan_id', _currentFloorPlanId!);

      setState(() {
        records.clear();
        records.addAll(
          response.map((record) => PhotoRecord.fromJson(record)).toList(),
        );
      });

      print('載入了 ${records.length} 筆記錄');
    } catch (e) {
      print('載入記錄失敗: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('載入記錄失敗: $e')));
      }
    }
  }

  /// 切換到指定的設計圖
  void _switchToFloorPlan(String floorPlanId) {
    final plan = _floorPlans.firstWhere((p) => p['id'] == floorPlanId);
    setState(() {
      _currentFloorPlanId = floorPlanId;
      _currentFloorPlanUrl = plan['image_url'] as String;
      _currentFloorPlanName = plan['name'] as String;
    });
    _loadRecords();
  }

  /// 顯示設計圖選擇對話框
  void _showFloorPlanSelector() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('選擇設計圖'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _floorPlans.length,
              itemBuilder: (context, index) {
                final plan = _floorPlans[index];
                final isSelected = plan['id'] == _currentFloorPlanId;
                
                return ListTile(
                  leading: Icon(
                    Icons.architecture,
                    color: isSelected ? Theme.of(context).primaryColor : null,
                  ),
                  title: Text(
                    plan['name'] as String,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text('創建於 ${_formatDate(plan['created_at'])}'),
                  selected: isSelected,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (!isSelected) {
                      _switchToFloorPlan(plan['id'] as String);
                    }
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  /// 格式化日期顯示
  String _formatDate(dynamic dateStr) {
    try {
      final date = DateTime.parse(dateStr.toString());
      return '${date.year}/${date.month}/${date.day}';
    } catch (e) {
      return '未知日期';
    }
  }

  /// 顯示上傳設計圖對話框
  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 標題列
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        '新增設計圖',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
                // 內容區域
                const Flexible(
                  child: FloorPlanUploadWidget(),
                ),
                // 底部按鈕
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // 重新載入設計圖列表
                          _loadFloorPlans();
                        },
                        child: const Text('完成'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void onTap(Offset offset) async {
    if (_currentFloorPlanId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('請先選擇設計圖')));
      return;
    }

    if (_isRecordMode) {
      try {
        final user = supabase.auth.currentUser;
        final session = supabase.auth.currentSession;

        if (user == null || session == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('請先登入或 Session 已過期')));
          return;
        }

        print('Current user ID: ${user.id}');
        print('開始拍攝或選擇照片...');

        // 顯示照片來源選擇對話框並上傳照片
        final photoUrl = await PhotoUploadService.showPhotoSourceDialog(
          context,
          _photoUploadService,
        );

        if (photoUrl == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('未選擇照片')));
          return;
        }

        print('照片上傳成功：$photoUrl');

        final record = PhotoRecord(
          floorPlanId: _currentFloorPlanId!,
          point: offset,
          imageUrl: photoUrl, // 使用實際上傳的照片URL
          userId: user.id,
          timestamp: DateTime.now(),
          description: '照片記錄於 ${DateTime.now().toString()}',
        );

        print('Attempting to create record: ${record.toString()}');

        final service = PhotoRecordService(supabase);
        final createdRecord = await service.create(record);

        setState(() {
          records.add(createdRecord);
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('成功創建照片記錄：${offset.toString()}')));
      } catch (e) {
        print('Error details: $e'); // 印出詳細錯誤
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('創建記錄失敗：$e')));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('tap at $offset')));
    }
  }

  void _showPhotoDialog() {
    if (selectedRecord == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('未選中任何記錄')),
      );
      return;
    }

    final screenSize = MediaQuery.of(context).size;
    final maxWidth = screenSize.width * 0.9; // 90% 的螢幕寬度
    final maxHeight = screenSize.height * 0.7; // 70% 的螢幕高度
    
    PhotoDialog.show(
      context: context,
      title: '現場照片',
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顯示照片
            Container(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
                minWidth: 200, // 最小寬度
                minHeight: 150, // 最小高度
              ),
              decoration: BoxDecoration(
                color: Colors.transparent, // 透明背景
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: Colors.transparent, // 容器透明背景
                  child: InteractiveViewer(
                  panEnabled: true, // 允許平移
                  scaleEnabled: true, // 允許縮放
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    selectedRecord!.imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print('照片載入失敗: $error');
                      return Container(
                        height: 200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error, color: Colors.red),
                              const SizedBox(height: 8),
                              Text('照片載入失敗'),
                              const SizedBox(height: 4),
                              Text(
                                'URL: ${selectedRecord!.imageUrl}',
                                style: TextStyle(fontSize: 10, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 顯示記錄資訊
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.3), // 半透明背景
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '記錄資訊',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('位置: (${selectedRecord!.point.dx.toStringAsFixed(1)}, ${selectedRecord!.point.dy.toStringAsFixed(1)})'),
                  const SizedBox(height: 4),
                  Text('時間: ${selectedRecord!.timestamp.toString().split('.')[0]}'),
                  if (selectedRecord!.description?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text('描述: ${selectedRecord!.description}'),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    IconData _getThemeIcon() {
      switch (widget.currentThemeMode) {
        case ThemeMode.light:
          return Icons.wb_sunny;
        case ThemeMode.dark:
          return Icons.nightlight_round;
        case ThemeMode.system:
          return Icons.brightness_auto;
      }
    }

    // 載入中狀態
    if (_isLoading) {
      return GeneralPage(
        actions: [
          IconButton(
            icon: Icon(_getThemeIcon()),
            onPressed: widget.onThemeToggle,
            tooltip: '切換主題',
          ),
          const LogoutButton(),
        ],
        children: const [
          Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }

    // 沒有設計圖的狀態
    if (_floorPlans.isEmpty) {
      return GeneralPage(
        actions: [
          IconButton(
            icon: Icon(_getThemeIcon()),
            onPressed: widget.onThemeToggle,
            tooltip: '切換主題',
          ),
          const LogoutButton(),
        ],
        children: [
          Expanded(
            child: NoFloorPlansState(
              onAddFloorPlan: _showUploadDialog,
            ),
          ),
        ],
      );
    }

    // 有設計圖的正常狀態
    return GeneralPage(
      actions: [
        IconButton(
          icon: const Icon(Icons.map),
          onPressed: _showFloorPlanSelector,
          tooltip: '選擇設計圖 (${_currentFloorPlanName ?? '未選擇'})',
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _showUploadDialog,
          tooltip: '新增設計圖',
        ),
        IconButton(
          icon: Icon(
            _isRecordMode ? Icons.camera_alt : Icons.camera_alt_outlined,
          ),
          onPressed: _currentFloorPlanId != null ? () {
            setState(() {
              _isRecordMode = !_isRecordMode;
            });
          } : null,
          tooltip: _isRecordMode ? '關閉記錄模式' : '開啟記錄模式',
        ),
        IconButton(
          icon: Icon(_getThemeIcon()),
          onPressed: widget.onThemeToggle,
          tooltip: '切換主題',
        ),
        const LogoutButton(),
      ],
      children: [
        if (_currentFloorPlanUrl != null)
          Expanded(
            child: Builder(
              builder: (context) {
                final filteredRecords = records
                    .where((r) => r.floorPlanId == _currentFloorPlanId)
                    .toList();
                
                print('PhotoRecordPage 渲染：');
                print('  - 設計圖URL: $_currentFloorPlanUrl');
                print('  - 當前設計圖ID: $_currentFloorPlanId');
                print('  - 總記錄數: ${records.length}');
                print('  - 過濾後記錄數: ${filteredRecords.length}');
                
                if (filteredRecords.isNotEmpty) {
                  print('  - 記錄詳情:');
                  for (var i = 0; i < filteredRecords.length; i++) {
                    final record = filteredRecords[i];
                    print('    ${i + 1}. ID=${record.id}, 座標=(${record.point.dx}, ${record.point.dy}), 圖片=${record.imageUrl}');
                  }
                }
                
                return Container(
                  color: Colors.transparent, // 確保容器背景透明
                  child: InteractiveViewer(
                    constrained: true,
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: FloorPlanView(
                    imageUrl: _currentFloorPlanUrl!,
                    records: filteredRecords,
                    onTapUp: onTap,
                    selectedRecord: selectedRecord,
                    selectedPoint: selectedPoint,
                    isRecordMode: _isRecordMode,
                    onRecordTap: (record) {
                      print('點擊記錄: ${record.id}');
                      setState(() {
                        selectedRecord = record;
                        selectedPoint = record.point;
                      });
                      _showPhotoDialog();
                    },
                  ),
                  ),
                );
              },
            ),
          )
        else
          const Expanded(
            child: Center(
              child: Text('請選擇設計圖'),
            ),
          ),
      ],
    );
  }
}
