import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:daily_dose_of_humors/screens/shop.dart';
import 'package:daily_dose_of_humors/screens/humor_screen.dart';
import 'package:daily_dose_of_humors/screens/bookmark.dart';
import 'package:daily_dose_of_humors/screens/settings.dart';
import 'package:daily_dose_of_humors/widgets/humor_card.dart';
import 'package:daily_dose_of_humors/data/category_data.dart';
import 'package:daily_dose_of_humors/widgets/background.dart';
import 'package:daily_dose_of_humors/widgets/app_bar.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends State<TabsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _selectedPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Duration of the animation
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(const Duration(seconds: 1), () {
            // Delay of 1 second
            _controller.reset();
            _controller.forward();
          });
        }
      }); // Start the animation automatically

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void _openHumorCategory(selectedCategory) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (ctx) => HumorScreen(selectedCategory)));
  }

  Widget getBottomNavLottie(String assetPath) {
    return Lottie.asset(
      assetPath,
      width: 24,
      controller: _controller,
      delegates: LottieDelegates(
        values: [
          ValueDelegate.colorFilter(
            ['**'],
            value: ColorFilter.mode(Colors.grey.shade500, BlendMode.src),
          ),
        ],
      ),
    );
  }

  Widget getBottomNavSVG(String assetPath, bool isDarkMode) {
    return SvgPicture.asset(
      assetPath,
      colorFilter: ColorFilter.mode(
          isDarkMode
              ? Colors.white.withOpacity(1)
              : Colors.black.withOpacity(1),
          BlendMode.srcIn),
      width: 24,
    );
  }

  Widget getBottomNavPNG(String assetPath, bool isDarkMode) {
    return Image.asset(
      assetPath,
      color: isDarkMode ? Colors.white : Colors.black,
      width: 24,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    late Widget activePage;

    switch (_selectedPageIndex) {
      case 0:
        activePage = Scaffold(
          appBar: const CustomAppBar(
            heading: 'Daily Dose of Humors',
            subheading: 'New Humors Added Everyday',
            // backgroundColor: Colors.white,
          ),
          body: Stack(
            children: [
              const ScrollingBackground(
                imagePathList: [
                  'assets/images/smile-background-0.png',
                  'assets/images/smile-background-1.png',
                  'assets/images/smile-background-2.png',
                  'assets/images/smile-background-3.png',
                ],
                imageSize: 25,
                imageMargin: 50,
                scrollTime: 10000,
                patternLength: 2,
              ),
              ScrollSnapList(
                scrollDirection: Axis.vertical,
                onItemFocus: (index) => (),
                duration: 300,
                itemSize: 500,
                itemCount: humorCategoryList.length,
                dynamicItemSize: true,
                dynamicSizeEquation: (distance) => 1 - (distance / 2000).abs(),
                itemBuilder: (context, index) => InkWell(
                  child: HumorCategoryCard(humorCategoryList[index]),
                  onTap: () => _openHumorCategory(humorCategoryList[index]),
                ),
              ),
            ],
          ),
        );
        break;
      case 1:
        activePage = const ShopScreen();
        break;
      case 2:
        activePage = const BookmarkScreen();
        break;
      case 3:
      default:
        activePage = const SettingsScreen();
    }

    return Scaffold(
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.amber,
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        selectedItemColor:
            isDarkMode ? Colors.grey.shade100 : Colors.grey.shade900,
        unselectedItemColor: Colors.grey.shade500,
        selectedLabelStyle:
            const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        items: [
          BottomNavigationBarItem(
            icon: _selectedPageIndex == 0
                ? getBottomNavPNG('assets/icons/home.png', isDarkMode)
                : getBottomNavLottie('assets/lottie/home-1.json'),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _selectedPageIndex == 1
                ? getBottomNavPNG('assets/icons/shop.png', isDarkMode)
                : getBottomNavLottie('assets/lottie/shop-1.json'),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: _selectedPageIndex == 2
                ? getBottomNavPNG('assets/icons/bookmark.png', isDarkMode)
                : getBottomNavLottie('assets/lottie/bookmark-3.json'),
            label: 'Bookmarks',
          ),
          BottomNavigationBarItem(
            icon: _selectedPageIndex == 3
                ? getBottomNavPNG('assets/icons/settings.png', isDarkMode)
                : getBottomNavLottie('assets/lottie/settings-1.json'),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
