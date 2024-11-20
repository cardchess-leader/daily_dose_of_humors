import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:lottie/lottie.dart';
import 'package:daily_dose_of_humors/models/subscription.dart';
import 'package:daily_dose_of_humors/data/subscription_data.dart';
import 'package:daily_dose_of_humors/widgets/lottie_icon.dart';
import 'package:daily_dose_of_humors/util/util.dart';
import 'package:daily_dose_of_humors/providers/app_state.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({
    super.key,
  });

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  final controller = PageController(initialPage: 1, viewportFraction: 0.5);
  int focusedIndex = 1;

  Widget generateListTile(Perk perk, bool isDarkMode) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom: 10),
      constraints: isDarkMode
          ? null
          : const BoxConstraints(
              minHeight: 95.0, // Set minimum height here
            ),
      decoration: isDarkMode
          ? null
          : BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: lighten(perk.color, 0.3), width: 2.5),
            ),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: lighten(perk.color, 0.3),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.check,
                color: perk.color,
                size: 16,
              ),
            ),
            const SizedBox(width: 16),
            Image.asset(
              perk.imgPath,
              width: 40,
            ),
          ],
        ),
        title: Text(
          perk.title,
          style: TextStyle(
            color: perk.color,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        subtitle: Text(
          perk.subtitle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDarkMode ? Colors.white : Colors.grey.shade900,
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubscription() async {
    final subscriptionResult = await ref
        .read(subscriptionStatusProvider.notifier)
        .updateSubscription(subscriptionTypes[focusedIndex].subscriptionCode);

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(subscriptionResult
              ? 'Subscription successful!\nPlease enjoy the app with all subscription benefits! :)'
              : 'Subscription failed unexpectedly...\nPlease try again later :('),
        ),
      );
      if (subscriptionResult) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Begin Your Humorous Journey!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 30,
                          color: Colors.amber.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 180,
                      child: Lottie.asset(
                        subscriptionTypes[focusedIndex].lottiePath,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // const SizedBox(height: 100),
                    SizedBox(
                      height: 250,
                      child: ScrollSnapList(
                        // duration: 200,
                        initialIndex: focusedIndex.toDouble(),
                        itemSize: 300,
                        itemCount: 3,
                        dynamicItemSize: true,
                        dynamicSizeEquation: (distance) =>
                            1 - (distance / 3000).abs(),
                        onItemFocus: (index) => setState(() {
                          focusedIndex = index;
                        }),
                        itemBuilder: (context, index) => SizedBox(
                          width: 300,
                          child: Material(
                            color: Colors.white,
                            elevation: 8,
                            borderRadius: BorderRadius.circular(16.0),
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(
                                  width: 5,
                                  color: lighten(
                                    subscriptionTypes[index].color,
                                    0.2,
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    '${subscriptionTypes[index].text1}!',
                                    style: TextStyle(
                                      // color: Colors.blue.shade900,
                                      color: lighten(
                                          subscriptionTypes[index].color),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 239, 250, 255),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        children: [
                                          const SizedBox(height: 10),
                                          Text(
                                            subscriptionTypes[index].text2,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 30,
                                            ),
                                          ),
                                          ref.watch(iapProvider)[
                                                          'product_details'][
                                                      subscriptionTypes[index]
                                                          .productId] ==
                                                  null
                                              ? Lottie.asset(
                                                  'assets/lottie/loading.json',
                                                  width: 35,
                                                  height: 35,
                                                  delegates: LottieDelegates(
                                                    values: [
                                                      ValueDelegate.colorFilter(
                                                        ['**'],
                                                        value: const ColorFilter
                                                            .mode(Colors.black,
                                                            BlendMode.src),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Text(
                                                  '${ref.watch(iapProvider)['product_details'][subscriptionTypes[index].productId].price} ${subscriptionTypes[index].text3}',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                          const SizedBox(height: 20),
                                          Container(
                                            height: 3,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 4),
                                          ),
                                          const SizedBox(height: 10),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                subscriptionTypes[index].text4,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      184, 0, 0, 0),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 22,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(54, 63, 81, 181),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.flip(
                          flipY: true,
                          flipX: false,
                          child: LottieIcon(
                            lottiePath: 'assets/lottie/finger-up.json',
                            color: lighten(
                                subscriptionTypes[focusedIndex].color,
                                isDarkMode ? 0.1 : 0),
                            size: 30,
                            duration: 1000,
                            delay: 250,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Here\'s what you\'ll get',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: lighten(
                                subscriptionTypes[focusedIndex].color,
                                isDarkMode ? 0.1 : 0),
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ...(subscriptionTypes[focusedIndex].perks.map(
                          (perk) => generateListTile(perk, isDarkMode),
                        )),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                iconSize: 36,
                icon: const Icon(Icons.close_rounded),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        isDarkMode ? Colors.black : Colors.white,
                        isDarkMode
                            ? const Color.fromARGB(128, 0, 0, 0)
                            : const Color.fromARGB(128, 255, 255, 255),
                        isDarkMode
                            ? const Color.fromARGB(0, 0, 0, 0)
                            : const Color.fromARGB(0, 255, 255, 255),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: const [
                        0.0,
                        0.5,
                        1.0,
                      ]),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: subscriptionTypes[focusedIndex]
                        .color, // Background color
                    foregroundColor: Colors.white, // Text color
                  ),
                  onPressed: ref.watch(iapProvider)['product_details']
                              [subscriptionTypes[focusedIndex].productId] ==
                          null
                      ? null
                      : _handleSubscription,
                  child: const Text(
                    'Start My Subscription',
                    style: TextStyle(
                      fontFamily: null,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
