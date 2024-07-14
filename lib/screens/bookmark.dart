import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:daily_dose_of_humors/widgets/page_header_text.dart';
import 'package:daily_dose_of_humors/data/category_data.dart';
import 'package:daily_dose_of_humors/util/util.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() {
    return _BookmarkScreenState();
  }
}

class _BookmarkScreenState extends State<BookmarkScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<int> indexes = List.generate(10, (index) => index);
  List<Color> colorList = generateRandomColors(10);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    print('index from decorator is: ' + index.toString());
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(1.0, 6.0, animValue)!;
        final double scale = lerpDouble(1.0, 1.02, animValue)!;
        return Transform.scale(
          scale: scale,
          child: cardBuilder(context, index, elevation: elevation),
        );
      },
    );
  }

  Widget cardBuilder(context, index, {elevation = 1.0}) {
    print('index from cardbuilder is: $index');
    return Container(
      // color: Colors.red,
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 15),
      key: ValueKey(indexes[index]),
      child: Dismissible(
        onDismissed: (direction) {
          setState(() {
            indexes.removeAt(index);
          });
        },
        key: ValueKey(index),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          child: const Icon(
            Icons.delete_forever_rounded,
            color: Colors.grey,
            size: 35,
          ),
        ),
        child: Card(
          elevation: elevation,
          color: colorList[indexes[index]],
          child: Container(
            padding: EdgeInsets.all(25),
            // decoration: BoxDecoration(
            //   color: const Color.fromARGB(255, 177, 225, 178),
            //   borderRadius: BorderRadius.circular(20),
            // ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Image.asset(
                    'assets/images/fist.png',
                    width: 80,
                    height: 80,
                    color: Color.fromARGB(21, 0, 0, 0),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'What do you call a pig that does a karate? Also, what do you call a sleeping bull?',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
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
    return Scaffold(
      appBar: AppBar(
        title: const PageHeaderText(
          heading: 'Bookmarks',
          subheading: 'Your Favorite Humors',
        ),
        bottom: TabBar(
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
          ReorderableListView.builder(
            proxyDecorator: proxyDecorator,
            itemCount: indexes.length,
            onReorder: _onReorder,
            padding: EdgeInsets.symmetric(horizontal: 25),
            itemBuilder: cardBuilder,
          ),
          const Center(
            child: Text('Wow, such empty!'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
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
