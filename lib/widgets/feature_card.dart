import 'package:flutter/material.dart';
import 'package:ctc/services/image_service.dart';

class FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageName;
  final _imageService = ImageService();

  FeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageName,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 計算螢幕寬度的一半，但限制最大寬度為 300
    final imageWidth = (screenWidth * 0.5).clamp(0.0, 400.0);
    final imageHeight = imageWidth * 0.75; // 寬度的 3/4，產生 4:3 的比例

    return Card(
      elevation: 4,
      color: const Color(0xFFF5E6D3), // 米色背景
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5E6D3), // 淺米色
              Color(0xFFE8D5C4), // 中等米色
            ],
          ),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              FutureBuilder<String>(
                future: _imageService.getImageUrl(imageName),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Image.network(
                      snapshot.data!,
                      width: imageWidth,
                      height: imageHeight,
                      fit: BoxFit.cover,
                    );
                  } else if (snapshot.hasError) {
                    return Container(
                      width: imageWidth,
                      height: imageHeight,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    );
                  }
                  return Container(
                    width: imageWidth,
                    height: imageHeight,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF8B6914), // 金棕色
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFFB8956F), // 深棕色
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
