import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/floor_plans_service.dart';

class FloorPlanUploadWidget extends StatefulWidget {
  const FloorPlanUploadWidget({Key? key}) : super(key: key);

  @override
  State<FloorPlanUploadWidget> createState() => _FloorPlanUploadWidgetState();
}

class _FloorPlanUploadWidgetState extends State<FloorPlanUploadWidget> {
  final FloorPlansService _floorPlansService = FloorPlansService(
    Supabase.instance.client,
  );
  final TextEditingController _nameController = TextEditingController();
  bool _isUploading = false;
  String? _uploadedImageUrl;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// 從圖庫選擇並上傳圖片
  Future<void> _pickFromGallery() async {
    setState(() {
      _isUploading = true;
    });

    try {
      final imageUrl = await _floorPlansService.pickAndUploadImage(
        source: ImageSource.gallery,
      );

      if (imageUrl != null) {
        setState(() {
          _uploadedImageUrl = imageUrl;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('圖片上傳成功！')));
      }
    } catch (e) {
      String errorMessage = '上傳失敗: $e';

      // 檢查具體錯誤類型
      if (e.toString().contains('Invalid key') || 
          e.toString().contains('InvalidKey')) {
        errorMessage = '檔名格式錯誤：請選擇檔名為英文的圖片，或重新命名後再試';
      } else if (e.toString().contains('413') || 
                 e.toString().contains('too large')) {
        errorMessage = '檔案太大：請選擇小於 10MB 的圖片';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  /// 從相機拍照並上傳圖片
  Future<void> _pickFromCamera() async {
    // 檢查使用者是否已登入
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('請先登入後再上傳圖片'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final imageUrl = await _floorPlansService.pickAndUploadImage(
        source: ImageSource.camera,
      );

      if (imageUrl != null) {
        setState(() {
          _uploadedImageUrl = imageUrl;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('圖片上傳成功！')));
      }
    } catch (e) {
      String errorMessage = '上傳失敗: $e';

      // 檢查具體錯誤類型
      if (e.toString().contains('403') ||
          e.toString().contains('Unauthorized')) {
        errorMessage = '權限不足：請確認已登入且有上傳權限';
      } else if (e.toString().contains('請先登入')) {
        errorMessage = '請先登入後再上傳圖片';
      } else if (e.toString().contains('Invalid key') || 
                 e.toString().contains('InvalidKey')) {
        errorMessage = '檔名格式錯誤：請選擇檔名為英文的圖片，或重新命名後再試';
      } else if (e.toString().contains('413') || 
                 e.toString().contains('too large')) {
        errorMessage = '檔案太大：請選擇小於 10MB 的圖片';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  /// 創建完整的設計圖記錄
  Future<void> _createFloorPlan() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('請輸入設計圖名稱')));
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // 確保有圖片URL
      String? imageUrl = _uploadedImageUrl;
      if (imageUrl == null) {
        imageUrl = await _floorPlansService.pickAndUploadImage();
        if (imageUrl == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('未選擇圖片')));
          return;
        }
      }

      // 使用圖片URL創建記錄
      await _floorPlansService.createFloorPlanRecord(
        name: _nameController.text,
        imageUrl: imageUrl,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('設計圖創建成功！')));

      // 清空表單
      _nameController.clear();
      setState(() {
        _uploadedImageUrl = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('創建失敗: $e')));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  /// 顯示圖片選擇對話框
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('選擇圖片來源'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('從圖庫選擇'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('拍照'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 設計圖名稱輸入
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '設計圖名稱',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 圖片上傳區域
            Container(
              height: 180, // 稍微減少高度以節省空間
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _uploadedImageUrl != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _uploadedImageUrl!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _uploadedImageUrl = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18, // 稍微縮小圖示
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : InkWell(
                      onTap: _isUploading ? null : _showImageSourceDialog,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: _isUploading
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 8),
                                    Text('上傳中...'),
                                  ],
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cloud_upload,
                                      size: 40, // 稍微縮小圖示
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '點擊選擇圖片',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            // 上傳按鈕（只在已有圖片時顯示重新選擇）
            if (_uploadedImageUrl != null) ...[
              OutlinedButton(
                onPressed: _isUploading ? null : _showImageSourceDialog,
                child: const Text('重新選擇圖片'),
              ),
              const SizedBox(height: 12),
            ],

            // 創建設計圖按鈕
            ElevatedButton(
              onPressed: _isUploading ? null : _createFloorPlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isUploading 
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('創建設計圖'),
            ),
          ],
        ),
      ),
    );
  }
}
