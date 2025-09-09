import 'package:ctc/models/photo_record.dart';
import 'package:ctc/services/photo_record_service.dart';
import 'package:ctc/widgets/general_page.dart';
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
  bool _isRecordMode = false;
  Offset? selectedPoint;
  PhotoRecord? selectedRecord;
  // 平面圖的 ID (UUID)
  String _currentFloorPlanId = 'bc26ea40-6550-4901-950a-bc30ffec116d';
  // 平面圖的 URL
  String _currentFloorPlanUrl =
      'https://coselig.com:8080/storage/v1/object/public/assets/floor_plans/1757402440180_scaled_2f.png';

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      final response = await supabase
          .from('photo_records')
          .select()
          .eq('floor_plan_id', _currentFloorPlanId);
      
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入記錄失敗: $e')),
        );
      }
    }
  }

  PhotoRecord? _findNearestRecord(Offset point) {
    const double threshold = 20.0;
    PhotoRecord? nearest;
    double minDistance = double.infinity;

    for (var record in records) {
      if (record.floorPlanId != _currentFloorPlanId) continue;

      final distance = (record.point - point).distance;
      if (distance < threshold && distance < minDistance) {
        minDistance = distance;
        nearest = record;
      }
    }

    return nearest;
  }

  void onTap(Offset offset) async {
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
        print('Session status: ${session.accessToken}'); // 不要在生產環境印出 token

        final record = PhotoRecord(
          floorPlanId: _currentFloorPlanId,
          point: offset,
          imageUrl: 'https://example.com/placeholder.jpg', // 使用有效的 URL
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
        ).showSnackBar(SnackBar(content: Text('成功創建記錄點：${offset.toString()}')));
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
    PhotoDialog.show(
      context: context,
      title: '現場照片',
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min),
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

    return GeneralPage(
      actions: [
        IconButton(
          icon: const Icon(Icons.map),
          onPressed: () {},
          tooltip: '選擇設計圖',
        ),
        IconButton(
          icon: Icon(
            _isRecordMode ? Icons.camera_alt : Icons.camera_alt_outlined,
          ),
          onPressed: () {
            setState(() {
              _isRecordMode = !_isRecordMode;
            });
          },
          tooltip: _isRecordMode ? '關閉記錄模式' : '開啟記錄模式',
        ),
        IconButton(
          icon: Icon(_getThemeIcon()),
          onPressed: widget.onThemeToggle,
          tooltip: '切換主題',
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            // 顯示確認對話框
            final shouldLogout = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('確認登出'),
                content: const Text('您確定要登出嗎？'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('登出'),
                  ),
                ],
              ),
            );

            if (shouldLogout == true) {
              try {
                // 先清除所有頁面到根級別
                if (mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }

                // 執行登出 - 全域認證監聽器會處理 UI 更新
                await supabase.auth.signOut();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('登出失敗: $e')));
                }
              }
            }
          },
          tooltip: '登出',
        ),
      ],
      children: [
        Expanded(
          child: InteractiveViewer(
            constrained: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: FloorPlanView(
              imageUrl: _currentFloorPlanUrl,
              records: records
                  .where((r) => r.floorPlanId == _currentFloorPlanId)
                  .toList(),
              onTapUp: onTap,
              selectedRecord: selectedRecord,
              selectedPoint: selectedPoint,
              isRecordMode: _isRecordMode,
              onRecordTap: (record) {
                setState(() {
                  selectedRecord = record;
                  selectedPoint = record.point;
                });
                _showPhotoDialog();
              },
            ),
          ),
        ),
      ],
    );
  }
}
