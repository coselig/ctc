import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:typed_data';
import 'dart:io';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qikzlcnsyiihftudbmkp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFpa3psY25zeWlpaGZ0dWRibWtwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM3MzI3NDcsImV4cCI6MjA2OTMwODc0N30.Sjy7wm7gqgXfOy48aW52w9lYD8UdeBoKe3AGY1NaUPk',
  );
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  final supabase = Supabase.instance.client;
  bool _isAuthenticated = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkInitialAuthState();
    _setupAuthListener();
  }

  Future<void> _checkInitialAuthState() async {
    final session = supabase.auth.currentSession;
    if (mounted) {
      setState(() {
        _isAuthenticated = session != null;
        _isLoading = false;
      });
    }
  }

  void _setupAuthListener() {
    supabase.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;
      
      setState(() {
        _isAuthenticated = data.session != null;
      });
    });
  }

  Widget _buildHomeWidget() {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isAuthenticated) {
      return PhotoRecordPage(
        title: '工地照片記錄',
        onThemeToggle: toggleTheme,
        currentThemeMode: _themeMode,
      );
    } else {
      return const LoginPage();
    }
  }
  
  void toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else if (_themeMode == ThemeMode.dark) {
        _themeMode = ThemeMode.system;
      } else {
        _themeMode = ThemeMode.light;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const lightPrimaryColor = Colors.deepPurple;
    const darkPrimaryColor = Colors.purple;
    
    return MaterialApp(
      title: '工地照片記錄',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: lightPrimaryColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: darkPrimaryColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: _buildHomeWidget(),
    );
  }
}

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
  List<PhotoRecord> records = [];
  final ImagePicker _picker = ImagePicker();
  final supabase = Supabase.instance.client;
  final bool _isLoading = false;
  Offset? selectedPoint;
  PhotoRecord? selectedRecord;

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
      // 不要立即顯示全螢幕載入指示器，讓使用者看到拍照預覽
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920, // 限制圖片寬度
        maxHeight: 1080, // 限制圖片高度
        imageQuality: 85, // 降低圖片品質以減少檔案大小
      );
      
      if (photo == null) return;

      // 顯示上傳進度提示
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('正在處理圖片...')),
      );

      // 生成唯一的文件名
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // 壓縮圖片
      final File file = File(photo.path);
      final Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        quality: 85,
        minWidth: 1024,
        minHeight: 1024,
      );
      
      if (compressedBytes == null) throw Exception('圖片壓縮失敗');

      // 先在本地顯示圖片
      final tempRecord = PhotoRecord(
        imagePath: photo.path,
        point: point,
        timestamp: DateTime.now(),
        isLocal: true, // 標記為本地文件
      );
      
      setState(() {
        records.add(tempRecord);
        selectedRecord = tempRecord;
      });

      // 在背景上傳圖片
      final String publicUrl = await _uploadPhoto(fileName, compressedBytes);
      
      // 更新記錄為雲端URL
      if (mounted) {
        setState(() {
          final index = records.indexOf(tempRecord);
          if (index != -1) {
            final updatedRecord = PhotoRecord(
              imagePath: publicUrl,
              point: point,
              timestamp: tempRecord.timestamp,
              isLocal: false, // 標記為雲端URL
            );
            records[index] = updatedRecord;
            if (selectedRecord == tempRecord) {
              selectedRecord = updatedRecord;
            }
          }
        });
      }

      if (mounted) {
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

  Future<String> _uploadPhoto(String fileName, Uint8List bytes) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('請先登入');
    }

    // 在檔案名稱前加上用戶ID作為前綴
    final String userFilePath = 'user_$userId/$fileName';
    
    await supabase.storage
        .from('site_photos')
        .uploadBinary(
          userFilePath,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    return supabase.storage
        .from('site_photos')
        .getPublicUrl(userFilePath);
  }

  PhotoRecord? _findNearestRecord(Offset point) {
    const double threshold = 20.0; // 點擊容差範圍
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
        // 如果點擊位置附近有existing標記，就顯示該照片
        selectedRecord = nearest;
        selectedPoint = nearest.point;
      } else {
        // 如果是新位置，就拍新照片
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
            icon: Icon(_getThemeIcon()),
            onPressed: widget.onThemeToggle,
            tooltip: '切換主題',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
            tooltip: '登出',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: InteractiveViewer(
              constrained: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: GestureDetector(
                onTapUp: _handleTapUp,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 底圖
                    Center(
                      child: Image.asset(
                        'assets/floorplan.png',
                        fit: BoxFit.contain,
                        width: double.infinity,
                      ),
                    ),
                    // 繪製標記點
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
          if (selectedRecord != null) Container(
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
                    child: Text(
                      '拍攝時間: ${selectedRecord!.timestamp}',
                      style: Theme.of(context).textTheme.bodyLarge,
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

class MarkerPainter extends CustomPainter {
  final List<PhotoRecord> records;
  final Offset? selectedPoint;
  final PhotoRecord? selectedRecord;

  MarkerPainter({
    required this.records,
    this.selectedPoint,
    this.selectedRecord,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 繪製所有記錄點
    final dotPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 10
      ..style = PaintingStyle.fill;

    for (var record in records) {
      if (record == selectedRecord) {
        dotPaint.color = Colors.green;
      } else if (record.isLocal) {
        dotPaint.color = Colors.orange; // 上傳中的圖片用橙色標記
      } else {
        dotPaint.color = Colors.red;
      }
      canvas.drawCircle(record.point, 8, dotPaint);
    }

    // 繪製選中的點
    if (selectedPoint != null) {
      final selectedPaint = Paint()
        ..color = Colors.green
        ..strokeWidth = 10
        ..style = PaintingStyle.fill;
      canvas.drawCircle(selectedPoint!, 8, selectedPaint);
    }
  }

  @override
  bool shouldRepaint(covariant MarkerPainter oldDelegate) {
    return oldDelegate.records != records ||
        oldDelegate.selectedPoint != selectedPoint ||
        oldDelegate.selectedRecord != selectedRecord;
  }
}

class PhotoRecord {
  final String imagePath;
  final bool isLocal; // 標記是否為本地文件
  final Offset point;
  final DateTime timestamp;

  PhotoRecord({
    required this.imagePath,
    required this.point,
    required this.timestamp,
    this.isLocal = false,
  });
}