import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:daily_dose_of_humors/providers/app_state.dart';
import 'package:daily_dose_of_humors/screens/subscription.dart';
import 'package:daily_dose_of_humors/widgets/lottie_icon.dart';
import 'package:daily_dose_of_humors/widgets/app_bar.dart';
import 'package:daily_dose_of_humors/util/global_var.dart';
import 'package:daily_dose_of_humors/util/util.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() {
    return _SettingsScreenState();
  }
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Widget generateHeader(String headerText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        headerText,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget generateSettingTile({
    required String lottiePath,
    required String title,
    required bool isDarkMode,
    Widget? trailingWidget,
    void Function()? onTap,
  }) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
      ),
      child: ListTile(
        leading: LottieIcon(
          duration: 1800,
          delay: 1500,
          initDelay: 500,
          size: 24,
          lottiePath: lottiePath,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: trailingWidget,
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(userSettingsProvider)['darkMode'] ?? false;
    final vibration = ref.watch(userSettingsProvider)['vibration'] ?? false;
    final subscriptionName =
        ref.watch(subscriptionStatusProvider).subscriptionName;

    final notification =
        ref.watch(userSettingsProvider)['notification'] ?? false;
    return Scaffold(
      appBar: const CustomAppBar(
        heading: 'Settings',
        subheading: 'Set Your Preferences',
        backgroundColor: Color.fromARGB(255, 218, 230, 255),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          generateHeader('Subscription'),
          generateSettingTile(
            lottiePath: 'assets/lottie/takeoff.json',
            title: 'My Subscription: $subscriptionName',
            isDarkMode: isDarkMode,
            trailingWidget: const Icon(Icons.keyboard_arrow_right_rounded),
            onTap: () => {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const SubscriptionScreen(),
                ),
              )
            },
          ),
          generateSettingTile(
            lottiePath: 'assets/lottie/history.json',
            title: 'Restore Purchases',
            isDarkMode: isDarkMode,
            onTap: () async {
              final restoreResult =
                  await ref.read(iapProvider.notifier).restorePurchases();
              setState(() {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(restoreResult
                        ? 'Restore purchases successful!'
                        : 'There was an error restoring your purchases. \nPlease try again later.'),
                  ),
                );
              });
            },
          ),
          const SizedBox(height: 24),
          generateHeader('App Preferences'),
          generateSettingTile(
            lottiePath: 'assets/lottie/bulb.json',
            title: 'Current Theme: ${isDarkMode ? 'Dark' : 'Light'}',
            isDarkMode: isDarkMode,
            trailingWidget: Transform.scale(
              scale: 0.8,
              alignment: Alignment.centerRight,
              child: Switch(
                value: isDarkMode,
                onChanged: (value) => {
                  ref
                      .read(userSettingsProvider.notifier)
                      .toggleSettings('darkMode')
                },
                activeColor: Colors.white,
                activeTrackColor: isDarkMode
                    ? Colors.amberAccent
                    : Colors.blueAccent.shade200,
                inactiveThumbColor:
                    isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600,
                inactiveTrackColor: Colors.transparent,
              ),
            ),
          ),
          generateSettingTile(
            lottiePath: 'assets/lottie/vibration.json',
            title: 'Vibration: ${vibration ? 'On' : 'Off'}',
            isDarkMode: isDarkMode,
            trailingWidget: Transform.scale(
              scale: 0.8,
              alignment: Alignment.centerRight,
              child: Switch(
                value: vibration,
                onChanged: (value) => {
                  ref
                      .read(userSettingsProvider.notifier)
                      .toggleSettings('vibration')
                },
                activeColor: Colors.white,
                activeTrackColor: isDarkMode
                    ? Colors.amberAccent
                    : Colors.blueAccent.shade200,
                inactiveThumbColor:
                    isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600,
                inactiveTrackColor: Colors.transparent,
              ),
            ),
          ),
          generateSettingTile(
            lottiePath: 'assets/lottie/notification.json',
            title: 'Notification: ${notification ? 'On' : 'Off'}',
            isDarkMode: isDarkMode,
            trailingWidget: Transform.scale(
              scale: 0.8,
              alignment: Alignment.centerRight,
              child: Switch(
                value: notification,
                onChanged: (value) => {
                  ref
                      .read(userSettingsProvider.notifier)
                      .toggleSettings('notification')
                },
                activeColor: Colors.white,
                activeTrackColor: isDarkMode
                    ? Colors.amberAccent
                    : Colors.blueAccent.shade200,
                inactiveThumbColor:
                    isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600,
                inactiveTrackColor: Colors.transparent,
              ),
            ),
          ),
          const SizedBox(height: 24),
          generateHeader('Support'),
          generateSettingTile(
            lottiePath: 'assets/lottie/thumbs.json',
            title: 'Rate Us',
            isDarkMode: isDarkMode,
            onTap: () {
              final InAppReview inAppReview = InAppReview.instance;
              inAppReview.openStoreListing();
            },
          ),
          generateSettingTile(
            lottiePath: 'assets/lottie/mail-open.json',
            title: 'Contact Us',
            isDarkMode: isDarkMode,
            onTap: () async {
              final Uri emailUri = Uri(
                scheme: 'mailto',
                path: GLOBAL.EMAIL_ADDRESS, // Replace with your email address
                query: encodeQueryParameters(<String, String>{
                  'subject': 'Inquiry About Daily Dose of Humors',
                  'body':
                      'If you have any questions or feedback about our app, we\'d love to hear from you. \n\nPlease feel free to share your thoughts with us!'
                }),
              );

              if (await canLaunchUrl(emailUri)) {
                await launchUrl(emailUri);
              }
            },
          ),
          const SizedBox(height: 24),
          generateHeader('Legal'),
          generateSettingTile(
            lottiePath: 'assets/lottie/file.json',
            title: 'Terms Of Service',
            isDarkMode: isDarkMode,
            onTap: () async {
              final url = Uri.parse(
                  GLOBAL.TERMS_OF_SERVICE_URL); // Replace with your URL
              if (await canLaunchUrl(url)) {
                await launchUrl(url,
                    mode:
                        LaunchMode.externalApplication); // Opens in the browser
              }
            },
          ),
          generateSettingTile(
            lottiePath: 'assets/lottie/verified.json',
            title: 'Privacy Policy',
            isDarkMode: isDarkMode,
            onTap: () async {
              final url =
                  Uri.parse(GLOBAL.PRIVACY_POLICY_URL); // Replace with your URL
              if (await canLaunchUrl(url)) {
                await launchUrl(url,
                    mode:
                        LaunchMode.externalApplication); // Opens in the browser
              }
            },
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: const Text(
              'Daily Dose Of Humor ${GLOBAL.VERSION_NO}\nBy Board Collie',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
