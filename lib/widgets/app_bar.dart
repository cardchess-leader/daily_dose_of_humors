import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String heading;
  final String subheading;
  final int additionalHeight;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    required this.heading,
    this.additionalHeight = 25,
    this.subheading = '',
    this.backgroundColor,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    Color? titleColor = DefaultTextStyle.of(context).style.color;
    if (Theme.of(context).brightness == Brightness.dark) {
      if (backgroundColor != null) {
        titleColor = Colors.black;
      } else {
        titleColor = Colors.grey.shade100;
      }
    }

    return AppBar(
      backgroundColor: backgroundColor,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: TextStyle(
              fontSize: 30, // Adjusted for better fit in AppBar
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          if (subheading.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              subheading,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),
          ],
        ],
      ),
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + additionalHeight);
}
