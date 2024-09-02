import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:daily_dose_of_humors/widgets/app_bar.dart';
import 'package:daily_dose_of_humors/models/humor.dart';
import 'package:daily_dose_of_humors/widgets/lottie_icon.dart';
import 'package:daily_dose_of_humors/screens/add_humor.dart';
import 'package:daily_dose_of_humors/screens/humor_screen.dart';
import 'package:daily_dose_of_humors/widgets/last_frame_lottie.dart';
import 'package:daily_dose_of_humors/util/util.dart';
import 'package:daily_dose_of_humors/models/category.dart';
import 'package:daily_dose_of_humors/providers/app_state.dart';
import 'package:daily_dose_of_humors/util/global_var.dart';

class BookmarkScreen extends ConsumerStatefulWidget {
  const BookmarkScreen({super.key});

  @override
  ConsumerState<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends ConsumerState<BookmarkScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  bool isLoading = true;
  List<Humor> bookmarks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initBookmarks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initBookmarks() async {
    final loadedBookmarks =
        await ref.read(bookmarkProvider.notifier).getAllBookmarks();
    setState(() {
      bookmarks = loadedBookmarks;
      isLoading = false;
    });
  }

  Future<void> _loadBookmarks() async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    setState(() {
      isLoading = true;
    });

    final searchTerm = _searchController.text.trim();
    final loadedBookmarks = searchTerm.isEmpty
        ? await ref.read(bookmarkProvider.notifier).getAllBookmarks()
        : await ref
            .read(bookmarkProvider.notifier)
            .getBookmarksByKeyword(searchTerm);

    setState(() {
      bookmarks = loadedBookmarks;
      isLoading = false;
    });
  }

  void _openBookmarkHumors(int index) async {
    final isBookmarkUpdated = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => HumorScreen(
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

  Widget _buildCard(BuildContext context, int index) {
    final humor = bookmarks[index];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      key: ValueKey(humor.uuid),
      child: Dismissible(
        key: ValueKey(humor.uuid),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          final removedHumor = bookmarks[index];
          setState(() {
            bookmarks.removeAt(index);
          });
          ref.read(bookmarkProvider.notifier).removeBookmark(humor);
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
                  });
                  ref.read(bookmarkProvider.notifier).addBookmark(humor);
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
          elevation: 5,
          color: humor.getCategoryData().themeColor,
          child: InkWell(
            onTap: () => _openBookmarkHumors(index),
            child: Container(
              padding: const EdgeInsets.all(25),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    right: humor.getCategoryData().categoryCode ==
                            CategoryCode.ONE_LINERS
                        ? -10
                        : 0,
                    child: humor.getCategoryData().lottiePath != null
                        ? LastFrameLottie(
                            lottiePath: humor.getCategoryData().lottiePath!,
                            size: humor.getCategoryData().categoryCode ==
                                    CategoryCode.ONE_LINERS
                                ? 110
                                : 80,
                            // color: const Color.fromARGB(50, 0, 0, 0),
                            color:
                                darken(humor.getCategoryData().themeColor, 0.2),
                            lottiePointInTime:
                                humor.getCategoryData().lottiePointInTime ??
                                    1.0,
                          )
                        : Image.asset(
                            humor.getCategoryData().imgPath!,
                            width: 80,
                            color: const Color.fromARGB(50, 0, 0, 0),
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
                            color: Colors.black),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '- From "${humor.source}"',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Added on ${DateFormat('yyyy-MM-dd').format((humor as BookmarkHumor).bookmarkAddedDate)}',
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

  Widget _emptyPlaceHolder(Color color, String message) {
    return Column(
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
                  color: color,
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
        Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxBookmarkCount = ref.watch(subscriptionStatusProvider).maxBookmarks;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final blackOrWhite = isDarkMode ? Colors.white : Colors.black;

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
            Tab(
                text: 'Bookmarks (${bookmarks.length}${(() {
              if (maxBookmarkCount == GLOBAL.SMALL_MAX_INT) return '';
              return '/$maxBookmarkCount';
            })()})'),
            const Tab(text: 'Library (0)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: !isLoading &&
                    _searchController.text.trim() == '' &&
                    bookmarks.isEmpty
                ? _emptyPlaceHolder(blackOrWhite, 'Wow, such empty!')
                : Column(
                    children: [
                      const SizedBox(height: 10),
                      TextField(
                        controller: _searchController,
                        maxLength: 100,
                        style: const TextStyle(fontSize: 20),
                        decoration: const InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(10),
                            child: LottieIcon(
                              duration: 800,
                              delay: 1600,
                              lottiePath: 'assets/lottie/search.json',
                              color: Colors.grey,
                            ),
                          ),
                          hintText: 'Search for keyword...',
                          border: InputBorder.none,
                          counterText: '',
                        ),
                        onChanged: (value) => _loadBookmarks(),
                      ),
                      Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(65, 158, 158, 158),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      isLoading
                          ? const Expanded(
                              child: Center(child: CircularProgressIndicator()))
                          : Expanded(
                              child: bookmarks.isEmpty
                                  ? _emptyPlaceHolder(
                                      blackOrWhite, 'Wow, no results!')
                                  : ListView.builder(
                                      itemCount: bookmarks.length,
                                      itemBuilder: (context, index) =>
                                          _buildCard(context, index),
                                    ),
                            ),
                    ],
                  ),
          ),
          _emptyPlaceHolder(blackOrWhite, 'Wow, such empty!'),
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
                  ref.read(bookmarkProvider.notifier).addBookmark(humor);
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
