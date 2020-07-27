import '../helpers/parse.dart';

class Episodes {
  List<Episode> items = new List();

  Episodes();

  Episodes.fromJsonList(List<dynamic> jsonList) {
    if (jsonList == null) return;

    for (final item in jsonList) {
      final episode = new Episode.fromJson(item);
      items.add(episode);
    }
  }
}

class Episode {
  int id;
  int tmdbId;
  int seasonId;
  String name;
  String overview;
  String stillPath;
  double voteAverage;
  int voteCount;
  String airDate;
  String createdAt;
  String updatedAt;

  Episode({
    this.id,
    this.tmdbId,
    this.seasonId,
    this.name,
    this.overview,
    this.stillPath,
    this.voteAverage,
    this.voteCount,
    this.airDate,
    this.createdAt,
    this.updatedAt,
  });

  Episode.fromJson(Map<String, dynamic> json) {
    id = Parse.checkInt(json["id"]);
    tmdbId = Parse.checkInt(json["tmdb_id"]);
    seasonId = Parse.checkInt(json["season_id"]);
    name = json["name"];
    overview = json["overview"];
    stillPath = json["still_path"];
    voteAverage = Parse.checkDouble(json["vote_average"]);
    voteCount = Parse.checkInt(json["vote_count"]);
    airDate = json["air_date"];
  }

  getStill() {
    if (stillPath == null) {
      return 'http://isabelpaz.com/wp-content/themes/nucleare-pro/images/no-image-box.png';
    } else {
      return stillPath;
    }
  }
}
