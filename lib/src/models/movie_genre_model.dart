import '../helpers/parse.dart';

class MovieGenres {
  List<MovieGenre> items = new List();

  MovieGenres();

  MovieGenres.fromJsonList(List<dynamic> jsonList) {
    if (jsonList == null) return;

    for (final item in jsonList) {
      final genre = new MovieGenre.fromJson(item);
      items.add(genre);
    }
  }

}

class MovieGenre {
  int id;
  String name;

    MovieGenre(
      {this.id,
      this.name,
      });

MovieGenre.fromJson(Map<String, dynamic> json) {
    id = Parse.checkInt(json["id"]);
    name = json["name"];
  }

}

