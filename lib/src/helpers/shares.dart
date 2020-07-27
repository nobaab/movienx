import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings_model.dart';

class Shares {
  static String all(context, {@required title}) {
    final Settings settings = Provider.of<Settings>(context);

      String share = 'Watch $title on ${settings.appName}';
      if (settings.appUrlAndroid != null) {
        share += '\n \n Android: ${settings.appUrlAndroid}';
      }
      if (settings.appUrlIos != null) {
        share += '\n \n iOs: ${settings.appUrlIos}';
      }
      return share;
  }
}