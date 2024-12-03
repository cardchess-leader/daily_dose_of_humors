import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lottie/lottie.dart';
import 'package:daily_dose_of_humors/models/bundle.dart';
import 'package:daily_dose_of_humors/models/category.dart';
import 'package:daily_dose_of_humors/widgets/network_image.dart';
import 'package:daily_dose_of_humors/providers/app_state.dart';
import 'package:daily_dose_of_humors/screens/humor_screen.dart';
import 'package:daily_dose_of_humors/util/global_var.dart';

enum ProductMessage { Buy, Download, ReDownload, View }

class ProductScreen extends ConsumerStatefulWidget {
  final Bundle bundle;
  final bool fromLibrary;
  final String heroTagUuid;

  const ProductScreen({
    super.key,
    required this.bundle,
    this.fromLibrary = false,
    required this.heroTagUuid,
  });

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  ScaffoldMessengerState? _scaffoldMessengerState;

  var productMessage = ProductMessage.Buy;
  var isLoading = false;
  var purchaseInProcess = false;

  @override
  void initState() {
    super.initState();
    setupPurchaseListener();
    initProductMessage();
  }

  void setupPurchaseListener() {
    _subscription = InAppPurchase.instance.purchaseStream.listen(
      _listenToPurchaseUpdated,
      onDone: () => _subscription.cancel(),
      onError: (_) {
        setState(() => purchaseInProcess = false);
        showSnackbar('Oops! Your purchase didn’t go through. Try again!');
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessengerState = ScaffoldMessenger.of(context);
  }

  @override
  void dispose() {
    _subscription.cancel();
    _scaffoldMessengerState?.clearSnackBars();
    super.dispose();
  }

  void showSnackbar(String message) {
    _scaffoldMessengerState
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        duration: const Duration(seconds: 5),
        content: Text(message),
      ));
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.productID == widget.bundle.productId) {
        switch (purchaseDetails.status) {
          case PurchaseStatus.purchased:
            InAppPurchase.instance.completePurchase(purchaseDetails);
            setState(() => productMessage = ProductMessage.Download);
            showSnackbar(
                'Purchase successful! You can now download the humor bundle!');
            break;

          case PurchaseStatus.error:
            showSnackbar('Purchase failed. Please try again.');
            break;

          default:
            break;
        }
      }
    }
    setState(() => purchaseInProcess = false);
  }

  Future<void> initProductMessage() async {
    if (widget.fromLibrary) {
      productMessage = ProductMessage.View;
    } else {
      final isInLibrary =
          (await ref.read(libraryProvider.notifier).getAllBundles())
              .any((bundle) => bundle.uuid == widget.bundle.uuid);

      if (isInLibrary) {
        productMessage = ProductMessage.ReDownload;
      } else if (ref
          .read(iapProvider.notifier)
          .isSkuPurchased(widget.bundle.productId)) {
        productMessage = ProductMessage.Download;
      } else {
        productMessage = ProductMessage.Buy;
      }
    }
    setState(() {});
  }

  Future<void> loadPreview() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    final previewHumors = await ref
        .read(serverProvider.notifier)
        .previewHumorBundle(widget.bundle);

    if (previewHumors.isNotEmpty && mounted) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => HumorScreen(
          buildHumorScreenFrom: BuildHumorScreenFrom.preview,
          humorList: previewHumors,
        ),
      ));
    }

    setState(() => isLoading = false);
  }

  Future<void> downloadBundle() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    final bundleHumors = await ref
        .read(serverProvider.notifier)
        .downloadHumorBundle(widget.bundle);
    final downloadSuccess = bundleHumors.isNotEmpty &&
        await ref
            .read(libraryProvider.notifier)
            .saveBundleHumorsIntoLibrary(widget.bundle, bundleHumors);

    setState(() {
      isLoading = false;
      productMessage = downloadSuccess ? ProductMessage.View : productMessage;
      showSnackbar(downloadSuccess
          ? 'Download successful! Check the Library tab in Bookmarks!'
          : 'Download failed. Please check your internet connection and try again.');
    });
  }

  Future<void> viewAllHumors() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    final bundleHumors = await ref
        .read(libraryProvider.notifier)
        .getAllBundleHumors(widget.bundle);

    if (mounted) {
      setState(() => isLoading = false);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => HumorScreen(
          buildHumorScreenFrom: BuildHumorScreenFrom.bookmark,
          humorList: bundleHumors,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(iapProvider);
    ref.read(iapProvider.notifier).loadAllIapSkuList();
    ProductDetails? productDetails = ref
        .read(iapProvider.notifier)
        .getProductDetails(widget.bundle.productId);
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
                if (widget.bundle.coverImgList.isNotEmpty)
                  LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      double maxHeight =
                          MediaQuery.of(context).size.height * 0.6;
                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: maxHeight,
                        ),
                        child: AspectRatio(
                          aspectRatio: GLOBAL.aspectRatio,
                          child: Hero(
                            tag: widget.heroTagUuid,
                            child: Card(
                              color: Colors.amber,
                              clipBehavior: Clip.hardEdge,
                              child: CustomNetworkImage(
                                  widget.bundle.coverImgList[0]),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                const Text('Cover design by Freepik AI'),
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
                      Transform.translate(
                        offset: const Offset(0, 0),
                        child: Html(data: widget.bundle.description, style: {
                          'div': Style(
                            fontSize: FontSize(17),
                          ),
                          'p': Style(
                            margin:
                                Margins(top: Margin.zero(), bottom: Margin(16)),
                          ),
                          'ul': Style(
                            padding: HtmlPaddings(left: HtmlPadding(20)),
                            margin: Margins(left: Margin.zero()),
                          ),
                        }),
                      )
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
            if (productMessage == ProductMessage.Buy) {
              // Raw case
              return Row(
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
                      onPressed: () {
                        loadPreview();
                      },
                      child: isLoading
                          ? Lottie.asset(
                              'assets/lottie/loading.json',
                              width: 25,
                              height: 25,
                              delegates: LottieDelegates(
                                values: [
                                  ValueDelegate.colorFilter(
                                    ['**'],
                                    value: const ColorFilter.mode(
                                        Colors.blueAccent, BlendMode.src),
                                  ),
                                ],
                              ),
                            )
                          : const Text(
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
                      onPressed: purchaseInProcess || (productDetails == null)
                          ? null
                          : () {
                              InAppPurchase.instance.buyNonConsumable(
                                purchaseParam: PurchaseParam(
                                    productDetails: productDetails),
                              );
                              setState(() {
                                purchaseInProcess = true;
                              });
                            },
                      child: Text(
                        'Buy at ${productDetails?.price}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              late String btnText;
              switch (productMessage) {
                case ProductMessage.Download:
                  btnText = 'Download Humors';
                case ProductMessage.ReDownload:
                  btnText = 'Re-Download Humors';
                default:
                  btnText = 'View All Humors';
              }
              return TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: () {
                  if (productMessage == ProductMessage.View) {
                    viewAllHumors();
                  } else {
                    downloadBundle();
                  }
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
                    : Text(
                        btnText,
                        style: const TextStyle(
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
