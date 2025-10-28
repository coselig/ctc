import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfPreviewMini extends StatefulWidget {
  final String fileName;
  const PdfPreviewMini({Key? key, required this.fileName}) : super(key: key);

  @override
  State<PdfPreviewMini> createState() => _PdfPreviewMiniState();
}

class _PdfPreviewMiniState extends State<PdfPreviewMini> {
  String? _pdfUrl;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPdfUrl();
  }

  Future<void> _loadPdfUrl() async {
    try {
      final supabase = Supabase.instance.client;
      final url = supabase.storage
          .from('assets')
          .getPublicUrl('books/${widget.fileName}');
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
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null || _pdfUrl == null || _pdfUrl!.isEmpty) {
      return const Center(child: Text('PDF 預覽失敗', style: TextStyle(color: Colors.red, fontSize: 12)));
    }
    return SfPdfViewer.network(
      _pdfUrl!,
      canShowScrollHead: false,
      canShowScrollStatus: false,
      canShowPaginationDialog: false,
      enableDoubleTapZooming: false,
      pageLayoutMode: PdfPageLayoutMode.single,
    );
  }
}