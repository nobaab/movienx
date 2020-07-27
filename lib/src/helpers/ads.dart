import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings_model.dart';
import '../helpers/screen.dart';

class Ads {

static MobileAdTargetingInfo _targetingInfo = MobileAdTargetingInfo(
  nonPersonalizedAds: true,
  childDirected: true,
);

static InterstitialAd _newInterstitial(Settings settings) {
  return new InterstitialAd(
    adUnitId: _getAdUnitIdInterstitial(settings),
    targetingInfo: _targetingInfo,
  );
}

static InterstitialAd _interstitialAd;

static init({Settings settings}) {
    FirebaseAdMob.instance
        .initialize(appId: _getAppId(settings));
    Admob.initialize(_getAppId(settings));
  }

  static Widget _banner(Settings settings) {
    if(settings.adBanner){
      return Center(
        child: Container(
          width: 320.0,
          height: 50.0,
          margin: EdgeInsets.only(top: 15.0),
          child: AdmobBanner(
                      adUnitId: _getAdUnitIdBanner(settings),
                      adSize: AdmobBannerSize.BANNER,
              ),
        ),
      );
    }else{
      return Container();
    }
  }

  static Widget _fullBanner(Settings settings) {
    if(settings.adBanner){
      return Center(
        child: Container(
          width: 468.0,
          height: 60.0,
          margin: EdgeInsets.only(top: 15.0),
          child: AdmobBanner(
                      adUnitId: _getAdUnitIdBanner(settings),
                      adSize: AdmobBannerSize.FULL_BANNER,
              ),
        ),
      );
    }else{
      return Container();
    }
  }

  static Widget _leaderBoard(Settings settings) {
    if(settings.adBanner){
      return Center(
        child: Container(
          width: 728.0,
          height: 90.0,
          margin: EdgeInsets.only(top: 15.0),
          child: AdmobBanner(
                      adUnitId: _getAdUnitIdBanner(settings),
                      adSize: AdmobBannerSize.LEADERBOARD,
              ),
        ),
      );
    }else{
      return Container();
    }
  }

  static Widget responsive(BuildContext context){
    final settings = Provider.of<Settings>(context);
    if (Screen.isMobile(context)) {
      if (Screen.isPortrait(context)) {
        return _banner(settings);
      } else {
        return _fullBanner(settings);
      }
    } else {
      return _leaderBoard(settings);
    }
  }

  static String _getAppId(Settings settings){
    return (Platform.isIOS) ? settings.adIosAppId : settings.adAppId;
  }

  static String _getAdUnitIdBanner(Settings settings){
    return (Platform.isIOS) ? settings.adIosUnitIdBanner ?? 'ca-app-pub-3940256099942544/2934735716' : settings.adUnitIdBanner ?? 'ca-app-pub-3940256099942544/6300978111';
  }

  static String _getAdUnitIdInterstitial(Settings settings){
    return (Platform.isIOS) ? settings.adIosUnitIdInterstitial ?? 'ca-app-pub-3940256099942544/4411468910' : settings.adUnitIdInterstitial ?? 'ca-app-pub-3940256099942544/1033173712';
  }

  static void interstitialLoad(BuildContext context) {
    final settings = Provider.of<Settings>(context);
    if(settings.adInterstitial){
    if (_interstitialAd != null) {
      _interstitialAd..load();
    } else {
      _interstitialAd = _newInterstitial(settings);
      _interstitialAd..load();
    }
    }
  }

  static void interstitialShow() {
    if (_interstitialAd != null) {
      _interstitialAd..show();
    }
  }

  static void interstitialDispose() {
    _interstitialAd.dispose();
  }

}
