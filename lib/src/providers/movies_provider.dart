import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../helpers/api.dart';
import '../models/movie_model.dart';
export '../models/movie_model.dart';
import '../models/movie_video_model.dart';

class MoviesProvider {
  String _url = Api.url;
  bool _loading = false;
  int _currentPage = 1;
  int _pages = 1;
  List<Movie> _movies = List();
  final _moviesStream = StreamController<List<Movie>>();

  Function(List<Movie>) get moviesSink => _moviesStream.sink.add;
  Stream<List<Movie>> get moviesStream => _moviesStream.stream;

  void dispose() {
    _moviesStream?.close();
  }

  Future<List<Movie>> _process(String endpoint) async {
    try {
      final resp = await http.get(_url + endpoint);

      if (resp.statusCode != 200) {
        throw Exception('Failed to load');
      }

      final data = json.decode(resp.body);

      final movies = Movies.fromJsonList(data);

      return movies.items;
    } catch (e) {
      throw Exception('Failed to load');
    }
  }

  Future<bool> index() async {
    try {
      if (_currentPage <= _pages) {
        _loading = !_loading;
        final resp = await http.get(_url + 'movies?page=$_currentPage');

        if (resp.statusCode != 200) {
          _moviesStream.addError('Failed to load');
          throw Exception('Failed to load');
        }

        final data = json.decode(resp.body);
        final movies = Movies.fromJsonList(data['data']);
        _pages = data['last_page'];
          _currentPage++;
        

        _movies.addAll(movies.items);
        moviesSink(_movies);
        _loading = !_loading;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      _moviesStream.addError('Failed to load');
      throw Exception('Failed to load');
    }
  }

  Future<List<Movie>> latest() async {
    return _process('movies/latest');
  }

  Future<List<Movie>> recommended() async {
    return _process('movies/recommended');
  }

  Future<List<Movie>> popular() async {
    return _process('movies/popular');
  }

  Future<List<Movie>> recents() async {
    return _process('movies/recents');
  }

  Future<List<Movie>> kids() async {
    return _process('movies/kids');
  }

  Future<List<Movie>> genre(int id) async {
    return _process('genres/show/' + id.toString());
  }

  Future<List<Movie>> relateds(id) async {
    return _process('movies/relateds/' + id.toString());
  }

  Future<Movie> show(String id) async {
    try {
      final resp = await http.get(_url + 'movies/show/' + id);

      if (resp.statusCode != 200) {
        throw Exception('Failed to load');
      }

      final data = json.decode(resp.body);

      final movie = Movie.fromJson(data);

      return movie;
    } catch (e) {
      throw Exception('Failed to load');
    }
  }

  Future<List<MovieVideo>> videos(String id) async {
    try {
      final resp = await http.get(_url + 'movies/videos/' + id);

      if (resp.statusCode != 200) {
        throw Exception('Failed to load');
      }

      final data = json.decode(resp.body);

      final videos = MovieVideos.fromJsonList(data);

      return videos.items;
    } catch (e) {
      throw Exception('Failed to load');
    }
  }

  void view(id) {
    http.get(_url + 'movies/view/' + id);
  }
}
