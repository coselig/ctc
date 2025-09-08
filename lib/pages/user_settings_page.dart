import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/user_preferences_service.dart';
import '../widgets/transparent_app_bar.dart';

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

  @override
  void initState() {
    super.initState();
    _userPreferencesService = UserPreferencesService(Supabase.instance.client);
    _loadUserData();
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const TransparentAppBar(title: Text('用戶設置'), showUserInfo: true),
      body: Column(
        children: [
          // AppBar 間距
          SizedBox(
            height:
                MediaQuery.of(context).padding.top +
                AppBar().preferredSize.height +
                20,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 用戶資訊卡片
                  _buildUserInfoCard(),

                  // 主題設置標題
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      '主題設置',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // 主題選項
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

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
