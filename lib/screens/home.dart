import 'package:flutter/material.dart';
import 'package:daily_dose_of_humors/models/category.dart';
import 'package:daily_dose_of_humors/widgets/background.dart';
import 'package:daily_dose_of_humors/widgets/app_bar.dart';
import 'package:daily_dose_of_humors/widgets/humor_card.dart';
import 'package:daily_dose_of_humors/screens/humor_screen.dart';
import 'package:daily_dose_of_humors/data/humor_data.dart';
import 'package:daily_dose_of_humors/util/physics.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _focusCardIndex = 0;
  void _openHumorCategory(selectedCategory, context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => HumorScreen(
          humorCategory: selectedCategory,
          buildHumorScreenFrom: BuildHumorScreenFrom.daily,
          // humorList: todayHumorList,
          initIndexInBookmark: 0,
        ),
      ),
    );
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
          ListWheelScrollView(
            itemExtent: 500,
            diameterRatio: 10,
            physics: const FastSnapScrollPhysics(
              speedFactor: 5.0,
              frictionFactor: 0.2,
            ),
            onSelectedItemChanged: (index) {
              setState(() {
                _focusCardIndex = index;
              });
            },
            children:
                List.generate(Category.getDailyCategories().length, (index) {
              return InkWell(
                child: HumorCategoryCard(Category.getDailyCategories()[index],
                    index == _focusCardIndex),
                onTap: () => _openHumorCategory(
                    Category.getDailyCategories()[index], context),
              );
            }),
          ),
        ],
      ),
    );
  }
}
