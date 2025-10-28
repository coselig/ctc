// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/photo_upload_service.dart';

class UploadAssetPage extends StatefulWidget {
  const UploadAssetPage({Key? key}) : super(key: key);

  @override
  State<UploadAssetPage> createState() => _UploadAssetPageState();
}

class _UploadAssetPageState extends State<UploadAssetPage> {
  String _selectedFolder = 'photos'; // 'photos', 'floor_plans', 'assets_root'
  bool _isUploading = false;
  String? _uploadedUrl;
  List<String>? _uploadedUrls;
  String? _uploadedPdfUrl;
  Future<void> _pickAndUploadPdf() async {
    setState(() {
      _isUploading = true;
      _error = null;
      _uploadedPdfUrl = null;
    });
    try {
      final result = await _uploadService.uploadPdfToBooksFolder();
      setState(() {
        _uploadedPdfUrl = result;
      });
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
  String? _error;

  final PhotoUploadService _uploadService = PhotoUploadService(Supabase.instance.client);

  Future<void> _pickAndUpload({bool multiple = false}) async {
    setState(() {
      _isUploading = true;
      _error = null;
      _uploadedUrl = null;
      _uploadedUrls = null;
    });
    try {
      if (multiple) {
        List<String> urls = [];
        if (_selectedFolder == 'assets_root') {
          urls = await _uploadService.uploadMultipleToAssetsRoot();
        } else {
          urls = await _uploadService.pickMultipleAndUploadToFolder(_selectedFolder);
        }
        setState(() {
          _uploadedUrls = urls;
        });
      } else {
        String? result;
        if (_selectedFolder == 'assets_root') {
          result = await _uploadService.uploadToAssetsRoot();
        } else {
          result = await _uploadService.pickPhotoAndUploadToFolder(_selectedFolder);
        }
        setState(() {
          _uploadedUrl = result;
        });
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('上傳資產圖片')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('選擇上傳目標：'),
            Row(
              children: [
                Radio<String>(
                  value: 'photos',
                  groupValue: _selectedFolder,
                  onChanged: (v) => setState(() => _selectedFolder = v!),
                ),
                const Text('員工照片'),
                Radio<String>(
                  value: 'floor_plans',
                  groupValue: _selectedFolder,
                  onChanged: (v) => setState(() => _selectedFolder = v!),
                ),
                const Text('設計圖'),
                Radio<String>(
                  value: 'assets_root',
                  groupValue: _selectedFolder,
                  onChanged: (v) => setState(() => _selectedFolder = v!),
                ),
                const Text('assets 根目錄'),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isUploading ? null : () => _pickAndUpload(multiple: false),
                  child: _isUploading ? const CircularProgressIndicator() : const Text('單檔上傳'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isUploading ? null : () => _pickAndUpload(multiple: true),
                  child: _isUploading ? const CircularProgressIndicator() : const Text('多檔上傳'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isUploading ? null : _pickAndUploadPdf,
                  child: _isUploading
                      ? const CircularProgressIndicator()
                      : const Text('PDF 上傳到 books'),
                ),
              ],
            ),
            if (_uploadedPdfUrl != null) ...[
              const SizedBox(height: 24),
              const Text('PDF 上傳成功！檔案連結：'),
              SelectableText(_uploadedPdfUrl!),
            ],
            if (_uploadedUrl != null) ...[
              const SizedBox(height: 24),
              const Text('上傳成功！圖片連結：'),
              SelectableText(_uploadedUrl!),
              const SizedBox(height: 12),
              Image.network(_uploadedUrl!),
            ],
            if (_uploadedUrls != null && _uploadedUrls!.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text('多檔上傳成功！圖片連結：'),
              ..._uploadedUrls!.map((url) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(url),
                  const SizedBox(height: 8),
                  Image.network(url, height: 120),
                  const SizedBox(height: 16),
                ],
              )),
            ],
            if (_error != null) ...[
              const SizedBox(height: 24),
              Text('錯誤：$_error', style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}

extension PhotoUploadServiceExt on PhotoUploadService {
  Future<String?> pickPhotoAndUploadToFolder(String folder) async {
    // 直接呼叫 pickPhotoAndUpload，並在 service 內部加 folder 參數
    return await pickPhotoAndUpload(folder: folder);
  }
}
