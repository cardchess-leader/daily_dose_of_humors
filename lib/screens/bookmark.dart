import 'package:flutter/material.dart';
import 'package:daily_dose_of_humors/widgets/app_bar.dart';
import 'package:daily_dose_of_humors/models/humor.dart';
import 'package:daily_dose_of_humors/db/db.dart';
import 'package:daily_dose_of_humors/widgets/lottie_icon.dart';
import 'package:daily_dose_of_humors/screens/add_humor.dart';
import 'package:daily_dose_of_humors/screens/humor_screen.dart';
import 'package:daily_dose_of_humors/data/category_data.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Humor>> _futureBookmarks;
  List<Humor> bookmarks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookmarks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadBookmarks() {
    setState(() {
      _futureBookmarks = DatabaseHelper().getBookmarks().then((bookmarks) {
        setState(() {
          this.bookmarks = bookmarks;
        });
        return bookmarks;
      });
    });
  }

  void _openBookmarkHumors(int index) async {
    final isBookmarkUpdated = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => HumorScreen(
          humorCategoryList[0],
          buildHumorScreenFrom: BuildHumorScreenFrom.bookmark,
          humorList: bookmarks,
          initIndexInBookmark: index,
        ),
      ),
    );

    if (isBookmarkUpdated == true) {
      _loadBookmarks();
    }
  }

  Widget cardBuilder(BuildContext context, int index,
      {double elevation = 1.0}) {
    final humor = bookmarks[index];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
      key: ValueKey(humor.uuid),
      child: Dismissible(
        key: ValueKey(humor.uuid),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          final removedHumor = bookmarks[index];
          setState(() {
            bookmarks.removeAt(index);
            // db operation
            DatabaseHelper().removeBookmark(humor.uuid);
          });
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Bookmark Removed'),
              action: SnackBarAction(
                label: 'Undo',
                textColor: Colors.amber,
                onPressed: () {
                  setState(() {
                    bookmarks.insert(index, removedHumor);
                    // db operation
                    DatabaseHelper().addBookmark(humor);
                  });
                },
              ),
            ),
          );
        },
        background: Container(
          alignment: Alignment.centerRight,
          child: const LottieIcon(
            duration: 800,
            delay: 400,
            size: 30,
            lottiePath: 'assets/lottie/trash.json',
            color: Colors.grey,
          ),
        ),
        child: Card(
          elevation: elevation,
          color: humor.getCategoryData().themeColor,
          child: InkWell(
            onTap: () => _openBookmarkHumors(index),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final blackOrWhite = isDarkMode ? Colors.white : Colors.black;

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
                  color: blackOrWhite,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            LottieIcon(
              duration: 1000,
              delay: 800,
              size: 45,
              lottiePath: 'assets/lottie/human.json',
              color: Theme.of(context).scaffoldBackgroundColor,
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
          tabs: [
            Tab(text: 'Bookmarks (${bookmarks.length}/500)'),
            const Tab(text: 'Library (0)'),
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
                return ListView.builder(
                  itemCount: bookmarks.length,
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
          showModalBottomSheet(
            useSafeArea: true,
            isScrollControlled: true,
            context: context,
            builder: (ctx) => AddHumorScreen(
              (humor) => setState(
                () {
                  bookmarks.add(humor);
                  // db operation
                  DatabaseHelper().addBookmark(humor);
                },
              ),
            ),
          );
        },
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
  }
}
