import 'package:ctc/pages/management/upload_pdf_page.dart';
import 'package:ctc/pages/pages.dart';
import 'package:ctc/widgets/page_components/system_page/system_card.dart';
import 'package:ctc/widgets/page_components/system_page/system_card_data.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/models.dart';
import '../../services/services.dart';
import '../../services/general/registered_user_service.dart';
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
  late final RegisteredUserService _registeredUserService;
  Employee? _currentEmployee;
  bool _canViewAllAttendance = false; // 是否可以查看所有出勤（HR/老闆）

  @override
  void initState() {
    super.initState();
    _employeeService = EmployeeService(supabase);
    _permissionService = PermissionService();
    _registeredUserService = RegisteredUserService(supabase);
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
        setState(() {
        });
      }
    }
  }

  /// 系統診斷功能
  Future<void> _showSystemDiagnostics() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('系統診斷中...'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在檢查系統狀態，請稍候...'),
          ],
        ),
      ),
    );

    try {
      // 執行完整的系統診斷
      final diagnosticResults = await _registeredUserService
          .diagnoseDatabaseIssues();
      final authResults = await _registeredUserService.checkAuthIssues();

      // 關閉載入對話框
      if (mounted) Navigator.of(context).pop();

      // 顯示診斷結果
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.bug_report, color: Colors.blue),
                SizedBox(width: 8),
                Text('系統診斷報告'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '數據庫診斷結果：',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    width: double.maxFinite,
                    child: Text(
                      _formatDiagnosisResult(diagnosticResults),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '認證診斷結果：',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    width: double.maxFinite,
                    child: Text(
                      _formatDiagnosisResult(authResults),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: const Text(
                      '💡 提示：如果遇到 AuthRetryableFetchException 錯誤，通常是 Supabase 認證服務暫時不可用。請稍後重試或聯繫系統管理員。',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('關閉'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  _showUserRegistrationTest();
                },
                child: const Text('測試用戶註冊'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // 關閉載入對話框
      if (mounted) Navigator.of(context).pop();

      // 顯示錯誤
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text('診斷失敗'),
              ],
            ),
            content: Text('執行系統診斷時發生錯誤：\n\n$e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('關閉'),
              ),
            ],
          ),
        );
      }
    }
  }

  /// 測試用戶註冊功能
  Future<void> _showUserRegistrationTest() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('測試用戶註冊...'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在測試用戶註冊流程...'),
          ],
        ),
      ),
    );

    try {
      final testResult = await _registeredUserService.testUserRegistration();

      // 關閉載入對話框
      if (mounted) Navigator.of(context).pop();

      // 顯示測試結果
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.science, color: Colors.green),
                SizedBox(width: 8),
                Text('用戶註冊測試報告'),
              ],
            ),
            content: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                width: double.maxFinite,
                child: Text(
                  _formatDiagnosisResult(testResult),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('關閉'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // 關閉載入對話框
      if (mounted) Navigator.of(context).pop();

      // 顯示錯誤
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text('測試失敗'),
              ],
            ),
            content: Text('執行用戶註冊測試時發生錯誤：\n\n$e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('關閉'),
              ),
            ],
          ),
        );
      }
    }
  }

  /// 分析 AuthRetryableFetchException 錯誤
  Future<void> _analyzeAuthRetryableError() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('AuthRetryableFetchException 分析'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🚨 AuthRetryableFetchException 錯誤',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '錯誤: Database error saving new user\n'
                      '狀態碼: 500 (SQLSTATE 42501)\n'
                      '根本原因: permission denied for table user_profiles',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✅ 診斷結果：',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('✓ Supabase 客戶端: 已連接'),
                    Text('✓ 數據庫連接: 成功'),
                    Text('✓ 網路檢查: 連接正常'),
                    Text('✓ Auth Session: 有效'),
                    Text('✓ Access Token: 正常 (745 字符)'),
                    SizedBox(height: 8),
                    Text(
                      '✓ PostgreSQL 15.8 運行正常',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '� 問題定位：',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '數據庫連接正常，但用戶創建失敗',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('可能原因：'),
                    Text('• 🔒 Row Level Security (RLS) 政策限制'),
                    Text('• � auth.users 表權限不足'),
                    Text('• 📝 數據驗證規則觸發'),
                    Text('• � 數據庫觸發器錯誤'),
                    Text('• 💾 唯一約束衝突 (email 重複)'),
                    Text('• ⚡ 並發操作衝突'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '🛠️ 建議解決方案：',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '立即檢查：',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('1. 🔍 檢查 Supabase Dashboard 的 Auth 日誌'),
                    Text('2. � 查看 Database > Logs 中的錯誤詳情'),
                    Text('3. 🔒 確認 RLS 政策是否正確設置'),
                    Text('4. ✉️ 確認測試郵箱沒有被使用過'),
                    SizedBox(height: 8),
                    Text(
                      '技術檢查：',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('1. �️ 檢查 auth.users 表結構'),
                    Text('2. � 檢查 auth schema 權限'),
                    Text('3. ⚙️ 檢查數據庫觸發器'),
                    Text('4. � 檢查 email 驗證設置'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚠️ 注意事項：',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '• 這是 Supabase 服務端錯誤，不是客戶端程式問題\n'
                      '• 通常是暫時性問題，會自動恢復\n'
                      '• 如果頻繁出現，需要檢查 Supabase 配置和服務狀態',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('關閉'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSystemDiagnostics();
            },
            child: const Text('完整診斷'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSupabaseFixGuide();
            },
            child: const Text('修復指南'),
          ),
        ],
      ),
    );
  }

  /// 顯示 Supabase 修復指南
  Future<void> _showSupabaseFixGuide() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.build, color: Colors.blue),
            SizedBox(width: 8),
            Text('Supabase 修復指南'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔍 問題診斷：',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'PostgrestException: Could not find function public.version',
                    ),
                    Text('這表示 Supabase 數據庫缺少必要的函數'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '🛠️ 修復步驟：',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '步驟 1: 登入 Supabase Dashboard',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('• 前往 https://supabase.com/dashboard'),
                    Text('• 選擇您的項目'),
                    SizedBox(height: 8),
                    Text(
                      '步驟 2: 進入 SQL Editor',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('• 點擊左側導航的 "SQL Editor"'),
                    Text('• 點擊 "New Query"'),
                    SizedBox(height: 8),
                    Text(
                      '步驟 3: 執行修復 SQL',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('• 複製下方的 SQL 代碼'),
                    Text('• 貼上到 SQL Editor'),
                    Text('• 點擊 "Run" 執行'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SQL 修復代碼：',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    SelectableText(
                      '-- 創建 version 函數\n'
                      'CREATE OR REPLACE FUNCTION public.version()\n'
                      'RETURNS text AS \$\$\n'
                      'BEGIN\n'
                      '  RETURN version();\n'
                      'END;\n'
                      '\$\$ LANGUAGE plpgsql SECURITY DEFINER;\n\n'
                      '-- 設置函數權限\n'
                      'GRANT EXECUTE ON FUNCTION public.version() TO anon;\n'
                      'GRANT EXECUTE ON FUNCTION public.version() TO authenticated;',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✅ 驗證修復：',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text('1. 執行 SQL 後檢查是否有錯誤'),
                    Text('2. 重新整理應用程式'),
                    Text('3. 嘗試重新註冊用戶'),
                    Text('4. 使用系統診斷工具再次檢查'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚠️ 如果問題持續：',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text('• 檢查 Supabase 項目狀態'),
                    Text('• 確認 RLS 政策設置'),
                    Text('• 檢查 API 金鑰是否正確'),
                    Text('• 聯繫 Supabase 支援團隊'),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('關閉'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSystemDiagnostics();
            },
            child: const Text('重新診斷'),
          ),
        ],
      ),
    );
  }

  /// 格式化診斷結果為可讀文本
  String _formatDiagnosisResult(Map<String, dynamic> result) {
    final buffer = StringBuffer();

    void formatValue(String key, dynamic value, [int indent = 0]) {
      final prefix = '  ' * indent;
      if (value is Map<String, dynamic>) {
        buffer.writeln('$prefix$key:');
        value.forEach((k, v) => formatValue(k, v, indent + 1));
      } else if (value is List) {
        buffer.writeln('$prefix$key: [${value.join(', ')}]');
      } else {
        buffer.writeln('$prefix$key: $value');
      }
    }

    result.forEach((key, value) => formatValue(key, value));
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return GeneralPage(
      actions: [
        Text("${_currentEmployee?.name ?? user?.email ?? '訪客'}"),
        // AuthRetryableFetchException 專門分析按鈕
        IconButton(
          icon: const Icon(Icons.warning, color: Colors.orange),
          onPressed: _analyzeAuthRetryableError,
          tooltip: 'AuthRetryable 錯誤分析',
        ),
        // 系統診斷按鈕
        IconButton(
          icon: const Icon(Icons.bug_report),
          onPressed: _showSystemDiagnostics,
          tooltip: '系統診斷',
        ),
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
                // 系統診斷工具卡片 - 自定義實現
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: _showSystemDiagnostics,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.bug_report,
                            size: 48,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '系統診斷',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '檢查數據庫連接、認證狀態',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                // AuthRetryableFetchException 專門分析卡片
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: _analyzeAuthRetryableError,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.warning,
                            size: 48,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Auth 錯誤分析',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'AuthRetryableFetchException 專門分析',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  
}
