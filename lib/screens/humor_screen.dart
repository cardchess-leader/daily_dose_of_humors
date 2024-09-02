import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:daily_dose_of_humors/models/category.dart';
import 'package:daily_dose_of_humors/widgets/humor_view.dart';
import 'package:daily_dose_of_humors/widgets/banner_ad.dart';
import 'package:daily_dose_of_humors/providers/app_state.dart';
import 'package:daily_dose_of_humors/models/humor.dart';
import 'package:daily_dose_of_humors/widgets/lottie_icon.dart';
import 'package:daily_dose_of_humors/widgets/manual.dart';
import 'package:daily_dose_of_humors/screens/subscription.dart';
import 'package:daily_dose_of_humors/data/emoji_data.dart';
import 'package:daily_dose_of_humors/util/util.dart';

enum BuildHumorScreenFrom {
  daily,
  bookmark,
  library,
}

class HumorScreen extends ConsumerStatefulWidget {
  final BuildHumorScreenFrom buildHumorScreenFrom;
  final List<Humor> humorList;
  final List<String>? humorUuidList;
  final int? initIndexInBookmark;
  final Category? humorCategory;
  const HumorScreen({
    super.key,
    required this.buildHumorScreenFrom,
    this.humorList = const [],
    this.humorUuidList,
    this.initIndexInBookmark,
    this.humorCategory,
  });

  @override
  ConsumerState<HumorScreen> createState() {
    return _HumorScreenState();
  }
}

