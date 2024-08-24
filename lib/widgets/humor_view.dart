import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:daily_dose_of_humors/models/humor.dart';
import 'package:daily_dose_of_humors/providers/app_state.dart';

class HumorView extends ConsumerStatefulWidget {
  final Humor? humor;
  final void Function(Humor humor) setHumor;

  const HumorView({
    super.key,
    this.humor,
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
              itemCount: humor.contextList!.length,
              physics: const NeverScrollableScrollPhysics(),
              controller: pageController,
              itemBuilder: (context, index) {
                return _centerContentWidget(
                    humor.contextList![index], textColor);
              },
            ),
          ),
          SmoothPageIndicator(
            controller: pageController,
            count: humor.contextList!.length,
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
    final isDarkMode = ref.watch(userSettingsProvider)['darkMode'] ?? false;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return InkWell(
      onDoubleTap: () {
        setState(() {
          viewPunchLine = !viewPunchLine;
        });
      },
      onTap: () {
        if (widget.humor?.contextList?.isNotEmpty ?? false) {
          final nextPage = (pageController.page!.toInt() + 1) %
              widget.humor!.contextList!.length;
          pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 250),
            curve: Curves.decelerate,
          );
        }
      },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.hardEdge,
              child: Row(
                children: [
                  Lottie.asset(
                    'assets/lottie/lottie2.json',
                    width: 45,
                    height: 45,
                    delegates: LottieDelegates(
                      values: [
                        ValueDelegate.colorFilter(
                          ['**'],
                          value: ColorFilter.mode(
                            textColor,
                            BlendMode.src,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'x  123',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '2024/07/27 #1',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _generateHumorContent(widget.humor!, textColor),
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
