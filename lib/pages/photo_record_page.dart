import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
import '../models/photo_record.dart';
import '../services/supabase_service.dart';
import '../widgets/marker_painter.dart';
import 'floor_plan_selector_page.dart';

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
  late final SupabaseService _supabaseService;
  bool _isLoading = false;
  bool _isRecordMode = false;
  Offset? selectedPoint;
  PhotoRecord? selectedRecord;
  String _currentFloorPlan = 'assets/floorplan.png';

  void _openFloorPlanSelector() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FloorPlanSelectorPage(
          onFloorPlanSelected: (String assetPath) {
            setState(() {
              _currentFloorPlan = assetPath;
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService(supabase);
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      setState(() => _isLoading = true);
      
      final newRecords = await _supabaseService.loadRecords();

      setState(() {
        records.clear();
        records.addAll(newRecords);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入記錄失敗: ${e.toString()}')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

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

  Future<void> _takePicture(Offset point) async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('請先登入');
      }

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (photo == null) return;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('正在處理圖片...')),
      );

      // 先在本地顯示圖片
      final tempRecord = PhotoRecord(
        userId: currentUser.id,
        username: currentUser.email ?? '未知用戶',
        imagePath: photo.path,
        point: point,
        timestamp: DateTime.now(),
        isLocal: true,
      );
      
      setState(() {
        records.add(tempRecord);
        selectedRecord = tempRecord;
      });

      // 壓縮圖片
      final File file = File(photo.path);
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        quality: 85,
        minWidth: 1024,
        minHeight: 1024,
      );
      
      if (compressedBytes == null) throw Exception('圖片壓縮失敗');

      // 上傳圖片並創建記錄
      final updatedRecord = await _supabaseService.uploadPhotoAndCreateRecord(
        localPath: photo.path,
        photoBytes: compressedBytes,
        x: point.dx,
        y: point.dy,
      );
      
      if (mounted) {
        setState(() {
          final index = records.indexOf(tempRecord);
          if (index != -1) {
            records[index] = updatedRecord;
            if (selectedRecord == tempRecord) {
              selectedRecord = updatedRecord;
            }
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('上傳完成')),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('上傳失敗: ${e.toString()}')),
        );
      }
    }
  }

  PhotoRecord? _findNearestRecord(Offset point) {
    const double threshold = 20.0;
    PhotoRecord? nearest;
    double minDistance = double.infinity;

    for (var record in records) {
      final distance = (record.point - point).distance;
      if (distance < threshold && distance < minDistance) {
        minDistance = distance;
        nearest = record;
      }
    }

    return nearest;
  }

  void _handleTapUp(TapUpDetails details) {
    final nearest = _findNearestRecord(details.localPosition);
    
    setState(() {
      if (nearest != null) {
        selectedRecord = nearest;
        selectedPoint = nearest.point;
      } else if (_isRecordMode) {
        selectedPoint = details.localPosition;
        selectedRecord = null;
        _takePicture(details.localPosition);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: _openFloorPlanSelector,
            tooltip: '選擇設計圖',
          ),
          IconButton(
            icon: Icon(_isRecordMode ? Icons.camera_alt : Icons.camera_alt_outlined),
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
              await supabase.auth.signOut();
            },
            tooltip: '登出',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              constrained: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: GestureDetector(
                onTapUp: _handleTapUp,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Center(
                      child: Image.asset(
                        _currentFloorPlan,
                        fit: BoxFit.contain,
                        width: double.infinity,
                      ),
                    ),
                    SizedBox.expand(
                      child: CustomPaint(
                        painter: MarkerPainter(
                          records: records,
                          selectedPoint: selectedPoint,
                          selectedRecord: selectedRecord,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (selectedRecord != null) SizedBox(
            height: 200,
            child: Card(
              margin: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: selectedRecord!.isLocal
                        ? Image.file(
                            File(selectedRecord!.imagePath),
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            selectedRecord!.imagePath,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '拍攝時間: ${selectedRecord!.timestamp.toString()}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '拍攝者: ${selectedRecord!.username}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

  }
}
