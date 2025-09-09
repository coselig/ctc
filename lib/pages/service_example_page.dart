import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';
import '../services/floor_plan_service.dart';
import '../services/photo_record_service.dart';
import '../services/integrated_service.dart';

/// 新服務架構使用範例
class ServiceExamplePage extends StatefulWidget {
  const ServiceExamplePage({Key? key}) : super(key: key);

  @override
  State<ServiceExamplePage> createState() => _ServiceExamplePageState();
}

class _ServiceExamplePageState extends State<ServiceExamplePage> {
  // 方法 1: 使用整合服務（推薦用於快速遷移）
  late final IntegratedService _integratedService;

  // 方法 2: 使用個別服務（推薦用於新專案）
  late final FloorPlanService _floorPlanService;
  late final PhotoRecordService _photoRecordService;

  List<Map<String, dynamic>> _floorPlans = [];
  List<PhotoRecord> _photoRecords = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final client = Supabase.instance.client;

    // 初始化服務
    _integratedService = IntegratedService(client);
    _floorPlanService = FloorPlanService(client);
    _photoRecordService = PhotoRecordService(client);

    _loadData();
  }

  /// 載入資料範例
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // 使用整合服務載入資料
      final floorPlans = await _integratedService.loadFloorPlans();
      final photoRecords = await _integratedService.loadRecords();

      setState(() {
        _floorPlans = floorPlans;
        _photoRecords = photoRecords;
      });
    } catch (e) {
      _showErrorSnackBar('載入資料失敗: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 使用個別服務載入資料的範例
  Future<void> _loadDataWithIndividualServices() async {
    setState(() => _isLoading = true);

    try {
      // 使用個別服務
      final floorPlans = await _floorPlanService.loadFloorPlans();
      final photoRecords = await _photoRecordService.loadRecords();

      setState(() {
        _floorPlans = floorPlans;
        _photoRecords = photoRecords;
      });
    } catch (e) {
      _showErrorSnackBar('載入資料失敗: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 進階功能範例 - 獲取用戶儀表板
  Future<void> _loadUserDashboard() async {
    try {
      final dashboard = await _integratedService.getUserDashboard();

      _showInfoDialog('用戶儀表板', '''
可存取的平面圖: ${dashboard['statistics']['accessible_floor_plans_count']}
擁有的平面圖: ${dashboard['statistics']['owned_floor_plans_count']}
用戶記錄數: ${dashboard['statistics']['user_records_count']}
總記錄數: ${dashboard['statistics']['total_statistics']['total_count']}
今日記錄數: ${dashboard['statistics']['total_statistics']['today_count']}
      ''');
    } catch (e) {
      _showErrorSnackBar('載入儀表板失敗: $e');
    }
  }

  /// 權限檢查範例
  Future<void> _checkPermissions(String floorPlanUrl) async {
    try {
      final permissions = await _integratedService.checkFloorPlanPermissions(
        floorPlanUrl,
      );

      _showInfoDialog('權限資訊', '''
可檢視: ${permissions['canView'] == true ? '是' : '否'}
可編輯: ${permissions['canEdit'] == true ? '是' : '否'}
可刪除: ${permissions['canDelete'] == true ? '是' : '否'}
可分享: ${permissions['canShare'] == true ? '是' : '否'}
是擁有者: ${permissions['isOwner'] == true ? '是' : '否'}
      ''');
    } catch (e) {
      _showErrorSnackBar('檢查權限失敗: $e');
    }
  }

  /// 搜尋照片記錄範例
  Future<void> _searchPhotoRecords() async {
    try {
      final searchResults = await _integratedService.searchPhotoRecords(
        startDate: DateTime.now().subtract(const Duration(days: 7)),
        limit: 10,
      );

      _showInfoDialog('搜尋結果', '找到 ${searchResults.length} 筆最近一週的記錄');
    } catch (e) {
      _showErrorSnackBar('搜尋失敗: $e');
    }
  }

  /// 獲取記錄統計範例
  Future<void> _getStatistics() async {
    try {
      final stats = await _integratedService.getRecordStatistics();

      _showInfoDialog('統計資訊', '''
總記錄數: ${stats['total_count']}
今日記錄數: ${stats['today_count']}
最後更新: ${stats['last_updated']}
      ''');
    } catch (e) {
      _showErrorSnackBar('獲取統計失敗: $e');
    }
  }

  /// 平面圖詳細資訊範例
  Future<void> _getFloorPlanDetails(String floorPlanId) async {
    try {
      final details = await _integratedService.getFloorPlanDetails(floorPlanId);

      if (details != null) {
        _showInfoDialog('平面圖詳細資訊', '''
名稱: ${details['name']}
記錄數量: ${details['records_count']}
分享用戶數: ${details['shared_users_count']}
建立時間: ${details['created_at']}
        ''');
      } else {
        _showErrorSnackBar('找不到平面圖詳細資訊');
      }
    } catch (e) {
      _showErrorSnackBar('獲取詳細資訊失敗: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新服務架構範例'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: '重新載入（整合服務）',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _loadDataWithIndividualServices,
            tooltip: '重新載入（個別服務）',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 功能按鈕區
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _loadUserDashboard,
                        icon: const Icon(Icons.dashboard),
                        label: const Text('用戶儀表板'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _searchPhotoRecords,
                        icon: const Icon(Icons.search),
                        label: const Text('搜尋記錄'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _getStatistics,
                        icon: const Icon(Icons.analytics),
                        label: const Text('獲取統計'),
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // 資料顯示區
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        const TabBar(
                          tabs: [
                            Tab(text: '平面圖', icon: Icon(Icons.map)),
                            Tab(text: '照片記錄', icon: Icon(Icons.photo_camera)),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildFloorPlansList(),
                              _buildPhotoRecordsList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFloorPlansList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _floorPlans.length,
      itemBuilder: (context, index) {
        final floorPlan = _floorPlans[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.map),
            title: Text(floorPlan['name'] ?? '未命名'),
            subtitle: Text('權限等級: ${floorPlan['permission_level']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (floorPlan['is_owner'] == true)
                  const Icon(Icons.star, color: Colors.amber),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('檢查權限'),
                      onTap: () => _checkPermissions(floorPlan['image_url']),
                    ),
                    PopupMenuItem(
                      child: const Text('詳細資訊'),
                      onTap: () => _getFloorPlanDetails(floorPlan['id']),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoRecordsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _photoRecords.length,
      itemBuilder: (context, index) {
        final record = _photoRecords[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.photo_camera),
            title: Text(
              '座標: (${record.point.dx.toStringAsFixed(1)}, ${record.point.dy.toStringAsFixed(1)})',
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('用戶: ${record.username}'),
                Text('建立時間: ${record.timestamp}'),
                if (record.description != null)
                  Text('描述: ${record.description}'),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}

/// 如何在現有專案中整合新服務架構
/// 
/// 1. 快速遷移（最小變更）：
/// ```dart
/// // 將原來的
/// final supabaseService = SupabaseService(client);
/// 
/// // 替換為
/// final integratedService = IntegratedService(client);
/// ```
/// 
/// 2. 漸進式遷移：
/// ```dart
/// class MyService {
///   final IntegratedService _integratedService;
///   final FloorPlanService _floorPlanService;
///   final PhotoRecordService _photoRecordService;
/// 
///   MyService(SupabaseClient client) 
///     : _integratedService = IntegratedService(client),
///       _floorPlanService = FloorPlanService(client),
///       _photoRecordService = PhotoRecordService(client);
/// 
///   // 先使用整合服務保持相容性
///   Future<List<dynamic>> loadFloorPlans() async {
///     return await _integratedService.loadFloorPlans();
///   }
/// 
///   // 逐步使用個別服務的新功能
///   Future<List<dynamic>> searchRecords(String query) async {
///     return await _photoRecordService.searchRecords(description: query);
///   }
/// }
/// ```
