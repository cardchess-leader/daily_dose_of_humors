import 'package:flutter/material.dart';

class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;

  const CustomNetworkImage(
    this.imageUrl, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
        return const Center(
          child: Text(
              'Unable to\nload image...'), // Later change this with default img from asset or such
        );
      },
      fit: BoxFit.cover,
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          return child;
        } else {
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
            ),
          ); // Show a loading indicator while the image is being loaded
        }
      },
    );
  }
}
