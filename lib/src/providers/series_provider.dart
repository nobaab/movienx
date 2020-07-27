import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../helpers/api.dart';
import '../models/serie_model.dart';
export '../models/serie_model.dart';

class SeriesProvider {
  String _url = Api.url;
  bool _loading = false;
  int _currentPage = 1;
  int _pages = 1;
  List<Serie> _series = List();
  final _seriesStream = StreamController<List<Serie>>();

  Function(List<Serie>) get seriesSink => _seriesStream.sink.add;
  Stream<List<Serie>> get seriesStream => _seriesStream.stream;

  void dispose() {
    _seriesStream?.close();
  }

  Future<List<Serie>> _process(String endpoint) async {
    try {
      final resp = await http.get(_url + endpoint);

      if (resp.statusCode != 200) {
        throw Exception('Failed to load');
      }

      final data = json.decode(resp.body);

      final series = Series.fromJsonList(data);

      return series.items;
    } catch (e) {
      throw Exception('Failed to load');
    }
  }

  Future<bool> index() async {
    try {
      if (_currentPage <= _pages) {
        _loading = !_loading;
        final resp = await http.get(_url + 'series?page=$_currentPage');

        if (resp.statusCode != 200) {
          _seriesStream.addError('Failed to load');
          throw Exception('Failed to load');
        }

        final data = json.decode(resp.body);
        final movies = Series.fromJsonList(data['data']);
        _pages = data['last_page'];
          _currentPage++;
        

        _series.addAll(movies.items);
         seriesSink(_series);
        _loading = !_loading;
        return true;
      } else {
        return false;
      }
    } catch (e) {
       _seriesStream.addError('Failed to load');
       throw Exception('Failed to load');
    }
  }

  Future<List<Serie>> recommended() async {
    return _process('series/recommended');
  }

  Future<List<Serie>> popular() async {
    return _process('series/popular');
  }

  Future<List<Serie>> recents() async {
    return _process('series/recents');
  }

  Future<List<Serie>> kids() async {
    return _process('series/kids');
  }

  Future<List<Serie>> relateds(String id) async {
    return _process('series/relateds/' + id);
  }

  Future<Serie> show(String id) async {
    try {
      final resp = await http.get(_url + 'series/show/' + id);

      if (resp.statusCode != 200) {
        throw Exception('Failed to load');
      }

      final data = json.decode(resp.body);

      final serie = Serie.fromJson(data);

      return serie;
    } catch (e) {
      throw Exception('Failed to load');
    }
  }
}
