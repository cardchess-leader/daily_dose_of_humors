import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:daily_dose_of_humors/models/manual.dart';

class ManualWidget extends StatefulWidget {
  final int duration;
  final int delay;
  final Color color;
  final List<ManualItem> manualList;
  final void Function()? onTap;

  const ManualWidget({
    this.duration = 1000,
    this.delay = 0,
    this.color = Colors.black,
    this.manualList = const [],
    this.onTap,
    super.key,
  });

  @override
  State<ManualWidget> createState() {
    return _ManualWidgetState();
  }
}

class _ManualWidgetState extends State<ManualWidget>
    with TickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration),
    )..addStatusListener(_animStatusListener);

    Future.delayed(const Duration(milliseconds: 1000), () {
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
    return Container(
      color: const Color.fromARGB(230, 0, 0, 0),
      width: double.infinity,
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 75,
            ),
            Text(
              'How to enjoy this humor?',
              style: TextStyle(
                color: widget.color,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            // const SizedBox(
            //   height: 50,
            // ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...widget.manualList.map(
                    (manualItem) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            alignment: Alignment.center,
                            child: Lottie.asset(
                              manualItem.lottiePath,
                              width: manualItem.iconSize,
                              height: manualItem.iconSize,
                              controller: _animController,
                              delegates: LottieDelegates(
                                values: [
                                  ValueDelegate.colorFilter(
                                    ['**'],
                                    value: ColorFilter.mode(
                                        widget.color, BlendMode.src),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // if (i == 3) const SizedBox(width: 40),
                          Text(
                            manualItem.text,
                            style: TextStyle(
                              color: widget.color,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 50),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            // const SizedBox(
            //   height: 50,
            // ),
          ],
        ),
      ),
    );
    ;
  }
}
