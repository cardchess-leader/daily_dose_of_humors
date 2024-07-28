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

class _HumorScreenState extends State<HumorScreen> {
  late Category _selectedCategory;
  // int _currentPage = 0;
  final controller = PageController(viewportFraction: 0.8, keepPage: true);

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pop();
        break;
    }
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
            // color: Colors.white,
          ),
        ),
        backgroundColor: _selectedCategory.themeColor,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => {},
            icon: const Icon(Icons.question_mark_rounded),
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
                                        'What did the Fox say?',
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
              icon: const Icon(
                Icons.arrow_back,
                // color: Colors.white,
              ),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: const Icon(
                Icons.share_outlined,
                // color: Colors.white,
              ),
              onPressed: () => _onItemTapped(1),
            ),
            IconButton(
              icon: const Icon(
                Icons.bookmark_add_outlined,
                // color: Colors.white,
              ),
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
