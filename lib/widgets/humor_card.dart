import 'package:flutter/material.dart';
import 'package:daily_dose_of_humors/models/category.dart';
import 'package:daily_dose_of_humors/util/util.dart';
import 'package:lottie/lottie.dart';

class HumorCategoryCard extends StatefulWidget {
  final Category category;
  final bool playLottieAnim;

  const HumorCategoryCard(
    this.category,
    this.playLottieAnim, {
    super.key,
  });

  @override
  State<HumorCategoryCard> createState() => _HumorCategoryCardState();
}

class _HumorCategoryCardState extends State<HumorCategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.category.animDuration),
    )..addStatusListener(_animationStatusListener);

    if (widget.playLottieAnim) {
      _startAnimationWithDelay();
    }
  }

  @override
  void didUpdateWidget(covariant HumorCategoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.playLottieAnim != oldWidget.playLottieAnim) {
      if (widget.playLottieAnim) {
        _startAnimationWithDelay();
      } else {
        _controller.reset();
        _controller.stop();
      }
    }
  }

  void _startAnimationWithDelay() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && widget.playLottieAnim) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_animationStatusListener);
    _controller.dispose();
    super.dispose();
  }

  void _animationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          if (widget.playLottieAnim) {
            _controller.reset();
            _controller.forward();
          } else {
            _controller.stop();
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color darkenThemeColor = darken(widget.category.themeColor, 0.5);
    Color lightenThemeColor = lighten(widget.category.themeColor, 0.25);
    Color adaptiveTextColor =
        isDarkMode ? lightenThemeColor : Colors.grey.shade900;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      height: 500,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        color: isDarkMode ? darkenThemeColor : Colors.white,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? lightenThemeColor
                        : widget.category.themeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(30),
                        width: double.infinity,
                        child: Text(
                          widget.category.title,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? darkenThemeColor : Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Transform.scale(
                          scale: widget.category.title == 'Tricky Riddles'
                              ? 1.2
                              : 1,
                          child: Lottie.asset(
                            widget.category.imgPath,
                            fit: BoxFit.contain,
                            controller: _controller,
                            delegates: LottieDelegates(
                              values: [
                                ValueDelegate.colorFilter(
                                  ['**'],
                                  value: ColorFilter.mode(
                                      darkenThemeColor, BlendMode.srcATop),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 140,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.category.description,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: adaptiveTextColor),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.category.numDailyNew} new jokes daily',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: adaptiveTextColor,
                          ),
                        ),
                        if (widget.category.subscriberOnly)
                          Chip(
                            avatar: Icon(
                              Icons.lock,
                              color: isDarkMode ? lightenThemeColor : null,
                            ),
                            backgroundColor: isDarkMode
                                ? darkenThemeColor
                                : Colors.grey.shade100,
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: isDarkMode
                                    ? lightenThemeColor
                                    : Colors.transparent,
                                width: isDarkMode ? 0.5 : 0,
                              ),
                            ),
                            shadowColor:
                                isDarkMode ? null : Colors.grey.shade100,
                            label: Text(
                              'Subscribers Only',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isDarkMode ? lightenThemeColor : null,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
