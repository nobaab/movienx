import 'dart:async';
import 'dart:convert';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import '../helpers/api.dart';
import '../helpers/network.dart';
import '../models/settings_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider {
  Future<Settings> index() async {
    SharedPreferences previous = await SharedPreferences.getInstance();
    Response resp;
    Map<String, dynamic> data;
    Settings settings;

    final network = await Network.check();

    if (network) {
      resp = await http.get(Api.url + 'settings');

      if (resp.statusCode == 200) {
        previous.setString('settings', resp.body);
      }
    }

    if (previous.getString('settings') != null || resp != null) {
      data = json.decode(previous.getString('settings') ?? resp.body);
    } else {
      return null;
    }

    settings = Settings.fromMap(data);

    return settings;
  }

  Future<String> logoType() async {
    SharedPreferences previous = await SharedPreferences.getInstance();

    final network = await Network.check();

    if (network) {
      final res = await http.get(Api.url + 'image/logo');

      if (previous.getString('type') != res.headers['type']) await DiskCache().clear();
      
      previous.setString('type', res.headers['type']);

      return res.headers['type'];
      
    } else {
      return previous.getString('type');
    }
  }
}
