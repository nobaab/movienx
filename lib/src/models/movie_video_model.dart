
import '..//helpers/parse.dart';

class MovieVideos {
  List<MovieVideo> items = new List();

  MovieVideos();

  MovieVideos.fromJsonList(List<dynamic> jsonList) {
    if (jsonList == null) return;

    for (final item in jsonList) {
      final movie = new MovieVideo.fromJson(item);
      items.add(movie);
    }
  }

}

class MovieVideo {
  int id;
  int movieId;
  String server;
  String link;
  String lang;
  bool hd;

    MovieVideo(
      {this.id,
      this.movieId,
      this.server,
      this.link,
      this.lang,
      this.hd,
      });

MovieVideo.fromJson(Map<String, dynamic> json) {
    id = Parse.checkInt(json["id"]);
    movieId = Parse.checkInt(json["movie_id"]);
    server = json["server"];
    link = json["link"];
    lang = json["lang"];
    hd = Parse.toBool(json["hd"]);
  }

}

