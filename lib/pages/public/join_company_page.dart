import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/job_vacancy.dart';
import '../../services/job_vacancy_service.dart';
import '../../widgets/widgets.dart';

class JoinCompanyPage extends StatefulWidget {
  const JoinCompanyPage({
    super.key,
    required this.onThemeToggle,
    required this.currentThemeMode,
  });

  final VoidCallback onThemeToggle;
  final ThemeMode currentThemeMode;

  @override
  State<JoinCompanyPage> createState() => _JoinCompanyPageState();
}

class _JoinCompanyPageState extends State<JoinCompanyPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late JobVacancyService _jobVacancyService;
  List<JobVacancy> _jobVacancies = [];
  bool _isLoadingJobs = false;
  String? _jobLoadError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _jobVacancyService = JobVacancyService(Supabase.instance.client);
    _loadJobVacancies();
  }

  /// 載入職位空缺數據
  Future<void> _loadJobVacancies() async {
    setState(() {
      _isLoadingJobs = true;
      _jobLoadError = null;
    });

    try {
      final jobVacancies = await _jobVacancyService.getActiveJobVacancies();
      
      if (mounted) {
        setState(() {
          _jobVacancies = jobVacancies;
          _isLoadingJobs = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _jobLoadError = e.toString();
          _isLoadingJobs = false;
        });
      }
      print('載入職位空缺失敗: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('加入光悅'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        actions: [
          ThemeToggleButton(currentThemeMode: widget.currentThemeMode, onToggle: widget.onThemeToggle),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.business),
              text: '公司介紹',
            ),
            Tab(
              icon: Icon(Icons.work),
              text: '職位空缺',
            ),
            Tab(
              icon: Icon(Icons.people),
              text: '企業文化',
            ),
            Tab(
              icon: Icon(Icons.contact_mail),
              text: '聯絡我們',
            ),
          ],
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCompanyIntroTab(),
          _buildJobOpeningsTab(),
          _buildCultureTab(),
          _buildContactTab(),
        ],
      ),
    );
  }

  Widget _buildCompanyIntroTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 公司 Logo 和基本資訊
          Center(
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/sqare_ctc_icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Coselig 光悅科技',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '智慧家居 輕鬆入門',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 公司介紹
          _buildSectionCard(
            icon: Icons.business_center,
            title: '關於我們',
            content: '''光悅科技專注於智慧家居解決方案，致力於將複雜的技術簡化，讓每個家庭都能享受到智慧生活的便利。

我們提供從硬體設計到軟體整合的完整服務，包括：
• 台灣製造的高品質調光控制器
• Home Assistant 開源平台整合
• 快時尚照明解決方案
• 客製化智慧家居服務''',
          ),
          
          const SizedBox(height: 16),
          
          // 公司優勢
          _buildSectionCard(
            icon: Icons.star,
            title: '我們的優勢',
            content: '''• 技術實力：擁有豐富的硬體與軟體開發經驗
• 本土優勢：台灣製造，品質保證
• 創新能力：持續投入研發，追求技術突破
• 服務品質：提供完整的售前售後服務
• 市場前景：智慧家居市場快速成長，發展潜力巨大''',
          ),
          
          const SizedBox(height: 16),
          
          // 發展歷程
          _buildSectionCard(
            icon: Icons.timeline,
            title: '發展歷程',
            content: '''2020 - 公司成立，專注智慧家居技術研發
2021 - 推出首款調光控制器產品
2022 - 開始 Home Assistant 平台整合服務
2023 - 擴展快時尚照明產品線
2024 - 建立完整的客製化服務體系
2025 - 持續創新，拓展市場版圖''',
          ),
        ],
      ),
    );
  }

  Widget _buildJobOpeningsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '目前職位空缺',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_isLoadingJobs)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadJobVacancies,
                  tooltip: '重新載入',
                ),
            ],
          ),
          const SizedBox(height: 24),
          
          // 顯示載入狀態或錯誤訊息
          if (_isLoadingJobs)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_jobLoadError != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '載入職位空缺失敗',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _jobLoadError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadJobVacancies,
                    child: const Text('重試'),
                  ),
                ],
              ),
            )
          else if (_jobVacancies.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.work_off,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '目前沒有職位空缺',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '請稍後再來查看，或直接聯絡我們了解未來機會',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            // 顯示職位列表
            Column(
              children: _jobVacancies.asMap().entries.map((entry) {
                final index = entry.key;
                final job = entry.value;
                
                return Column(
                  children: [
                    _buildJobCardFromModel(job),
                    if (index < _jobVacancies.length - 1)
                      const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildCultureTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '企業文化',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // 核心價值
          _buildSectionCard(
            icon: Icons.favorite,
            title: '核心價值',
            content: '''務實 (Feasible) - 腳踏實地，解決實際問題
穩定 (Stable) - 可靠的產品，持續的服務
實惠 (Affordable) - 讓智慧科技更親民
耐用 (Durable) - 高品質，長期使用
永續 (Sustainable) - 環保意識，永續發展
舒適 (Comfortable) - 提升生活品質''',
          ),
          
          const SizedBox(height: 16),
          
          // 工作環境
          _buildSectionCard(
            icon: Icons.work_outline,
            title: '工作環境',
            content: '''• 彈性工作時間，注重工作與生活平衡
• 開放式辦公空間，促進團隊交流
• 提供最新的開發設備和工具
• 定期團建活動和技術分享會
• 舒適的休息區域和咖啡吧台''',
          ),
          
          const SizedBox(height: 16),
          
          // 成長機會
          _buildSectionCard(
            icon: Icons.trending_up,
            title: '成長機會',
            content: '''• 內部技術培訓和外部研習機會
• 跨部門專案合作經驗
• 新技術學習和應用機會
• 完整的職涯發展規劃
• 績效獎金和晉升機制''',
          ),
          
          const SizedBox(height: 16),
          
          // 福利制度
          _buildSectionCard(
            icon: Icons.card_giftcard,
            title: '福利制度',
            content: '''• 具競爭力的薪資和年終獎金
• 完整的勞健保和團體保險
• 員工健康檢查補助
• 教育訓練補助
• 員工旅遊和聚餐活動
• 生日禮金和節慶禮品''',
          ),
        ],
      ),
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '聯絡我們',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // 聯絡資訊
          _buildContactCard(
            icon: Icons.location_on,
            title: '公司地址',
            content: '台北市信義區信義路五段7號',
          ),
          
          const SizedBox(height: 16),
          
          _buildContactCard(
            icon: Icons.phone,
            title: '聯絡電話',
            content: '+886-2-1234-5678',
          ),
          
          const SizedBox(height: 16),
          
          _buildContactCard(
            icon: Icons.email,
            title: '電子信箱',
            content: 'hr@coselig.com',
          ),
          
          const SizedBox(height: 16),
          
          _buildContactCard(
            icon: Icons.web,
            title: '公司網站',
            content: 'www.coselig.com',
          ),
          
          const SizedBox(height: 32),
          
          // 應徵方式
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.send,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '應徵方式',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '請將您的履歷和求職信寄到 hr@coselig.com\n\n我們將在收到您的申請後 3-5 個工作天內回覆。\n\n面試流程：\n1. 履歷審核\n2. 電話初步面談\n3. 現場面試\n4. 技術測試（技術職位）\n5. 主管面談',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  /// 從 JobVacancy 模型建立職位卡片
  Widget _buildJobCardFromModel(JobVacancy job) {
    return _buildJobCard(
      title: job.title,
      department: job.department,
      location: job.location,
      type: job.type,
      requirements: job.requirements,
      responsibilities: job.responsibilities,
      description: job.description,
      jobId: job.id,
    );
  }

  Widget _buildJobCard({
    required String title,
    required String department,
    required String location,
    required String type,
    required List<String> requirements,
    required List<String> responsibilities,
    String? description,
    String? jobId,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 職位標題
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // 部門和地點
          Row(
            children: [
              Icon(
                Icons.business,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                department,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.location_on,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                location,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 工作職責
          Text(
            '工作職責',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...responsibilities.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• '),
                Expanded(child: Text(item)),
              ],
            ),
          )),
          
          const SizedBox(height: 16),
          
          // 應徵條件
          Text(
            '應徵條件',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...requirements.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• '),
                Expanded(child: Text(item)),
              ],
            ),
          )),
          
          // 職位描述（如果有的話）
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '職位描述',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          
          const SizedBox(height: 16),
          
          // 應徵按鈕
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // 這裡可以添加應徵邏輯
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('請將履歷寄到 hr@coselig.com 應徵「$title」職位'),
                  ),
                );
              },
              icon: const Icon(Icons.send),
              label: const Text('立即應徵'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}