import '../helpers/api.dart';
import 'package:http/http.dart' as http;
import 'dart:io'; //InternetAddress utility
import 'dart:async';

class Network {
  static Future<bool> check() async {
    try {
      await http.get(Api.url + 'status');

      return true;
    } on SocketException catch (_) {
      return false;
    }
  }
}
