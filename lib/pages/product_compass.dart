import 'package:flutter/material.dart';
import '../services/image_service.dart';
import '../widgets/compass_background.dart';

class ProductCompassPage extends StatefulWidget {
  const ProductCompassPage({super.key});

  @override
  State<ProductCompassPage> createState() => _ProductCompassPageState();
}

class _ProductCompassPageState extends State<ProductCompassPage> {
  final _imageService = ImageService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CompassBackground(
        child: SafeArea(
          child: Column(
            children: [
              // 頂部導航
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.brown),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              // 主要內容區域
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 主標題
                    const Text(
                      '調光',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B6914),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 副標題
                    const Text(
                      '開啟智慧新生活',
                      style: TextStyle(
                        fontSize: 24,
                        color: Color(0xFF8B6914),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 版本號
                    const Text(
                      '25th ver.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF8B6914),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 80),
                    // 產品圖片區域
                    Container(
                      width: 300,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: FutureBuilder<String>(
                          future: _imageService.getImageUrl(
                            'product_compass.jpg',
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Image.network(
                                snapshot.data!,
                                fit: BoxFit.cover,
                              );
                            } else if (snapshot.hasError) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(
                                    Icons.error,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            }
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF8B6914),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 底部 Logo
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Row(
                  children: [
                    // Logo 圖標
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD17A3A),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'G',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 公司名稱
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '光悅',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD17A3A),
                          ),
                        ),
                        Text(
                          'COSELIO TECH.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8B6914),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
