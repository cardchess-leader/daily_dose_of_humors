import 'package:daily_dose_of_humors/widgets/page_header_text.dart';
import 'package:flutter/material.dart';
import 'package:daily_dose_of_humors/data/category_data.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.yellow,
        // title: Text(
        //   'Bookmarks',
        //   style: TextStyle(
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
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
          ListView.separated(
            itemCount: 5,
            itemBuilder: (context, index) {
              return Dismissible(
                key: ValueKey(index),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                child: ListTile(
                  // isThreeLine: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  // tileColor: const Color.fromARGB(85, 255, 255, 255),
                  leading: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      // border: Border.all(color: Colors.grey.shade500, width: 1),
                      borderRadius: BorderRadius.circular(20),
                      color: index % 2 == 0
                          ? Color.fromARGB(255, 63, 172, 255)
                          : Color.fromARGB(255, 232, 77, 66),
                    ),
                    child: Image.asset(
                      humorCategoryList[index % 2].imgPath,
                      width: 30,
                      height: 30,
                    ),
                  ),
                  title: Text(
                    'What does the fox say to the hunter in the evening of the day?',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('From Daily Dose of Humors'),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Added on 2024-07-10',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return Divider(
                height: 0,
                color: const Color.fromARGB(32, 0, 0, 0),
              );
            },
          ),
          Center(child: Text('Wow, such empty!')),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
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
