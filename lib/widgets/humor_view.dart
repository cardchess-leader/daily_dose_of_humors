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
  ConsumerState<HumorView> createState() {
    return _HumorViewState();
  }
}

class _HumorViewState extends ConsumerState<HumorView>
    with TickerProviderStateMixin {
  final controller = PageController(keepPage: true);
  var viewPunchLine = false;
  Color textColor = Colors.black;

  @override
  void initState() {
    super.initState();
    // when humor is loaded, invoke setHumor
    widget.setHumor(widget.humor!);
  }

  Widget centerContentWidget(String text) {
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

  Widget generateHumorContent(Humor humor) {
    if (viewPunchLine) {
      return centerContentWidget(humor.punchline ?? '');
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
                return centerContentWidget(humor.contextList![index]);
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
      return centerContentWidget(humor.context!);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = ref.watch(darkModeProvider);
    textColor = isDarkMode ? Colors.white : Colors.black;
    // textColor = blackOrWhite;

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
                  Expanded(child: Container()),
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
            Expanded(child: generateHumorContent(widget.humor!)),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
