import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LastFrameLottie extends StatefulWidget {
  final String lottiePath;
  final double size;
  final Color color;
  final double lottiePointInTime;

  const LastFrameLottie({
    super.key,
    required this.lottiePath,
    required this.size,
    required this.color,
    this.lottiePointInTime = 1.0,
  });

  @override
  State<LastFrameLottie> createState() => _LastFrameLottieState();
}

class _LastFrameLottieState extends State<LastFrameLottie>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
    )..value = widget.lottiePointInTime;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      widget.lottiePath,
      width: widget.size,
      controller: _controller,
      delegates: LottieDelegates(
        values: [
          ValueDelegate.colorFilter(
            ['**'],
            value: ColorFilter.mode(widget.color, BlendMode.src),
          ),
        ],
      ),
    );
  }
}
