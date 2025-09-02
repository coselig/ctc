import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/supabase_service.dart';
import '../widgets/compass_background.dart';
import '../widgets/name_input_dialog.dart';
import '../widgets/confirmation_dialog.dart';

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

class _FloorPlanSelectorPageState extends State<FloorPlanSelectorPage> {
  final ImagePicker _picker = ImagePicker();
  List<Map<String, String>> floorPlans = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFloorPlans();
  }

  Future<void> _showDeleteDialog(Map<String, String> floorPlan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: '確認刪除',
        content: '確定要刪除「${floorPlan['name']}」嗎？\n\n注意：這會同時刪除與此設計圖相關的所有照片記錄。',
        confirmText: '刪除',
        isDestructive: true,
      ),
    );

    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);

        await widget.supabaseService.deleteFloorPlan(floorPlan['asset']!);

        setState(() {
          floorPlans.removeWhere((plan) => plan['asset'] == floorPlan['asset']);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已刪除設計圖：${floorPlan['name']}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('刪除設計圖失敗：${e.toString()}')));
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadFloorPlans() async {
    try {
      setState(() => _isLoading = true);

      final plans = await widget.supabaseService.loadFloorPlans();

      setState(() {
        floorPlans = plans
            .map(
              (plan) => {
                'name': plan['name'] as String,
                'asset': plan['image_url'] as String,
                'isLocal': 'false',
              },
            )
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('載入設計圖失敗：${e.toString()}')));
      }
      setState(() => _isLoading = false);
    }
  }

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
      builder: (context) => const NameInputDialog(
        title: '輸入設計圖名稱',
        labelText: '名稱',
        hintText: '例如：4樓平面圖',
      ),
    );

    if (name == null || name.isEmpty) return;

    try {
      // 顯示上傳進度
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('正在上傳設計圖...')));
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
        floorPlans.add({'name': name, 'asset': imageUrl, 'isLocal': 'false'});
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('已上傳設計圖：$name')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('新增設計圖失敗：${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('選擇設計圖'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewFloorPlan,
            tooltip: '新增設計圖',
          ),
        ],
      ),
      body: CompassBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : floorPlans.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('尚未有任何設計圖'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _addNewFloorPlan,
                      child: const Text('新增設計圖'),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadFloorPlans,
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: floorPlans.length,
                  itemBuilder: (context, index) {
                    final floorPlan = floorPlans[index];
                    return InkWell(
                      onTap: () =>
                          widget.onFloorPlanSelected(floorPlan['asset']!),
                      onLongPress: () => _showDeleteDialog(floorPlan),
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
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value:
                                                    loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
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
              ),
      ),
    );
  }
}
