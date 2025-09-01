import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ctc/services/image_service.dart';

class ProductCard extends StatelessWidget {
  final String imageName;
  final String title;
  final String subtitle;
  final bool invertColors;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.imageName,
    required this.title,
    required this.subtitle,
    this.invertColors = false,
    this.onTap,
  });

  Widget _buildImage(BuildContext context, String imageName, ThemeData theme) {
    return FutureBuilder<String>(
      future: ImageService().getImageUrl(imageName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Icon(Icons.error));
        }
        return Container(
          alignment: Alignment.center,
          child: CachedNetworkImage(
            imageUrl: snapshot.data!,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) =>
                const Center(child: Icon(Icons.error)),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      color: const Color(0xFFF5E6D3), // 米色背景
      elevation: 4,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5E6D3), // 淺米色
              Color(0xFFE8D5C4), // 中等米色
            ],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: invertColors
                    ? ColorFiltered(
                        colorFilter: ColorFilter.matrix(
                          theme.brightness == Brightness.dark
                              ? [
                                  -1,
                                  0,
                                  0,
                                  0,
                                  255,
                                  0,
                                  -1,
                                  0,
                                  0,
                                  255,
                                  0,
                                  0,
                                  -1,
                                  0,
                                  255,
                                  0,
                                  0,
                                  0,
                                  1,
                                  0,
                                ]
                              : [
                                  1,
                                  0,
                                  0,
                                  0,
                                  0,
                                  0,
                                  1,
                                  0,
                                  0,
                                  0,
                                  0,
                                  0,
                                  1,
                                  0,
                                  0,
                                  0,
                                  0,
                                  0,
                                  1,
                                  0,
                                ],
                        ),
                        child: _buildImage(context, imageName, theme),
                      )
                    : _buildImage(context, imageName, theme),
              ),
              // 標題和內容
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final titleSize = width * 0.08; // 8% of width
                  final subtitleSize = width * 0.06; // 6% of width
                  final buttonTextSize = width * 0.05; // 5% of width

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.04, // 4% of width
                      vertical: width * 0.02, // 2% of width
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: const Color(0xFF8B6914), // 金棕色
                            fontWeight: FontWeight.bold,
                            fontSize: titleSize,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: width * 0.01),
                        Text(
                          subtitle,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: const Color(0xFFB8956F), // 深棕色
                            fontSize: subtitleSize,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: width * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFD17A3A), // 橘棕色邊框
                                ),
                                borderRadius: BorderRadius.circular(
                                  width * 0.02,
                                ),
                                color: Colors.white.withOpacity(0.8),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: width * 0.02,
                                vertical: width * 0.01,
                              ),
                              child: Text(
                                '瞭解更多',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: const Color(0xFFD17A3A), // 橘棕色文字
                                  fontSize: buttonTextSize,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward,
                              color: const Color(0xFFD17A3A), // 橘棕色圖標
                              size: width * 0.08,
                            ),

                            SizedBox(height: width * 0.04),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
