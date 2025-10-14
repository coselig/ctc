import 'package:ctc/widgets/backgrounds/triangle_background.dart';
import 'package:flutter/material.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TriangleBackground(
        child: SafeArea(
          child: Column(
            children: [
              // PageView 佔據大部分空間
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    // 第一頁
                    _buildPage1(context),
                    // 第二頁
                    _buildPage2(context),
                    // 第三頁
                    _buildPage3(context),
                  ],
                ),
              ),
              // 頁面指示器和導航按鈕
              _buildPageIndicator(context),
            ],
          ),
        ),
      ),
    );
  }

  // 第一頁內容
  Widget _buildPage1(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,  // 改為靠左對齊
        children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.17),
                Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                        '調光',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.12,
                          color: Color(0xFF4F4A45),  // 深灰褐色
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ),
                const SizedBox(height: 8),  // 減少間距
                Center(
                  child: Text(
                    '開啟智慧新生活',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.07,
                      color: Color(0xFF4F4A45),  // 深灰褐色
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,  // 靠右對齊
                  child: Padding(
                    padding: EdgeInsets.only(right: 32.0),  // 右側間距
                    child: Text(
                      '25th ver.',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                        color: Color(0xFF8B4513),  // 深褐色
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Center(  // 置中對齊
                  child: Image.asset(
                    'assets/sqare_ctc_icon.png',
                    height: 48,  // 調整 logo 大小
                  ),
                ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // 第二頁內容
  Widget _buildPage2(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          // 標題
          Text(
            '智慧管理',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.1,
              color: const Color(0xFF4F4A45),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          // 功能介紹
          _buildFeatureCard(
            icon: Icons.people,
            title: '員工管理',
            description: '完整的員工資料管理系統\n支援考勤、技能、績效追蹤',
            color: Colors.blue,
          ),
          const SizedBox(height: 20),
          _buildFeatureCard(
            icon: Icons.access_time,
            title: '打卡系統',
            description: '智慧打卡記錄\n自動計算工時與出勤統計',
            color: Colors.green,
          ),
          const SizedBox(height: 20),
          _buildFeatureCard(
            icon: Icons.assessment,
            title: '數據報表',
            description: '即時數據分析\n多維度統計圖表展示',
            color: Colors.orange,
          ),
          const Spacer(),
        ],
      ),
    );
  }

  // 第三頁內容
  Widget _buildPage3(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          // 標題
          Text(
            '開始使用',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.1,
              color: const Color(0xFF4F4A45),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 60),
          // 步驟說明
          _buildStepItem(1, '註冊帳號', '使用電子郵件快速註冊'),
          const SizedBox(height: 30),
          _buildStepItem(2, '完善資料', '填寫個人資訊與偏好設定'),
          const SizedBox(height: 30),
          _buildStepItem(3, '開始體驗', '探索系統的強大功能'),
          const Spacer(),
          // 開始按鈕
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F4A45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                '開始使用',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // 功能卡片
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 32,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4F4A45),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 步驟項目
  Widget _buildStepItem(int step, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF4F4A45),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              '$step',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4F4A45),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 頁面指示器和導航按鈕
  Widget _buildPageIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 跳過按鈕（只在前兩頁顯示）
          if (_currentPage < 2)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                '跳過',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF4F4A45),
                ),
              ),
            )
          else
            const SizedBox(width: 60),
          
          // 頁面指示點
          Row(
            children: List.generate(3, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? const Color(0xFF4F4A45)
                      : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          
          // 下一頁/完成按鈕
          if (_currentPage < 2)
            IconButton(
              onPressed: () {
                _goToPage(_currentPage + 1);
              },
              icon: const Icon(
                Icons.arrow_forward,
                color: Color(0xFF4F4A45),
                size: 28,
              ),
            )
          else
            const SizedBox(width: 60),
        ],
      ),
    );
  }
}