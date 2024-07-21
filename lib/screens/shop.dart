import 'package:flutter/material.dart';
import 'package:daily_dose_of_humors/widgets/app_bar.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:daily_dose_of_humors/screens/shop_category.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() {
    return _ShopScreenState();
  }
}

class _ShopScreenState extends State<ShopScreen> {
  Widget categorySectionGenerator({
    required String title,
    required String subtitle,
    required int itemCount,
  }) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.arrow_forward_rounded),
          onTap: () => {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => ShopCategoryScreen(
                  title: title,
                  subtitle: subtitle,
                ),
              ),
            )
          },
        ),
        SizedBox(
          height: 260,
          child: ScrollSnapList(
            listViewPadding: const EdgeInsets.only(right: 150),
            selectedItemAnchor: SelectedItemAnchor.START,
            duration: 300,
            scrollDirection: Axis.horizontal,
            onItemFocus: (index) => (),
            itemSize: 150,
            itemCount: itemCount,
            itemBuilder: (context, index) => Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 5,
              ),
              width: 140,
              child: IntrinsicHeight(
                child: InkWell(
                  onTap: () => {},
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        color: Colors.amber,
                        margin: EdgeInsets.zero,
                        child: SizedBox(
                          width: double.infinity,
                          height: 200,
                          // color: Colors.amber,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        ' Best Dad Jokes of 2023',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        ' \$2.24',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        heading: 'Humor Shop',
        subheading: 'Premium Quality Humor Bundles',
        backgroundColor: Color.fromARGB(255, 255, 254, 200),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 20,
        ),
        child: Column(
          children: [
            categorySectionGenerator(
                title: 'New Humor Releases',
                subtitle:
                    'Discover the Latest and Greatest in Humor Collections',
                itemCount: 10),
            categorySectionGenerator(
                title: 'Top-Selling Humor Bundles',
                subtitle: 'Join the Crowd - Our Most Loved Humor Bundles',
                itemCount: 10),
            categorySectionGenerator(
                title: 'Ultimate Joke Collection',
                subtitle: 'Laugh Out Loud with Our Funniest Jokes Ever',
                itemCount: 10),
            categorySectionGenerator(
                title: 'Challenging Puzzles for the Clever',
                subtitle: 'Mind-Bending Puzzles That Will Test Your Wits',
                itemCount: 10),
            categorySectionGenerator(
                title: 'Curious and Hilarious Mix',
                subtitle: 'A Treasure Trove of Funny Quotes, Quizzes, and More',
                itemCount: 10),
          ],
        ),
      ),
    );
  }
}
