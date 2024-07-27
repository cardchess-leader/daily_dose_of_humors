import 'package:flutter/material.dart';
import 'package:daily_dose_of_humors/models/category.dart';
import 'package:daily_dose_of_humors/util/util.dart';
import 'package:lottie/lottie.dart';

class HumorCategoryCard extends StatefulWidget {
  final Category category;
  const HumorCategoryCard(
    this.category, {
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
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color darkenThemeColor = darken(widget.category.themeColor, 0.5);
    Color lightenThemeColor = lighten(widget.category.themeColor, 0.25);
    // Color adaptiveTextColor =
    //     isDarkMode ? Colors.grey.shade200 : Colors.grey.shade900;
    Color adaptiveTextColor =
        isDarkMode ? lightenThemeColor : Colors.grey.shade900;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      // width: 500,
      height: 500,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        color: isDarkMode ? darkenThemeColor : Colors.white,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  // margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? lightenThemeColor
                        // ? darken(widget.category.themeColor, 0.2)
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
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 30),
                          child: ScaleTransition(
                            scale: _controller.drive(
                              Tween<double>(begin: 0.9, end: 1.05),
                            ),
                            // child: Image.asset(
                            //   widget.category.imgPath,
                            //   color: darkenThemeColor,
                            // ),
                            child: Lottie.asset(
                              // widget.category.imgPath,
                              // color: darkenThemeColor,
                              'assets/lottie/lottie2.json',
                              fit: BoxFit.contain,
                              delegates: LottieDelegates(
                                values: [
                                  ValueDelegate.colorFilter(
                                    ['**'],
                                    value: ColorFilter.mode(
                                        darkenThemeColor, BlendMode.src),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                // color: Colors.white,
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
                                    : Colors.transparent, // No border color
                                width: isDarkMode
                                    ? 0.5
                                    : 0, // Border width set to zero
                              ),
                            ),
                            // elevation: 1,
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
