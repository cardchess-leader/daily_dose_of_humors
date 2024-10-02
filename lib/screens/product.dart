import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:daily_dose_of_humors/models/bundle.dart';
import 'package:daily_dose_of_humors/models/category.dart';
import 'package:daily_dose_of_humors/widgets/network_image.dart';
import 'package:daily_dose_of_humors/providers/app_state.dart';
import 'package:daily_dose_of_humors/screens/humor_screen.dart';

class ProductScreen extends ConsumerStatefulWidget {
  final Bundle bundle;
  final bool fromLibrary;

  const ProductScreen({
    super.key,
    required this.bundle,
    this.fromLibrary = false,
  });

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  final controller = PageController();
  var purchased = false;
  var isLoading = false;

  Future<void> downloadBundle() async {
    setState(() {
      isLoading = true;
    });
    // 1. Download all bundle humors
    final downloadSuccess = await (() async {
      final bundleHumors = await ref
          .read(serverProvider.notifier)
          .downloadHumorBundle(widget.bundle);
      if (bundleHumors.isEmpty) {
        return false;
      }
      // 2. Put them (both bundle & bundle humors) into library
      return await ref
          .read(libraryProvider.notifier)
          .saveBundleHumorsIntoLibrary(widget.bundle, bundleHumors);
    })();

    setState(() {
      isLoading = false;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 3000),
            content: Text(downloadSuccess.toString()),
          ),
        );
    });
  }

  Future<void> viewAllHumors() async {
    setState(() {
      isLoading = true;
    });
    final bundleHumors = await ref
        .read(libraryProvider.notifier)
        .getAllBundleHumors(widget.bundle);
    print('length is: ${bundleHumors.length}');
    if (mounted) {
      setState(() {
        isLoading = false;
      });
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => HumorScreen(
            buildHumorScreenFrom: BuildHumorScreenFrom.bookmark,
            humorList: bundleHumors,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    final verticalBar = Container(
      height: 35,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.bundle.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    double maxHeight = MediaQuery.of(context).size.height * 0.6;
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: maxHeight,
                      ),
                      child: AspectRatio(
                        aspectRatio: 140 / 200,
                        child: Stack(
                          children: [
                            PageView.builder(
                              itemCount: widget.bundle.coverImgList.length,
                              controller: controller,
                              itemBuilder: (context, index) {
                                return Card(
                                    color: Colors.amber,
                                    child: CustomNetworkImage(
                                        widget.bundle.coverImgList[index]));
                              },
                            ),
                            Container(
                              alignment: Alignment.bottomCenter,
                              padding: const EdgeInsets.only(bottom: 14),
                              child: SmoothPageIndicator(
                                controller: controller, // PageController
                                count: widget.bundle.coverImgList.length,
                                effect: const WormEffect(
                                  dotWidth: 10,
                                  dotHeight: 10,
                                  spacing: 6,
                                ), // your preferred effect
                                onDotClicked: (index) {
                                  controller.animateToPage(
                                    index,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  widget.bundle.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(top: 5),
                            child: Image.asset(
                              'assets/icons/category.png',
                              width: 28,
                              height: 28,
                              color: textColor,
                            ),
                          ),
                          Text(
                            Category.getCategoryByCode(
                                    widget.bundle.categoryCode)
                                .title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      verticalBar,
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.bundle.humorCount.toString(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Unique Humors',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      verticalBar,
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.bundle.languageCode,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Language',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 40),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey,
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  // The Product Description Part //
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '<Product Description>',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.bundle.description,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          color: Colors.transparent,
          child: (() {
            if (widget.fromLibrary) {
              return TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: () {
                  viewAllHumors();
                },
                child: isLoading
                    ? Lottie.asset(
                        'assets/lottie/loading.json',
                        width: 35,
                        height: 35,
                        delegates: LottieDelegates(
                          values: [
                            ValueDelegate.colorFilter(
                              ['**'],
                              value: const ColorFilter.mode(
                                  Colors.white, BlendMode.src),
                            ),
                          ],
                        ),
                      )
                    : const Text(
                        'View All Humors',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              );
            } else {
              return !purchased
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                side: const BorderSide(
                                  color: Colors.blueAccent,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            onPressed: () => {},
                            child: const Text(
                              'Preview',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            onPressed: () => {
                              setState(() {
                                purchased = true;
                              })
                            },
                            child: const Text(
                              'Buy at \$2.99',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      onPressed: () {
                        downloadBundle();
                      },
                      child: isLoading
                          ? Lottie.asset(
                              'assets/lottie/loading.json',
                              width: 35,
                              height: 35,
                              delegates: LottieDelegates(
                                values: [
                                  ValueDelegate.colorFilter(
                                    ['**'],
                                    value: const ColorFilter.mode(
                                        Colors.white, BlendMode.src),
                                  ),
                                ],
                              ),
                            )
                          : const Text(
                              'Download Humors',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    );
            }
          })()),
    );
  }
}
