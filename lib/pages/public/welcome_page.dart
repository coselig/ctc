import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/widgets.dart';
import 'public_pages.dart';

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
  bool _hasEmployeePermission = false;

  @override
  void initState() {
    super.initState();
    _currentUser = supabase.auth.currentUser;
    _setupAuthListener();
  }



  void _setupAuthListener() {
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final Session? session = data.session;
      if (mounted) {
        setState(() {
          _currentUser = session?.user;
        });
      }
      // debugPrint('Auth state changed: $event, User: ${_currentUser?.email}');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return GeneralPage(
      actions: [
        ThemeToggleButton(
          currentThemeMode: widget.currentThemeMode,
          onToggle: widget.onThemeToggle,
          color: primaryColor,
        ),
        AuthActionButton(),
        Text("首頁"),
        Text("產品型錄"),
        Text("智能方案流程"),
        Text("居家智能提案"),
        Text("商業空間智能提案"),

      ],
      children: [
        if (_imageUrls.isEmpty) ...[
          const SizedBox(height: 32),
          Image.asset('assets/sqare_ctc_icon.png', width: 200, height: 200),
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
                              (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                          child: Image.asset(
                            "${_imageUrls[_currentImageIndex]}",
                          ),
                          // CachedNetworkImage(
                          //   key: ValueKey(_currentImageIndex),
                          //   imageUrl: _imageUrls[_currentImageIndex],
                          //   fit: BoxFit.cover,
                          //   alignment: Alignment.center,
                          //   width: MediaQuery.of(context).size.width,
                          //   height: 600,
                          //   errorWidget: (context, url, error) {
                          //     debugPrint('Image load error: $error');
                          //     return const Center(child: Icon(Icons.error));
                          //   },
                          //   placeholder: (context, url) => const Center(
                          //     child: CircularProgressIndicator(),
                          //   ),
                          // ),
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
            ),
          ),
        ],
        // 顯示給已登入但沒有員工權限的用戶
        if (user != null && !_hasEmployeePermission)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '您尚未被加入到員工列表',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '請聯繫管理員將您的帳號 (${user.email}) 加入員工管理系統，即可使用系統功能',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
                                  builder: (context) => const ProductPage(),
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
                                  builder: (context) => ProductCompassPage(),
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
                    '產品目錄',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 1,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.7,
                    children: [
                      UnifiedCard(
                        imageName: 'customize_service.jpg',
                        title: '產品目錄 2025',
                        subtitle: '查看光悅科技最新產品與解決方案',
                        cardType: CardType.product,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const IntroPage(),
                            ),
                          );
                        },
                      ),
                      PdfCard(
                        title: '電子型錄',
                        pdfName: 'front.pdf',
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '價值理念 Our Mission',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
    );
  }
}
