import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_dose_of_humors/providers/app_state.dart';
import 'package:daily_dose_of_humors/models/category.dart';
import 'package:daily_dose_of_humors/screens/subscription.dart';
import 'package:daily_dose_of_humors/widgets/background.dart';
import 'package:daily_dose_of_humors/widgets/app_bar.dart';
import 'package:daily_dose_of_humors/widgets/humor_card.dart';
import 'package:daily_dose_of_humors/screens/humor_screen.dart';
import 'package:daily_dose_of_humors/util/physics.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  var _focusCardIndex = 0;
  void _openHumorCategory(Category selectedCategory, context) {
    final targetScreen =
        (ref.read(subscriptionStatusProvider.notifier).isSubscribed() ||
                !selectedCategory.subscriberOnly)
            ? HumorScreen(
                humorCategory: selectedCategory,
                buildHumorScreenFrom: BuildHumorScreenFrom.daily)
            : const SubscriptionScreen();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => targetScreen,
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
              Category selectedCategory = Category.getDailyCategories()[index];
              return InkWell(
                child: HumorCategoryCard(
                  selectedCategory,
                  index == _focusCardIndex,
                ),
                onTap: () => _openHumorCategory(selectedCategory, context),
              );
            }),
          ),
        ],
      ),
    );
  }
}
