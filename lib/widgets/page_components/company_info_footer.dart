import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// 公司資訊 Widget
/// 顯示光悅科技的地址和版權資訊，支援亮暗主題切換，可點擊跳轉Google Map
class CompanyInfoFooter extends StatelessWidget {
  const CompanyInfoFooter({super.key});

  // 打開 Google Maps 的函數
  Future<void> _openGoogleMaps(BuildContext context) async {
    const address = '台中市北屯區后庄七街215號';
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('無法開啟地圖')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('開啟地圖時發生錯誤: $e')));
      }
    }
  }

  // 打開 Instagram 的函數
  Future<void> _openInstagram(BuildContext context) async {
    const instagramUrl = 'https://instagram.com/coselig';
    final uri = Uri.parse(instagramUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('無法開啟 Instagram')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('開啟 Instagram 時發生錯誤: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // 使用與其他卡片相同的主題風格，調整透明度讓卡片更亮
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        // 使用與其他卡片相同的漸變背景
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(12), // 增加圓角，移除邊框
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDarkMode ? 0.15 : 0.05,
            ), // 稍微增加陰影
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 公司名稱和地址
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on,
                color: isDarkMode
                    ? theme.colorScheme.primary
                    : const Color(0xFF8B6914), // 金棕色 (與其他卡片一致)
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '光悅科技 (Coselig)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode
                      ? theme.colorScheme.primary
                      : const Color(0xFF8B6914), // 金棕色 (與其他卡片一致)
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 地址（可點擊查看地圖）
          GestureDetector(
            onTap: () => _openGoogleMaps(context),
            child: Text(
              '台中市北屯區后庄七街215號1樓',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDarkMode
                    ? theme.colorScheme.primary
                    : const Color(0xFFD17A3A), // 使用可點擊的顏色
                decoration: TextDecoration.underline, // 添加底線表示可點擊
                fontWeight: FontWeight.w500, // 稍微加粗
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          // Instagram 連結
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _openInstagram(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      color: isDarkMode
                          ? theme.colorScheme.secondary
                          : const Color(0xFFD17A3A), // 橙色
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Instagram',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDarkMode
                            ? theme.colorScheme.secondary
                            : const Color(0xFFD17A3A), // 橙色
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 版權資訊
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.copyright,
                color: isDarkMode
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                    : const Color(
                        0xFFB8956F,
                      ).withValues(alpha: 0.7), // 深棕色 (與其他卡片一致)
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '2025 光悅科技. All rights reserved.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDarkMode
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                      : const Color(
                          0xFFB8956F,
                        ).withValues(alpha: 0.7), // 深棕色 (與其他卡片一致)
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
