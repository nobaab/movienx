
import '..//helpers/parse.dart';

class SerieVideos {
  List<SerieVideo> items = new List();

  SerieVideos();

  SerieVideos.fromJsonList(List<dynamic> jsonList) {
    if (jsonList == null) return;

    for (final item in jsonList) {
      final serie = new SerieVideo.fromJson(item);
      items.add(serie);
    }
  }

}

class SerieVideo {
  int id;
  int serieId;
  String server;
  String link;
  String lang;
  bool hd;

    SerieVideo(
      {this.id,
      this.serieId,
      this.server,
      this.link,
      this.lang,
      this.hd,
      });

SerieVideo.fromJson(Map<String, dynamic> json) {
    id = Parse.checkInt(json["id"]);
    serieId = Parse.checkInt(json["serie_id"]);
    server = json["server"];
    link = json["link"];
    lang = json["lang"];
    hd = Parse.toBool(json["hd"]);
  }

}

