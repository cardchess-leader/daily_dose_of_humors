import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:daily_dose_of_humors/models/category.dart';

class HumorScreen extends StatefulWidget {
  final Category selectedCategory;
  const HumorScreen(this.selectedCategory, {super.key});

  @override
  State<HumorScreen> createState() {
    return _HumorScreenState();
  }
}

class _HumorScreenState extends State<HumorScreen>
    with TickerProviderStateMixin {
  late Category _selectedCategory;
  late AnimationController _infoAnimController;
  late AnimationController _shareAnimController;
  late AnimationController _bookmarkAnimController;
  // int _currentPage = 0;
  final controller = PageController(viewportFraction: 0.8, keepPage: true);
  var bookmarkLottieAsset = 'assets/lottie/regular-marked-bookmark.json';
  var bookmarked = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _infoAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addStatusListener(_infoAnimationStatusListener);
    _infoAnimController.forward();
    _shareAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _bookmarkAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _infoAnimController.removeStatusListener(_infoAnimationStatusListener);
    _infoAnimController.dispose();
    _shareAnimController.dispose();
    _bookmarkAnimController.dispose();
    super.dispose();
  }

  void _infoAnimationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          _infoAnimController.reset();
          _infoAnimController.forward();
        }
      });
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pop();
        break;
      case 1:
        _shareAnimController.reset();
        _shareAnimController.forward();
        break;
      case 2:
        setState(() {
          bookmarked = !bookmarked;
          if (bookmarked) {
            bookmarkLottieAsset = 'assets/lottie/regular-marked-bookmark.json';
          } else {
            bookmarkLottieAsset =
                'assets/lottie/regular-unmarked-bookmark.json';
          }
          _bookmarkAnimController.reset();
          _bookmarkAnimController.forward();
        });
        break;
    }
  }

  Widget getBottomNavLottie(
      String assetPath, Color color, AnimationController controller) {
    return Lottie.asset(
      assetPath,
      width: 24,
      controller: controller,
      delegates: LottieDelegates(
        values: [
          ValueDelegate.colorFilter(
            ['**'],
            value: ColorFilter.mode(color, BlendMode.src),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color blackOrWhite = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _selectedCategory.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        backgroundColor: _selectedCategory.themeColor,
        // backgroundColor: Colors.amber,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => {},
            icon: Stack(
              children: [
                Container(
                  width: 45.0,
                  height: 45.0,
                  alignment: Alignment.center,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: blackOrWhite, // Set the circle color
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Lottie.asset(
                  'assets/lottie/help-1.json',
                  width: 45,
                  height: 45,
                  controller: _infoAnimController,
                  delegates: LottieDelegates(
                    values: [
                      ValueDelegate.colorFilter(
                        ['**'],
                        value: ColorFilter.mode(
                          _selectedCategory.themeColor,
                          BlendMode.src,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          // color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Lottie.asset(
                              // widget.category.imgPath,
                              // color: darkenThemeColor,
                              'assets/lottie/lottie2.json',
                              width: 45,
                              height: 45,
                              delegates: LottieDelegates(
                                values: [
                                  ValueDelegate.colorFilter(
                                    ['**'],
                                    value: ColorFilter.mode(
                                      // _selectedCategory.themeColor,
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
                            Expanded(
                              child: Container(),
                            ),
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
                    ),
                    Expanded(
                      child: PageView.builder(
                        itemCount: 3,
                        onPageChanged: (pageIndex) {
                          print(pageIndex);
                        },
                        controller: controller,
                        itemBuilder: (context, index) {
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight,
                                  ),
                                  child: Container(
                                    // color: Colors.red,
                                    padding: const EdgeInsets.all(30),
                                    child: Center(
                                      child: Text(
                                        "¿Qué acabas de decir?",
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w600,
                                          color: blackOrWhite,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    SmoothPageIndicator(
                      controller: controller, // PageController
                      count: 3,
                      effect: WormEffect(
                        dotWidth: 12,
                        dotHeight: 12,
                        activeDotColor: _selectedCategory.themeColor,
                      ), // your preferred effect
                      onDotClicked: (index) {
                        controller.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        // color: Colors.transparent,
        color: _selectedCategory.themeColor,
        notchMargin: 6.0,
        child: Row(
          children: [
            IconButton(
              icon: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
                child: Image.asset('assets/icons/arrow-right.png', width: 24),
              ),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: getBottomNavLottie('assets/lottie/share.json', blackOrWhite,
                  _shareAnimController),
              onPressed: () => _onItemTapped(1),
            ),
            IconButton(
              icon: getBottomNavLottie(
                  bookmarkLottieAsset, blackOrWhite, _bookmarkAnimController),
              onPressed: () => _onItemTapped(2),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber.shade400,
        // backgroundColor: _selectedCategory.themeColor,
        // elevation: 0,
        onPressed: () {
          // Handle the FAB action
          print('FAB Pressed');
        },
        tooltip: 'Add',
        child: Lottie.asset(
          'assets/lottie/lottie-test.json',
          fit: BoxFit.contain,
          // width: 10,
          // height: 10,
          delegates: LottieDelegates(
            values: [
              ValueDelegate.colorFilter(
                ['**'],
                value: const ColorFilter.mode(Colors.black, BlendMode.src),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
