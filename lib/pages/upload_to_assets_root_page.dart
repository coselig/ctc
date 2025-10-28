import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/photo_upload_service.dart';

class UploadToAssetsRootPage extends StatefulWidget {
  const UploadToAssetsRootPage({Key? key}) : super(key: key);

  @override
  State<UploadToAssetsRootPage> createState() => _UploadToAssetsRootPageState();
}

class _UploadToAssetsRootPageState extends State<UploadToAssetsRootPage> {
  bool _isUploading = false;
  String? _uploadedUrl;
  String? _error;

  final PhotoUploadService _uploadService = PhotoUploadService(Supabase.instance.client);

  Future<void> _pickAndUpload() async {
    setState(() {
      _isUploading = true;
      _error = null;
      _uploadedUrl = null;
    });
    try {
      final result = await _uploadService.uploadToAssetsRoot();
      setState(() {
        _uploadedUrl = result;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('上傳到 assets 根目錄')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _isUploading ? null : _pickAndUpload,
              child: _isUploading ? const CircularProgressIndicator() : const Text('選擇並上傳圖片'),
            ),
            if (_uploadedUrl != null) ...[
              const SizedBox(height: 24),
              const Text('上傳成功！圖片連結：'),
              SelectableText(_uploadedUrl!),
              const SizedBox(height: 12),
              Image.network(_uploadedUrl!),
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
