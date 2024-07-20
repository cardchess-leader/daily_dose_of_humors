import 'package:daily_dose_of_humors/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:daily_dose_of_humors/widgets/page_header_text.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() {
    return _SettingsScreenState();
  }
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
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

  Widget generateSettingTile(
      {required Icon leadingIcon,
      required String title,
      Widget? trailingWidget,
      void Function()? onTap}) {
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
        leading: leadingIcon,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: trailingWidget,
        // splashColor: Colors.white,
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            leadingIcon: const Icon(Icons.subscriptions_outlined),
            title: 'My Subscription: Free',
            trailingWidget: const Icon(Icons.keyboard_arrow_right_rounded),
            onTap: () => {},
          ),
          generateSettingTile(
            leadingIcon: const Icon(Icons.restore_rounded),
            title: 'Restore Purchases',
            onTap: () => {},
          ),
          const SizedBox(height: 24),
          generateHeader('App Preferences'),
          generateSettingTile(
            leadingIcon: const Icon(Icons.light_mode_outlined),
            title: 'Current Theme: Light',
            trailingWidget: Transform.scale(
              scale: 0.8,
              alignment: Alignment.centerRight,
              child: Switch(
                value: true,
                onChanged: (value) => {},
              ),
            ),
            // const Icon(Icons.keyboard_arrow_right_rounded),
          ),
          generateSettingTile(
            leadingIcon: const Icon(Icons.vibration),
            title: 'Vibration: On',
            trailingWidget: Transform.scale(
              scale: 0.8,
              alignment: Alignment.centerRight,
              child: Switch(
                value: true,
                onChanged: (value) => {},
              ),
            ),
          ),
          generateSettingTile(
            leadingIcon: const Icon(Icons.notifications_outlined),
            title: 'Notification: On',
            trailingWidget: Transform.scale(
              scale: 0.8,
              alignment: Alignment.centerRight,
              child: Switch(
                value: true,
                onChanged: (value) => {},
              ),
            ),
          ),
          const SizedBox(height: 24),
          generateHeader('Support'),
          generateSettingTile(
            leadingIcon: const Icon(Icons.star_rate_outlined),
            title: 'Rate Us',
            onTap: () => {},
          ),
          generateSettingTile(
            leadingIcon: const Icon(Icons.mail_outlined),
            title: 'Contact Us',
            onTap: () => {},
          ),
          const SizedBox(height: 24),
          generateHeader('Legal'),
          generateSettingTile(
            leadingIcon: const Icon(Icons.document_scanner_outlined),
            title: 'Terms Of Service',
            onTap: () => {},
          ),
          generateSettingTile(
            leadingIcon: const Icon(Icons.privacy_tip_outlined),
            title: 'Privacy Policy',
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
