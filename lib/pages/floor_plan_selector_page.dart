import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../pages/permission_management_page.dart';
import '../services/supabase_service.dart';
import '../widgets/compass_background.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/name_input_dialog.dart';
import '../widgets/transparent_app_bar.dart';

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

  Future<void> _showFloorPlanOptions(Map<String, String> floorPlan) async {
    // 簡單的長按顯示刪除對話框，保持原有行為
    await _showDeleteDialog(floorPlan);
  }

  Future<void> _openPermissionManagement(Map<String, String> floorPlan) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PermissionManagementPage(
          floorPlanUrl: floorPlan['asset']!,
          floorPlanName: floorPlan['name']!,
          permissionService: widget.supabaseService.permissionService,
        ),
      ),
    );
  }

  Future<void> _loadFloorPlans() async {
    try {
      setState(() => _isLoading = true);

      final plans = await widget.supabaseService.loadFloorPlans();

      setState(() {
        floorPlans = plans
            .map(
              (plan) => {
                'name': plan['name']?.toString() ?? '未命名',
                'asset': plan['image_url']?.toString() ?? '',
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

    // 添加短暫延遲以確保圖片選擇器完全關閉
    await Future.delayed(const Duration(milliseconds: 300));

    // Show dialog to get the name for the new floor plan
    if (!mounted) return;
    final name = await showDialog<String>(
      context: context,
      barrierDismissible: false, // 防止意外關閉
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
      extendBodyBehindAppBar: true, // 讓內容延伸到 AppBar 後面
      appBar: TransparentAppBar(
        title: const Text('選擇設計圖'),
        showUserInfo: true, // 顯示用戶資訊
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewFloorPlan,
            tooltip: '新增設計圖',
          ),
        ],
      ),
      body: CompassBackground(
        child: Column(
          children: [
            // AppBar 間距
            SizedBox(
              height:
                  MediaQuery.of(context).padding.top +
                  AppBar().preferredSize.height +
                  20, // 額外20像素給用戶資訊
            ),
            Expanded(
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
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, // 每排3個
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: floorPlans.length,
                        itemBuilder: (context, index) {
                          final floorPlan = floorPlans[index];
                          return InkWell(
                            onTap: () =>
                                widget.onFloorPlanSelected(floorPlan['asset']!),
                            onLongPress: () => _showFloorPlanOptions(floorPlan),
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              color: Colors.transparent, // 改為透明背景
                              elevation: 0, // 移除陰影讓它更透明
                              child: Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child:
                                            floorPlan['asset']!.startsWith(
                                              'http',
                                            )
                                            ? Image.network(
                                                floorPlan['asset']!,
                                                fit: BoxFit
                                                    .contain, // 改為 contain，顯示完整圖片
                                                loadingBuilder: (context, child, loadingProgress) {
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
                                                fit: BoxFit
                                                    .contain, // 改為 contain，顯示完整圖片
                                              ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          floorPlans[index]['name']!,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // 權限管理按鈕
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: PopupMenuButton<String>(
                                      icon: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.more_vert,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      onSelected: (value) {
                                        switch (value) {
                                          case 'permissions':
                                            _openPermissionManagement(
                                              floorPlan,
                                            );
                                            break;
                                          case 'delete':
                                            _showDeleteDialog(floorPlan);
                                            break;
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'permissions',
                                          child: Row(
                                            children: [
                                              Icon(Icons.people),
                                              SizedBox(width: 8),
                                              Text('權限管理'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuDivider(),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                '刪除設計圖',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
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
          ],
        ),
      ),
    );
  }
}
