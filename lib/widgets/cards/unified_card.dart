import 'package:ctc/services/image_service.dart';
import 'package:flutter/material.dart';

enum CardType {
  product, // 產品卡片樣式
  mission, // 價值理念卡片樣式
}

class UnifiedCard extends StatelessWidget {
  final String imageName;
  final String title;
  final String subtitle;
  final bool invertColors;
  final VoidCallback? onTap;
  final CardType cardType;
  final String? buttonText; // 可自定義按鈕文字

  const UnifiedCard({
    super.key,
    required this.imageName,
    required this.title,
    required this.subtitle,
    this.invertColors = false,
    this.onTap,
    this.cardType = CardType.product,
    this.buttonText,
  });

  Widget _buildImage(BuildContext context, String imageName, ThemeData theme) {
    return FutureBuilder<String>(
      future: FileService().getImageUrl(imageName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: cardType == CardType.mission
                ? theme.colorScheme.surface
                : null,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Container(
            color: cardType == CardType.mission
                ? theme.colorScheme.surface
                : null,
            child: const Center(child: Icon(Icons.error)),
          );
        }

        if (cardType == CardType.mission) {
          // Mission卡片樣式：圖標風格，contain fit，可著色
          return Image.asset("home/$imageName");
          // return CachedNetworkImage(
          //   imageUrl: snapshot.data!,
          //   color: invertColors && theme.brightness == Brightness.dark
          //       ? Colors.white
          //       : theme.colorScheme.primary,
          //   fit: BoxFit.contain,
          //   placeholder: (context, url) => Container(
          //     color: theme.colorScheme.surface,
          //     child: const Center(child: CircularProgressIndicator()),
          //   ),
          //   errorWidget: (context, url, error) => Container(
          //     color: theme.colorScheme.surface,
          //     child: const Icon(Icons.error),
          //   ),
          // );
        } else {
          // Product卡片樣式：照片風格，cover fit，可反色
          Widget imageWidget = Container(
            alignment: Alignment.center,
            child: Image.asset("home/$imageName"),
            // CachedNetworkImage(
            //   imageUrl: snapshot.data!,
            //   width: double.infinity,
            //   fit: BoxFit.cover,
            //   placeholder: (context, url) =>
            //       const Center(child: CircularProgressIndicator()),
            //   errorWidget: (context, url, error) =>
            //       const Center(child: Icon(Icons.error)),
            // ),
          );

          if (invertColors) {
            return ColorFiltered(
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
              child: imageWidget,
            );
          }
          return imageWidget;
        }
      },
    );
  }

  Widget _buildProductLayout(
    BuildContext context,
    ThemeData theme,
    bool isDarkMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 圖片區域 - 固定佔用一部分空間
        Expanded(
          flex: 3, // 圖片佔 3/5 的空間
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: _buildImage(context, imageName, theme),
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
              final subtitleFontSize = (width * 0.04 + height * 0.06).clamp(
                12.0,
                18.0,
              );
              final buttonFontSize = (width * 0.035 + height * 0.05).clamp(
                11.0,
                16.0,
              );
              final iconSize = (width * 0.04 + height * 0.06).clamp(12.0, 20.0);

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
                    SizedBox(height: (height * 0.02).clamp(2.0, 8.0)), // 動態間距
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
                    SizedBox(height: (height * 0.03).clamp(4.0, 12.0)), // 動態間距
                    if (onTap != null) // 只有當有onTap時才顯示按鈕
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
                            width: (width * 0.005).clamp(1.0, 3.0), // 動態邊框寬度
                          ),
                          borderRadius: BorderRadius.circular(
                            (width * 0.015).clamp(4.0, 8.0),
                          ),
                          color: isDarkMode
                              ? theme.colorScheme.surface.withValues(alpha: 0.9)
                              : Colors.white.withValues(alpha: 0.9),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              buttonText ?? '瞭解更多',
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
    );
  }

  Widget _buildMissionLayout(
    BuildContext context,
    ThemeData theme,
    bool isDarkMode,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon part with dynamic sizing
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _buildImage(context, imageName, theme),
                ),
              ),
              const SizedBox(height: 8),
              // Text part
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  return Column(
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isDarkMode
                              ? theme.colorScheme.primary
                              : const Color(0xFF8B6914), // 金棕色
                          fontWeight: FontWeight.bold,
                          fontSize: width * 0.15,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDarkMode
                              ? theme.colorScheme.onSurface.withValues(
                                  alpha: 0.8,
                                )
                              : const Color(0xFFB8956F), // 深棕色
                          fontSize: width * 0.12,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final gradientColors = isDarkMode
        ? [
            theme.colorScheme.surface.withValues(alpha: 0.5), // 提高透明度讓卡片更亮
            theme.colorScheme.surface.withValues(alpha: 0.4), // 提高透明度讓卡片更亮
          ]
        : [
            const Color(0xFFF5E6D3), // 淺米色
            const Color(0xFFE8D5C4), // 中等米色
          ];

    return Container(
      margin: cardType == CardType.mission
          ? const EdgeInsets.all(8.0)
          : const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.15 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: cardType == CardType.mission
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _buildMissionLayout(context, theme, isDarkMode),
                  ),
                ],
              )
            : _buildProductLayout(context, theme, isDarkMode),
      ),
    );
  }
}
