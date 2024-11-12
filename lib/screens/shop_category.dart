import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_dose_of_humors/providers/app_state.dart';
import 'package:daily_dose_of_humors/screens/product.dart';
import 'package:daily_dose_of_humors/models/bundle_set.dart';
import 'package:daily_dose_of_humors/models/bundle.dart';
import 'package:daily_dose_of_humors/widgets/loading.dart';
import 'package:daily_dose_of_humors/util/global_var.dart';
import 'package:daily_dose_of_humors/widgets/network_image.dart';

class ShopCategoryScreen extends ConsumerStatefulWidget {
  final BundleSet bundleSet;
  const ShopCategoryScreen({
    super.key,
    required this.bundleSet,
  });

  @override
  ConsumerState<ShopCategoryScreen> createState() => _ShopCategoryScreenState();
}

class _ShopCategoryScreenState extends ConsumerState<ShopCategoryScreen> {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.bundleSet.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: LayoutBuilder(builder: (context, constraints) {
            double spacing = 16;
            double itemWidth = ((constraints.maxWidth - spacing) / 2) -
                0.1; // Adjust the width for 2 items per row, 0.1 is safe margin
            return Wrap(
              spacing: spacing,
              runSpacing: 20,
              alignment: WrapAlignment.start,
              children: List.generate(
                widget.bundleSet.bundleList.length,
                (index) => SizedBox(
                  width: itemWidth,
                  child: FutureBuilder<Bundle?>(
                      future: ref
                          .read(serverProvider.notifier)
                          .getBundleDetail(widget.bundleSet.bundleList[index]),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AspectRatio(
                                aspectRatio: 140 / 200,
                                child: Card(
                                  color: Color.fromARGB(255, 255, 254, 200),
                                  margin: EdgeInsets.zero,
                                  child: Center(
                                    child: LoadingWidget(
                                      color: Colors.black,
                                      size: 50,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10), // placeholder
                              Text(''), // placeholder
                              Text(''), // placeholder
                            ],
                          );
                        } else if (snapshot.hasError || snapshot.data == null) {
                          return Text(
                              'Error: ${snapshot.error}'); // Replace with check internet connection lottie widget (that fills the entire remaining screen)
                        } else {
                          final bundle = snapshot.data!;
                          final heroTagUuid = GLOBAL.uuid.v4();
                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => ProductScreen(
                                    bundle: bundle,
                                    heroTagUuid: heroTagUuid,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AspectRatio(
                                  aspectRatio: 140 / 200,
                                  child: Hero(
                                    tag: heroTagUuid,
                                    child: Card(
                                      // color: Colors.amber,
                                      margin: EdgeInsets.zero,
                                      clipBehavior: Clip.hardEdge,
                                      child: CustomNetworkImage(
                                          bundle.coverImgList[0]),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  ' ${bundle.title}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  ' ${bundle.price}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        }
                      }),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
