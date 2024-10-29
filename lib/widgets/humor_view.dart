import 'dart:math'; // For using pi
import 'dart:async'; // Import for StreamSubscription
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:daily_dose_of_humors/models/humor.dart';
import 'package:daily_dose_of_humors/util/util.dart';
import 'package:daily_dose_of_humors/models/category.dart';

class HumorView extends ConsumerStatefulWidget {
  final Humor humor;

  const HumorView({
    super.key,
    required this.humor,
  });

  @override
  ConsumerState<HumorView> createState() => _HumorViewState();
}

class _HumorViewState extends ConsumerState<HumorView> {
  late StreamSubscription<DatabaseEvent> likesCountSubscription;
  final pageController = PageController(keepPage: true);
  bool viewPunchLine = false;
  int likesCount = 0;

  @override
  void initState() {
    super.initState();
    DatabaseReference likesCountRef =
        FirebaseDatabase.instance.ref('likes/${widget.humor.uuid}');
    likesCountSubscription =
        likesCountRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      setState(() {
        if (data == null) {
          likesCount = 0;
        } else {
          likesCount = data as int;
        }
      });
    });
  }

  @override
  void dispose() {
    likesCountSubscription.cancel();
    super.dispose();
  }

  Widget _centerContentWidget(String text, Color textColor) {
    late double fontSize;
    if (text.length > 200) {
      fontSize = 24;
    } else if (text.length > 70) {
      fontSize = 27;
    } else {
      fontSize = 30;
    }
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          widget.humor.categoryCode == CategoryCode.FUNNY_QUOTES
              ? '"$text"\n\n- ${widget.humor.author} -'
              : text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: textColor,
            fontStyle: widget.humor.categoryCode == CategoryCode.FUNNY_QUOTES
                ? FontStyle.italic
                : FontStyle.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _generateHumorContent(Humor humor, Color textColor) {
    if (viewPunchLine) {
      return _centerContentWidget(humor.punchline, textColor);
    } else if (humor.contextList.isNotEmpty) {
      return Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: humor.contextList.length + 1,
              physics: const NeverScrollableScrollPhysics(),
              controller: pageController,
              itemBuilder: (context, index) {
                return _centerContentWidget(
                    [humor.context, ...humor.contextList][index], textColor);
              },
            ),
          ),
          SmoothPageIndicator(
            controller: pageController,
            count: humor.contextList.length + 1,
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
      return _centerContentWidget(humor.context, textColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return InkWell(
      onDoubleTap: widget.humor.punchline != ''
          ? () {
              setState(() {
                HapticFeedback.mediumImpact();
                viewPunchLine = !viewPunchLine;
              });
            }
          : null,
      onTap: () {
        if (widget.humor.contextList.isNotEmpty) {
          final nextPage = (pageController.page!.toInt() + 1) %
              (widget.humor.contextList.length + 1);
          pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 250),
            curve: Curves.decelerate,
          );
        }
      },
      child: Padding(
        // color: Colors.transparent,
        padding: const EdgeInsets.all(10),
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
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Text(
                        (() {
                          if (widget.humor.source == 'Daily Dose of Humors') {
                            return 'Sent by: ${widget.humor.sender}';
                          } else if (widget.humor.source == 'Your Own Humors') {
                            return 'Your Own Humors';
                          } else {
                            return '${intToNumeralString(widget.humor.humorIndex)} humor!';
                          }
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
                  if (widget.humor is DailyHumor &&
                      (widget.humor as DailyHumor).isNew)
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Image.asset(
                    'assets/icons/thumb-up.png',
                    color: textColor,
                    width: 18,
                  ),
                  const SizedBox(width: 5),
                  AnimatedFlipCounter(
                    value: likesCount,
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
              child: _generateHumorContent(widget.humor, textColor),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
