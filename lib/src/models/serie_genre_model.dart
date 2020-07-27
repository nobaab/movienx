import '../helpers/parse.dart';

class SerieGenres {
  List<SerieGenre> items = new List();

  SerieGenres();

  SerieGenres.fromJsonList(List<dynamic> jsonList) {
    if (jsonList == null) return;

    for (final item in jsonList) {
      final genre = new SerieGenre.fromJson(item);
      items.add(genre);
    }
  }

}

class SerieGenre {
  int id;
  String name;

    SerieGenre(
      {this.id,
      this.name,
      });

SerieGenre.fromJson(Map<String, dynamic> json) {
    id = Parse.checkInt(json["id"]);
    name = json["name"];
  }

}