import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../services/user_service.dart';

/// 用戶資料管理頁面
/// 展示如何使用 UserService 進行 CRUD 操作
class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late final UserService _userService;
  UserProfile? _currentUser;
  bool _isLoading = true;

  final _fullNameController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  String _selectedTheme = 'system';

  @override
  void initState() {
    super.initState();
    _userService = UserService(Supabase.instance.client);
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  /// 載入當前用戶資料
  Future<void> _loadCurrentUser() async {
    setState(() => _isLoading = true);

    try {
      final user = await _userService.getCurrentUserProfile();

      if (user != null) {
        setState(() {
          _currentUser = user;
          _fullNameController.text = user.fullName ?? '';
          _avatarUrlController.text = user.avatarUrl ?? '';
          _selectedTheme = user.themePreference;
        });
      } else {
        // 如果沒有 profile，嘗試創建一個
        await _createUserProfile();
      }
    } catch (e) {
      _showErrorSnackBar('載入用戶資料失敗: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 創建用戶 Profile
  Future<void> _createUserProfile() async {
    try {
      final user = await _userService.upsertCurrentUserProfile(
        fullName: '新用戶',
        themePreference: 'system',
      );

      if (user != null) {
        setState(() => _currentUser = user);
        _showSuccessSnackBar('用戶 Profile 創建成功');
      }
    } catch (e) {
      _showErrorSnackBar('創建 Profile 失敗: $e');
    }
  }

  /// 更新用戶資料
  Future<void> _updateUserProfile() async {
    if (_currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      final updatedUser = await _userService.updateCurrentUserProfile(
        fullName: _fullNameController.text.trim().isEmpty
            ? null
            : _fullNameController.text.trim(),
        avatarUrl: _avatarUrlController.text.trim().isEmpty
            ? null
            : _avatarUrlController.text.trim(),
        themePreference: _selectedTheme,
      );

      if (updatedUser != null) {
        setState(() => _currentUser = updatedUser);
        _showSuccessSnackBar('資料更新成功');
      } else {
        _showErrorSnackBar('更新失敗');
      }
    } catch (e) {
      _showErrorSnackBar('更新失敗: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 根據 ID 搜尋用戶
  Future<void> _searchUserById(String userId) async {
    if (userId.trim().isEmpty) return;

    try {
      final user = await _userService.getUserProfileById(userId.trim());

      if (user != null) {
        _showInfoDialog('找到用戶', '''
ID: ${user.id}
Email: ${user.email ?? '未設定'}
姓名: ${user.fullName ?? '未設定'}
主題偏好: ${user.themePreference}
建立時間: ${user.createdAt}
        ''');
      } else {
        _showErrorSnackBar('找不到該用戶');
      }
    } catch (e) {
      _showErrorSnackBar('搜尋失敗: $e');
    }
  }

  /// 顯示成功訊息
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  /// 顯示錯誤訊息
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// 顯示資訊對話框
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

  /// 顯示搜尋對話框
  void _showSearchDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('透過 ID 搜尋用戶'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '輸入用戶 ID',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _searchUserById(controller.text);
            },
            child: const Text('搜尋'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用戶資料管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
            tooltip: '搜尋用戶',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCurrentUser,
            tooltip: '重新載入',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
          ? _buildNoUserWidget()
          : _buildUserProfileForm(),
    );
  }

  Widget _buildNoUserWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('沒有找到用戶資料'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _createUserProfile,
            child: const Text('創建 Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用戶基本資訊
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('基本資訊', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Text('ID: ${_currentUser!.id}'),
                  Text('Email: ${_currentUser!.email ?? '未設定'}'),
                  Text('建立時間: ${_currentUser!.createdAt}'),
                  Text('更新時間: ${_currentUser!.updatedAt}'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 可編輯的資料
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('可編輯資料', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: '姓名',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _avatarUrlController,
                    decoration: const InputDecoration(
                      labelText: '頭像 URL',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedTheme,
                    decoration: const InputDecoration(
                      labelText: '主題偏好',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'light', child: Text('淺色')),
                      DropdownMenuItem(value: 'dark', child: Text('深色')),
                      DropdownMenuItem(value: 'system', child: Text('系統')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedTheme = value);
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateUserProfile,
                      child: const Text('更新資料'),
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
}
