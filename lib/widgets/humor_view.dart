import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:daily_dose_of_humors/models/humor.dart';

class HumorView extends StatefulWidget {
  final Humor humor;
  const HumorView(this.humor, {super.key});

  @override
  State<HumorView> createState() {
    return _HumorViewState();
  }
}

class _HumorViewState extends State<HumorView> with TickerProviderStateMixin {
  final controller = PageController(keepPage: true);
  var viewPunchLine = false;

  Widget centerContentWidget(String text, Color color) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget generateHumorContent(Humor humor) {
    if (viewPunchLine) {
      return centerContentWidget(humor.punchline, Colors.black);
    } else if (humor.contextList?.isNotEmpty ?? false) {
      return Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: humor.contextList!.length,
              onPageChanged: (pageIndex) {
                print(pageIndex);
              },
              controller: controller,
              itemBuilder: (context, index) {
                return centerContentWidget(
                    humor.contextList![index], Colors.black);
              },
            ),
          ),
          SmoothPageIndicator(
            controller: controller, // PageController
            count: humor.contextList!.length,
            effect: WormEffect(
              dotWidth: 12,
              dotHeight: 12,
              activeDotColor: humor.getCategoryData().themeColor,
            ), // your preferred effect
            onDotClicked: (index) {
              controller.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ],
      );
    } else {
      return centerContentWidget(humor.context, Colors.black);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color blackOrWhite = isDarkMode ? Colors.white : Colors.black;

    return GestureDetector(
      onDoubleTap: () {
        print('double tap!');
        setState(() => viewPunchLine = !viewPunchLine);
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
                mainAxisSize: MainAxisSize.min,
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
                            blackOrWhite,
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
                      color: isDarkMode
                          ? Colors.grey.shade100
                          : Colors.grey.shade900,
                    ),
                  ),
                  Expanded(child: Container()),
                  Text(
                    '2024/07/27 #1',
                    style: TextStyle(
                      color: blackOrWhite,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: generateHumorContent(widget.humor)),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
