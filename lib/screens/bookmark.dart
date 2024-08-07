import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:daily_dose_of_humors/widgets/app_bar.dart';
import 'package:lottie/lottie.dart';
import 'package:daily_dose_of_humors/models/humor.dart';
import 'package:daily_dose_of_humors/db/db.dart';

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
  late Future<List<Humor>> _futureBookmarks;
  List<Humor>? bookmarks;

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

    _futureBookmarks = _loadBookmarks();
  }

  Future<List<Humor>> _loadBookmarks() async {
    final dbHelper = DatabaseHelper();
    return await dbHelper.getBookmarks();
  }

  @override
  void dispose() {
    _trashAnimController.removeStatusListener(_trashAnimationStatusListener);
    _humanAnimController.removeStatusListener(_humanAnimationStatusListener);
    _trashAnimController.dispose();
    _humanAnimController.dispose();
    _tabController.dispose();
    print('bookmark dispose length: ${bookmarks?.length}');
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
          child: child,
        );
      },
      child: child,
    );
  }

  Widget cardBuilder(BuildContext context, int index,
      {double elevation = 1.0}) {
    final humor = bookmarks![index];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
      key: ValueKey(humor.uuid),
      child: Dismissible(
        key: ValueKey(humor.uuid),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          setState(() {
            bookmarks!.removeAt(index);
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
          color: humor.getCategoryData().themeColor,
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
                    Text(
                      humor.context ?? humor.contextList?[0] ?? '',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '- From ${humor.getCategoryData().title}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Added on ${humor.addedDate ?? ''}',
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
      final item = bookmarks!.removeAt(oldIndex);
      bookmarks!.insert(newIndex, item);
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
          FutureBuilder<List<Humor>>(
            future: _futureBookmarks,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return emptyPlaceHolder;
              } else {
                bookmarks = snapshot.data!;
                print('is this part run again?');
                print('bookmark length is: ${bookmarks!.length}');
                print('snapshot.data ${snapshot.data!.length}');
                return ReorderableListView.builder(
                  proxyDecorator: (child, index, animation) =>
                      proxyDecorator(child, index, animation),
                  itemCount: bookmarks!.length,
                  onReorder: (oldIndex, newIndex) =>
                      _onReorder(oldIndex, newIndex),
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  itemBuilder: (context, index) => cardBuilder(context, index),
                );
              }
            },
          ),
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
