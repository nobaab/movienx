import 'dart:async';
import 'dart:convert';

import '../helpers/api.dart';
import '../models/movie_model.dart';
import '../models/serie_model.dart';

import 'package:http/http.dart' as http;

class BrowserProvider {
  String _url = Api.url;
  bool _loading = false;
  int _currentPageMovies = 1;
  int _currentPageSeries = 1;
  int _pagesMovies = 1;
  int _pagesSeries = 1;
  List<dynamic> _browsers = List();
  final _browsersStream = StreamController<List<dynamic>>();

  Function(List<dynamic>) get browsersSink => _browsersStream.sink.add;
  Stream<List<dynamic>> get browsersStream => _browsersStream.stream;

  void dispose() {
    _browsersStream?.close();
  }

  Future<bool> index(String id) async {
    try {
      if (_currentPageSeries <= _pagesSeries ||
          _currentPageMovies <= _pagesMovies) {
        _loading = !_loading;

        final resp = await http
            .get(_url + 'genres/series/show/$id?page=$_currentPageSeries');

        final resp2 = await http
            .get(_url + 'genres/movies/show/$id?page=$_currentPageMovies');

        if (resp.statusCode != 200 || resp2.statusCode != 200) {
          _browsersStream.addError('Failed to load');
          throw Exception('Failed to load');
        }

        if (_currentPageSeries <= _pagesSeries) {
          final data = json.decode(resp.body);
          if (data['data'] != null) {
            final series = Series.fromJsonList(data['data']);
            _pagesSeries = data['last_page'];
              _currentPageSeries++;
            _browsers.addAll(series.items);
          }
        }

        if (_currentPageMovies <= _pagesMovies) {
          final data2 = json.decode(resp2.body);
          if (data2['data'] != null) {
            final movies = Movies.fromJsonList(data2['data']);
            _pagesMovies = data2['last_page'];
              _currentPageMovies++;
            _browsers.addAll(movies.items);
          }
        }

        browsersSink(_browsers);
        _loading = !_loading;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      _browsersStream.addError('Failed to load');
      throw Exception('Failed to load');
    }
  }
}
