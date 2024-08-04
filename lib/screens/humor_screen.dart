import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:daily_dose_of_humors/models/category.dart';
import 'package:daily_dose_of_humors/data/humor_data.dart';
import 'package:daily_dose_of_humors/widgets/humor_view.dart';
import 'package:daily_dose_of_humors/widgets/banner_ad.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_dose_of_humors/providers/app_state.dart';

class HumorScreen extends ConsumerStatefulWidget {
  final Category selectedCategory;
  const HumorScreen(this.selectedCategory, {super.key});

  @override
  ConsumerState<HumorScreen> createState() {
    return _HumorScreenState();
  }
}

class _HumorScreenState extends ConsumerState<HumorScreen>
    with TickerProviderStateMixin {
  late Category _selectedCategory;
  late AnimationController _infoAnimController;
  late AnimationController _shareAnimController;
  late AnimationController _bookmarkAnimController;
  // int _currentPage = 0;
  final controller = PageController(keepPage: true);
  var bookmarkLottieAsset = 'assets/lottie/bookmark-mark.json';
  var bookmarked = false;
  var viewPunchLine = false;

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
            bookmarkLottieAsset = 'assets/lottie/bookmark-mark.json';
          } else {
            bookmarkLottieAsset = 'assets/lottie/bookmark-unmark.json';
          }
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bookmark ${bookmarked ? 'Added' : 'Removed'}'),
              action: SnackBarAction(
                label: 'Undo',
                textColor: Colors.amber,
                onPressed: () => {},
              ),
            ),
          );
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
                  'assets/lottie/help.json',
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
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: todayHumorList.length,
              itemBuilder: (context, index) => HumorView(todayHumorList[index]),
              onPageChanged: (pageIndex) {
                ref.watch(adProvider.notifier).incrementCounter();
              },
            ),
          ),
          const BannerAdWidget(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: _selectedCategory.themeColor,
        notchMargin: 6.0,
        child: Row(
          children: [
            IconButton(
              icon: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
                child: Image.asset(
                  'assets/icons/arrow-right.png',
                  width: 24,
                  color: blackOrWhite,
                ),
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
