import 'dart:convert';

import 'package:flutter/material.dart';
import '..//helpers/parse.dart';

Settings settingsFromJson(String str) => Settings.fromMap(json.decode(str));

class Settings {
    String appName;
    String authorization;
    String appUrlAndroid;
    String appUrlIos;
    bool titleInPoster;
    bool appBarAnimation;
    bool livetv;
    bool kids;
    String adAppId;
    bool adBanner;
    String adUnitIdBanner;
    bool adInterstitial;
    String adUnitIdInterstitial;
    String adIosAppId;
    bool adIosBanner;
    String adIosUnitIdBanner;
    bool adIosInterstitial;
    String adIosUnitIdInterstitial;
    bool appColorDark;
    Color appBackgroundColor;
    Color appHeaderRecentTaskColor;
    Color appPrimaryColor;
    Color appSplashColor;
    Color appButtonsColor;
    Color appBarColor;
    double appBarOpacity;
    Color appBarIconsColor;
    Color bottomNavigationBarColor;
    Color iconsColor;
    Color textColor;
    Color appBarTitleColor;

    Settings({
        this.appName,
        this.appUrlAndroid,
        this.appUrlIos,
        this.titleInPoster,
        this.appBarAnimation,
        this.livetv,
        this.kids,
        this.adAppId,
        this.adBanner,
        this.adUnitIdBanner,
        this.adInterstitial,
        this.adUnitIdInterstitial,
        this.adIosAppId,
        this.adIosBanner,
        this.adIosUnitIdBanner,
        this.adIosInterstitial,
        this.adIosUnitIdInterstitial,
        this.appColorDark,
        this.appBackgroundColor,
        this.appHeaderRecentTaskColor,
        this.appPrimaryColor,
        this.appSplashColor,
        this.appButtonsColor,
        this.appBarColor,
        this.appBarOpacity,
        this.appBarIconsColor,
        this.bottomNavigationBarColor,
        this.iconsColor,
        this.textColor,
        this.appBarTitleColor,
    });

    factory Settings.fromMap(Map<String, dynamic> json) => new Settings(
        appName: json["app_name"],
        appUrlAndroid: json["app_url_android"],
        appUrlIos: json["app_url_ios"],
        titleInPoster: Parse.toBool(json["title_in_poster"]),
        appBarAnimation: Parse.toBool(json["app_bar_animation"]),
        livetv: Parse.toBool(json["livetv"]),
        kids: Parse.toBool(json["kids"]),
        adAppId: json["ad_app_id"],
        adBanner: Parse.toBool(json["ad_banner"]),
        adUnitIdBanner: json["ad_unit_id_banner"],
        adInterstitial: Parse.toBool(json["ad_interstitial"]),
        adUnitIdInterstitial: json["ad_unit_id_interstitial"],
        adIosAppId: json["ad_ios_app_id"],
        adIosBanner: Parse.toBool(json["ad_ios_banner"]),
        adIosUnitIdBanner: json["ad_ios_unit_id_banner"],
        adIosInterstitial: Parse.toBool(json["ad_ios_interstitial"]),
        adIosUnitIdInterstitial: json["ad_ios_unit_id_interstitial"],
        appColorDark: Parse.toBool(json["app_color_dark"]),
        appBackgroundColor: Parse.toColor(json["app_background_color"]),
        appHeaderRecentTaskColor: Parse.toColor(json["app_header_recent_task_color"]),
        appPrimaryColor: Parse.toColor(json["app_primary_color"]),
        appSplashColor: Parse.toColor(json["app_splash_color"]),
        appButtonsColor: Parse.toColor(json["app_buttons_color"]),
        appBarColor: Parse.toColor(json["app_bar_color"]),
        appBarOpacity: Parse.checkDouble(json["app_bar_opacity"]),
        appBarIconsColor: Parse.toColor(json["app_bar_icons_color"]),
        bottomNavigationBarColor: Parse.toColor(json["bottom_navigation_bar_color"]),
        iconsColor: Parse.toColor(json["icons_color"]),
        textColor: Parse.toColor(json["text_color"]),
        appBarTitleColor: Parse.toColor(json["app_bar_title_color"]),
    );

}