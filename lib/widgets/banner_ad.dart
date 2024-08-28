import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  final void Function(double bannerHeight)? setBannerHeight;

  const BannerAdWidget({super.key, this.setBannerHeight});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  Future<void> _loadAd() async {
    // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    } else if (widget.setBannerHeight != null) {
      widget.setBannerHeight!(size.height.toDouble());
    }

    _anchoredAdaptiveAd = BannerAd(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111' // Test Ad Unit ID for Android
          : 'ca-app-pub-3940256099942544/2934735716', // Test Ad Unit ID for iOS
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$ad loaded: ${ad.responseInfo}');
          setState(() {
            _anchoredAdaptiveAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Anchored adaptive banner failed to load: $error');
          ad.dispose();
        },
      ),
    );
    _anchoredAdaptiveAd!.load();
  }

  @override
  Widget build(BuildContext context) => _anchoredAdaptiveAd != null && _isLoaded
      ? SizedBox(
          width: _anchoredAdaptiveAd!.size.width.toDouble(),
          height: _anchoredAdaptiveAd!.size.height.toDouble(),
          child: AdWidget(ad: _anchoredAdaptiveAd!),
        )
      : const SizedBox.shrink();

  @override
  void dispose() {
    super.dispose();
    _anchoredAdaptiveAd?.dispose();
  }
}
