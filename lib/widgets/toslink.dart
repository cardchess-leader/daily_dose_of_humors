import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:daily_dose_of_humors/util/global_var.dart';

class TermsOfServiceLink extends StatefulWidget {
  const TermsOfServiceLink({super.key});

  @override
  State<TermsOfServiceLink> createState() => _TermsOfServiceLinkState();
}

class _TermsOfServiceLinkState extends State<TermsOfServiceLink> {
  // Utility method to get text theme based on brightness
  TextTheme _getTextTheme(BuildContext context, Brightness brightness) {
    final baseTextTheme = Theme.of(context).textTheme;
    return GoogleFonts.patrickHandTextTheme(
      brightness == Brightness.light
          ? baseTextTheme
          : baseTextTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
              decorationColor: Colors.white,
            ),
    );
  }

  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final textTheme = _getTextTheme(context, brightness);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final blackOrWhite = isDarkMode ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: RichText(
        text: TextSpan(
          style: textTheme.bodySmall, // Apply the dynamic font style here
          children: [
            TextSpan(
              text: 'By subscribing, you agree to our ',
              style: textTheme.bodySmall?.copyWith(
                color: blackOrWhite,
              ),
            ),
            TextSpan(
              text: 'Privacy Policy',
              style: textTheme.bodySmall?.copyWith(
                color: Colors.blue,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  _launchUrl(GLOBAL.PRIVACY_POLICY_URL);
                },
            ),
            TextSpan(
              text: ' and ',
              style: textTheme.bodySmall?.copyWith(
                color: blackOrWhite,
              ),
            ),
            TextSpan(
              text: 'Terms of Service',
              style: textTheme.bodySmall?.copyWith(
                color: Colors.blue,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  _launchUrl(GLOBAL.getTosLink());
                },
            ),
            TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }
}
