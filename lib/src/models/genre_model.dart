import '../helpers/parse.dart';

class Genres {
  List<Genre> items = new List();

  Genres();

  Genres.fromJsonList(List<dynamic> jsonList) {
    if (jsonList == null) return;

    for (final item in jsonList) {
      final genre = new Genre.fromJson(item);
      items.add(genre);
    }
  }

}

class Genre {
  int id;
  String name;

    Genre(
      {this.id,
      this.name,
      });

Genre.fromJson(Map<String, dynamic> json) {
    id = Parse.checkInt(json["id"]);
    name = json["name"];
  }

}