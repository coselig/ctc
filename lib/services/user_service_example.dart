import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../services/user_service.dart';

/// UserService 使用範例
///
/// 這個範例展示如何使用 UserService 來管理用戶資料
class UserServiceExample {
  late final UserService _userService;

  UserServiceExample() {
    // 初始化 UserService
    _userService = UserService(Supabase.instance.client);
  }

  /// 範例 1: 獲取當前登入用戶的資料
  Future<void> getCurrentUserExample() async {
    print('=== 獲取當前用戶 Profile ===');

    final userProfile = await _userService.getCurrentUserProfile();

    if (userProfile != null) {
      print('用戶資料：');
      print('ID: ${userProfile.id}');
      print('Email: ${userProfile.email}');
      print('姓名: ${userProfile.fullName ?? '未設定'}');
      print('頭像: ${userProfile.avatarUrl ?? '未設定'}');
      print('主題偏好: ${userProfile.themePreference}');
      print('建立時間: ${userProfile.createdAt}');
      print('更新時間: ${userProfile.updatedAt}');
    } else {
      print('找不到用戶資料');
    }
  }

  /// 範例 2: 透過用戶 ID 獲取特定用戶的資料
  Future<void> getUserByIdExample(String userId) async {
    print('=== 透過 ID 獲取用戶 Profile ===');
    print('查詢用戶 ID: $userId');

    final userProfile = await _userService.getUserProfileById(userId);

    if (userProfile != null) {
      print('找到用戶：${userProfile.fullName ?? userProfile.email}');
      print('主題偏好: ${userProfile.themePreference}');
    } else {
      print('找不到指定的用戶');
    }
  }

  /// 範例 3: 更新當前用戶的資料
  Future<void> updateCurrentUserExample() async {
    print('=== 更新當前用戶 Profile ===');

    final updatedProfile = await _userService.updateCurrentUserProfile(
      fullName: '新的用戶名稱',
      themePreference: 'dark',
    );

    if (updatedProfile != null) {
      print('更新成功！');
      print('新姓名: ${updatedProfile.fullName}');
      print('新主題: ${updatedProfile.themePreference}');
    } else {
      print('更新失敗');
    }
  }

  /// 範例 4: 為新用戶創建 Profile
  Future<void> createUserProfileExample() async {
    print('=== 為新用戶創建 Profile ===');

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      print('沒有用戶登入');
      return;
    }

    final newProfile = await _userService.upsertCurrentUserProfile(
      fullName: '預設用戶名',
      themePreference: 'system',
    );

    if (newProfile != null) {
      print('Profile 創建/更新成功！');
      print('用戶 ID: ${newProfile.id}');
      print('Email: ${newProfile.email}');
    } else {
      print('Profile 創建失敗');
    }
  }

  /// 範例 5: 批量獲取多個用戶的資料
  Future<void> getBatchUsersExample(List<String> userIds) async {
    print('=== 批量獲取用戶 Profiles ===');
    print('查詢的用戶 IDs: $userIds');

    final userProfiles = await _userService.getUserProfilesByIds(userIds);

    print('找到 ${userProfiles.length} 個用戶：');
    for (final profile in userProfiles) {
      print('- ${profile.fullName ?? profile.email} (${profile.id})');
    }
  }

  /// 範例 6: 搜尋用戶
  Future<void> searchUsersExample(String searchTerm) async {
    print('=== 搜尋用戶 ===');
    print('搜尋關鍵字: $searchTerm');

    final users = await _userService.searchUsers(
      email: searchTerm,
      fullName: searchTerm,
      limit: 10,
    );

    print('搜尋結果 (${users.length} 個用戶)：');
    for (final user in users) {
      print('- ${user.fullName ?? user.email}');
    }
  }

  /// 範例 7: 檢查用戶 Profile 是否存在
  Future<void> checkUserExistsExample(String userId) async {
    print('=== 檢查用戶是否存在 ===');
    print('檢查用戶 ID: $userId');

    final exists = await _userService.userProfileExists(userId);
    print('用戶存在: $exists');
  }

  /// 完整的用戶管理流程範例
  Future<void> completeUserManagementExample() async {
    print('\n' + '=' * 50);
    print('完整的用戶管理流程範例');
    print('=' * 50);

    // 1. 檢查當前用戶
    await getCurrentUserExample();
    print('\n' + '-' * 30 + '\n');

    // 2. 確保用戶 Profile 存在
    await createUserProfileExample();
    print('\n' + '-' * 30 + '\n');

    // 3. 更新用戶資料
    await updateCurrentUserExample();
    print('\n' + '-' * 30 + '\n');

    // 4. 再次獲取確認更新
    await getCurrentUserExample();
  }
}

/// 如何在實際應用中使用 UserService
/// 
/// 在您的 Widget 或其他 Service 中：
/// 
/// ```dart
/// class MyWidget extends StatefulWidget {
///   @override
///   _MyWidgetState createState() => _MyWidgetState();
/// }
/// 
/// class _MyWidgetState extends State<MyWidget> {
///   late final UserService _userService;
///   UserProfile? _currentUser;
/// 
///   @override
///   void initState() {
///     super.initState();
///     _userService = UserService(Supabase.instance.client);
///     _loadCurrentUser();
///   }
/// 
///   Future<void> _loadCurrentUser() async {
///     final user = await _userService.getCurrentUserProfile();
///     setState(() {
///       _currentUser = user;
///     });
///   }
/// 
///   Future<void> _updateUserTheme(String newTheme) async {
///     final updatedUser = await _userService.updateCurrentUserProfile(
///       themePreference: newTheme,
///     );
///     
///     if (updatedUser != null) {
///       setState(() {
///         _currentUser = updatedUser;
///       });
///       // 可以在這裡觸發主題變更
///     }
///   }
/// 
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: AppBar(
///         title: Text(_currentUser?.fullName ?? '載入中...'),
///       ),
///       body: Column(
///         children: [
///           if (_currentUser != null) ...[
///             Text('歡迎, ${_currentUser!.fullName ?? _currentUser!.email}'),
///             Text('目前主題: ${_currentUser!.themePreference}'),
///             ElevatedButton(
///               onPressed: () => _updateUserTheme('dark'),
///               child: Text('切換到深色主題'),
///             ),
///           ] else ...[
///             CircularProgressIndicator(),
///           ],
///         ],
///       ),
///     );
///   }
/// }
/// ```
