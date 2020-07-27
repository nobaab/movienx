import 'dart:convert';

import 'package:http/http.dart' as http;
import '../helpers/api.dart';
import '../models/episode_model.dart';
import '../models/serie_video_model.dart';
export '../models/episode_model.dart';

class EpisodesProvider {
  String _url = Api.url;

  Future<List<Episode>> getAll(id) async {
    try {
      final resp = await http.get(_url + 'series/season/' + id.toString());

      if (resp.statusCode != 200) {
        throw Exception('Failed to load');
      }

      final data = json.decode(resp.body);

      final episodes = Episodes.fromJsonList(data);

      return episodes.items;
    } catch (e) {
      throw Exception('Failed to load');
    }
  }

  Future<List<SerieVideo>> videos(id) async {
    try {
      final resp = await http.get(_url + 'series/episode/' + id.toString());

      if (resp.statusCode != 200) {
        throw Exception('Failed to load');
      }

      final data = json.decode(resp.body);

      final videos = SerieVideos.fromJsonList(data);

      return videos.items;
    } catch (e) {
      throw Exception('Failed to load');
    }
  }

  void view(id) {
    http.get(_url + 'series/view/' + id);
  }
}
