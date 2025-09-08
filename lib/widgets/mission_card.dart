import 'package:cached_network_image/cached_network_image.dart';
import 'package:ctc/services/image_service.dart';
import 'package:flutter/material.dart';

class MissionCard extends StatelessWidget {
  final String imageName;
  final String title;
  final String subtitle;
  final bool invertColors;

  const MissionCard({
    super.key,
    required this.imageName,
    required this.title,
    required this.subtitle,
    this.invertColors = false,
  });

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

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
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
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: LayoutBuilder(
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
                              child: FutureBuilder<String>(
                                future: ImageService().getImageUrl(imageName),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Container(
                                      color: theme.colorScheme.surface,
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                  if (snapshot.hasError) {
                                    return Container(
                                      color: theme.colorScheme.surface,
                                      child: const Icon(Icons.error),
                                    );
                                  }
                                  return CachedNetworkImage(
                                    imageUrl: snapshot.data!,
                                    color:
                                        invertColors &&
                                            theme.brightness == Brightness.dark
                                        ? Colors.white
                                        : theme.colorScheme.primary,
                                    fit: BoxFit.contain,
                                    placeholder: (context, url) => Container(
                                      color: theme.colorScheme.surface,
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                          color: theme.colorScheme.surface,
                                          child: const Icon(Icons.error),
                                        ),
                                  );
                                },
                              ),
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
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
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
                                          ? theme.colorScheme.onSurface
                                                .withValues(alpha: 0.8)
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
