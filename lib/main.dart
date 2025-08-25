import 'package:ctc/pages/photo_record_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
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
/*
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
  bool _isLoading = false;
  Offset? selectedPoint;
  PhotoRecord? selectedRecord;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadRecords();
    // 設置60秒自動重新載入
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _loadRecords();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadRecords() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('請先登入');
      }

      final response = await supabase
          .from('photo_records')
          .select()
          .order('created_at');

      final newRecords = (response as List<dynamic>)
          .map((record) => PhotoRecord.fromJson(record))
          .toList();

      if (mounted) {
        setState(() {
          records.clear();
          records.addAll(newRecords);
          _isLoading = false;
        });
      }
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
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('請先登入');
      }

      // 不要立即顯示全螢幕載入指示器，讓使用者看到拍照預覽
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (photo == null) return;

      // 顯示上傳進度提示
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('正在處理圖片...')),
      );

      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String userFilePath = 'user_$userId/$fileName';
      
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
      final currentUser = supabase.auth.currentUser!;
      final timestamp = DateTime.now();
      final tempRecord = PhotoRecord(
        userId: currentUser.id,
        username: currentUser.email ?? '未知用戶',
        imagePath: photo.path,
        point: point,
        timestamp: timestamp,
        isLocal: true,
      );
      
      setState(() {
        records.add(tempRecord);
        selectedRecord = tempRecord;
      });

      // 上傳圖片到 Storage
      await supabase.storage
          .from('site_photos')
          .uploadBinary(
            userFilePath,
            compressedBytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      // 獲取公開訪問URL
      final String publicUrl = supabase.storage
          .from('site_photos')
          .getPublicUrl(userFilePath);

      // 儲存記錄到資料庫
      final recordData = {
        'user_id': currentUser.id,
        'image_url': publicUrl,
        'x_coordinate': point.dx,
        'y_coordinate': point.dy,
        'created_at': timestamp.toIso8601String(),
      };

      final response = await supabase
          .from('photo_records')
          .insert(recordData)
          .select()
          .single();
      
      // 更新本地記錄
      if (mounted) {
        setState(() {
          final index = records.indexOf(tempRecord);
          if (index != -1) {
            final updatedRecord = PhotoRecord.fromJson(response);
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
*/