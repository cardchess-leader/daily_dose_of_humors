import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:share_plus/share_plus.dart';
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
import 'package:daily_dose_of_humors/widgets/humor_scaffold.dart';
import 'package:daily_dose_of_humors/util/global_var.dart';

enum BuildHumorScreenFrom {
  daily,
  bookmark,
  library,
  preview,
}

class HumorScreen extends ConsumerStatefulWidget {
  final BuildHumorScreenFrom buildHumorScreenFrom;
  final List<Humor> humorList;
  final List<String>? humorUuidList;
  final int initIndexInBookmark;
  final Category? humorCategory;
  const HumorScreen({
    super.key,
    required this.buildHumorScreenFrom,
    this.humorList = const [],
    this.humorUuidList,
    this.initIndexInBookmark = 0,
    this.humorCategory,
  });

  @override
  ConsumerState<HumorScreen> createState() {
    return _HumorScreenState();
  }
}

class _HumorScreenState extends ConsumerState<HumorScreen>
    with TickerProviderStateMixin {
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
  var _isLoading = false;

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
    _humorIndex = widget.initIndexInBookmark;
    _pageController = PageController(keepPage: true, initialPage: _humorIndex);
    if (widget.buildHumorScreenFrom != BuildHumorScreenFrom.daily) {
      humorList = widget.humorList;
      initBookmark();
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
    final fetchedHumorList =
        await ref.read(serverProvider.notifier).loadDailyHumors(humorCategory);
    setState(() {
      _isLoading = false;
      humorList = fetchedHumorList;
      if (fetchedHumorList.isNotEmpty) {
        initBookmark();
      }
    });
  }

  void _fabLottieAnimListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _isFabAnimating = false;
      });
    }
  }

  void initBookmark() async {
    if (humorList.length <= _humorIndex) return;
    Humor humor = humorList[_humorIndex];
    final isBookmarked =
        await ref.read(bookmarkProvider.notifier).isHumorBookmarked(humor);
    setState(() {
      bookmarkLottieAsset = isBookmarked
          ? 'assets/lottie/bookmark-mark.json'
          : 'assets/lottie/bookmark-unmark.json';
      _bookmarkAnimController.value = 1.0;
    });
  }

  void updateBookmark() async {
    if (humorList.isEmpty) return;
    Humor humor = humorList[_humorIndex];
    int resultCode =
        await ref.read(bookmarkProvider.notifier).toggleBookmark(humor);
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
          return showSubscriptionSnackbar(
              'Bookmark limit reached!\nUpgrade your plan to unlock more bookmarks! :)');
        case 5:
          snackBarMsg = 'Could not add bookmark.\nPlease try again later.';
          break;
      }
      showSnackbar(snackBarMsg);
    });
  }

  bool _currentHumorHasAnalysis() {
    if (_isLoading ||
        humorList.isEmpty ||
        humorList[_humorIndex].aiAnalysis == '') {
      return false;
    }
    return true;
  }

  void _onItemTapped(int index) async {
    if (index > 0) {
      // if the humor value is null or humor list is empty, show snackbar
      if (_isLoading || humorList.isEmpty) {
        return _showSimpleSnackbar(
            'Please wait until humors are fully loaded...');
      }
    }
    switch (index) {
      case 0:
        Navigator.of(context).pop(_isBookmarkUpdated);
        break;
      case 1:
        _shareAnimController.reset();
        _shareAnimController.forward();
        final sharedFormat = humorList[_humorIndex].toSharedFormat();
        if (sharedFormat == null) {
          return;
        } else if (sharedFormat.defaultFormat != null) {
          Share.share(sharedFormat.defaultFormat!,
              subject: sharedFormat.dialogSubject);
        } else {
          final response = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(sharedFormat.dialogSubject),
                content: Text(
                  sharedFormat.dialogBody,
                  style: const TextStyle(fontSize: 18),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop('option1'); // Close the dialog
                    },
                    child: Text(sharedFormat.option1BtnText!,
                        style: const TextStyle(fontSize: 18)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop('option2'); // Close the dialog
                    },
                    child: Text(
                      sharedFormat.option2BtnText!,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              );
            },
          );
          const emailSubject = 'Shared Humor From Daily Dose of Humors';
          if (response == 'option1') {
            Share.share(sharedFormat.option1Format!, subject: emailSubject);
          } else if (response == 'option2') {
            Share.share(sharedFormat.option2Format!, subject: emailSubject);
          }
        }
        break;
      case 2:
        updateBookmark();
        break;
      case 3:
        if (!ref.read(subscriptionStatusProvider.notifier).isSubscribed()) {
          showSubscriptionSnackbar(
              'AI humor analysis feature is exclusive to subscribers.\nWould you like to find out subscription benefits?');
        } else {
          await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Why Is This Funny?'),
                  content: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: SingleChildScrollView(
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          humorList[_humorIndex].aiAnalysis,
                          style: const TextStyle(fontSize: 17),
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child:
                          const Text('Got it!', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                );
              });
        }
        break;
    }
  }

  void showSnackbar(String msg, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 3000),
          content: Text(msg),
          action: action,
          behavior: SnackBarBehavior.floating, // Makes the Snackbar float
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          margin: EdgeInsets.only(
            bottom:
                _bannerHeight, // Adjust this value as needed to control position
          ),
        ),
      );
  }

  void showSubscriptionSnackbar(String msg) {
    final snackBarAction = SnackBarAction(
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
    showSnackbar(msg, action: snackBarAction);
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

  void _incrementLikesCount() {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("likes/${humorList[_humorIndex].uuid}");
    ref.set({
      '.value': ServerValue.increment(1),
    });
  }

  void _showSimpleSnackbar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 3000),
          content: Text(message),
          behavior: SnackBarBehavior.floating, // Makes the Snackbar float
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          margin: EdgeInsets.only(
            bottom:
                _bannerHeight, // Adjust this value as needed to control position
          ),
        ),
      );
  }

  void _handleFabPress() async {
    if (_isLoading || humorList.isEmpty) {
      _showSimpleSnackbar('Please wait until humors are fully loaded...');
    } else if (isPreview()) {
      _showSimpleSnackbar('Thumbs up not available for preview humors...');
    } else {
      setState(() {
        if (ref.read(userSettingsProvider)['vibration'] ?? false) {
          HapticFeedback.mediumImpact();
        }

        _isFabAnimating = true;
        _fabLottieAnimController.reset();
        _fabLottieAnimController.forward();
      });
      if (await ref.read(appStateProvider.notifier).hitThumbsUpFab()) {
        _incrementLikesCount();
        _showSimpleSnackbar(
            'Awesome! Thumbs up for this humor!  (${ref.read(appStateProvider)['likes_count_remaining']} left today!)');
      } else {
        _showSimpleSnackbar(
            'You already gave ${GLOBAL.MAX_THUMBSUP_COUNT} thumbs-ups for today!');
      }
    }
  }

  bool isPreview() {
    return widget.buildHumorScreenFrom == BuildHumorScreenFrom.preview;
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDarkMode ? Colors.white : Colors.black;
    Color themeColor = _isDaily()
        ? widget.humorCategory!.themeColor
        : humorList[_humorIndex].getCategoryData().themeColor;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Text(
            _isDaily()
                ? widget.humorCategory!.title
                : humorList[_humorIndex].sourceName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
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
                      color: textColor, // Set the circle color
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
          Expanded(
            child: Stack(
              children: [
                (_isLoading || humorList.isEmpty)
                    ? HumorScreenScaffold(isLoading: _isLoading)
                    : PageView.builder(
                        controller: _pageController,
                        itemCount: humorList.length,
                        itemBuilder: (context, index) => HumorView(
                            humor: humorList[index], isPreview: isPreview()),
                        onPageChanged: (pageIndex) {
                          ref.watch(adProvider.notifier).incrementCounter();
                          _humorIndex = pageIndex;
                          initBookmark();
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
          if (!ref.read(subscriptionStatusProvider.notifier).isSubscribed())
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
                  color: textColor,
                ),
              ),
              onPressed: () => _onItemTapped(0),
            ),
            if (!isPreview())
              IconButton(
                tooltip: 'share this humor',
                icon: getBottomNavLottie('assets/lottie/share.json', textColor,
                    _shareAnimController),
                onPressed: () => _onItemTapped(1),
              ),
            if (!isPreview())
              IconButton(
                tooltip: 'bookmark this humor',
                icon: getBottomNavLottie(
                    bookmarkLottieAsset, textColor, _bookmarkAnimController),
                onPressed: () => _onItemTapped(2),
              ),
            if (!isPreview() && _currentHumorHasAnalysis())
              IconButton(
                tooltip: 'ai humor analysis',
                icon: Image.asset(
                  'assets/icons/bot2.png',
                  width: 24,
                  color: textColor,
                ),
                onPressed: () => _onItemTapped(3),
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
        tooltip: 'thumbs up!',
        child: Stack(
          children: [
            Center(
              child: Lottie.asset(
                'assets/lottie/thumb-regular.json',
                width: 32,
                controller:
                    _fabLottieAnimController, // For bookmark, set to disabled
                onLoaded: (composition) {
                  _fabLottieAnimController.duration = composition.duration;
                },
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.only(right: 10),
                height: 32,
                child: AnimatedFlipCounter(
                  value: ref.watch(appStateProvider)['likes_count_remaining'],
                  // _thumbsUpLeft,
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
