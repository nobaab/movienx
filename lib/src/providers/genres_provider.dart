import 'dart:convert';

import 'package:http/http.dart' as http;
import '../helpers/api.dart';
import '../models/genre_model.dart';

class GenresProvider {
  String _url = Api.url;

  Future<List<Genre>> list() async {
    try {
    final resp = await http.get(_url + 'genres/list');

    if (resp.statusCode != 200) {
      throw Exception('Failed to load');
    }
    
    final data = json.decode(resp.body);

    final genres = Genres.fromJsonList(data);

    return genres.items;
  } catch (e) {
        throw Exception('Failed to load');
      }
  }
}
