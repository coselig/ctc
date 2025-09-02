import 'package:ctc/pages/product_compass.dart';
import 'package:ctc/widgets/product_card.dart';
import 'package:ctc/widgets/mission_card.dart';
import 'package:ctc/widgets/responsive_container.dart';
import 'package:ctc/widgets/compass_background.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'auth_page.dart';
import 'photo_record_page.dart';
import 'product_page.dart';
import 'package:ctc/services/image_service.dart';

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
      debugPrint('Loading carousel images...');
      final imageService = ImageService();
      final List<String> fileNames = ['bedroom.jpg', 'living-room.jpg'];

      final urls = await imageService.getImageUrls(fileNames);

      if (mounted) {
        setState(() {
          _imageUrls.clear();
          _imageUrls.addAll(urls);
          debugPrint('Set carousel URLs: $_imageUrls');
        });
      }
    } catch (error) {
      debugPrint('Error loading carousel images: $error');
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFD17A3A)), // 更鮮豔的橙棕色
        actions: [
          IconButton(
            icon: Icon(_getThemeIcon(), color: const Color(0xFFD17A3A)),
            onPressed: widget.onThemeToggle,
            tooltip: '切換主題',
          ),
          if (user == null)
            TextButton.icon(
              icon: const Icon(
                Icons.login,
                color: Color(0xFFD17A3A), // 更鮮豔的橙棕色
              ),
              label: const Text(
                '登入',
                style: TextStyle(
                  color: Color(0xFFD17A3A), // 更鮮豔的橙棕色
                ),
              ),
              onPressed: _handleLoginTap,
            )
          else
            TextButton.icon(
              icon: const Icon(
                Icons.arrow_forward,
                color: Color(0xFFD17A3A), // 更鮮豔的橙棕色
              ),
              label: const Text(
                '進入系統',
                style: TextStyle(
                  color: Color(0xFFD17A3A), // 更鮮豔的橙棕色
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PhotoRecordPage(
                      title: '工地照片記錄系統',
                      onThemeToggle: widget.onThemeToggle,
                      currentThemeMode: widget.currentThemeMode,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: CompassBackground(
        child: SingleChildScrollView(
          clipBehavior: Clip.none,
          child: Column(
            children: [
              if (_imageUrls.isEmpty) ...[
                const SizedBox(height: 32),
                Image.asset(
                  'assets/sqare_ctc_icon.png',
                  width: 200,
                  height: 200,
                ),
              ] else ...[
                Container(
                  height: 300,
                  clipBehavior: Clip.none,
                  child: Transform.scale(
                    scale: 1.2,
                    child: SizedBox(
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        clipBehavior: Clip.none,
                        children: [
                          ClipRect(
                            child: OverflowBox(
                              maxHeight: double.infinity,
                              maxWidth: double.infinity,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 800),
                                transitionBuilder:
                                    (
                                      Widget child,
                                      Animation<double> animation,
                                    ) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                child: CachedNetworkImage(
                                  key: ValueKey(_currentImageIndex),
                                  imageUrl: _imageUrls[_currentImageIndex],
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(context).size.width,
                                  height: 600,
                                  errorWidget: (context, url, error) {
                                    debugPrint('Image load error: $error');
                                    return const Center(
                                      child: Icon(Icons.error),
                                    );
                                  },
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
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
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
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
                  ),
                ),
              ],
              ResponsiveContainer(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      'Coselig',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '智慧家居 輕鬆入門',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.9),
                          ),
                    ),
                    const SizedBox(height: 40),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '服務項目',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.75,
                          children: [
                            ProductCard(
                              imageName: 'DI.jpg',
                              title: '高規元件',
                              subtitle: '台灣製造\n調光控制器',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProductPage(),
                                  ),
                                );
                              },
                            ),
                            ProductCard(
                              imageName: 'HA.jpg',
                              title: '開源整合平台',
                              subtitle: '啟動智慧生活\nHome Assistant',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductPage(),
                                  ),
                                );
                              },
                            ),
                            ProductCard(
                              imageName: 'LIGHT.jpeg',
                              title: '快時尚照明',
                              subtitle: '裝修新高度\n輕量複和金屬板',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductCompassPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.7,
                          children: const [
                            ProductCard(
                              imageName: 'customize_service.jpg',
                              title: '客製化服務',
                              subtitle: '專屬於你的智慧家居解決方案',
                            ),
                            ProductCard(
                              imageName: 'handshake.jpg',
                              title: '加入光悅',
                              subtitle: '不一樣的工作體驗',
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text(
                          '價值理念 Our Mission',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.85,
                          children: [
                            MissionCard(
                              imageName: 'feasible.png',
                              title: '務實',
                              subtitle: 'Feasible',
                              invertColors: true,
                            ),
                            MissionCard(
                              imageName: 'stable.png',
                              title: '穩定',
                              subtitle: 'Stable',
                              invertColors: true,
                            ),
                            MissionCard(
                              imageName: 'affordable.png',
                              title: '實惠',
                              subtitle: 'Affordable',
                              invertColors: true,
                            ),
                            MissionCard(
                              imageName: 'durable.png',
                              title: '耐用',
                              subtitle: 'Durable',
                              invertColors: true,
                            ),
                            MissionCard(
                              imageName: 'sustainable.png',
                              title: '永續',
                              subtitle: 'Sustainable',
                              invertColors: true,
                            ),
                            MissionCard(
                              imageName: 'comfortable.png',
                              title: '舒適',
                              subtitle: 'Comfortable',
                              invertColors: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
