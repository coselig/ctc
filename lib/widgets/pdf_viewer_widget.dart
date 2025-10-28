import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerWidget extends StatefulWidget {
  final String fileName;
  final String? title;

  const PdfViewerWidget({Key? key, required this.fileName, this.title})
    : super(key: key);

  @override
  State<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends State<PdfViewerWidget> {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'PDF 預覽'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            )
          : (_pdfUrl == null || _pdfUrl!.isEmpty)
          ? const Center(child: Text('無法載入 PDF，連結不存在或路徑錯誤'))
          : SfPdfViewer.network(_pdfUrl!),
    );
  }
}
