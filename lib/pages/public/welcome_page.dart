import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../widgets/widgets.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({
    super.key,
  });

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  Timer? _timer;

  bool _loading = true;
  String? _pdfUrl;
  String? _error;

  SfPdfViewer? pdf;

  List<String> pdfFiles = [];
  Map<String, String> pdfLabels = {};
  int? _activePdfIndex;
  int? _hoverPdfIndex;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  Future<void> _loadPdfUrl(String fileName) async {
    try {
      setState(() {
        _pdfUrl = 'assets/pages/$fileName';
        _loading = false;
      });
      pdf = SfPdfViewer.asset(
        'assets/pages/$fileName',
        pageSpacing: 0,
        canShowScrollStatus: false,
        canShowScrollHead: false,
      );
    } catch (e) {
      setState(() {
        _error = 'PDF 載入失敗: $e';
        _loading = false;
      });
    }
  }

  Future<void> _fetchPdfFiles() async {
    try {
      // 讀取 AssetManifest.json 取得所有 assets/pages/ 下的 PDF 檔案
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      final files = manifestMap.keys
          .where(
            (String key) =>
                key.startsWith('assets/pages/') && key.endsWith('.pdf'),
          )
          .toList();
      files.sort();
      pdfFiles = files.map((e) => e.replaceFirst('assets/pages/', '')).toList();
      pdfLabels = {for (var f in pdfFiles) f: _autoLabel(f)};
    } catch (e) {
      print('取得 assets/pages/ PDF 檔案失敗: $e');
      pdfLabels = {};
      pdfFiles = [];
    }
  }

  String _autoLabel(String fileName) {
    // 以檔名自動產生 label（去除副檔名、底線轉空格、首字大寫）
    final base = fileName.replaceAll('.pdf', '').replaceAll('_', ' ');
    return base.isNotEmpty
        ? base[0].toUpperCase() + base.substring(1)
        : fileName;
  }

  @override
  void initState() {
    super.initState();
    _activePdfIndex = null;
    _hoverPdfIndex = null;
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _initFilesAndPdf();
  }

  Future<void> _initFilesAndPdf() async {
    await _fetchPdfFiles();
    if (pdfFiles.isNotEmpty) {
      _loadPdfUrl(pdfFiles[0]);
      setState(() {
        _activePdfIndex = 0;
      });
    }
  }



  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  Widget getBookMark(String name, String pdfName, Color primaryColor) {
    final int idx = pdfFiles.indexOf(pdfName);
    final bool isActive = _activePdfIndex == idx;
    final bool isHover = _hoverPdfIndex == idx;

    final Color baseColor = isActive
        ? primaryColor
        : (isHover ? primaryColor.withAlpha(180) : Colors.black87);

    final Color bgColor = isActive
        ? primaryColor.withAlpha(38)
        : (isHover ? Colors.white.withAlpha(120) : Colors.white.withAlpha(80));

    return MouseRegion(
      onEnter: (_) => setState(() => _hoverPdfIndex = idx),
      onExit: (_) => setState(() => _hoverPdfIndex = null),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _loading = true;
            _activePdfIndex = idx;
          });
          _loadPdfUrl(pdfFiles[idx]);
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
              fontSize: MediaQuery.of(context).textScaler.scale(20),
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> getBookMarks(Color primaryColor) {
    return [
      for (int i = 0; i < pdfFiles.length; i++)
        getBookMark(
          pdfLabels[pdfFiles[i]] ?? pdfFiles[i],
          pdfFiles[i],
          primaryColor,
        ),
    ];
    //首頁
    //產品型錄
    //智能方案流程
    //居家智能提案
    //商業空間智能提案
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return GeneralPage(
      actions: [
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
