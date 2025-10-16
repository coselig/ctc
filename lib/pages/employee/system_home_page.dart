import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/models.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';
import '../pages.dart'; // 統一匯入所有頁面

class SystemHomePage extends StatefulWidget {
  const SystemHomePage({
    super.key,
    required this.title,
    required this.onThemeToggle,
    required this.currentThemeMode,
  });

  final String title;
  final VoidCallback onThemeToggle;
  final ThemeMode currentThemeMode;

  @override
  State<SystemHomePage> createState() => _SystemHomePageState();
}

class _SystemHomePageState extends State<SystemHomePage> {
  final supabase = Supabase.instance.client;
  late final EmployeeService _employeeService;
  late final PermissionService _permissionService;
  Employee? _currentEmployee;
  bool _isLoadingEmployee = true;
  bool _canViewAllAttendance = false; // 是否可以查看所有出勤（HR/老闆）

  @override
  void initState() {
    super.initState();
    _employeeService = EmployeeService(supabase);
    _permissionService = PermissionService();
    _loadCurrentEmployee();
    _loadPermissions();
  }

  /// 載入用戶權限
  Future<void> _loadPermissions() async {
    try {
      final canView = await _permissionService.canViewAllAttendance();
      if (mounted) {
        setState(() {
          _canViewAllAttendance = canView;
        });
      }
    } catch (e) {
      print('載入權限失敗: $e');
    }
  }

  /// 載入當前用戶的員工資料
  Future<void> _loadCurrentEmployee() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        // 直接用當前用戶的 ID 查詢自己的員工資料（避免 RLS 權限問題）
        final employee = await _employeeService.getEmployeeById(user.id);

        if (mounted) {
          setState(() {
            _currentEmployee = employee;
            _isLoadingEmployee = false;
          });
        }
      }
    } catch (e) {
      print('載入員工資料失敗: $e');
      if (mounted) {
        setState(() {
          _isLoadingEmployee = false;
        });
      }
    }
  }

  /// 建構歡迎文字
  Widget _buildWelcomeText(BuildContext context, User? user) {
    if (_isLoadingEmployee) {
      return Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(
            '載入用戶資料中...',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      );
    }

    String displayText;
    if (_currentEmployee != null) {
      // 如果是員工，顯示姓名
      displayText = '歡迎您，${_currentEmployee!.name}';
    } else {
      // 如果不是員工，顯示郵箱
      displayText = '歡迎您，${user?.email ?? '使用者'}';
    }

    return Text(
      displayText,
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
    );
  }

  IconData _getThemeIcon() {
    switch (widget.currentThemeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.auto_awesome;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return GeneralPage(
      actions: [
        IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => WelcomePage(
                  onThemeToggle: widget.onThemeToggle,
                  currentThemeMode: widget.currentThemeMode,
                ),
              ),
            );
          },
          tooltip: '回到首頁',
        ),
        IconButton(
          icon: Icon(_getThemeIcon()),
          onPressed: widget.onThemeToggle,
          tooltip: '切換主題',
        ),
        const LogoutButton(),
      ],
      children: [
        // 歡迎信息
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '歡迎使用光悅科技管理系統',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildWelcomeText(context, user),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 系統功能選單
        Text(
          '系統功能',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        LayoutBuilder(
          builder: (context, constraints) {
            // 根據螢幕寬度動態計算列數
            int crossAxisCount;
            double childAspectRatio;

            if (constraints.maxWidth >= 1600) {
              // 超大螢幕（1600px 以上）：6 列
              crossAxisCount = 6;
              childAspectRatio = 1.2;
            } else if (constraints.maxWidth >= 1280) {
              // 大螢幕（1280-1599px）：5 列
              crossAxisCount = 5;
              childAspectRatio = 1.2;
            } else if (constraints.maxWidth >= 1080) {
              // 中大螢幕（1080-1279px）：4 列
              crossAxisCount = 4;
              childAspectRatio = 1.2;
            } else if (constraints.maxWidth >= 768) {
              // 中螢幕（768-1079px）：3 列
              crossAxisCount = 3;
              childAspectRatio = 1.2;
            } else if (constraints.maxWidth >= 480) {
              // 小螢幕（480-767px）：2 列
              crossAxisCount = 2;
              childAspectRatio = 1.2;
            } else {
              // 極小螢幕（小於 480px）：1 列
              crossAxisCount = 1;
              childAspectRatio = 2.5;
            }

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: childAspectRatio,
              children: [
                // 專案管理系統
                _buildSystemCard(
                  context,
                  icon: Icons.folder_special,
                  title: '專案管理',
                  subtitle: '專案、任務、時程管理',
                  color: Colors.deepPurple,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ProjectManagementPage(),
                      ),
                    );
                  },
                ),

                // 照片記錄系統
                _buildSystemCard(
                  context,
                  icon: Icons.camera_alt,
                  title: '照片記錄',
                  subtitle: '工地照片記錄管理',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PhotoRecordPage(
                          title: '工地照片記錄系統',
                          onThemeToggle: widget.onThemeToggle,
                          currentThemeMode: widget.currentThemeMode,
                        ),
                      ),
                    );
                  },
                ),

                // 員工管理系統
                _buildSystemCard(
                  context,
                  icon: Icons.people,
                  title: '員工管理',
                  subtitle: '人力資源管理系統',
                  color: Colors.green,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EmployeeManagementPage(
                          title: '員工管理系統',
                          onThemeToggle: widget.onThemeToggle,
                          currentThemeMode: widget.currentThemeMode,
                        ),
                      ),
                    );
                  },
                ),

                // 打卡系統
                _buildSystemCard(
                  context,
                  icon: Icons.access_time,
                  title: '打卡系統',
                  subtitle: '員工考勤打卡管理',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AttendancePage(
                          title: '打卡系統',
                          onThemeToggle: widget.onThemeToggle,
                          currentThemeMode: widget.currentThemeMode,
                        ),
                      ),
                    );
                  },
                ),

                // 個人出勤中心（整合打卡統計、請假申請、補打卡申請）
                _buildSystemCard(
                  context,
                  icon: Icons.assessment,
                  title: '個人出勤中心',
                  subtitle: '出勤統計、請假、補打卡申請',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AttendanceStatsPage(),
                      ),
                    );
                  },
                ),

                // 人事管理（僅 HR 和老闆可見）
                if (_canViewAllAttendance)
                  _buildSystemCard(
                    context,
                    icon: Icons.badge,
                    title: '人事管理',
                    subtitle: '出勤管理、請假與補打卡審核',
                    color: Colors.indigo,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const HRReviewPage(),
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSystemCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
