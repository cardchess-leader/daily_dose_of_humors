import 'dart:math'; // For using pi
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:daily_dose_of_humors/models/humor.dart';
import 'package:daily_dose_of_humors/models/category.dart';

class HumorView extends ConsumerStatefulWidget {
  final Humor humor;
  final void Function(Humor humor) setHumor;

  const HumorView({
    super.key,
    required this.humor,
    required this.setHumor,
  });

  @override
  ConsumerState<HumorView> createState() => _HumorViewState();
}

class _HumorViewState extends ConsumerState<HumorView> {
  final pageController = PageController(keepPage: true);
  bool viewPunchLine = false;

  @override
  void initState() {
    super.initState();
    // Invoke setHumor when the humor is loaded
    if (widget.humor != null) {
      widget.setHumor(widget.humor!);
    }
  }

  Widget _centerContentWidget(String text, Color textColor) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _generateHumorContent(Humor humor, Color textColor) {
    if (viewPunchLine) {
      return _centerContentWidget(humor.punchline ?? '', textColor);
    } else if (humor.contextList?.isNotEmpty ?? false) {
      return Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: humor.contextList!.length + 1,
              physics: const NeverScrollableScrollPhysics(),
              controller: pageController,
              itemBuilder: (context, index) {
                return _centerContentWidget(
                    [humor.context!, ...humor.contextList!][index], textColor);
              },
            ),
          ),
          SmoothPageIndicator(
            controller: pageController,
            count: humor.contextList!.length + 1,
            effect: WormEffect(
              dotWidth: 12,
              dotHeight: 12,
              activeDotColor: humor.getCategoryData().themeColor,
            ),
            onDotClicked: (index) {
              pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ],
      );
    } else {
      return _centerContentWidget(humor.context!, textColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return InkWell(
      onDoubleTap: widget.humor?.punchline != null
          ? () {
              setState(() {
                viewPunchLine = !viewPunchLine;
              });
            }
          : null,
      onTap: () {
        if (widget.humor?.contextList?.isNotEmpty ?? false) {
          final nextPage = (pageController.page!.toInt() + 1) %
              (widget.humor!.contextList!.length + 1);
          pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 250),
            curve: Curves.decelerate,
          );
        }
      },
      child: Padding(
        // color: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Column(
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(50),
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 70),
                      child: Text(
                        (() {
                          if (widget.humor == null) {
                            return 'Loading Humors...';
                          }
                          if (widget.humor!.categoryCode ==
                              CategoryCode.YOUR_HUMORS) {
                            return 'Your Own Humors';
                          }
                          return 'Sent by: Board Collie';
                        })(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: const Alignment(1.1, 0),
                    child: Transform(
                      transform: Matrix4.rotationZ(pi / 4),
                      alignment: Alignment.center,
                      child: Container(
                        color: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            if (widget.humor is DailyHumor)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icons/thumb-up.png',
                      color: textColor,
                      width: 18,
                    ),
                    const SizedBox(width: 5),
                    AnimatedFlipCounter(
                      value: (widget.humor as DailyHumor).thumbsUpCount,
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            Expanded(
              child: _generateHumorContent(widget.humor!, textColor),
            ),
            const SizedBox(height: 5),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            //   child: Row(
            //     children: [
            //       const Spacer(),
            //       const Text(
            //         '2024.7.12 #3',
            //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            //       ),
            //     ],
            //   ),
            // ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
