import 'package:flutter/material.dart';
import 'package:ctc/widgets/triangle_background.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TriangleBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,  // 改為靠左對齊
              children: [
                const SizedBox(height: 40),
                const Text(
                  '調光',
                  style: TextStyle(
                    fontSize: 48,
                    color: Color(0xFF4F4A45),  // 深灰褐色
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),  // 減少間距
                const Text(
                  '開啟智慧新生活',
                  style: TextStyle(
                    fontSize: 32,
                    color: Color(0xFF4F4A45),  // 深灰褐色
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerRight,  // 靠右對齊
                  child: Padding(
                    padding: EdgeInsets.only(right: 32.0),  // 右側間距
                    child: Text(
                      '25th ver.',
                      style: TextStyle(
                        fontSize: 24,
                        color: Color(0xFF8B4513),  // 深褐色
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,  // 斜體
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
          ),
        ),
      ),
    );
  }
}