import '../helpers/parse.dart';

class Seasons {
  List<Season> items = new List();

  Seasons();

  Seasons.fromJsonList(List<dynamic> jsonList) {
    if (jsonList == null) return;

    for (final item in jsonList) {
      final season = new Season.fromJson(item);
      items.add(season);
    }
  }
}

class Season {
  int id;
  int tmdbId;
  int serieId;
  String name;
  String overview;
  String posterPath;
  int seasonNumber;
  String airDate;

  Season(
      {this.id,
      this.tmdbId,
      this.name,
      this.overview,
      this.posterPath,
      this.seasonNumber,
      this.airDate});

  Season.fromJson(Map<String, dynamic> json) {
    id = Parse.checkInt(json["id"]);
    tmdbId = Parse.checkInt(json["tmdb_id"]);
    serieId = Parse.checkInt(json["serie_id"]);
    name = json["name"];
    overview = json["overview"];
    posterPath = json["poster_path"];
    seasonNumber = Parse.checkInt(json["season_number"]);
    airDate = json["air_date"];
  }

  getPoster() {
    if (posterPath == null) {
      return 'http://isabelpaz.com/wp-content/themes/nucleare-pro/images/no-image-box.png';
    } else {
      return posterPath;
    }
  }

}
