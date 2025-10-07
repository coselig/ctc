import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ctc/pages/ha_page.dart';
import 'package:ctc/pages/join_company_page.dart';
import 'package:ctc/pages/product_compass.dart';
import 'package:ctc/pages/user_settings_page.dart';
import 'package:ctc/services/image_service.dart';
import 'package:ctc/widgets/company_info_footer.dart';
import 'package:ctc/widgets/compass_background.dart';
import 'package:ctc/widgets/responsive_container.dart';
import 'package:ctc/widgets/transparent_app_bar.dart';
import 'package:ctc/widgets/unified_card.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_page.dart';
import 'product_page.dart';
import 'system_home_page.dart';

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
  StreamSubscription<AuthState>? _authSubscription;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = supabase.auth.currentUser;
    _setupAuthListener();
    _loadImages();
    _startImageTimer();
  }

  void _setupAuthListener() {
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (mounted) {
        setState(() {
          _currentUser = session?.user;
        });
      }

      // 可選：添加日誌以便調試
      debugPrint('Auth state changed: $event, User: ${_currentUser?.email}');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }

  void _loadImages() async {
    try {
      debugPrint('Loading carousel images...');
      final imageService = ImageService();
      final List<String> fileNames = ['bedroom.jpg', 'living-room.jpg'];

      // 分批載入，避免同時載入太多圖片
      for (String fileName in fileNames) {
        try {
          final url = await imageService
              .getImageUrl(fileName)
              .timeout(const Duration(seconds: 5));

          if (mounted) {
            setState(() {
              _imageUrls.add(url);
              debugPrint('Added carousel URL: $url');
            });
          }
        } catch (e) {
          debugPrint('Failed to load image $fileName: $e');
        }
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

  void _handleLoginTap() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AuthPage(
          onThemeToggle: widget.onThemeToggle,
          currentThemeMode: widget.currentThemeMode,
        ),
      ),
    );

    // 登入頁面返回後，強制刷新狀態
    if (mounted) {
      setState(() {
        _currentUser = supabase.auth.currentUser;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser; // 使用 _currentUser 而不是即時查詢
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: TransparentAppBar(
        showUserInfo: user != null, // 登入後顯示用戶資訊
        actions: [
          IconButton(
            icon: Icon(_getThemeIcon(), color: primaryColor),
            onPressed: widget.onThemeToggle,
            tooltip: '切換主題',
          ),
          if (user != null)
            IconButton(
              icon: Icon(Icons.settings, color: primaryColor),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        UserSettingsPage(onThemeChanged: widget.onThemeToggle),
                  ),
                );
              },
              tooltip: '用戶設置',
            ),
          if (user == null)
            TextButton.icon(
              icon: Icon(Icons.login, color: primaryColor),
              label: Text('登入', style: TextStyle(color: primaryColor)),
              onPressed: _handleLoginTap,
            )
          else
            PopupMenuButton<String>(
              icon: Icon(Icons.account_circle, color: primaryColor),
              tooltip: '用戶選單',
              onSelected: (value) {
                switch (value) {
                  case 'system':
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SystemHomePage(
                          title: '光悅科技管理系統',
                          onThemeToggle: widget.onThemeToggle,
                          currentThemeMode: widget.currentThemeMode,
                        ),
                      ),
                    );
                    break;
                  case 'settings':
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            UserSettingsPage(onThemeChanged: widget.onThemeToggle),
                      ),
                    );
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'system',
                  child: ListTile(
                    leading: Icon(Icons.dashboard, color: primaryColor),
                    title: const Text('進入系統'),
                    dense: true,
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'settings',
                  child: ListTile(
                    leading: Icon(Icons.settings, color: primaryColor),
                    title: const Text('用戶設置'),
                    dense: true,
                  ),
                ),
              ],
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
                            ).colorScheme.onSurface.withValues(alpha: 0.9),
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
                        LayoutBuilder(
                          builder: (context, constraints) {
                            // 根據螢幕寬度決定列數
                            int crossAxisCount;
                            double childAspectRatio;

                            if (constraints.maxWidth > 600) {
                              // 寬螢幕：三列
                              crossAxisCount = 3;
                              childAspectRatio = 0.6; // 更高的比例，確保有足夠空間顯示文字
                            } else {
                              // 窄螢幕：一列，使用更高的比例來確保文字可見
                              crossAxisCount = 1;
                              childAspectRatio = 0.7; // 調整為更合適的比例，給文字更多空間
                            }

                            return GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: childAspectRatio,
                              children: [
                                UnifiedCard(
                                  imageName: 'DI.jpg',
                                  title: '高規元件',
                                  subtitle: '台灣製造\n調光控制器',
                                  cardType: CardType.product,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ProductPage(),
                                      ),
                                    );
                                  },
                                ),
                                UnifiedCard(
                                  imageName: 'HA.jpg',
                                  title: '開源整合平台',
                                  subtitle: '啟動智慧生活\nHome Assistant',
                                  cardType: CardType.product,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HAPage(),
                                      ),
                                    );
                                  },
                                ),
                                UnifiedCard(
                                  imageName: 'LIGHT.jpeg',
                                  title: '快時尚照明',
                                  subtitle: '裝修新高度\n輕量複和金屬板',
                                  cardType: CardType.product,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProductCompassPage(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.7,
                          children: [
                            const UnifiedCard(
                              imageName: 'customize_service.jpg',
                              title: '客製化服務',
                              subtitle: '專屬於你的智慧家居解決方案',
                              cardType: CardType.product,
                            ),
                            UnifiedCard(
                              imageName: 'handshake.jpg',
                              title: '加入光悅',
                              subtitle: '不一樣的工作體驗',
                              cardType: CardType.product,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => JoinCompanyPage(
                                      onThemeToggle: widget.onThemeToggle,
                                      currentThemeMode: widget.currentThemeMode,
                                    ),
                                  ),
                                );
                              },
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
                          crossAxisCount: 6, // 改為6個一排
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.85,
                          children: [
                            UnifiedCard(
                              imageName: 'feasible.png',
                              title: '務實',
                              subtitle: 'Feasible',
                              cardType: CardType.mission,
                              invertColors: true,
                            ),
                            UnifiedCard(
                              imageName: 'stable.png',
                              title: '穩定',
                              subtitle: 'Stable',
                              cardType: CardType.mission,
                              invertColors: true,
                            ),
                            UnifiedCard(
                              imageName: 'affordable.png',
                              title: '實惠',
                              subtitle: 'Affordable',
                              cardType: CardType.mission,
                              invertColors: true,
                            ),
                            UnifiedCard(
                              imageName: 'durable.png',
                              title: '耐用',
                              subtitle: 'Durable',
                              cardType: CardType.mission,
                              invertColors: true,
                            ),
                            UnifiedCard(
                              imageName: 'sustainable.png',
                              title: '永續',
                              subtitle: 'Sustainable',
                              cardType: CardType.mission,
                              invertColors: true,
                            ),
                            UnifiedCard(
                              imageName: 'comfortable.png',
                              title: '舒適',
                              subtitle: 'Comfortable',
                              cardType: CardType.mission,
                              invertColors: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // 使用統一的公司資訊 Widget
                    const CompanyInfoFooter(),
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
