import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;

  const CustomNetworkImage(
    this.imageUrl, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fadeInDuration: const Duration(milliseconds: 0),
      fadeOutDuration: const Duration(milliseconds: 0),
      fit: BoxFit.cover,
      placeholder: (context, url) => const Center(
        child:
            CircularProgressIndicator(), // Show a loading indicator while the image is loading
      ),
      errorWidget: (context, url, error) => const Center(
        child: Text(
          'Unable to\nload image...', // Fallback when the image fails to load
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
