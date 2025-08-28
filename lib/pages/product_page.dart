import 'package:flutter/material.dart';
import '../widgets/feature_card.dart';
import '../widgets/feature_item.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('調光控制器'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 頂部大標題
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '選擇光悅的調光控制器',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '您將有不一樣的新體驗',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // 三個功能塊
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  FeatureCard(
                    title: '按鈕設定，重身定做',
                    subtitle: '智慧家庭，由您定義',
                    imageName: 'customize_button.jpg',
                  ),
                  const SizedBox(height: 16),
                  FeatureCard(
                    title: '自定義按座開關',
                    subtitle: '智能觸控介面',
                    imageName: 'smart_interface.jpg',
                  ),
                ],
              ),
            ),
            // 產品特點列表
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '產品特點',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  const FeatureItem(text: '高品質台灣製造'),
                  const FeatureItem(text: '支援各類智慧家庭平台'),
                  const FeatureItem(text: '穩定可靠的控制系統'),
                  const FeatureItem(text: '簡單直觀的操作介面'),
                  const FeatureItem(text: '完整的技術支援服務'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
