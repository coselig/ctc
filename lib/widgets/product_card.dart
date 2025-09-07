import 'package:cached_network_image/cached_network_image.dart';
import 'package:ctc/services/image_service.dart';
import 'package:flutter/material.dart';

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
    final isDarkMode = theme.brightness == Brightness.dark;

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
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      color: cardColor,
      elevation: 4,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 圖片區域 - 固定佔用一部分空間
              Expanded(
                flex: 3, // 圖片佔 3/5 的空間
                child: AspectRatio(
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
              ),
              // 文字區域 - 佔用剩餘空間並確保文字完整顯示
              Expanded(
                flex: 2, // 文字區域佔 2/5 的空間
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // 根據可用寬度動態計算字體大小
                    final width = constraints.maxWidth;
                    final height = constraints.maxHeight;

                    // 基於寬度和高度的動態字體大小計算
                    final titleFontSize = (width * 0.06 + height * 0.08).clamp(
                      14.0,
                      24.0,
                    );
                    final subtitleFontSize = (width * 0.04 + height * 0.06)
                        .clamp(12.0, 18.0);
                    final buttonFontSize = (width * 0.035 + height * 0.05)
                        .clamp(11.0, 16.0);
                    final iconSize = (width * 0.04 + height * 0.06).clamp(
                      12.0,
                      20.0,
                    );

                    // 動態計算 padding
                    final horizontalPadding = (width * 0.03).clamp(6.0, 12.0);
                    final verticalPadding = (height * 0.02).clamp(2.0, 8.0);

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: verticalPadding,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: isDarkMode
                                  ? theme.colorScheme.primary
                                  : const Color(0xFF8B6914), // 金棕色
                              fontWeight: FontWeight.bold,
                              fontSize: titleFontSize,
                            ),
                            maxLines: 2, // 允許標題換行
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: (height * 0.02).clamp(2.0, 8.0),
                          ), // 動態間距
                          Flexible(
                            child: Text(
                              subtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDarkMode
                                    ? theme.colorScheme.onSurface.withValues(
                                        alpha: 0.8,
                                      )
                                    : const Color(0xFFB8956F), // 深棕色
                                fontSize: subtitleFontSize,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 3, // 允許副標題多行顯示
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            height: (height * 0.03).clamp(4.0, 12.0),
                          ), // 動態間距
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: (width * 0.04).clamp(
                                8.0,
                                20.0,
                              ), // 動態按鈕內邊距
                              vertical: (height * 0.02).clamp(4.0, 10.0),
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isDarkMode
                                    ? theme.colorScheme.primary
                                    : const Color(0xFFD17A3A), // 橘棕色邊框
                                width: (width * 0.005).clamp(
                                  1.0,
                                  3.0,
                                ), // 動態邊框寬度
                              ),
                              borderRadius: BorderRadius.circular(
                                (width * 0.015).clamp(4.0, 8.0),
                              ),
                              color: isDarkMode
                                  ? theme.colorScheme.surface.withValues(
                                      alpha: 0.9,
                                    )
                                  : Colors.white.withValues(alpha: 0.9),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '瞭解更多',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isDarkMode
                                        ? theme.colorScheme.primary
                                        : const Color(0xFFD17A3A), // 橘棕色文字
                                    fontWeight: FontWeight.w600,
                                    fontSize: buttonFontSize,
                                  ),
                                ),
                                SizedBox(
                                  width: (width * 0.015).clamp(3.0, 8.0),
                                ), // 動態間距
                                Icon(
                                  Icons.arrow_forward,
                                  color: isDarkMode
                                      ? theme.colorScheme.primary
                                      : const Color(0xFFD17A3A), // 橘棕色圖標
                                  size: iconSize,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
