import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:daily_dose_of_humors/providers/app_state.dart';

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
      adUnitId: RemoteConfigService.fetchStringValue(
          Platform.isAndroid ? 'banner_ad_id_android' : 'banner_ad_id_ios'),
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
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
    widget.setBannerHeight!(0);
    _anchoredAdaptiveAd?.dispose();
    super.dispose();
  }
}
