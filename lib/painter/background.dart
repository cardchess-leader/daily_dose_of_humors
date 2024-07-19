import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ScrollingBackgroundPainter extends CustomPainter {
  final List<ui.Image> imageList;
  final double offset;
  final double imageSize;
  final double imageMargin;
  final int patternLength;

  ScrollingBackgroundPainter(this.imageList, this.offset, this.imageSize,
      this.imageMargin, this.patternLength);

  @override
  void paint(Canvas canvas, Size size) {
    int indexX = 0, indexY = 0;
    for (double dx = -offset;
        dx < size.width;
        dx += imageSize + imageMargin, indexX++) {
      indexY = 0;
      for (double dy = -offset;
          dy < size.height;
          dy += imageSize + imageMargin, indexY++) {
        ui.Image image = imageList[
            ((indexY % patternLength) * 2 + (indexX % patternLength)) %
                (patternLength * patternLength)];
        canvas.drawImageRect(
          image,
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
          Rect.fromLTWH(dx, dy, imageSize, imageSize),
          Paint()
            ..colorFilter =
                ColorFilter.mode(Colors.grey.shade500, BlendMode.srcATop),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
