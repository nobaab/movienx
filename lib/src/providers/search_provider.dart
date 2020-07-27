import 'dart:convert';

import 'package:http/http.dart' as http;
import '../helpers/api.dart';
import '../models/livetv_model.dart';
import '../models/movie_model.dart';
import '../models/serie_model.dart';

class SearchProvider {
  String _url = Api.url;

  Future<List> index(String query) async {
    try {
      final resp = await http.get(_url + 'search/' + query);

      if (resp.statusCode != 200) {
        throw Exception('Failed to load');
      }

      final data = json.decode(resp.body);

      final movies = Movies.fromJsonList(data['movies']);
      final series = Series.fromJsonList(data['series']);
      final livetvs = Livetvs.fromJsonList(data['livetvs']);

      final results = [...movies.items, ...series.items, ...livetvs.items]
          .toList()
            ..shuffle();

      return results;
    } catch (e) {
      throw Exception('Failed to load');
    }
  }
}
