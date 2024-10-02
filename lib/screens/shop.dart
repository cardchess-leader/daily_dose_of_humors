import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_dose_of_humors/widgets/app_bar.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:daily_dose_of_humors/screens/shop_category.dart';
import 'package:daily_dose_of_humors/screens/product.dart';
import 'package:daily_dose_of_humors/models/bundle_set.dart';
import 'package:daily_dose_of_humors/providers/app_state.dart';
import 'package:daily_dose_of_humors/models/bundle.dart';
import 'package:daily_dose_of_humors/widgets/network_image.dart';
import 'package:daily_dose_of_humors/widgets/loading.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() {
    return _ShopScreenState();
  }
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  Widget categorySectionGenerator({
    required BundleSet bundleSet,
    required Color textColor,
  }) {
    return Column(
      children: [
        ListTile(
          title: Text(
            bundleSet.title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          subtitle: Text(
            bundleSet.subtitle,
          ),
          trailing: const Icon(Icons.arrow_forward_rounded),
          onTap: () => {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => ShopCategoryScreen(
                  title: bundleSet.title,
                  subtitle: bundleSet.subtitle,
                ),
              ),
            )
          },
        ),
        SizedBox(
          height: 260,
          child: FutureBuilder<List<Bundle>>(
              future: ref
                  .read(serverProvider.notifier)
                  .getBundleListInSet(bundleSet),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: LoadingWidget(
                    color: textColor,
                    size: 50,
                  ));
                } else if (snapshot.hasError) {
                  return Text(
                      'Error: ${snapshot.error}'); // Replace with check internet connection lottie widget (that fills the entire remaining screen)
                } else {
                  return ScrollSnapList(
                    listViewPadding: const EdgeInsets.only(right: 150),
                    selectedItemAnchor: SelectedItemAnchor.START,
                    duration: 300,
                    scrollDirection: Axis.horizontal,
                    onItemFocus: (index) => (),
                    itemSize: 150,
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (context, index) => Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 5,
                      ),
                      width: 140,
                      child: IntrinsicHeight(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => ProductScreen(
                                  bundle: snapshot.data![index],
                                ),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Card(
                                color: Colors.amber,
                                margin: EdgeInsets.zero,
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 200,
                                  child: CustomNetworkImage(
                                      snapshot.data?[index].coverImgList[0] ??
                                          ''),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                ' ${snapshot.data?[index].title ?? ''}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                ' ${snapshot.data?[index].price ?? ''}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              }),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: const CustomAppBar(
        heading: 'Humor Shop',
        subheading: 'Premium Quality Humor Bundles',
        backgroundColor: Color.fromARGB(255, 255, 254, 200),
      ),
      body: FutureBuilder<List<BundleSet>>(
        future: ref.read(serverProvider.notifier).fetchHumorBundleSets(),
        builder: (context, snapshot) {
          // Checking the connection state
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting for the future to complete
            return Center(
                child: LoadingWidget(
              color: textColor,
              size: 80,
            ));
          } else if (snapshot.hasError) {
            // If an error occurred
            return Text(
                'Error: ${snapshot.error}'); // Replace with check internet connection lottie widget (that fills the entire remaining screen)
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 20,
              ),
              child: Column(
                children: snapshot.data
                        ?.map<Widget>(
                          (bundleSet) => categorySectionGenerator(
                            bundleSet: bundleSet,
                            textColor: textColor,
                          ),
                        )
                        .toList() ??
                    [],
              ),
            );
          }
        },
      ),
    );
  }
}
