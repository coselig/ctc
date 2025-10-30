import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/general/user_preferences_service.dart';
import '../../widgets/general_components/general_page.dart';

/// 用戶設置頁面
/// 讓用戶管理各種偏好設置，包括主題模式
class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key, this.onThemeChanged});

  final VoidCallback? onThemeChanged;

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  late UserPreferencesService _userPreferencesService;
  String _currentThemePreference = UserPreferencesService.themeModeSystem;
  bool _isLoading = true;
  Map<String, dynamic>? _userProfile;

  // 密碼修改相關的控制器
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _userPreferencesService = UserPreferencesService(Supabase.instance.client);
    _loadUserData();
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final themePreference = await _userPreferencesService
          .getThemePreference();
      final userProfile = await _userPreferencesService.getUserProfile();

      if (mounted) {
        setState(() {
          _currentThemePreference = themePreference;
          _userProfile = userProfile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('載入用戶資料失敗: $e')));
      }
    }
  }

  Future<void> _updateThemePreference(String themeMode) async {
    try {
      final success = await _userPreferencesService.updateThemePreference(
        themeMode,
      );

      if (success && mounted) {
        setState(() {
          _currentThemePreference = themeMode;
        });

        // 通知父組件主題已變更
        widget.onThemeChanged?.call();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('主題偏好已更新')));
      } else {
        throw Exception('更新失敗');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('更新主題偏好失敗: $e')));
      }
    }
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) {
      return;
    }

    // 驗證新密碼和確認密碼是否一致
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('新密碼和確認密碼不一致')));
      return;
    }

    try {
      // 使用 Supabase 更新密碼（無需舊密碼驗證）
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _newPasswordController.text),
      );

      if (mounted) {
        // 清空輸入框
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        // 顯示成功訊息
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('密碼修改成功！')));

        // 關閉密碼修改對話框
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('密碼修改失敗: $e')));
      }
    }
  }

  /// 處理登出
  Future<void> _handleLogout() async {
    // 顯示確認對話框
    final confirmed = await showDialog<bool>(
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('確認登出'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // 執行登出
      await Supabase.instance.client.auth.signOut();

      if (mounted) {
        // 顯示成功訊息
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已成功登出')));

        // 返回到上一頁（通常會回到歡迎頁面，因為 auth listener 會處理導航）
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('登出失敗: $e')));
      }
    }
  }

  void _showChangePasswordDialog() {
    // 清空輸入框
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改密碼'),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: _passwordFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 提示訊息
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '無需輸入舊密碼，直接設定新密碼即可',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 新密碼輸入框
                TextFormField(
                  controller: _newPasswordController,
                  decoration: const InputDecoration(
                    labelText: '新密碼',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                    helperText: '密碼長度至少6個字符',
                  ),
                  obscureText: true,
                  autofocus: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '請輸入新密碼';
                    }
                    if (value.length < 6) {
                      return '密碼長度至少6個字符';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // 確認密碼輸入框
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: '確認新密碼',
                    prefixIcon: Icon(Icons.lock_reset),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '請確認新密碼';
                    }
                    if (value != _newPasswordController.text) {
                      return '密碼不一致';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(onPressed: _changePassword, child: const Text('確認修改')),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required String themeMode,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _currentThemePreference == themeMode;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? theme.colorScheme.primary : null,
            ),
          ),
          subtitle: Text(subtitle),
          trailing: isSelected
              ? Icon(Icons.check, color: theme.colorScheme.primary)
              : null,
          onTap: () => _updateThemePreference(themeMode),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    if (_userProfile == null) return const SizedBox.shrink();

    final email = _userProfile!['email'] as String?;
    final fullName = _userProfile!['full_name'] as String?;
    final createdAt = _userProfile!['created_at'] as String?;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_circle,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName ?? '未設置姓名',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (email != null)
                          Text(
                            email,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (createdAt != null) ...[
                const SizedBox(height: 12),
                Text(
                  '註冊時間: ${DateTime.parse(createdAt).toLocal().toString().split('.')[0]}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // 密碼修改按鈕
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showChangePasswordDialog,
                  icon: const Icon(Icons.security),
                  label: const Text('修改密碼'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return GeneralPage(
      title: '用戶設置',
      children: [
        SizedBox(
          height:
              MediaQuery.of(context).padding.top +
              AppBar().preferredSize.height +
              20,
        ),
        _buildUserInfoCard(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('主題設置',
            style: Theme.of(context).textTheme.headlineSmall),
        ),
        _buildThemeOption(
          themeMode: UserPreferencesService.themeModeLight,
          title: '亮色主題',
          subtitle: '始終使用亮色外觀',
          icon: Icons.light_mode,
        ),
        _buildThemeOption(
          themeMode: UserPreferencesService.themeModeDark,
          title: '暗色主題',
          subtitle: '始終使用暗色外觀',
          icon: Icons.dark_mode,
        ),
        _buildThemeOption(
          themeMode: UserPreferencesService.themeModeSystem,
          title: '跟隨系統',
          subtitle: '根據系統設置自動切換',
          icon: Icons.settings_brightness,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text('安全設置',
            style: Theme.of(context).textTheme.headlineSmall),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Card(
            child: ListTile(
              title: const Text('修改密碼'),
              leading: const Icon(Icons.security),
              onTap: _showChangePasswordDialog,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Card(
            child: ListTile(
              title: const Text('登出'),
              leading: const Icon(Icons.logout),
              onTap: _handleLogout,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
