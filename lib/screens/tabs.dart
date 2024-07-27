import 'package:flutter/material.dart';
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

class _TabsScreenState extends State<TabsScreen> {
  int _selectedPageIndex = 0;

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void _openHumorCategory(selectedCategory) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (ctx) => HumorScreen(selectedCategory)));
  }

  @override
  Widget build(BuildContext context) {
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
        activePage = ShopScreen();
        break;
      case 2:
        activePage = BookmarkScreen();
        break;
      case 3:
      default:
        activePage = SettingsScreen();
    }

    return Scaffold(
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        selectedItemColor: Colors.grey.shade900,
        unselectedItemColor: Colors.grey.shade500,
        // selectedIconTheme:
        //     IconThemeData(size: 22), // Set the size for selected icons
        // unselectedIconTheme: IconThemeData(size: 22),
        selectedLabelStyle:
            TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        items: [
          BottomNavigationBarItem(
            icon: _selectedPageIndex == 0
                ? Icon(Icons.dashboard)
                : Icon(Icons.dashboard_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _selectedPageIndex == 1
                ? Icon(Icons.shopping_cart)
                : Icon(Icons.shopping_cart_outlined),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: _selectedPageIndex == 2
                ? Icon(Icons.bookmark)
                : Icon(Icons.bookmark_outline),
            label: 'Bookmarks',
          ),
          BottomNavigationBarItem(
            icon: _selectedPageIndex == 3
                ? Icon(Icons.settings)
                : Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
