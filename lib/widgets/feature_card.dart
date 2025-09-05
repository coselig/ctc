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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    // 計算螢幕寬度的一半，但限制最大寬度為 400
    final maxImageWidth = (screenWidth * 0.5).clamp(0.0, 400.0);

    // 根據主題模式選擇背景顏色和漸變
    final cardColor = isDarkMode
        ? theme.colorScheme.surface
        : const Color(0xFFF5E6D3);

    final gradientColors = isDarkMode
        ? [
            theme.colorScheme.surface,
            theme.colorScheme.surface.withValues(alpha: 0.8),
          ]
        : [
            const Color(0xFFF5E6D3), // 淺米色
            const Color(0xFFE8D5C4), // 中等米色
          ];

    return Card(
      elevation: 4,
      color: cardColor,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              FutureBuilder<({int width, int height})>(
                future: _imageService.getImageDimensions(imageName),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final dimensions = snapshot.data!;
                    final aspectRatio = dimensions.width / dimensions.height;
                    final imageHeight = maxImageWidth / aspectRatio;

                    return FutureBuilder<String>(
                      future: _imageService.getImageUrl(imageName),
                      builder: (context, urlSnapshot) {
                        if (urlSnapshot.hasData) {
                          return Image.network(
                            urlSnapshot.data!,
                            width: maxImageWidth,
                            height: imageHeight,
                            fit: BoxFit.cover,
                          );
                        } else if (urlSnapshot.hasError) {
                          return Container(
                            width: maxImageWidth,
                            height: imageHeight,
                            color: theme.colorScheme.surface,
                            child: Icon(
                              Icons.error,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          );
                        }
                        return Container(
                          width: maxImageWidth,
                          height: imageHeight,
                          color: theme.colorScheme.surface,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    // 如果無法獲取尺寸，使用預設的 4:3 比例
                    final imageHeight = maxImageWidth * 0.75;
                    return FutureBuilder<String>(
                      future: _imageService.getImageUrl(imageName),
                      builder: (context, urlSnapshot) {
                        if (urlSnapshot.hasData) {
                          return Image.network(
                            urlSnapshot.data!,
                            width: maxImageWidth,
                            height: imageHeight,
                            fit: BoxFit.cover,
                          );
                        }
                        return Container(
                          width: maxImageWidth,
                          height: imageHeight,
                          color: theme.colorScheme.surface,
                          child: Icon(
                            Icons.error,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        );
                      },
                    );
                  }
                  // 加載中，使用預設比例
                  final imageHeight = maxImageWidth * 0.75;
                  return Container(
                    width: maxImageWidth,
                    height: imageHeight,
                    color: theme.colorScheme.surface,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    ),
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
                          color: isDarkMode
                              ? theme.colorScheme.primary
                              : const Color(0xFF8B6914), // 金棕色
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isDarkMode
                              ? theme.colorScheme.onSurface.withValues(
                                  alpha: 0.8,
                                )
                              : const Color(0xFFB8956F), // 深棕色
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
