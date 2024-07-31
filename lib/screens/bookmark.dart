import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:daily_dose_of_humors/util/util.dart';
import 'package:daily_dose_of_humors/widgets/app_bar.dart';
import 'package:lottie/lottie.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() {
    return _BookmarkScreenState();
  }
}

class _BookmarkScreenState extends State<BookmarkScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _trashAnimController;
  late AnimationController _humanAnimController;

  List<int> indexes = List.generate(10, (index) => index);
  List<Color> colorList = generateRandomColors(10);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _trashAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..addStatusListener(_trashAnimationStatusListener);
    _trashAnimController.forward();

    _humanAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..addStatusListener(_humanAnimationStatusListener);
    _humanAnimController.forward();
  }

  @override
  void dispose() {
    _trashAnimController.removeStatusListener(_trashAnimationStatusListener);
    _humanAnimController.removeStatusListener(_humanAnimationStatusListener);
    _trashAnimController.dispose();
    _humanAnimController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _trashAnimationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          _trashAnimController.reset();
          _trashAnimController.forward();
        }
      });
    }
  }

  void _humanAnimationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _humanAnimController.reset();
          _humanAnimController.forward();
        }
      });
    }
  }

  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(1.0, 6.0, animValue)!;
        final double scale = lerpDouble(1.0, 1.06, animValue)!;
        return Transform.scale(
          scale: scale,
          child: cardBuilder(context, index, elevation: elevation),
        );
      },
      child: child,
    );
  }

  Widget cardBuilder(BuildContext context, int index,
      {double elevation = 1.0}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
      key: ValueKey(indexes[index]),
      child: Dismissible(
        key: ValueKey(indexes[index]),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          setState(() {
            indexes.removeAt(index);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Bookmark Removed'),
                action: SnackBarAction(
                  label: 'Undo',
                  textColor: Colors.amber,
                  onPressed: () => {},
                ),
              ),
            );
          });
        },
        background: Container(
          alignment: Alignment.centerRight,
          child: Lottie.asset(
            'assets/lottie/trash.json',
            width: 30,
            controller: _trashAnimController,
            delegates: LottieDelegates(
              values: [
                ValueDelegate.colorFilter(
                  ['**'],
                  value: const ColorFilter.mode(Colors.grey, BlendMode.src),
                ),
              ],
            ),
          ),
        ),
        child: Card(
          elevation: elevation,
          color: colorList[indexes[index]],
          child: Container(
            padding: const EdgeInsets.all(25),
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Image.asset(
                    'assets/images/fist.png',
                    width: 80,
                    height: 80,
                    color: const Color.fromARGB(21, 0, 0, 0),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'What do you call a pig that does a karate? Also, what do you call a sleeping bull?',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '- From Dad Jokes',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Added on 2024-07-14',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = indexes.removeAt(oldIndex);
      indexes.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color blackOrWhite = isDarkMode ? Colors.white : Colors.black;

    final emptyPlaceHolder = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
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
              'assets/lottie/human.json',
              width: 45,
              height: 45,
              controller: _humanAnimController,
              delegates: LottieDelegates(
                values: [
                  ValueDelegate.colorFilter(
                    ['**'],
                    value: ColorFilter.mode(
                      Theme.of(context).scaffoldBackgroundColor,
                      BlendMode.src,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Wow, such empty!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: CustomAppBar(
        heading: 'Humor Bookmarks',
        subheading: 'Your Favorite Humors',
        additionalHeight: 98,
        backgroundColor: const Color.fromARGB(255, 248, 255, 242),
        bottom: TabBar(
          indicatorColor: isDarkMode ? Colors.grey.shade900 : Colors.grey,
          labelStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
            color: Colors.black,
          ),
          unselectedLabelColor: Colors.grey.shade500,
          controller: _tabController,
          tabs: const [
            Tab(text: 'Bookmarks'),
            Tab(text: 'Library'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          if (indexes.isNotEmpty)
            ReorderableListView.builder(
              proxyDecorator: proxyDecorator,
              itemCount: indexes.length,
              onReorder: _onReorder,
              padding: const EdgeInsets.symmetric(horizontal: 25),
              itemBuilder: cardBuilder,
            )
          else
            emptyPlaceHolder,
          emptyPlaceHolder,
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber.shade400,
        elevation: 2,
        onPressed: () {
          // Handle the FAB action
          print('FAB Pressed');
        },
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
  }
}
