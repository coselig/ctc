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
                    Page1(context), Page2(context),
                  ],
                ),
              ),
              _buildPageIndicator(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget Page1(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 改為靠左對齊
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.17),
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              '調光',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.12,
                color: Color(0xFF4F4A45), // 深灰褐色
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8), // 減少間距
          Center(
            child: Text(
              '開啟智慧新生活',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.07,
                color: Color(0xFF4F4A45), // 深灰褐色
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight, // 靠右對齊
            child: Padding(
              padding: EdgeInsets.only(right: 32.0), // 右側間距
              child: Text(
                '25th ver.',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                  color: Color(0xFF8B4513), // 深褐色
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Image.asset(
            'menu/1.png',
            width: 220,
            height: 220,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          Center(
            // 置中對齊
            child: Image.asset(
              'assets/sqare_ctc_icon.png',
              height: 48, // 調整 logo 大小
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
  
  Widget Page2(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 改為靠左對齊
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.17),
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              '調光',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.12,
                color: Color(0xFF4F4A45), // 深灰褐色
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8), // 減少間距
          Center(
            child: Text(
              '開啟智慧新生活',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.07,
                color: Color(0xFF4F4A45), // 深灰褐色
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight, // 靠右對齊
            child: Padding(
              padding: EdgeInsets.only(right: 32.0), // 右側間距
              child: Text(
                '25th ver.',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                  color: Color(0xFF8B4513), // 深褐色
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Image.asset(
            'menu/1.png',
            width: 220,
            height: 220,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          Center(
            // 置中對齊
            child: Image.asset(
              'assets/sqare_ctc_icon.png',
              height: 48, // 調整 logo 大小
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
  
  


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
                style: TextStyle(fontSize: 16, color: Color(0xFF4F4A45)),
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
