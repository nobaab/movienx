import '../helpers/parse.dart';

class Livetvs {
  List<Livetv> items = new List();

  Livetvs();

  Livetvs.fromJsonList(List<dynamic> jsonList) {
    if (jsonList == null) return;

    for (final item in jsonList) {
      final livetv = new Livetv.fromJson(item);
      items.add(livetv);
    }
  }
}

class Livetv {
  int id;
  String uniqueId;
  String name;
  String overview;
  String backdropPath;
  String posterPath;
  String link;

  Livetv(
      {this.id,
      this.name,
      this.overview,
      this.backdropPath,
      this.posterPath,
      this.link,
      });

  Livetv.fromJson(Map<String, dynamic> json) {
    id = Parse.checkInt(json["id"]);
    name = json["name"];
    overview = json["overview"];
    backdropPath = json["backdrop_path"];
    posterPath = json["poster_path"];
    link = json["link"];
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
