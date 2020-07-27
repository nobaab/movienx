import '..//helpers/parse.dart';

import '../models/season_model.dart';

class Series {
  List<Serie> items = new List();

  Series();

  Series.fromJsonList(List<dynamic> jsonList) {
    if (jsonList == null) return;

    for (final item in jsonList) {
      final serie = new Serie.fromJson(item);
      items.add(serie);
    }
  }
}

class Serie {
  int id;
  int tmdbId;
  String uniqueId;
  String name;
  String overview;
  String backdropPath;
  String posterPath;
  String previewPath;
  double voteAverage;
  double voteCount;
  double popularity;
  List genres;
  bool hd;
  String firstAirDate;
  List<Season> seasons;

  Serie(
      {this.id,
      this.tmdbId,
      this.name,
      this.overview,
      this.backdropPath,
      this.posterPath,
      this.previewPath,
      this.voteAverage,
      this.voteCount,
      this.popularity,
      this.genres,
      this.hd,
      this.firstAirDate});

  Serie.fromJson(Map<String, dynamic> json) {
    id = Parse.checkInt(json["id"]);
    tmdbId = Parse.checkInt(json["tmdb_id"]);
    name = json["name"];
    overview = json["overview"];
    backdropPath = json["backdrop_path"];
    posterPath = json["poster_path"];
    previewPath = json["preview_path"];
    voteAverage = Parse.checkDouble(json["vote_average"]);
    voteAverage = Parse.checkDouble(json["vote_count"]);
    voteAverage = Parse.checkDouble(json["popularity"]);
    genres = json['genreslist'];
    hd = Parse.toBool(json["hd"]);
    firstAirDate = json["first_air_date"];
    seasons = Seasons.fromJsonList(json["seasons"]).items;
  }

  getPoster() {
    if (posterPath == null) {
      return 'http://isabelpaz.com/wp-content/themes/nucleare-pro/images/no-image-box.png';
    } else {
      return posterPath;
    }
  }

  getBackdrop() {
    if (backdropPath == null) {
      return 'http://isabelpaz.com/wp-content/themes/nucleare-pro/images/no-image-box.png';
    } else {
      return backdropPath;
    }
  }

}
