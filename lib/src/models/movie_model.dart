import '..//helpers/parse.dart';

class Movies {
  List<Movie> items = new List();

  Movies();

  Movies.fromJsonList(List<dynamic> jsonList) {
    if (jsonList == null) return;

    for (final item in jsonList) {
      final movie = new Movie.fromJson(item);
      items.add(movie);
    }
  }
}

class Movie {
  int id;
  int tmdbId;
  String uniqueId;
  String title;
  String overview;
  String backdropPath;
  String posterPath;
  String previewPath;
  double voteAverage;
  List genres;
  bool hd;
  String releaseDate;

  Movie(
      {this.id,
      this.tmdbId,
      this.title,
      this.overview,
      this.backdropPath,
      this.posterPath,
      this.previewPath,
      this.voteAverage,
      this.genres,
      this.hd,
      this.releaseDate});

  Movie.fromJson(Map<String, dynamic> json) {
    id = Parse.checkInt(json["id"]);
    tmdbId = Parse.checkInt(json["tmdb_id"]);
    title = json["title"];
    overview = json["overview"];
    backdropPath = json["backdrop_path"];
    posterPath = json["poster_path"];
    previewPath = json["preview_path"];
    voteAverage = Parse.checkDouble(json["vote_average"]);
    genres = json['genreslist'];
    hd = Parse.toBool(json["hd"]);
    releaseDate = json["release_date"];
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