class _HumorScreenState extends ConsumerState<HumorScreen>
    with TickerProviderStateMixin {
  // late Category _selectedCategory;
  ScaffoldMessengerState? _scaffoldMessengerState;
  late AnimationController _shareAnimController;
  late AnimationController _bookmarkAnimController;
  late AnimationController _fabLottieAnimController;
  late PageController _pageController;
  List<Humor> humorList = [];
  var bookmarkLottieAsset = 'assets/lottie/bookmark-mark.json';
  var _humorIndex = 0;
  var viewPunchLine = false;
  var _isExpanded = false;
  var _isBookmarkUpdated = false;
  double _bannerHeight = 0;
  bool _isFabAnimating = false;
  var _emojiLottieIndex = 0;
  var _thumbsUpLeft = 5;
  var _isLoading = false;
  var _errorLoading = false;

  @override
  void initState() {
    super.initState();
    _shareAnimController = AnimationController(
      vsync: this,
    );
    _bookmarkAnimController = AnimationController(
      vsync: this,
    );
    _fabLottieAnimController = AnimationController(
      vsync: this,
    )..addStatusListener(_fabLottieAnimListener);
    _humorIndex = widget.initIndexInBookmark ?? 1;
    _pageController = PageController(keepPage: true, initialPage: _humorIndex);
    if (widget.buildHumorScreenFrom != BuildHumorScreenFrom.daily) {
      humorList = widget.humorList;
    } else {
      // load from the server //
      _isLoading = true;
      _loadDailyHumors(widget.humorCategory!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save a reference to ScaffoldMessengerState in didChangeDependencies
    _scaffoldMessengerState = ScaffoldMessenger.of(context);
  }

  @override
  void dispose() {
    _fabLottieAnimController.removeStatusListener(_fabLottieAnimListener);
    _shareAnimController.dispose();
    _bookmarkAnimController.dispose();
    _fabLottieAnimController.dispose();
    _scaffoldMessengerState?.clearSnackBars();
    super.dispose();
  }

  Future<void> _loadDailyHumors(Category humorCategory) async {
    try {
      // Construct the full URL with query parameters
      final Uri url = Uri.parse(
          'https://us-central1-daily-dose-of-humors.cloudfunctions.net/getDailyHumors?category=${humorCategory.categoryCode.name}');

      // Send a GET request to the Firebase function
      final response = await http.get(url);

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Decode the JSON response
        final data = jsonDecode(response.body);

        // Handle the data as needed
        print('Humor List: ${data['humorList']}');
        humorList = data['humorList']
            .map<DailyHumor>((json) => DailyHumor.fromDocument(json))
            .toList();
        // humorList = data.map(json => Humor.)
      } else {
        // Handle errors
        print('Error: ${response.statusCode} - ${response.body}');
        _errorLoading = true;
      }
    } catch (e) {
      // Handle any exceptions that occur during the request
      print('Request failed: $e');
      _errorLoading = true;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _fabLottieAnimListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _isFabAnimating = false;
        if (widget.buildHumorScreenFrom != BuildHumorScreenFrom.daily) {
          print('why is this running?');
          _fabLottieAnimController.reset();
          _fabLottieAnimController.forward();
        }
      });
    }
  }

  void initBookmark(Humor humor) async {
    final isBookmarked =
        await ref.read(bookmarkProvider.notifier).isHumorBookmarked(humor);
    // print('initBookmark: $isBookmarked');
    setState(() {
      bookmarkLottieAsset = isBookmarked
          ? 'assets/lottie/bookmark-mark.json'
          : 'assets/lottie/bookmark-unmark.json';
      _bookmarkAnimController.value = 1.0;
    });
  }

  void updateBookmark(Humor humor) async {
    int resultCode =
        await ref.read(bookmarkProvider.notifier).toggleBookmark(humor);
    print('resultCode is: $resultCode');
    // if (mounted) {
    setState(() {
      if (resultCode == 1 || resultCode == 3) {
        _isBookmarkUpdated = true;
        bookmarkLottieAsset = resultCode == 1
            ? 'assets/lottie/bookmark-unmark.json'
            : 'assets/lottie/bookmark-mark.json';
        _bookmarkAnimController.reset();
        _bookmarkAnimController.forward();
      }
      String snackBarMsg = '';
      SnackBarAction? snackBarAction;
      switch (resultCode) {
        case 1:
          snackBarMsg = 'Bookmark removed successfully.';
          break;
        case 2:
          snackBarMsg = 'Could not remove bookmark.\nPlease try again later.';
          break;
        case 3:
          snackBarMsg = 'Bookmark added successfully.';
          break;
        case 4:
          snackBarMsg =
              'Bookmark feature is exclusive to subscribers.\nWould you like to find out subscription benefits?';
          snackBarAction = SnackBarAction(
            label: 'Sure',
            textColor: Colors.amber,
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const SubscriptionScreen(),
                ),
              );
              setState(() {});
            },
          );
          break;
        case 5:
          snackBarMsg = 'Could not add bookmark.\nPlease try again later.';
          break;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 3000),
            content: Text(snackBarMsg),
            action: snackBarAction,
            behavior: SnackBarBehavior.floating, // Makes the Snackbar float
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            margin: EdgeInsets.only(
              bottom:
                  _bannerHeight, // Adjust this value as needed to control position
            ),
          ),
        );
    });
  }

  void _onItemTapped(int index) async {
    switch (index) {
      case 0:
        Navigator.of(context).pop(_isBookmarkUpdated);
        break;
      case 1:
        _shareAnimController.reset();
        _shareAnimController.forward();
        break;
      case 2:
        if (!_isLoading && !_errorLoading) {
          updateBookmark(humorList[_humorIndex]);
        }
        break;
    }
  }

  Widget getBottomNavLottie(
      String assetPath, Color color, AnimationController controller) {
    return Lottie.asset(assetPath,
        width: 24,
        controller: controller,
        delegates: LottieDelegates(
          values: [
            ValueDelegate.colorFilter(
              ['**'],
              value: ColorFilter.mode(color, BlendMode.src),
            ),
          ],
        ), onLoaded: (composition) {
      controller.duration = composition.duration;
    });
  }

  bool _isDaily() {
    return widget.buildHumorScreenFrom == BuildHumorScreenFrom.daily;
  }

  void _handleFabPress() {
    setState(() {
      _isFabAnimating = true;
      _fabLottieAnimController.reset();
      _fabLottieAnimController.forward();
      if (widget.buildHumorScreenFrom == BuildHumorScreenFrom.daily) {
        (humorList[_humorIndex] as DailyHumor).thumbsUpCount++;
        _thumbsUpLeft--;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              duration: const Duration(milliseconds: 3000),
              content: Text(
                  'Awesome! Thumbs up for this humor!  ($_thumbsUpLeft left!)'),
              behavior: SnackBarBehavior.floating, // Makes the Snackbar float
              shape:
                  const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              margin: EdgeInsets.only(
                bottom:
                    _bannerHeight, // Adjust this value as needed to control position
              ),
            ),
          );
      } else {
        _emojiLottieIndex =
            getDifferentRandInt(emojiLottieList.length, _emojiLottieIndex);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              duration: const Duration(milliseconds: 3000),
              content: Text(
                  'You rate this humor as: "${emojiLottieList[_emojiLottieIndex]}".'),
              behavior: SnackBarBehavior.floating, // Makes the Snackbar float
              shape:
                  const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              margin: EdgeInsets.only(
                bottom:
                    _bannerHeight, // Adjust this value as needed to control position
              ),
            ),
          );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color blackOrWhite = isDarkMode ? Colors.white : Colors.black;
    Color themeColor = _isDaily()
        ? widget.humorCategory!.themeColor
        : humorList[_humorIndex].getCategoryData().themeColor;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _isDaily()
              ? widget.humorCategory!.title
              : humorList[_humorIndex].getCategoryData().title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        backgroundColor: themeColor,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'help',
            onPressed: () => {setState(() => _isExpanded = !_isExpanded)},
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
                  color: themeColor,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // const BannerAdWidget(),
          Expanded(
            child: Stack(
              children: [
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : PageView.builder(
                        controller: _pageController,
                        itemCount: humorList.length,
                        itemBuilder: (context, index) => HumorView(
                          humor: humorList[index],
                          setHumor: (humor) {
                            humorList[index] = humor;
                            initBookmark(humor);
                          },
                        ),
                        onPageChanged: (pageIndex) {
                          // currentHumorIndex = pageIndex;
                          ref.watch(adProvider.notifier).incrementCounter();
                          _humorIndex = pageIndex;
                          initBookmark(humorList[_humorIndex]);
                        },
                      ),
                Align(
                  alignment: Alignment.topRight,
                  child: AnimatedScale(
                    duration: Duration(milliseconds: _isExpanded ? 200 : 0),
                    curve: Curves.easeInOut,
                    scale: _isExpanded ? 1.0 : 0.0,
                    child: ManualWidget(
                      color: Colors.white,
                      manualList: _isDaily()
                          ? widget.humorCategory!.manualList
                          : humorList[_humorIndex].getCategoryData().manualList,
                      onTap: () => setState(() => _isExpanded = false),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!ref
              .read(subscriptionStatusProvider.notifier)
              .isSubscriptionAdFree())
            BannerAdWidget(
                setBannerHeight: (bannerHeight) =>
                    _bannerHeight = bannerHeight),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: themeColor,
        notchMargin: 6.0,
        child: Row(
          children: [
            IconButton(
              tooltip: 'go back',
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
              tooltip: 'share this humor',
              icon: getBottomNavLottie('assets/lottie/share.json', blackOrWhite,
                  _shareAnimController),
              onPressed: () => _onItemTapped(1),
            ),
            IconButton(
              tooltip: 'bookmark this humor',
              icon: getBottomNavLottie(
                  bookmarkLottieAsset, blackOrWhite, _bookmarkAnimController),
              onPressed: () => _onItemTapped(2),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      floatingActionButton: FloatingActionButton(
        elevation: _isFabAnimating ? 1 : 5,
        highlightElevation: 1,
        disabledElevation: 1,
        backgroundColor: Colors.amber.shade400,
        onPressed: _isFabAnimating ? null : _handleFabPress,
        tooltip: _isDaily() ? 'thumbs up!' : 'rate this humor!',
        child: Stack(
          children: [
            Center(
              child: Lottie.asset(
                _isDaily()
                    ? 'assets/lottie/thumb-regular.json'
                    : 'assets/lottie/emoji-lottie/${emojiLottieList[_emojiLottieIndex]}.json',
                width: _isDaily() ? 32 : 40,
                controller:
                    _fabLottieAnimController, // For bookmark, set to disabled
                onLoaded: (composition) {
                  _fabLottieAnimController.duration = composition.duration;
                  if (!_isDaily()) {
                    _fabLottieAnimController.forward();
                  }
                },
              ),
            ),
            if (_isDaily())
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.only(right: 10),
                  height: 32,
                  child: AnimatedFlipCounter(
                    value: _thumbsUpLeft,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
