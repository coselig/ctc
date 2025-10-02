import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/coselig_fix_dialog.dart';

class RegisteredUsersDebugPage extends StatefulWidget {
  const RegisteredUsersDebugPage({Key? key}) : super(key: key);

  @override
  State<RegisteredUsersDebugPage> createState() => _RegisteredUsersDebugPageState();
}

class _RegisteredUsersDebugPageState extends State<RegisteredUsersDebugPage> {
  final supabase = Supabase.instance.client;
  
  List<Map<String, dynamic>> userProfiles = [];
  List<Map<String, dynamic>> employees = [];
  bool isLoading = true;
  String? error;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // 查詢 user_profiles
      final userProfilesResponse = await supabase
          .from('user_profiles')
          .select('*')
          .order('created_at', ascending: false);
      
      // 查詢 employees
      final employeesResponse = await supabase
          .from('employees')
          .select('*')
          .order('created_at', ascending: false);

      setState(() {
        userProfiles = List<Map<String, dynamic>>.from(userProfilesResponse);
        employees = List<Map<String, dynamic>>.from(employeesResponse);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _searchCoseligAccount() async {
    setState(() {
      isLoading = true;
    });

    try {
      // 搜尋包含 "coselig" 的帳號
      final searchResponse = await supabase
          .from('user_profiles')
          .select('*')
          .like('email', '%coselig%');
      
      if (searchResponse.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('🎯 找到 Coselig 帳號'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: searchResponse.map((profile) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('📧 Email: ${profile['email']}', 
                             style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('👤 Display Name: ${profile['display_name'] ?? '無'}'),
                        Text('🆔 User ID: ${profile['user_id']}'),
                        Text('📅 Created: ${profile['created_at']}'),
                      ],
                    ),
                  ),
                )).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('關閉'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ 未找到包含 "coselig" 的帳號'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❗ 搜尋錯誤: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('已註冊用戶調試工具'),
        actions: [
          IconButton(
            onPressed: () => showCoseligFixDialog(context),
            icon: const Icon(Icons.build),
            tooltip: '修復 Coselig 帳號',
          ),
          IconButton(
            onPressed: _searchCoseligAccount,
            icon: const Icon(Icons.search),
            tooltip: '搜尋 Coselig 帳號',
          ),
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            tooltip: '重新載入',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 64),
                      const SizedBox(height: 16),
                      Text('錯誤: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('重試'),
                      ),
                    ],
                  ),
                )
              : DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const TabBar(
                        tabs: [
                          Tab(text: '已註冊用戶', icon: Icon(Icons.people)),
                          Tab(text: '員工記錄', icon: Icon(Icons.badge)),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildUserProfilesTab(),
                            _buildEmployeesTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _searchCoseligAccount,
        tooltip: '搜尋 coseligtest@gmail.com',
        child: const Icon(Icons.person_search),
      ),
    );
  }

  Widget _buildUserProfilesTab() {
    final filteredProfiles = userProfiles.where((profile) {
      final email = (profile['email'] ?? '').toString().toLowerCase();
      final name = (profile['display_name'] ?? '').toString().toLowerCase();
      final query = searchQuery.toLowerCase();
      return email.contains(query) || name.contains(query);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: '搜尋用戶',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredProfiles.length,
            itemBuilder: (context, index) {
              final profile = filteredProfiles[index];
              final isTargetUser = (profile['email'] ?? '').toString().toLowerCase() == 'coseligtest@gmail.com';
              
              return Card(
                color: isTargetUser ? Colors.yellow.shade100 : null,
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: profile['avatar_url'] != null
                        ? NetworkImage(profile['avatar_url'])
                        : null,
                    child: profile['avatar_url'] == null
                        ? Text(((profile['display_name'] ?? profile['email'] ?? 'U')[0]).toUpperCase())
                        : null,
                  ),
                  title: Text(
                    profile['display_name'] ?? '無姓名',
                    style: TextStyle(
                      fontWeight: isTargetUser ? FontWeight.bold : FontWeight.normal,
                      color: isTargetUser ? Colors.orange.shade800 : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile['email'] ?? '無郵箱'),
                      Text('User ID: ${profile['user_id']}'),
                      Text('Created: ${profile['created_at']}'),
                    ],
                  ),
                  trailing: isTargetUser ? Icon(Icons.star, color: Colors.orange) : null,
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '總計: ${filteredProfiles.length} 個已註冊用戶',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeesTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final employee = employees[index];
              final isTargetUser = (employee['email'] ?? '').toString().toLowerCase() == 'coseligtest@gmail.com';
              
              return Card(
                color: isTargetUser ? Colors.green.shade100 : null,
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(employee['employee_id'] ?? 'E'),
                  ),
                  title: Text(
                    employee['name'] ?? '無姓名',
                    style: TextStyle(
                      fontWeight: isTargetUser ? FontWeight.bold : FontWeight.normal,
                      color: isTargetUser ? Colors.green.shade800 : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📧 ${employee['email'] ?? '無郵箱'}'),
                      Text('🏢 ${employee['department']} - ${employee['position']}'),
                      Text('📊 狀態: ${employee['status']}'),
                      Text('📅 入職: ${employee['hire_date']}'),
                    ],
                  ),
                  trailing: isTargetUser ? Icon(Icons.check_circle, color: Colors.green) : null,
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '總計: ${employees.length} 位員工',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}