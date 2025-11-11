import 'dart:convert';

import 'package:ctc/models/pdf_page.dart';
import 'package:ctc/services/general/photo_upload_service.dart';
import 'package:ctc/widgets/page_components/pdf_upload_page/pdf_tile.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadPdfPage extends StatefulWidget {
  const UploadPdfPage({Key? key}) : super(key: key);

  @override
  State<UploadPdfPage> createState() => UploadPdfPageState();
}

class UploadPdfPageState extends State<UploadPdfPage> {
  bool isUploading = false;
  String? uploadedPdfUrl;
  String? error;
  String pdfName = '';
  List<PdfPage> pdfFiles = [];
  Map<String, String> pdfLabels = {};
  Map<String, int> pdfOrders = {}; // 儲存 PDF 檔案的順序
  final PhotoUploadService uploadService = PhotoUploadService(
    Supabase.instance.client,
  );

  Future<void> deletePdf(PdfPage file) async {
    try {
      final storage = Supabase.instance.client.storage.from('assets');
      await storage.remove(['books/${file.name}']);
      
      // 同時從 pdf_labels.json 中移除該檔案的標籤
      pdfLabels.remove(file.name);
      await savePdfLabels();
      
      await fetchPdfFiles();
    } catch (e) {
      setState(() {
        error = '刪除失敗: $e';
      });
    }
  }

  Future<void> fetchPdfLabels() async {
    try {
      final storage = Supabase.instance.client.storage.from('assets');
      final res = await storage.download('books/pdf_labels.json');

      final String jsonStr = utf8.decode(res);
      pdfLabels = Map<String, String>.from(json.decode(jsonStr));
    } catch (e) {
      print('取得 pdf_labels.json 失敗: $e');
      pdfLabels = {};
    }
  }

  Future<void> fetchPdfOrders() async {
    try {
      final storage = Supabase.instance.client.storage.from('assets');
      final res = await storage.download('books/pdf_orders.json');

      final String jsonStr = utf8.decode(res);
      final Map<String, dynamic> rawData = json.decode(jsonStr);
      pdfOrders = rawData.map((key, value) => MapEntry(key, value as int));
    } catch (e) {
      print('取得 pdf_orders.json 失敗: $e');
      pdfOrders = {};
    }
  }

  Future<void> savePdfOrders() async {
    try {
      final storage = Supabase.instance.client.storage.from('assets');
      await storage.updateBinary(
        'books/pdf_orders.json',
        utf8.encode(json.encode(pdfOrders)),
      );
    } catch (e) {
      print('儲存 pdf_orders.json 失敗: $e');
    }
  }

