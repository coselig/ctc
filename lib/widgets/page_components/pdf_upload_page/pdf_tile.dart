
import 'package:ctc/models/pdf_page.dart';
import 'package:ctc/pages/management/upload_pdf_page.dart';
import 'package:flutter/material.dart';

class PdfFileTile extends StatefulWidget {
  final PdfPage file;
  final int? order;
  final ValueChanged<String> onRename;
  final ValueChanged<int>? onOrderChanged;
  const PdfFileTile({
    required this.file,
    required this.onRename,
    this.order,
    this.onOrderChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<PdfFileTile> createState() => _PdfFileTileState();
}

class _PdfFileTileState extends State<PdfFileTile> {
  late TextEditingController _controller;
  bool _editing = false;
bool _editingLabel = false;
  String? _label;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.file.name);
    _label = widget.file.label;
  }

  @override
  void didUpdateWidget(covariant PdfFileTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.file.name != widget.file.name) {
      _controller.text = widget.file.name;
    }
    if (oldWidget.file.label != widget.file.label) {
      _label = widget.file.label;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 取得父層的刪除方法
    final parentState = context.findAncestorStateOfType<UploadPdfPageState>();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // 順序號顯示和編輯
            Container(
              width: 50,
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Text(
                    '${widget.order ?? '?'}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  if (widget.onOrderChanged != null)
                    IconButton(
                      icon: const Icon(Icons.edit, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () async {
                        final controller = TextEditingController(
                          text: '${widget.order ?? 0}',
                        );
                        final newOrder = await showDialog<int>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('設定順序'),
                            content: TextField(
                              controller: controller,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: '順序號',
                                hintText: '輸入數字',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('取消'),
                              ),
                              TextButton(
                                onPressed: () {
                                  final value = int.tryParse(controller.text);
                                  Navigator.pop(ctx, value);
                                },
                                child: const Text('確定'),
                              ),
                            ],
                          ),
                        );
                        if (newOrder != null && widget.onOrderChanged != null) {
                          widget.onOrderChanged!(newOrder);
                        }
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // 拖動手柄
            const Icon(Icons.drag_handle, color: Colors.grey),
            const SizedBox(width: 8),
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
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _editingLabel
                              ? TextField(
                                  decoration: const InputDecoration(
                                    labelText: '中文標籤',
                                    border: OutlineInputBorder(),
                                  ),
                                  controller: TextEditingController(
                                    text: _label ?? '',
                                  ),
                                  onSubmitted: (v) async {
                                    setState(() {
                                      _editingLabel = false;
                                      _label = v;
                                    });
                                    final parentState = context
                                        .findAncestorStateOfType<
                                          UploadPdfPageState
                                        >();
                                    if (parentState != null) {
                                      parentState.pdfLabels[widget.file.name] =
                                          v;
                                      await parentState.savePdfLabels();
                                      await parentState.fetchPdfFiles();
                                    }
                                  },
                                )
                              : GestureDetector(
                                  onTap: () =>
                                      setState(() => _editingLabel = true),
                                  child: Text(
                                    _label ?? '（點擊編輯中文標籤）',
                                    style: const TextStyle(
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ),
                        ),
                      ],
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
                        parentState.deletePdf(widget.file);
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
