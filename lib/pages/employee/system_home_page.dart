import 'package:ctc/pages/management/upload_pdf_page.dart';
import 'package:ctc/pages/pages.dart';
import 'package:ctc/widgets/page_components/system_page/system_card.dart';
import 'package:ctc/widgets/page_components/system_page/system_card_data.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/models.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';
import '../management/upload_asset_page.dart';

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
  List<SystemCardData> get systemCards => [
    SystemCardData(
      icon: Icons.folder_special,
      title: '專案管理',
      subtitle: '專案、任務、時程管理',
      color: Colors.deepPurple,
      page: const ProjectManagementPage(),
    ),
    SystemCardData(
      icon: Icons.camera_alt,
      title: '照片記錄',
      subtitle: '工地照片記錄管理',
      color: Colors.blue,
      page: PhotoRecordPage(
        title: '工地照片記錄系統',
        onThemeToggle: widget.onThemeToggle,
        currentThemeMode: widget.currentThemeMode,
      ),
    ),
    SystemCardData(
      icon: Icons.upload_file,
      title: '資產圖片上傳',
      subtitle: '上傳照片至公司資產 bucket',
      color: Colors.teal,
      page: const UploadAssetPage(),
    ),
    SystemCardData(
      icon: Icons.upload_file,
      title: '首頁頁面管理',
      subtitle: '上傳pdf至資料庫',
      color: Colors.teal,
      page: const UploadPdfPage(),
    ),
    SystemCardData(
      icon: Icons.people,
      title: '員工管理',
      subtitle: '人力資源管理系統',
      color: Colors.green,
      page: EmployeeManagementPage(
        title: '員工管理系統',
        onThemeToggle: widget.onThemeToggle,
        currentThemeMode: widget.currentThemeMode,
      ),
    ),
    SystemCardData(
      icon: Icons.access_time,
      title: '打卡系統',
      subtitle: '員工考勤打卡管理',
      color: Colors.orange,
      page: AttendancePage(
        title: '打卡系統',
        onThemeToggle: widget.onThemeToggle,
        currentThemeMode: widget.currentThemeMode,
      ),
    ),
    SystemCardData(
      icon: Icons.assessment,
      title: '個人出勤中心',
      subtitle: '出勤統計、請假、補打卡申請',
      color: Colors.purple,
      page: const AttendanceStatsPage(),
    ),
  ];
  final supabase = Supabase.instance.client;
  late final EmployeeService _employeeService;
  late final PermissionService _permissionService;
  Employee? _currentEmployee;
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
      final employee = await _employeeService.getCurrentEmployee();
      if (mounted) {
        setState(() {
          _currentEmployee = employee;
        });
      }
    } catch (e) {
      print('載入員工資料失敗: $e');
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return GeneralPage(
      actions: [
        Text("${_currentEmployee?.name ?? user?.email ?? '訪客'}"),
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
        ThemeToggleButton(
          currentThemeMode: widget.currentThemeMode,
          onToggle: widget.onThemeToggle,
        ),
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    UserSettingsPage(onThemeChanged: widget.onThemeToggle),
              ),
            );
          },
          tooltip: '用戶設置',
        ),
        const AuthActionButton(),
      ],
      children: [
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
                ...systemCards.map(
                  (data) => SystemCard(
                    icon: data.icon,
                    title: data.title,
                    subtitle: data.subtitle,
                    color: data.color,
                    page: data.page,
                  ),
                ),
                if (_canViewAllAttendance)
                  SystemCard(
                    icon: Icons.badge,
                    title: '人事管理',
                    subtitle: '出勤管理、請假與補打卡審核',
                    color: Colors.indigo,
                    page: const HRReviewPage(),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
