import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final bool renderNothingOnError;

  const CustomNetworkImage(
    this.imageUrl, {
    super.key,
    this.renderNothingOnError = false,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fadeInDuration: const Duration(milliseconds: 0),
      fadeOutDuration: const Duration(milliseconds: 0),
      fit: BoxFit.cover,
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) {
        if (renderNothingOnError) {
          return SizedBox(height: 0);
        } else {
          return const Center(
            child: Text(
              'Unable to\nload image...',
              textAlign: TextAlign.center,
            ),
          );
        }
      },
      cacheKey: imageUrl, // Ensure caching based on URL
      useOldImageOnUrlChange: true, // Use cached image during rebuild
    );
  }
}
