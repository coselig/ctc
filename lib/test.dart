import 'package:flutter/material.dart';

class MyFirstWidgetState extends StatefulWidget {
  const MyFirstWidgetState({super.key});

  @override
  State<MyFirstWidgetState> createState() => _MyFirstWidgetStateState();
}

class _MyFirstWidgetStateState extends State<MyFirstWidgetState> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5E6E0),  // 淺粉紅色
              Color(0xFFE6E6E6),  // 淺灰色
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Text(
                  '調光',
                  style: TextStyle(
                    fontSize: 48,
                    color: Color(0xFF4A4A4A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  '開啟智慧新生活',
                  style: TextStyle(
                    fontSize: 32,
                    color: Color(0xFF4A4A4A),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '25th ver.',
                  style: TextStyle(
                    fontSize: 24,
                    color: Color(0xFF6B4423),  // 深褐色
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Image.asset(
                  'assets/sqare_ctc_icon.png',
                  height: 60,
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