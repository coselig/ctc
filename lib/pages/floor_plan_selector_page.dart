import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/supabase_service.dart';

class FloorPlanSelectorPage extends StatefulWidget {
  const FloorPlanSelectorPage({
    super.key,
    required this.onFloorPlanSelected,
    required this.supabaseService,
  });

  final Function(String) onFloorPlanSelected;
  final SupabaseService supabaseService;

  @override
  State<FloorPlanSelectorPage> createState() => _FloorPlanSelectorPageState();
}

class _NameInputDialog extends StatefulWidget {
  @override
  _NameInputDialogState createState() => _NameInputDialogState();
}

class _NameInputDialogState extends State<_NameInputDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('輸入設計圖名稱'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: '名稱',
          hintText: '例如：4樓平面圖',
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('確定'),
        ),
      ],
    );
  }
}

class _FloorPlanSelectorPageState extends State<FloorPlanSelectorPage> {
  final ImagePicker _picker = ImagePicker();
  List<Map<String, String>> floorPlans = [
    {'name': '1樓平面圖', 'asset': 'assets/floorplan.png', 'isLocal': 'false'},
    {'name': '2樓平面圖', 'asset': 'assets/floorplan2.png', 'isLocal': 'false'},
    {'name': '3樓平面圖', 'asset': 'assets/floorplan3.png', 'isLocal': 'false'},
  ];

  Future<void> _addNewFloorPlan() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
    );

    if (image == null) return;

    // Show dialog to get the name for the new floor plan
    final name = await showDialog<String>(
      context: context,
      builder: (context) => _NameInputDialog(),
    );

    if (name == null || name.isEmpty) return;

    try {
      // 顯示上傳進度
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('正在上傳設計圖...')),
        );
      }

      // 讀取圖片數據
      final imageBytes = await image.readAsBytes();
      
      // 上傳到 Supabase
      final imageUrl = await widget.supabaseService.uploadFloorPlan(
        localPath: image.path,
        imageBytes: imageBytes,
        name: name,
      );

      // 更新列表
      setState(() {
        floorPlans.add({
          'name': name,
          'asset': imageUrl,
          'isLocal': 'false',
        });
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已上傳設計圖：$name')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('新增設計圖失敗：${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('選擇設計圖'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewFloorPlan,
            tooltip: '新增設計圖',
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: floorPlans.length,
        itemBuilder: (context, index) {
          final floorPlan = floorPlans[index];
          final isLocal = floorPlan['isLocal'] == 'true';
          
          return InkWell(
            onTap: () => widget.onFloorPlanSelected(floorPlan['asset']!),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: floorPlan['asset']!.startsWith('http')
                        ? Image.network(
                            floorPlan['asset']!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            floorPlan['asset']!,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      floorPlans[index]['name']!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
