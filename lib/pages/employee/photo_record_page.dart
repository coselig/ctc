import 'package:ctc/models/photo_record.dart';
import 'package:ctc/services/floor_plans_service.dart';
import 'package:ctc/services/photo_record_service.dart';
import 'package:ctc/services/photo_upload_service.dart';
import 'package:ctc/widgets/widgets.dart';
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

  /// 編輯設計圖名稱
  Future<void> _editFloorPlanName(
    String floorPlanId,
    String currentName,
  ) async {
    final newName = await EditDescriptionDialog.show(
      context,
      initialDescription: currentName,
      title: '編輯設計圖名稱',
      labelText: '設計圖名稱',
      hintText: '請輸入設計圖名稱...',
      maxLines: 1,
    );

    if (newName == null || newName.trim().isEmpty) return;

    if (newName.trim() == currentName) {
      // 名稱沒有變更
      return;
    }

    try {
      // 顯示載入指示器
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // 更新設計圖名稱
      await _floorPlansService.updateFloorPlanName(floorPlanId, newName);

      // 關閉載入指示器
      Navigator.of(context).pop();

      // 如果修改的是當前選中的設計圖，更新名稱
      if (_currentFloorPlanId == floorPlanId) {
        setState(() {
          _currentFloorPlanName = newName;
        });
      }

      // 重新載入設計圖列表
      await _loadFloorPlans();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('設計圖名稱已更新')));
    } catch (e) {
      // 關閉載入指示器
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      print('更新設計圖名稱失敗: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('更新失敗：$e')));
    }
  }

  /// 刪除設計圖
  Future<void> _deleteFloorPlan(
    String floorPlanId,
    String floorPlanName,
  ) async {
    // 顯示確認對話框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('刪除設計圖'),
        content: Text(
          '確定要刪除設計圖「$floorPlanName」嗎？\n\n⚠️ 此操作將會：\n• 刪除設計圖檔案\n• 刪除所有相關的照片記錄\n• 此操作無法復原',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('刪除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // 顯示載入指示器
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // 刪除設計圖
      await _floorPlansService.deleteFloorPlan(floorPlanId);

      // 關閉載入指示器
      Navigator.of(context).pop();

      // 如果刪除的是當前選中的設計圖，清空選中狀態
      if (_currentFloorPlanId == floorPlanId) {
        setState(() {
          _currentFloorPlanId = null;
          _currentFloorPlanUrl = null;
          _currentFloorPlanName = null;
          records.clear(); // 清空記錄
        });
      }

      // 重新載入設計圖列表
      await _loadFloorPlans();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('設計圖「$floorPlanName」已刪除')));
    } catch (e) {
      // 關閉載入指示器
      Navigator.of(context).pop();

      print('刪除設計圖失敗: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('刪除失敗：$e')));
    }
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
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text('創建於 ${_formatDate(plan['created_at'])}'),
                  selected: isSelected,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.of(context).pop(); // 先關閉選擇對話框
                          _editFloorPlanName(
                            plan['id'] as String,
                            plan['name'] as String,
                          );
                        },
                        tooltip: '編輯名稱',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          Navigator.of(context).pop(); // 先關閉選擇對話框
                          _deleteFloorPlan(
                            plan['id'] as String,
                            plan['name'] as String,
                          );
                        },
                        tooltip: '刪除設計圖',
                      ),
                    ],
                  ),
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
  void _showUploadDialog() async {
    final result = await showDialog<bool>(
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
                      bottom: BorderSide(color: Colors.grey.shade300),
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
                const Flexible(child: FloorPlanUploadWidget()),
              ],
            ),
          ),
        );
      },
    );

    // 如果創建成功（返回 true），重新載入設計圖列表
    if (result == true) {
      _loadFloorPlans();
    }
  }

  void onTap(Offset offset) async {
    if (_currentFloorPlanId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('請先選擇設計圖')));
      return;
    }

    if (_isRecordMode) {
      // 只有在記錄模式下才顯示光標點擊操作介面
      _showCursorActionDialog(offset);
    }
    // 非記錄模式下不執行任何操作，不顯示點擊位置
  }

  /// 顯示光標點擊操作介面
  void _showCursorActionDialog(Offset offset) {
    // 設置選擇點以顯示標記
    setState(() {
      selectedPoint = offset;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(maxWidth: 400, maxHeight: 500),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 標題列
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '位置操作',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                            Text(
                              '座標: (${offset.dx.toStringAsFixed(1)}, ${offset.dy.toStringAsFixed(1)})',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                    .withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedPoint = null;
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),

                // 操作選項
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // 拍攝照片選項
                      _buildActionButton(
                        icon: Icons.camera_alt,
                        title: '拍攝照片',
                        subtitle: '使用相機拍攝現場照片',
                        onTap: () async {
                          Navigator.of(context).pop();
                          await _takePhotoAtLocation(offset);
                        },
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 12),

                      // 選擇相簿選項
                      _buildActionButton(
                        icon: Icons.photo_library,
                        title: '選擇照片',
                        subtitle: '從相簿選擇已有照片',
                        onTap: () async {
                          Navigator.of(context).pop();
                          await _pickPhotoAtLocation(offset);
                        },
                        color: Colors.green,
                      ),
                      const SizedBox(height: 12),

                      // 添加備註選項
                      _buildActionButton(
                        icon: Icons.note_add,
                        title: '添加備註',
                        subtitle: '在此位置添加文字備註',
                        onTap: () {
                          Navigator.of(context).pop();
                          _addNoteAtLocation(offset);
                        },
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 12),

                      // 查看附近記錄選項
                      _buildActionButton(
                        icon: Icons.search,
                        title: '查看附近記錄',
                        subtitle: '查看此位置附近的照片記錄',
                        onTap: () {
                          Navigator.of(context).pop();
                          _showNearbyRecords(offset);
                        },
                        color: Colors.purple,
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

  /// 構建操作按鈕
  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 使用相機拍攝照片
  Future<void> _takePhotoAtLocation(Offset offset) async {
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

        // 直接使用相機拍攝照片
        final photoUrl = await _photoUploadService.takePhotoAndUpload();

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
          selectedPoint = null; // 清除選擇點
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('成功創建照片記錄：${offset.toString()}')),
        );
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

  /// 從相簿選擇照片
  Future<void> _pickPhotoAtLocation(Offset offset) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('請先登入')));
        return;
      }

      // 直接從相簿選擇照片
      final photoUrl = await _photoUploadService.pickPhotoAndUpload();

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
        imageUrl: photoUrl,
        userId: user.id,
        timestamp: DateTime.now(),
        description: '照片記錄於 ${DateTime.now().toString()}',
      );

      final service = PhotoRecordService(supabase);
      final createdRecord = await service.create(record);

      setState(() {
        records.add(createdRecord);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('成功創建照片記錄：${offset.toString()}')));
    } catch (e) {
      print('Error details: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('創建記錄失敗：$e')));
    }
  }

  /// 在指定位置添加文字備註
  void _addNoteAtLocation(Offset offset) {
    final TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加備註'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '位置: (${offset.dx.toStringAsFixed(1)}, ${offset.dy.toStringAsFixed(1)})',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                hintText: '請輸入備註內容...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              if (noteController.text.trim().isEmpty) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('請輸入備註內容')));
                return;
              }

              Navigator.of(context).pop();

              try {
                final user = supabase.auth.currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('請先登入')));
                  return;
                }

                final record = PhotoRecord(
                  floorPlanId: _currentFloorPlanId!,
                  point: offset,
                  imageUrl: '', // 備註記錄沒有圖片
                  userId: user.id,
                  timestamp: DateTime.now(),
                  description: noteController.text.trim(),
                );

                final service = PhotoRecordService(supabase);
                final createdRecord = await service.create(record);

                setState(() {
                  records.add(createdRecord);
                  selectedPoint = null; // 清除選擇點
                });

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('備註已添加')));
              } catch (e) {
                print('添加備註失敗: $e');
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('添加備註失敗：$e')));
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// 查看附近的記錄
  void _showNearbyRecords(Offset offset) {
    // 查找附近50像素範圍內的記錄
    const double searchRadius = 50.0;
    final nearbyRecords = records.where((record) {
      final distance = (record.point - offset).distance;
      return distance <= searchRadius;
    }).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('附近記錄 (${nearbyRecords.length}個)'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: nearbyRecords.isEmpty
              ? const Center(child: Text('此位置附近沒有記錄'))
              : ListView.builder(
                  itemCount: nearbyRecords.length,
                  itemBuilder: (context, index) {
                    final record = nearbyRecords[index];
                    final distance = (record.point - offset).distance;
                    return ListTile(
                      leading: record.imageUrl.isNotEmpty
                          ? const Icon(Icons.photo, color: Colors.blue)
                          : const Icon(Icons.note, color: Colors.orange),
                      title: Text(record.imageUrl.isNotEmpty ? '照片記錄' : '文字備註'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('距離: ${distance.toStringAsFixed(1)} 像素'),
                          Text(
                            '位置: (${record.point.dx.toStringAsFixed(1)}, ${record.point.dy.toStringAsFixed(1)})',
                          ),
                          if (record.description?.isNotEmpty == true)
                            Text('備註: ${record.description}'),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        setState(() {
                          selectedRecord = record;
                          selectedPoint = record.point;
                        });
                        if (record.imageUrl.isNotEmpty) {
                          _showPhotoDialog();
                        }
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('關閉'),
          ),
        ],
      ),
    );
  }

  /// 編輯照片記錄的描述
  Future<void> _editPhotoRecord() async {
    if (selectedRecord == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('未選中任何記錄')));
      return;
    }

    final newDescription = await EditDescriptionDialog.show(
      context,
      initialDescription: selectedRecord!.description,
    );

    if (newDescription == null) return;

    try {
      final service = PhotoRecordService(supabase);
      final updatedRecord = await service.update(
        selectedRecord!.id!,
        description: newDescription,
      );

      // 更新本地記錄
      setState(() {
        final index = records.indexWhere((r) => r.id == selectedRecord!.id);
        if (index != -1) {
          records[index] = updatedRecord;
          selectedRecord = updatedRecord;
        }
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('記錄已更新')));

      // 關閉當前對話框
      Navigator.of(context).pop();

      // 短暫延遲後重新打開對話框以顯示更新後的內容
      await Future.delayed(const Duration(milliseconds: 100));
      _showPhotoDialog();
    } catch (e) {
      print('更新照片記錄失敗: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('更新失敗：$e')));
    }
  }

  /// 更換照片記錄的照片
  Future<void> _replacePhoto() async {
    if (selectedRecord == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('未選中任何記錄')));
      return;
    }

    // 顯示選擇方式對話框
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('更換照片'),
        content: const Text('請選擇照片來源'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('camera'),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt),
                SizedBox(width: 8),
                Text('拍攝照片'),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('gallery'),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.photo_library),
                SizedBox(width: 8),
                Text('選擇相簿'),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
      ),
    );

    if (choice == null) return;

    try {
      // 顯示載入指示器
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      String? newPhotoUrl;

      if (choice == 'camera') {
        newPhotoUrl = await _photoUploadService.takePhotoAndUpload();
      } else if (choice == 'gallery') {
        newPhotoUrl = await _photoUploadService.pickPhotoAndUpload();
      }

      // 關閉載入指示器
      Navigator.of(context).pop();

      if (newPhotoUrl == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('未選擇照片')));
        return;
      }

      print('新照片上傳成功：$newPhotoUrl');

      final service = PhotoRecordService(supabase);
      final updatedRecord = await service.update(
        selectedRecord!.id!,
        imageUrl: newPhotoUrl,
      );

      // 更新本地記錄
      setState(() {
        final index = records.indexWhere((r) => r.id == selectedRecord!.id);
        if (index != -1) {
          records[index] = updatedRecord;
          selectedRecord = updatedRecord;
        }
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('照片已更換')));

      // 關閉當前對話框
      Navigator.of(context).pop();

      // 短暫延遲後重新打開對話框以顯示更新後的照片
      await Future.delayed(const Duration(milliseconds: 100));
      _showPhotoDialog();
    } catch (e) {
      // 確保關閉載入指示器
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      print('更換照片失敗: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('更換照片失敗：$e')));
    }
  }

  Future<void> _deletePhotoRecord() async {
    if (selectedRecord == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('未選中任何記錄')));
      return;
    }

    // 顯示確認對話框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('刪除照片記錄'),
        content: const Text('確定要刪除這張照片記錄嗎？此操作無法復原。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('刪除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final service = PhotoRecordService(supabase);
      await service.delete(selectedRecord!.id!);

      // 從本地記錄中移除
      setState(() {
        records.removeWhere((record) => record.id == selectedRecord!.id);
        selectedRecord = null;
        selectedPoint = null;
      });

      // 關閉照片對話框
      Navigator.of(context).pop();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('照片記錄已刪除')));
    } catch (e) {
      print('刪除照片記錄失敗: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('刪除失敗：$e')));
    }
  }

  void _showPhotoDialog() {
    if (selectedRecord == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('未選中任何記錄')));
      return;
    }

    final screenSize = MediaQuery.of(context).size;
    final maxWidth = screenSize.width * 0.9; // 90% 的螢幕寬度
    final maxHeight = screenSize.height * 0.7; // 70% 的螢幕高度

    PhotoDialog.show(
      context: context,
      title: selectedRecord!.imageUrl.isNotEmpty ? '現場照片' : '記錄備註',
      actions: [
        if (selectedRecord!.imageUrl.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.photo_camera),
            onPressed: _replacePhoto,
            tooltip: '更換照片',
            color: Colors.green,
          ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: _deletePhotoRecord,
          tooltip: '刪除照片記錄',
          color: Colors.red,
        ),
      ],
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 只在有照片時顯示照片區域
            if (selectedRecord!.imageUrl.isNotEmpty) ...[
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
                                value:
                                    loadingProgress.expectedTotalBytes != null
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
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
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
            ],
            // 顯示記錄資訊
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withOpacity(0.3), // 半透明背景
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '記錄資訊',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: _deletePhotoRecord,
                            tooltip: '刪除記錄',
                            color: Colors.red,
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: _editPhotoRecord,
                            tooltip: '編輯記錄描述',
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '位置: (${selectedRecord!.point.dx.toStringAsFixed(1)}, ${selectedRecord!.point.dy.toStringAsFixed(1)})',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '時間: ${selectedRecord!.timestamp.toString().split('.')[0]}',
                  ),
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
        title: widget.title,
        actions: [
          IconButton(
            icon: Icon(_getThemeIcon()),
            onPressed: widget.onThemeToggle,
            tooltip: '切換主題',
          ),
          const LogoutButton(),
        ],
        children: [
          SizedBox(
            height:
                MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                AppBar().preferredSize.height -
                40,
            child: const Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    // 沒有設計圖的狀態
    if (_floorPlans.isEmpty) {
      return GeneralPage(
        title: widget.title,
        actions: [
          IconButton(
            icon: Icon(_getThemeIcon()),
            onPressed: widget.onThemeToggle,
            tooltip: '切換主題',
          ),
          const LogoutButton(),
        ],
        children: [
          SizedBox(
            height:
                MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                AppBar().preferredSize.height -
                40,
            child: NoFloorPlansState(onAddFloorPlan: _showUploadDialog),
          ),
        ],
      );
    }

    // 有設計圖的正常狀態
    return GeneralPage(
      title: widget.title,
      actions: [
        IconButton(
          icon: const Icon(Icons.map),
          onPressed: _showFloorPlanSelector,
          tooltip: '選擇設計圖 (${_currentFloorPlanName ?? '未選擇'})',
        ),
        if (_currentFloorPlanId != null && _currentFloorPlanName != null)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              _deleteFloorPlan(_currentFloorPlanId!, _currentFloorPlanName!);
            },
            tooltip: '刪除當前設計圖 ($_currentFloorPlanName)',
            color: Colors.red.shade400,
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
          onPressed: _currentFloorPlanId != null
              ? () {
                  setState(() {
                    _isRecordMode = !_isRecordMode;
                    // 當關閉記錄模式時清除選擇點
                    if (!_isRecordMode) {
                      selectedPoint = null;
                    }
                  });
                }
              : null,
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
          SizedBox(
            height:
                MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                AppBar().preferredSize.height -
                40,
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
                    print(
                      '    ${i + 1}. ID=${record.id}, 座標=(${record.point.dx}, ${record.point.dy}), 圖片=${record.imageUrl}',
                    );
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
          SizedBox(
            height:
                MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                AppBar().preferredSize.height -
                40,
            child: const Center(child: Text('請選擇設計圖')),
          ),
      ],
    );
  }
}
