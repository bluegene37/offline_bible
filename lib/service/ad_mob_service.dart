import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdmobService {
  static String? get bannerAddUnitID {
    if(Platform.isAndroid){
      return "ca-app-pub-1884428053001869/6804341253";
    } else if (Platform.isIOS) {
      return "ca-app-pub-1884428053001869/4337960018";
    }
    return null;
  }

  static final BannerAdListener bannerAdListener = BannerAdListener(
      onAdLoaded: (ad) => debugPrint('Ad loaded.'),
      onAdFailedToLoad: (ad, error) => {
        ad.dispose(),
        debugPrint('Ad failed to load: $error')
      },
      onAdOpened: (ad) => debugPrint('Ad opened.'),
      onAdClosed: (ad) => debugPrint('Ad closed.'),
    );

}

