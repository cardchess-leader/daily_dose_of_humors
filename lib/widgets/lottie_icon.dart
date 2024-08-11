import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieIcon extends StatefulWidget {
  final int duration;
  final int delay;
  final int initDelay;
  final double size;
  final String lottiePath;
  final Color color;
  const LottieIcon({
    super.key,
    this.duration = 1000,
    this.delay = 0,
    this.initDelay = 0,
    this.size = 24,
    required this.lottiePath,
    required this.color,
  });

  @override
  State<LottieIcon> createState() {
    return _LottieIconState();
  }
}

class _LottieIconState extends State<LottieIcon> with TickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration),
    )..addStatusListener(_animStatusListener);

    Future.delayed(Duration(milliseconds: widget.initDelay), () {
      if (mounted) {
        _animController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animController.removeStatusListener(_animStatusListener);
    _animController.dispose();
    super.dispose();
  }

  void _animStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) {
          _animController.reset();
          _animController.forward();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      widget.lottiePath,
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
      ),
    );
    ;
  }
}
