import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../helpers/api.dart';
import '../models/movie_model.dart';
import '../models/serie_model.dart';
export '../models/movie_model.dart';
export '../models/serie_model.dart';

class KidsProvider {
  String _url = Api.url;
  bool _loading = false;
  int _currentPageMovies = 1;
  int _currentPageSeries = 1;
  int _pagesMovies = 1;
  int _pagesSeries = 1;
  List<dynamic> _kids = List();
  final _kidsStream = StreamController<List<dynamic>>();

  Function(List<dynamic>) get kidsSink => _kidsStream.sink.add;
  Stream<List<dynamic>> get kidsStream => _kidsStream.stream;

  void dispose() {
    _kidsStream?.close();
  }

  Future<bool> index() async {
    try {
      if (_currentPageSeries <= _pagesSeries ||
          _currentPageMovies <= _pagesMovies) {
        _loading = !_loading;

        final resp =
            await http.get(_url + 'series/kids?page=$_currentPageSeries');

        final resp2 =
            await http.get(_url + 'movies/kids?page=$_currentPageMovies');

        if (resp.statusCode != 200 || resp2.statusCode != 200) {
          _kidsStream.addError('Failed to load');
          throw Exception('Failed to load');
        }

        if (_currentPageSeries <= _pagesSeries) {
          final data = json.decode(resp.body);
          if (data['data'] != null) {
            final series = Series.fromJsonList(data['data']);
            _pagesSeries = data['last_page'];
            
              _currentPageSeries++;
            
            _kids.addAll(series.items);
          }
        }

        if (_currentPageMovies <= _pagesMovies) {
          final data2 = json.decode(resp2.body);
          if (data2['data'] != null) {
            final movies = Movies.fromJsonList(data2['data']);

            _pagesMovies = data2['last_page'];
            
              _currentPageMovies++;
            
            _kids.addAll(movies.items);
          }
        }

        kidsSink(_kids);
        _loading = !_loading;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      _kidsStream.addError('Failed to load');
      throw Exception('Failed to load');
    }
  }
}