  Future<void> savePdfLabels() async {
    try {
      final storage = Supabase.instance.client.storage.from('assets');

      // 按照 _pdfOrders 的順序重新排列 _pdfLabels
      final orderedLabels = <String, String>{};
      final sortedFiles = pdfLabels.keys.toList()
        ..sort((a, b) {
          final orderA = pdfOrders[a] ?? 999999;
          final orderB = pdfOrders[b] ?? 999999;
          return orderA.compareTo(orderB);
        });

      for (final fileName in sortedFiles) {
        final label = pdfLabels[fileName];
        if (label != null) {
          orderedLabels[fileName] = label;
        }
      }
      
      await storage.updateBinary(
        'books/pdf_labels.json',
        utf8.encode(json.encode(orderedLabels)),
      );
    } catch (e) {
      print('儲存 pdf_labels.json 失敗: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPdfFiles();
  }

  Future<void> fetchPdfFiles() async {
    try {
      final response = await Supabase.instance.client.storage
          .from('assets')
          .list(path: 'books');
      
      // 載入舊的標籤資料和順序資料
      await fetchPdfLabels();
      await fetchPdfOrders();
      final oldLabels = Map<String, String>.from(pdfLabels);
      final oldOrders = Map<String, int>.from(pdfOrders);
      
      // 取得實際存在的 PDF 檔案
      final pdfFileObjects = response
          .where((f) => f.name.toLowerCase().endsWith('.pdf'))
          .toList();
      
      // 重建標籤和順序 Map，只保留實際存在檔案的資料
      pdfLabels.clear();
      pdfOrders.clear();
      for (final file in pdfFileObjects) {
        final label = oldLabels[file.name];
        if (label != null) {
          pdfLabels[file.name] = label;
        }
        final order = oldOrders[file.name];
        if (order != null) {
          pdfOrders[file.name] = order;
        }
      }
      
      // 重新儲存乾淨的 pdf_labels.json 和 pdf_orders.json
      await savePdfLabels();
      await savePdfOrders();
      
      setState(() {
        pdfFiles = pdfFileObjects
            .map(
              (f) => PdfPage(
                name: f.name,
                url: Supabase.instance.client.storage
                    .from('assets')
                    .getPublicUrl('books/${f.name}'),
                label: pdfLabels[f.name],
              ),
            )
            .toList();
        
        // 根據順序排序
        pdfFiles.sort((a, b) {
          final orderA = pdfOrders[a.name] ?? 999999;
          final orderB = pdfOrders[b.name] ?? 999999;
          return orderA.compareTo(orderB);
        });
      });
    } catch (e) {
      setState(() {
        error = '取得 PDF 清單失敗: $e';
      });
    }
  }

  Future<void> _pickAndUploadPdf() async {
    setState(() {
      isUploading = true;
      error = null;
      uploadedPdfUrl = null;
    });
    try {
      final result = await uploadService.uploadPdfToBooksFolder(
        name: pdfName.trim().isEmpty ? null : pdfName.trim(),
      );
      setState(() {
        uploadedPdfUrl = result;
      });
      await fetchPdfFiles();
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  Future<void> _renamePdf(PdfPage file, String newName) async {
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
      await fetchPdfFiles();
    } catch (e) {
      setState(() {
        error = '重新命名失敗: $e';
      });
    }
  }

  /// 更新 PDF 順序
  Future<void> _updateOrder(String fileName, int newOrder) async {
    setState(() {
      final oldOrder = pdfOrders[fileName] ?? 999999;

      // 調整其他檔案的順序
      for (final name in pdfOrders.keys) {
        if (name == fileName) continue;

        final currentOrder = pdfOrders[name]!;

        if (oldOrder < newOrder) {
          // 向後移動：中間的檔案向前移
          if (currentOrder > oldOrder && currentOrder <= newOrder) {
            pdfOrders[name] = currentOrder - 1;
          }
        } else {
          // 向前移動：中間的檔案向後移
          if (currentOrder >= newOrder && currentOrder < oldOrder) {
            pdfOrders[name] = currentOrder + 1;
          }
        }
      }

      // 設定新順序
      pdfOrders[fileName] = newOrder;
    });
    await savePdfOrders();
    await fetchPdfFiles();
  }

  /// 拖放重新排序
  Future<void> _onReorder(int oldIndex, int newIndex) async {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = pdfFiles.removeAt(oldIndex);
      pdfFiles.insert(newIndex, item);

      // 重新分配順序號
      for (int i = 0; i < pdfFiles.length; i++) {
        pdfOrders[pdfFiles[i].name] = i;
      }
    });
    await savePdfOrders();
    await savePdfLabels();
  }

  /// 自動編號（根據當前列表順序）
  Future<void> _autoAssignOrders() async {
    setState(() {
      for (int i = 0; i < pdfFiles.length; i++) {
        pdfOrders[pdfFiles[i].name] = i;
      }
    });
    await savePdfOrders();
    await savePdfLabels();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已自動編號完成')));
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
                onChanged: (v) => setState(() => pdfName = v),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isUploading ? null : _pickAndUploadPdf,
                child: isUploading
                    ? const CircularProgressIndicator()
                    : const Text('選擇並上傳 PDF'),
              ),
              if (uploadedPdfUrl != null) ...[
                const SizedBox(height: 24),
                const Text('PDF 上傳成功！檔案連結：'),
                SelectableText(uploadedPdfUrl ?? ''),
              ],
              if (error != null) ...[
                const SizedBox(height: 24),
                Text('錯誤：$error', style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 32),
              Row(
                children: [
                  const Text(
                    '目前 PDF 檔案：',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _autoAssignOrders,
                    icon: const Icon(Icons.sort),
                    label: const Text('自動編號'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorder: _onReorder,
                children: pdfFiles
                    .map(
                      (file) => PdfFileTile(
                        key: ValueKey(file.name),
                        file: file,
                        order: pdfOrders[file.name],
                        onRename: (newName) => _renamePdf(file, newName),
                        onOrderChanged: (newOrder) =>
                            _updateOrder(file.name, newOrder),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


