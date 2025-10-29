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

class _WelcomePageState extends State<WelcomePage> {
  final supabase = Supabase.instance.client;
  Timer? _timer;
  StreamSubscription<AuthState>? _authSubscription;
  User? _currentUser;

  bool _loading = true;
  String? _pdfUrl;
  String? _error;

  SfPdfViewer? pdf;

  Future<void> _loadPdfUrl(String fileName) async {
    try {
      final supabase = Supabase.instance.client;
      final url = supabase.storage
          .from('assets')
          .getPublicUrl('books/$fileName');
      setState(() {
        _pdfUrl = url;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'PDF 連結取得失敗: $e';
        _loading = false;
      });
    }
    pdf = SfPdfViewer.network(
      _pdfUrl!,
      pageSpacing: 0,
      canShowScrollStatus: false,
      canShowScrollHead: false,
    );
  }

  @override
  void initState() {
    super.initState();
    _currentUser = supabase.auth.currentUser;
    _setupAuthListener();
    _loadPdfUrl('p.123.pdf');
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

    Widget getBookMark(String name, String pdfName) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _loading = true;
            _loadPdfUrl(pdfName);
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            name,
            style: TextStyle(
              color: primaryColor,
              fontSize: MediaQuery.textScalerOf(context).scale(20),
            ),
          ),
        ),
      );
    }

    return GeneralPage(
      actions: [
        getBookMark("首頁", 'p.123.pdf'),
        getBookMark("產品型錄", 'front.pdf'),
        getBookMark("智能方案流程", 'front.pdf'),
        getBookMark("居家智能提案", 'front.pdf'),
        getBookMark("商業空間智能提案", 'front.pdf'),
        ThemeToggleButton(
          currentThemeMode: widget.currentThemeMode,
          onToggle: widget.onThemeToggle,
          color: primaryColor,
        ),
        AuthActionButton(),
      ],
      children: [
        Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
          ),
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 800,
              ),
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
      ],
      // const CompanyInfoFooter(),
    );
  }
}
