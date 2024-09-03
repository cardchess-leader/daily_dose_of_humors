import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingWidget extends StatefulWidget {
  final double size;
  final Color color;
  const LoadingWidget({
    super.key,
    this.size = 24,
    required this.color,
  });

  @override
  State<LoadingWidget> createState() {
    return _LottieIconState();
  }
}

class _LottieIconState extends State<LoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset('assets/lottie/circular-loading.json',
        width: widget.size,
        height: widget.size,
        controller: _animController,
        delegates: LottieDelegates(
          values: [
            ValueDelegate.colorFilter(
              ['**'],
              value: ColorFilter.mode(widget.color, BlendMode.src),
            ),
          ],
        ), onLoaded: (composition) {
      _animController.duration = composition.duration;
      _animController.repeat();
    });
  }
}
