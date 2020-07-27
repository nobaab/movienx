import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../helpers/api.dart';
import '../models/livetv_model.dart';
export '../models/livetv_model.dart';

class LivetvProvider {
  String _url = Api.url;
  bool _loading = false;
  int _currentPage = 1;
  int _pages = 1;
  List<Livetv> _livetvs = List();
  final _livetvsStream = StreamController<List<Livetv>>();

  Function(List<Livetv>) get livetvsSink => _livetvsStream.sink.add;
  Stream<List<Livetv>> get livetvsStream => _livetvsStream.stream;

  void dispose() {
    _livetvsStream?.close();
  }

  Future<bool> index() async {
    try {
      if (_currentPage <= _pages) {
        _loading = !_loading;
        final resp = await http.get(_url + 'livetv?page=$_currentPage');

        if (resp.statusCode != 200) {
          _livetvsStream.addError('Failed to load');
          throw Exception('Failed to load');
        }

        final data = json.decode(resp.body);
        final livetvs = Livetvs.fromJsonList(data['data']);
        _pages = data['last_page'];
          _currentPage++;

        _livetvs.addAll(livetvs.items);
        livetvsSink(_livetvs);
        _loading = !_loading;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      _livetvsStream.addError('Failed to load');
      throw Exception('Failed to load');
    }
  }

  Future<Livetv> show(String id) async {
    try {
      final resp = await http.get(_url + 'livetv/show/' + id);
      if (resp.statusCode != 200) {
        throw Exception('Failed to load');
      }

      final data = json.decode(resp.body);

      final livetv = Livetv.fromJson(data);

      return livetv;
    } catch (e) {
      throw Exception('Failed to load');
    }
  }
}
