import 'package:ctc/services/general/photo_upload_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadPdfPage extends StatefulWidget {
  const UploadPdfPage({Key? key}) : super(key: key);

  @override
  State<UploadPdfPage> createState() => _UploadPdfPageState();
}

class _UploadPdfPageState extends State<UploadPdfPage> {
  Future<void> _deletePdf(_PdfFile file) async {
    try {
      final storage = Supabase.instance.client.storage.from('assets');
      await storage.remove(['books/${file.name}']);
      await _fetchPdfFiles();
    } catch (e) {
      setState(() {
        _error = '刪除失敗: $e';
      });
    }
  }
  bool _isUploading = false;
  String? _uploadedPdfUrl;
  String? _error;
  String _pdfName = '';
  List<_PdfFile> _pdfFiles = [];
  final PhotoUploadService _uploadService = PhotoUploadService(
    Supabase.instance.client,
  );

  @override
  void initState() {
    super.initState();
    _fetchPdfFiles();
  }

  Future<void> _fetchPdfFiles() async {
    try {
      final response = await Supabase.instance.client.storage
          .from('assets')
          .list(path: 'books');
      print('Supabase books list response:');
      print(response);
      setState(() {
        _pdfFiles = response
            .where((f) => f.name.toLowerCase().endsWith('.pdf'))
            .map(
              (f) => _PdfFile(
                name: f.name,
                url: Supabase.instance.client.storage
                    .from('assets')
                    .getPublicUrl('books/${f.name}'),
              ),
            )
            .toList();
      });
    } catch (e) {
      setState(() {
        _error = '取得 PDF 清單失敗: $e';
      });
    }
  }

  Future<void> _pickAndUploadPdf() async {
    setState(() {
      _isUploading = true;
      _error = null;
      _uploadedPdfUrl = null;
    });
    try {
      final result = await _uploadService.uploadPdfToBooksFolder(name: _pdfName.trim().isEmpty ? null : _pdfName.trim());
      setState(() {
        _uploadedPdfUrl = result;
      });
      await _fetchPdfFiles();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _renamePdf(_PdfFile file, String newName) async {
    if (newName.trim().isEmpty || newName == file.name) return;
    String targetName = newName.trim();
    if (!targetName.toLowerCase().endsWith('.pdf')) {
      targetName += '.pdf';
    }
    try {
      // 先複製再刪除
      final storage = Supabase.instance.client.storage.from('assets');
      final fileBytes = await storage.download('books/${file.name}');
      await storage.uploadBinary('books/$targetName', fileBytes);
      await storage.remove(['books/${file.name}']);
      await _fetchPdfFiles();
    } catch (e) {
      setState(() {
        _error = '重新命名失敗: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF 上傳到 books')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'PDF 檔案名稱（存入資料庫）',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _pdfName = v),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isUploading ? null : _pickAndUploadPdf,
                child: _isUploading
                    ? const CircularProgressIndicator()
                    : const Text('選擇並上傳 PDF'),
              ),
              if (_uploadedPdfUrl != null) ...[
                const SizedBox(height: 24),
                const Text('PDF 上傳成功！檔案連結：'),
                SelectableText(_uploadedPdfUrl!),
              ],
              if (_error != null) ...[
                const SizedBox(height: 24),
                Text('錯誤：$_error', style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 32),
              const Text(
                '目前 PDF 檔案：',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._pdfFiles.map(
                (file) => _PdfFileTile(
                  file: file,
                  onRename: (newName) => _renamePdf(file, newName),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PdfFile {
  final String name;
  final String url;
  _PdfFile({required this.name, required this.url});
}

class _PdfFileTile extends StatefulWidget {
  final _PdfFile file;
  final ValueChanged<String> onRename;
  const _PdfFileTile({required this.file, required this.onRename, Key? key})
    : super(key: key);

  @override
  State<_PdfFileTile> createState() => _PdfFileTileState();
}

class _PdfFileTileState extends State<_PdfFileTile> {
  late TextEditingController _controller;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.file.name);
  }

  @override
  void didUpdateWidget(covariant _PdfFileTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.file.name != widget.file.name) {
      _controller.text = widget.file.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 取得父層的刪除方法
    final parentState = context.findAncestorStateOfType<_UploadPdfPageState>();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _editing = true),
                    child: _editing
                        ? TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              labelText: '重新命名',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (v) {
                              setState(() => _editing = false);
                              widget.onRename(v);
                            },
                          )
                        : Text(
                            widget.file.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                  SelectableText(
                    widget.file.url,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _editing = true),
              tooltip: '重新命名',
            ),
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () {
                // 開啟 PDF 網址
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    content: SizedBox(
                      width: 400,
                      height: 600,
                      child: Column(
                        children: [
                          Text(widget.file.name),
                          SelectableText(widget.file.url),
                        ],
                      ),
                    ),
                  ),
                );
              },
              tooltip: '預覽/複製連結',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: parentState == null
                  ? null
                  : () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('確認刪除'),
                          content: Text(
                            '確定要刪除 "${widget.file.name}" 嗎？此動作無法復原。',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('取消'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('刪除'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        parentState._deletePdf(widget.file);
                      }
                    },
              tooltip: '刪除',
            ),
          ],
        ),
      ),
    );
  }
}