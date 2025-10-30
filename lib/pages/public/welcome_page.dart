import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../widgets/widgets.dart';

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

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  Timer? _timer;
  StreamSubscription<AuthState>? _authSubscription;
  User? _currentUser;

  bool _loading = true;
  String? _pdfUrl;
  String? _error;

  SfPdfViewer? pdf;

  String? _activePdf; // ✅ 紀錄目前選中的 PDF
  String? _hoverPdf; // ✅ 紀錄目前 hover 的 PDF

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  Future<void> _loadPdfUrl(String fileName) async {
    try {
      final supabase = Supabase.instance.client;
      final url = supabase.storage
          .from('assets')
          .getPublicUrl('books/$fileName');
      setState(() {
        _pdfUrl = url;
        _loading = false;
        _activePdf = fileName; // ✅ 點擊後更新 active 狀態
      });
      pdf = SfPdfViewer.network(
        _pdfUrl!,
        pageSpacing: 0,
        canShowScrollStatus: false,
        canShowScrollHead: false,
      );
    } catch (e) {
      setState(() {
        _error = 'PDF 連結取得失敗: $e';
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _currentUser = supabase.auth.currentUser;
    _setupAuthListener();
    _loadPdfUrl('p.123.pdf');

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
  }

  void _setupAuthListener() {
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final Session? session = data.session;
      if (mounted) {
        setState(() {
          _currentUser = session?.user;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _authSubscription?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  Widget getBookMark(String name, String pdfName, Color primaryColor) {
    final bool isActive = _activePdf == pdfName;
    final bool isHover = _hoverPdf == pdfName;

    final Color baseColor = isActive
        ? primaryColor
        : (isHover ? primaryColor.withAlpha(180) : Colors.black87);

    final Color bgColor = isActive
        ? primaryColor.withAlpha(38)
        : (isHover ? Colors.white.withAlpha(120) : Colors.white.withAlpha(80));

    return MouseRegion(
      onEnter: (_) => setState(() => _hoverPdf = pdfName),
      onExit: (_) => setState(() => _hoverPdf = null),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _loading = true;
            _loadPdfUrl(pdfName);
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: primaryColor.withAlpha(76),
                      blurRadius: 6,
                      offset: const Offset(2, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            name.split('').join('\n'),
            style: TextStyle(
              color: baseColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> getBookMarks(Color primaryColor) {
    return [
      getBookMark("首頁", 'p1-3(content).pdf', primaryColor),
      getBookMark("產品型錄", 'front.pdf', primaryColor),
      // getBookMark("智能方案流程", 'front.pdf', primaryColor),
      // getBookMark("居家智能提案", 'front.pdf', primaryColor),
      // getBookMark("商業空間智能提案", 'front.pdf', primaryColor),
    ];
  }

  @override
  Widget build(BuildContext context) {
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
      ],
      children: [
        Stack(
          children: [
            // PDF Viewer
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height,
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? Center(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                      : (_pdfUrl == null || _pdfUrl!.isEmpty)
                      ? const Center(child: Text('無法載入 PDF，連結不存在或路徑錯誤'))
                      : pdf,
                ),
              ),
            ),

            // 固定左側垂直導航列（淡入 + hover + active）
            Positioned(
              left: 8,
              top: MediaQuery.of(context).size.height * 0.2,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: getBookMarks(primaryColor),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
