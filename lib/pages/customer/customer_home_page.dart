import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/customer.dart';
import '../../models/project.dart';
import '../../services/customer_service.dart';

/// 客戶主頁面
/// 顯示客戶可訪問的專案列表和個人資料
class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  late final CustomerService _customerService;
  
  Customer? _customer;
  List<Project> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _customerService = CustomerService(Supabase.instance.client);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final customer = await _customerService.getCurrentCustomer();
      final projects = await _loadCustomerProjects();
      
      if (mounted) {
        setState(() {
          _customer = customer;
          _projects = projects;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('載入資料失敗: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 載入客戶可訪問的專案
  Future<List<Project>> _loadCustomerProjects() async {
    try {
      // 透過 project_clients 表查詢客戶相關的專案
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return [];

      final customer = await _customerService.getCurrentCustomer();
      if (customer == null) return [];

      // 先獲取與客戶關聯的專案 ID
      final clientRecords = await Supabase.instance.client
          .from('project_clients')
          .select('project_id')
          .eq('email', customer.email ?? '')
          .or('phone.eq.${customer.phone}');

      if (clientRecords.isEmpty) return [];

      final projectIds = clientRecords
          .map((r) => r['project_id'] as String)
          .toSet()
          .toList();

      // 獲取專案詳細資料
      final projectsData = await Supabase.instance.client
          .from('projects')
          .select()
          .inFilter('id', projectIds)
          .order('created_at', ascending: false);

      return projectsData.map((json) => Project.fromJson(json)).toList();
    } catch (e) {
      print('載入客戶專案失敗: $e');
      return [];
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認登出'),
        content: const Text('您確定要登出嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('登出'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('客戶中心'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: '登出',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  // 客戶資料卡片
                  SliverToBoxAdapter(
                    child: _buildCustomerCard(),
                  ),
                  
                  // 專案列表標題
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.folder_open,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '我的專案',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '共 ${_projects.length} 個專案',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // 專案列表
                  _projects.isEmpty
                      ? SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '目前沒有可訪問的專案',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildProjectCard(_projects[index]),
                              childCount: _projects.length,
                            ),
                          ),
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildCustomerCard() {
    if (_customer == null) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    _customer!.name.isNotEmpty ? _customer!.name[0] : 'C',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _customer!.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_customer!.company != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _customer!.company!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (_customer!.email != null) 
              _buildInfoRow(Icons.email, _customer!.email!),
            if (_customer!.phone != null) 
              _buildInfoRow(Icons.phone, _customer!.phone!),
            if (_customer!.address != null) 
              _buildInfoRow(Icons.location_on, _customer!.address!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(Project project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Icon(
            Icons.business_center,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(
          project.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: project.description != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  project.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : null,
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
        ),
        onTap: () {
          // TODO: 導向專案詳情頁面
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('查看專案: ${project.name}')),
          );
        },
      ),
    );
  }
}
