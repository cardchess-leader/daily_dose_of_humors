import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:daily_dose_of_humors/models/category.dart';
import 'package:daily_dose_of_humors/data/humor_data.dart';
import 'package:daily_dose_of_humors/widgets/humor_view.dart';
import 'package:daily_dose_of_humors/widgets/banner_ad.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_dose_of_humors/providers/app_state.dart';
import 'package:daily_dose_of_humors/models/humor.dart';
import 'package:daily_dose_of_humors/db/db.dart';
import 'package:daily_dose_of_humors/widgets/lottie_icon.dart';

enum BuildHumorScreenFrom {
  daily,
  bookmark,
  library,
}

class HumorScreen extends ConsumerStatefulWidget {
  final Category selectedCategory;
  final BuildHumorScreenFrom buildHumorScreenFrom;
  final List<Humor>? humorList;
  final List<String>? humorUuidList;
  final int? initIndexInBookmark;
  const HumorScreen(
    this.selectedCategory, {
    super.key,
    required this.buildHumorScreenFrom,
    this.humorList,
    this.humorUuidList,
    this.initIndexInBookmark,
  });

  @override
  ConsumerState<HumorScreen> createState() {
    return _HumorScreenState();
  }
}

class _HumorScreenState extends ConsumerState<HumorScreen>
    with TickerProviderStateMixin {
  late Category _selectedCategory;
  late AnimationController _shareAnimController;
  late AnimationController _bookmarkAnimController;
  int _humorIndex = 0;
  late PageController _pageController;
  var bookmarkLottieAsset = 'assets/lottie/bookmark-mark.json';
  var bookmarked = false;
  var viewPunchLine = false;
  // late Humor humorInView;
  late List<Humor?> humorList;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _shareAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _bookmarkAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    // humorInView = todayHumorList[0];
    _humorIndex = widget.initIndexInBookmark ?? 0;
    _pageController = PageController(keepPage: true, initialPage: _humorIndex);
    if (widget.humorList != null) {
      humorList = widget.humorList!;
    } else {
      humorList =
          List<Humor?>.generate(widget.humorUuidList!.length, (index) => null);
    }
  }

  @override
  void dispose() {
    _shareAnimController.dispose();
    _bookmarkAnimController.dispose();
    super.dispose();
  }

  void initBookmark(String? uuid) async {
    if (uuid == null) {
      return;
    }
    final dbHelper = DatabaseHelper();
    final isBookmarked = await dbHelper.isBookmarked(uuid);
    print('initBookmark: $isBookmarked');
    setState(() {
      bookmarked = isBookmarked;
      bookmarkLottieAsset = isBookmarked
          ? 'assets/lottie/bookmark-mark.json'
          : 'assets/lottie/bookmark-unmark.json';
      _bookmarkAnimController.value = 1.0;
    });
  }

  void updateBookmark(Humor? humor) async {
    if (humor == null) return;

    final dbHelper = DatabaseHelper();
    bool isUpdateSuccessful;

    if (bookmarked) {
      // Remove the bookmark
      isUpdateSuccessful = await dbHelper.removeBookmark(humor.uuid);
    } else {
      // Add the bookmark
      isUpdateSuccessful = await dbHelper.addBookmark(humor);
    }

    if (mounted) {
      setState(() {
        if (isUpdateSuccessful) {
          bookmarked = !bookmarked;
          bookmarkLottieAsset = bookmarked
              ? 'assets/lottie/bookmark-mark.json'
              : 'assets/lottie/bookmark-unmark.json';

          _bookmarkAnimController.reset();
          _bookmarkAnimController.forward();

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                duration: const Duration(milliseconds: 3000),
                content: Text(
                    'Bookmark ${bookmarked ? 'added' : 'removed'} successfully.'),
              ),
            );
        } else {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                duration: const Duration(milliseconds: 3000),
                content: Text(
                    'Could not ${bookmarked ? 'remove' : 'add'} bookmark.\nPlease try again later.'),
              ),
            );
        }
      });
    }
  }

  void _onItemTapped(int index) async {
    switch (index) {
      case 0:
        Navigator.of(context).pop();
        break;
      case 1:
        _shareAnimController.reset();
        _shareAnimController.forward();
        break;
      case 2:
        updateBookmark(humorList[_humorIndex]);
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
                LottieIcon(
                  duration: 1000,
                  delay: 1000,
                  size: 45,
                  lottiePath: 'assets/lottie/help.json',
                  color: _selectedCategory.themeColor,
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
              controller: _pageController,
              itemCount: todayHumorList.length,
              itemBuilder: (context, index) => HumorView(
                  humor: todayHumorList[index],
                  setHumor: (humor) {
                    humorList[index] = humor;
                    if (_humorIndex == index) {
                      initBookmark(humor.uuid);
                    }
                  }),
              onPageChanged: (pageIndex) {
                // currentHumorIndex = pageIndex;
                ref.watch(adProvider.notifier).incrementCounter();
                _humorIndex = pageIndex;
                initBookmark(humorList[_humorIndex]?.uuid);
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
