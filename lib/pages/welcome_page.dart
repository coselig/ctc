import 'package:ctc/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'auth_page.dart';
import 'photo_record_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({
    super.key,
    required this.onThemeToggle,
    required this.currentThemeMode,
  });

  final VoidCallback onThemeToggle;
  final ThemeMode currentThemeMode;

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final supabase = Supabase.instance.client;
  int _currentImageIndex = 0;
  final List<String> _imageUrls = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadImages();
    _startImageTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadImages() async {
    try {
      debugPrint('Attempting to access Supabase storage...');
      final storage = supabase.storage;

      // 從 Supabase Storage 獲取圖片 URL
      final List<String> fileNames = ['bedroom.jpg', 'living-room.jpg'];
      final List<String> urls = [];

      for (var fileName in fileNames) {
        try {
          debugPrint('Attempting to get URL for $fileName');
          final url = storage.from('assets').getPublicUrl(fileName);
          debugPrint('Successfully generated URL for $fileName: $url');
          urls.add(url);
        } catch (e) {
          debugPrint('Error getting URL for $fileName: $e');
        }
      }

      if (mounted) {
        setState(() {
          _imageUrls.clear();
          _imageUrls.addAll(urls);
          debugPrint('Set storage URLs: $_imageUrls');
        });
      }
    } catch (error) {
      debugPrint('Error loading images: $error');
      debugPrint('Error details: ${error.toString()}');
    }
  }

  void _startImageTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && _imageUrls.isNotEmpty) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % _imageUrls.length;
        });
      }
    });
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

  void _handleLoginTap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AuthPage(
          onThemeToggle: widget.onThemeToggle,
          currentThemeMode: widget.currentThemeMode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('工地照片記錄系統'),
        actions: [
          IconButton(
            icon: Icon(_getThemeIcon()),
            onPressed: widget.onThemeToggle,
            tooltip: '切換主題',
          ),
          if (user == null)
            TextButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('登入'),
              onPressed: _handleLoginTap,
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            )
          else
            TextButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: const Text('進入系統'),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => PhotoRecordPage(
                      title: '工地照片記錄系統',
                      onThemeToggle: widget.onThemeToggle,
                      currentThemeMode: widget.currentThemeMode,
                    ),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_imageUrls.isEmpty) ...[
              const SizedBox(height: 32),
              Image.asset('assets/sqare_ctc_icon.png', width: 200, height: 200),
            ] else ...[
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.black,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRect(
                      child: OverflowBox(
                        maxHeight: 1000,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: Image.network(
                            _imageUrls[_currentImageIndex],
                            key: ValueKey(_currentImageIndex),
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            height: 400,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _imageUrls.asMap().entries.map((entry) {
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == entry.key
                                  ? Colors.white
                                  : Colors.white.withAlpha(127),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              '工地照片記錄系統',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('輕鬆記錄和管理工地照片', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 32),
            if (user == null) ...[
              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('立即開始使用'),
                onPressed: _handleLoginTap,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ] else ...[
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_forward),
                label: const Text('進入系統'),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => PhotoRecordPage(
                        title: '工地照片記錄系統',
                        onThemeToggle: widget.onThemeToggle,
                        currentThemeMode: widget.currentThemeMode,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '服務項目',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75,
                    children: const [
                      ProductCard(
                        imageName: 'DI.jpg',
                        title: '高規元件',
                        subtitle: '台灣製造\n調光控制器',
                      ),
                      ProductCard(
                        imageName: 'HA.jpg',
                        title: '開源整合平台',
                        subtitle: '啟動智慧生活\nHome Assistant',
                      ),
                      ProductCard(
                        imageName: 'LIGHT.jpeg',
                        title: '快時尚照明',
                        subtitle: '裝修新高度\n輕量複和金屬板',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
