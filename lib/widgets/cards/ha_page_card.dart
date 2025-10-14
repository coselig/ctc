import 'package:ctc/services/image_service.dart';
import 'package:flutter/material.dart';

class HaPageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageName;
  final _imageService = ImageService();

  HaPageCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    _imageService.getImageUrl(imageName);
    final imageWidth = (screenWidth);
    final imageHeight = (screenHeight);

    return Card(
      elevation: 4,
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
                    color: theme.colorScheme.surface,
                    child: Icon(
                      Icons.error,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  );
                }
                return Container(
                  width: imageWidth,
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
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
