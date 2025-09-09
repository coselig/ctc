import 'package:ctc/models/photo_record.dart';
import 'package:ctc/widgets/general_page.dart';
import 'package:ctc/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/floor_plan_upload_widget.dart';

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
  final ImagePicker _picker = ImagePicker();
  final supabase = Supabase.instance.client;
  bool _isLoading = false;
  bool _isRecordMode = false;
  Offset? selectedPoint;
  PhotoRecord? selectedRecord;
  String? _currentFloorPlan;

  Future<void> _takePicture(Offset point) async {
    // try {
    //   final currentUser = supabase.auth.currentUser;
    //   if (currentUser == null) {
    //     throw Exception('請先登入');
    //   }

    //   if (_currentFloorPlan == null) {
    //     throw Exception('請先選擇設計圖');
    //   }

    //   final XFile? photo = await _picker.pickImage(
    //     source: ImageSource.camera,
    //     maxWidth: 1920,
    //     maxHeight: 1080,
    //     imageQuality: 85,
    //   );

    //   if (photo == null) return;

    //   if (!mounted) return;
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(const SnackBar(content: Text('正在處理圖片...')));

    //   // 先在本地顯示圖片
    //   String tempImagePath;
    //   if (kIsWeb) {
    //     // Web 平台：將圖片轉換為 data URL
    //     final bytes = await photo.readAsBytes();
    //     final base64 = base64Encode(bytes);
    //     tempImagePath = 'data:image/jpeg;base64,$base64';
    //   } else {
    //     tempImagePath = photo.path;
    //   }

    //   final tempRecord = PhotoRecord(
    //     userId: currentUser.id,
    //     username: currentUser.email ?? '未知用戶',
    //     imagePath: tempImagePath,
    //     point: point,
    //     timestamp: DateTime.now(),
    //     floorPlanPath: _currentFloorPlan!,
    //     isLocal: true,
    //   );

    //   setState(() {
    //     records.add(tempRecord);
    //     selectedRecord = tempRecord;
    //   });

    //   // 獲取並壓縮圖片
    //   Uint8List? compressedBytes;
    //   if (kIsWeb) {
    //     // Web 平台：直接讀取圖片數據
    //     compressedBytes = await photo.readAsBytes();
    //   } else {
    //     // 其他平台：使用 FlutterImageCompress
    //     final file = File(photo.path);
    //     compressedBytes = await FlutterImageCompress.compressWithFile(
    //       file.absolute.path,
    //       quality: 85,
    //       minWidth: 1024,
    //       minHeight: 1024,
    //     );
    //   }

    //   if (compressedBytes == null) throw Exception('圖片壓縮失敗');

    //   // 上傳圖片並創建記錄
    //   final updatedRecord = await _intergratedService
    //       .uploadPhotoAndCreateRecord(
    //         localPath: photo.path,
    //         photoBytes: compressedBytes,
    //         x: point.dx,
    //         y: point.dy,
    //         floorPlanPath: _currentFloorPlan!,
    //       );

    //   if (mounted) {
    //     setState(() {
    //       final index = records.indexOf(tempRecord);
    //       if (index != -1) {
    //         records[index] = updatedRecord;
    //         if (selectedRecord == tempRecord) {
    //           selectedRecord = updatedRecord;
    //         }
    //       }
    //     });

    //     ScaffoldMessenger.of(
    //       context,
    //     ).showSnackBar(const SnackBar(content: Text('上傳完成')));
    //   }
    // } catch (e) {
    //   if (mounted) {
    //     ScaffoldMessenger.of(
    //       context,
    //     ).showSnackBar(SnackBar(content: Text('上傳失敗: ${e.toString()}')));
    //   }
    // }
  }

  PhotoRecord? _findNearestRecord(Offset point) {
    const double threshold = 20.0;
    PhotoRecord? nearest;
    double minDistance = double.infinity;

    for (var record in records) {
      if (record.floorPlanId != _currentFloorPlan) continue;

      final distance = (record.point - point).distance;
      if (distance < threshold && distance < minDistance) {
        minDistance = distance;
        nearest = record;
      }
    }

    return nearest;
  }

  void _handleTapUp(Offset point) {
    final nearest = _findNearestRecord(point);

    setState(() {
      if (nearest != null) {
        selectedRecord = nearest;
        selectedPoint = nearest.point;
      } else if (_isRecordMode) {
        selectedPoint = point;
        selectedRecord = null;
        _takePicture(point);
      }
    });
  }

  void _openFloorPlanSelector() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => FloorPlanSelectorPage(
    //       onFloorPlanSelected: (String assetPath) {
    //         setState(() {
    //           _currentFloorPlan = assetPath;
    //         });
    //         Navigator.pop(context);
    //       },
    //       intergratedService: _intergratedService,
    //     ),
    //   ),
    // );
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
          onPressed: _openFloorPlanSelector,
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
            child: _currentFloorPlan == null
                ? FloorPlanUploadWidget()
                : FloorPlanView(
                    imageUrl: _currentFloorPlan!,
                    records: records
                        .where((r) => r.floorPlanId == _currentFloorPlan)
                        .toList(),
                    onTapUp: (x) {},
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
