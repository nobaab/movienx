import 'package:flutter/material.dart';
import '../helpers/guards.dart';
import '../helpers/screen.dart';
import '../models/livetv_model.dart';
import '../models/movie_model.dart';
import '../models/serie_model.dart';
import '../widgets/material_poster_widget.dart';

class ScrollableItems extends StatelessWidget {
  final Future future;
  final String title;
  final ScrollController _scrollController = ScrollController();

  ScrollableItems({@required this.future, this.title = ''});

  @override
  Widget build(BuildContext context) {
     return Container(
        margin: EdgeInsets.symmetric(vertical: 5.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.all(10.0),
                  child: Text(title, style: TextStyle(fontSize: 18.0))),
              FutureBuilder(
                future: future,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
// guard clause: if there is an error it shows an error icon with tap to refresh
                  if (snapshot.hasError) {
                    return Container(
                      height: (Screen.isPortrait(context))
                          ? Screen.heigth(context) * 0.30
                          : Screen.heigth(context) * 0.70,
                      child: Guards.hasErrorWithoutRefresh(),
                    );
                  }

// guard clause: if there is no data it shows a progress icon
                  if (!snapshot.hasData) {
                    return Container(
                      height: (Screen.isPortrait(context))
                          ? Screen.heigth(context) * 0.30
                          : Screen.heigth(context) * 0.70,
                      child: Guards.noData());
                  }

// guard clause: if the list is empty, it shows a text.
                  if(snapshot.data.isEmpty){
                    return Container(height: (Screen.isPortrait(context))
                          ? Screen.heigth(context) * 0.30
                          : Screen.heigth(context) * 0.70, 
                          child: Center(child: Text('this list is empty')));
                  }

                  final items = snapshot.data;

                  return Container(
                      width: double.infinity,
                      height: (Screen.isPortrait(context))
                          ? Screen.heigth(context) * 0.30
                          : Screen.heigth(context) * 0.70,
                      child: ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: items.length,
                        itemBuilder: (BuildContext context, int index) {

                          return Container(
                              margin: EdgeInsets.symmetric(horizontal: 5.0),
                              child: AspectRatio(
                                aspectRatio: 2.0/3.0,
                                child: MaterialPoster(
                                  image: items[index].getPoster(),
                                  hd: items[index]?.hd ?? false,
                                  onTap: () {
                                    if (items[index] is Movie) {
                                      Navigator.of(context).pushNamed(
                                          'movie.detail',
                                          arguments: items[index]);
                                    }
                                    if (items[index] is Serie) {
                                      Navigator.of(context).pushNamed(
                                          'serie.detail',
                                          arguments: items[index]);
                                    }
                                    if (items[index] is Livetv) {
                                      Navigator.of(context).pushNamed(
                                          'livetv.detail',
                                          arguments: items[index]);
                                    }
                                  },
                                  title: (items[index] is Movie)
                                      ? items[index].title
                                      : items[index].name,
                                ),
                              ));
                        },
                      ));
                },
              ),
            ]));
  }
}
