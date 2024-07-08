import 'package:flutter/material.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:daily_dose_of_humors/screens/humor_screen.dart';
import 'package:daily_dose_of_humors/widgets/humor_card.dart';
import 'package:daily_dose_of_humors/data/category_data.dart';

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
    Widget activePage = ScrollSnapList(
      scrollDirection: Axis.vertical,
      onItemFocus: (index) => (),
      itemSize: 500,
      itemCount: humorCategoryList.length,
      dynamicItemSize: true,
      dynamicSizeEquation: (distance) => 1 - (distance / 2000).abs(),
      itemBuilder: (context, index) => InkWell(
        child: HumorCategoryCard(humorCategoryList[index]),
        onTap: () => _openHumorCategory(humorCategoryList[index]),
      ),
    );

    switch (_selectedPageIndex) {
      case 1:
        activePage = HumorScreen(humorCategoryList[0]);
    }

    return Scaffold(
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Bookmark',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Setting',
          ),
        ],
      ),
    );
  }
}
