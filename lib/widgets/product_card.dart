import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductCard extends StatelessWidget {
  final String imageName;
  final String title;
  final String subtitle;

  const ProductCard({
    super.key,
    required this.imageName,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final storage = Supabase.instance.client.storage;
    final imageUrl = storage.from('assets').getPublicUrl(imageName);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CachedNetworkImage(
            imageUrl: imageUrl,
            height: 160,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
