import 'package:daily_dose_of_humors/providers/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:daily_dose_of_humors/widgets/app_bar.dart';
// import 'package:daily_dose_of_humors/widgets/page_header_text.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() {
    return _SettingsScreenState();
  }
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  bool themeValue = true;
  bool vibValue = true;
  bool notiValue = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..addStatusListener(_animationStatusListener);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _animController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animController.removeStatusListener(_animationStatusListener);
    _animController.dispose();
    super.dispose();
  }

  void _animationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          _animController.reset();
          _animController.forward();
        }
      });
    }
  }

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
    required String assetPath,
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
        leading: Lottie.asset(
          assetPath,
          width: 24,
          controller: _animController,
          delegates: LottieDelegates(
            values: [
              ValueDelegate.colorFilter(
                ['**'],
                value: ColorFilter.mode(
                    isDarkMode ? Colors.white : Colors.black, BlendMode.src),
              ),
            ],
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: trailingWidget,
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = ref.watch(darkModeProvider);
    return Scaffold(
      appBar: const CustomAppBar(
        heading: 'Settings',
        subheading: 'Set Your Preferences',
        backgroundColor: Color.fromARGB(255, 218, 230, 255),
      ),
      body: ListView(
        // padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        children: [
          const SizedBox(height: 16),
          generateHeader('Subscription'),
          generateSettingTile(
            assetPath: 'assets/lottie/takeoff.json',
            title: 'My Subscription: Free',
            isDarkMode: isDarkMode,
            trailingWidget: const Icon(Icons.keyboard_arrow_right_rounded),
            onTap: () => {},
          ),
          generateSettingTile(
            assetPath: 'assets/lottie/history.json',
            title: 'Restore Purchases',
            isDarkMode: isDarkMode,
            onTap: () => {},
          ),
          const SizedBox(height: 24),
          generateHeader('App Preferences'),
          generateSettingTile(
            assetPath: 'assets/lottie/bulb.json',
            title: 'Current Theme: Light',
            isDarkMode: isDarkMode,

            trailingWidget: Transform.scale(
              scale: 0.8,
              alignment: Alignment.centerRight,
              child: Switch(
                value: isDarkMode,
                onChanged: (value) =>
                    {ref.read(darkModeProvider.notifier).toggleDarkMode()},
                activeColor: Colors.white,
                activeTrackColor: isDarkMode
                    ? Colors.amberAccent
                    : Colors.blueAccent.shade200,
                inactiveThumbColor:
                    isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600,
                inactiveTrackColor: Colors.transparent,
              ),
            ),
            // const Icon(Icons.keyboard_arrow_right_rounded),
          ),
          generateSettingTile(
            assetPath: 'assets/lottie/vibration.json',
            title: 'Vibration: On',
            isDarkMode: isDarkMode,
            trailingWidget: Transform.scale(
              scale: 0.8,
              alignment: Alignment.centerRight,
              child: Switch(
                value: vibValue,
                onChanged: (value) => {setState(() => vibValue = value)},
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
            assetPath: 'assets/lottie/notification.json',
            title: 'Notification: On',
            isDarkMode: isDarkMode,
            trailingWidget: Transform.scale(
              scale: 0.8,
              alignment: Alignment.centerRight,
              child: Switch(
                value: notiValue,
                onChanged: (value) => {setState(() => notiValue = value)},
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
            assetPath: 'assets/lottie/thumbs.json',
            title: 'Rate Us',
            isDarkMode: isDarkMode,
            onTap: () => {},
          ),
          generateSettingTile(
            assetPath: 'assets/lottie/mail-open.json',
            title: 'Contact Us',
            isDarkMode: isDarkMode,
            onTap: () => {},
          ),
          const SizedBox(height: 24),
          generateHeader('Legal'),
          generateSettingTile(
            assetPath: 'assets/lottie/file.json',
            title: 'Terms Of Service',
            isDarkMode: isDarkMode,
            onTap: () => {},
          ),
          generateSettingTile(
            assetPath: 'assets/lottie/verified.json',
            title: 'Privacy Policy',
            isDarkMode: isDarkMode,
            onTap: () => {},
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: const Text(
              'Daily Dose Of Humor v1.0.0\nBy Board Collie',
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
