import 'package:flutter/material.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:daily_dose_of_humors/models/category.dart';
import 'package:daily_dose_of_humors/widgets/background.dart';
import 'package:daily_dose_of_humors/widgets/app_bar.dart';
import 'package:daily_dose_of_humors/widgets/humor_card.dart';
import 'package:daily_dose_of_humors/screens/humor_screen.dart';
import 'package:daily_dose_of_humors/data/humor_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _focusCardIndex = 0;
  void _openHumorCategory(selectedCategory, context) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => HumorScreen(
              selectedCategory,
              buildHumorScreenFrom: BuildHumorScreenFrom.bookmark,
              humorList: todayHumorList,
              initIndexInBookmark: 0,
            )));
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            duration: 200,
            itemSize: 500,
            itemCount: Category.getDailyCategories().length,
            dynamicItemSize: true,
            dynamicSizeEquation: (distance) => 1 - (distance / 2000).abs(),
            onItemFocus: (index) => (setState(() {
              print(index);
              _focusCardIndex = index;
            })),
            itemBuilder: (context, index) => InkWell(
              child: HumorCategoryCard(Category.getDailyCategories()[index],
                  index == _focusCardIndex),
              onTap: () => _openHumorCategory(
                  Category.getDailyCategories()[index], context),
            ),
          ),
        ],
      ),
    );
  }
}
