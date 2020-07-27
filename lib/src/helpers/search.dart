import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import '../helpers/screen.dart';
import '../widgets/material_poster_widget.dart';
import '../helpers/guards.dart';
import '../models/livetv_model.dart';
import '../models/serie_model.dart';
import '../models/movie_model.dart';
import '../providers/movies_provider.dart';
import '../providers/search_provider.dart';

class Search extends SearchDelegate {
  final moviesProvider = new MoviesProvider();
  final searchProvider = new SearchProvider();

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      inputDecorationTheme: theme.inputDecorationTheme,
      backgroundColor: theme.backgroundColor,
      primaryColor: theme.appBarTheme.color,
      primaryIconTheme: theme.appBarTheme.iconTheme,
      brightness: theme.brightness,
      primaryTextTheme: theme.primaryTextTheme,
      iconTheme: theme.iconTheme,
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.search),
        onPressed: () {
          showResults(context);
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
        return FutureBuilder(
      future: searchProvider.index(query),
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
// guard clause: if there is an error it shows an error icon
        if (snapshot.hasError) {
          return Guards.hasErrorWithoutRefresh();
        }

// guard clause: if there is no data it shows a progress icon
        if (!snapshot.hasData) {
          return Guards.noData();
        }

// build a GridView with all results
        List results = snapshot.data;
        return Container(
              padding: EdgeInsets.only(top: Screen.statusbarHeight(context)),
              child: GridView.builder(
                  itemCount: results.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2.0/3.0,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10),
                  padding: EdgeInsets.only(
                      left: 10, right: 10, top: 10),
                  itemBuilder: (BuildContext context, int index) {
                    results[index].uniqueId = '${results[index].id}-resultsview';
                    return MaterialPoster(
                      heroTag: results[index].uniqueId,
                      image: results[index].getPoster(),
                      title: (results[index] is Movie) ? results[index].title : results[index].name,
                      onTap: () {
                        if (results[index] is Movie) {
                          Navigator.of(context)
                              .pushNamed('movie.detail', arguments: results[index]);
                        }
                        if (results[index] is Serie) {
                          Navigator.of(context)
                              .pushNamed('serie.detail', arguments: results[index]);
                        }
                        if (results[index] is Livetv) {
                          Navigator.of(context).pushNamed('livetv.detail',
                              arguments: results[index]);
                        }
                      },
                    );
                  }),
            );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Container();
    }

    return FutureBuilder(
      future: searchProvider.index(query),
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
// guard clause: if there is an error it shows an error icon
        if (snapshot.hasError) {
          return Guards.hasErrorWithoutRefresh();
        }

// guard clause: if there is no data it shows a progress icon
        if (!snapshot.hasData) {
          return Guards.noData();
        }

// build a listview with all suggestions
        List suggestions = snapshot.data;
        return Container(
              padding: EdgeInsets.only(top: 10),
              child: ListView.builder(
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  suggestions[index].uniqueId = '${suggestions[index].id}-suggestion-$index';
                  return Column(children: <Widget>[
                    ListTile(
                      leading: Container(
                        child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: TransitionToImage(
                                image: AdvancedNetworkImage(
                                    suggestions[index].getBackdrop(),
                                    useDiskCache: true),
                                fit: BoxFit.cover,
                                placeholder: Container(
                                  width: 100,
                                  height: 100,
                                    child: Center(child: Icon(Icons.refresh))),
                                enableRefresh: true,
                                loadingWidget: Container(
                                  width: 100,
                                  height: 100,
                                    child: Center(child: CircularProgressIndicator())),
                              ),
                            ),
                      ),
                      title: Text(
                            (suggestions[index] is Movie)
                                ? suggestions[index].title
                                : suggestions[index].name,
                                overflow: TextOverflow.ellipsis,
                          ),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () {
                        if (suggestions[index] is Movie) {
                          Navigator.of(context)
                              .pushNamed('movie.detail', arguments: suggestions[index]);
                        }
                        if (suggestions[index] is Serie) {
                          Navigator.of(context)
                              .pushNamed('serie.detail', arguments: suggestions[index]);
                        }
                        if (suggestions[index] is Livetv) {
                          Navigator.of(context).pushNamed('livetv.detail',
                              arguments: suggestions[index]);
                        }
                      },
                    ),
                    Divider()
                  ]);
                },
              ),
            );
      },
    );
  }
}
