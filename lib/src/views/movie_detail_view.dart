import 'package:flutter/material.dart';
import '../helpers/lang.dart';
import '../views/video_view.dart';
import '../widgets/custom_poster.dart';
import '../helpers/ads.dart';
import '../helpers/guards.dart';
import '../widgets/scrollable_items_widget.dart';
import '../widgets/custom_sliver_appbar_widget.dart';
import '../helpers/network.dart';
import '../helpers/screen.dart';
import '../providers/movies_provider.dart';
import '../models/movie_model.dart';

class MovieDetail extends StatefulWidget {
  @override
  _MovieDetailState createState() => _MovieDetailState();
}

class _MovieDetailState extends State<MovieDetail> {
  final moviesProvider = MoviesProvider();
  final scrollController = ScrollController();
  GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final Movie movie = ModalRoute.of(context).settings.arguments;
// Check the network, if there is no connection it shows a snackbar.
    Network.check().then((onValue) => {
          if (!onValue)
            _scaffoldkey.currentState.showSnackBar(
                new SnackBar(content: Text(Lang.noNetwork)))
        });
    Ads.interstitialLoad(context);

    return Scaffold(
        key: _scaffoldkey,
        body: CustomScrollView(
          slivers: <Widget>[
            CustomSliverAppBar(title: movie.title, image: movie.getBackdrop()),
            SliverList(
                delegate: SliverChildListDelegate([
              Ads.responsive(context),
              _moviePoster(movie),
              _movieOverview(movie),
              Divider(),
              _relateds(movie),
            ]))
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.play_arrow),
          onPressed: () {
            _serversDialog(context, movie);
          },
        ));
  }

  Widget _moviePoster(Movie movie) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Row(
        children: <Widget>[
          CustomPoster(
            heroTag: movie.uniqueId,
            image: movie.getPoster(),
          ),
          SizedBox(width: 20.0),
          Flexible(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    movie.genres
                        .toString()
                        .replaceAll(RegExp(r'\['), "")
                        .replaceAll(RegExp(r'\]'), "") ?? '',
                  ),
                  Text(movie.releaseDate ?? '', style: TextStyle(fontSize: 18.0)),
                  _voteAverage(movie),
                  (movie.previewPath != null)
                      ? RaisedButton.icon(
                          icon: Icon(Icons.play_arrow),
                          label: Text(
                            Lang.preview,
                          ),
                          onPressed: () {
                            Ads.interstitialShow();
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => VideoView(movie.previewPath)));
                          })
                      : Container()
                ]),
          )
        ],
      ),
    );
  }

  Widget _voteAverage(Movie movie) {
    List<Widget> icons = List();
    final average = (movie.voteAverage ?? 1 / 2).round();
    for (var i = 0; i < 5; i++) {
      if (average > i) {
        icons.add(Icon(Icons.star));
      } else {
        icons.add(Icon(Icons.star_border));
      }
    }
    return Row(children: icons);
  }

  Widget _movieOverview(Movie movie) {
    return Container(
      padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
      child: Text(movie.overview ?? '',
          style: TextStyle(fontSize: 18.0), textAlign: TextAlign.justify),
    );
  }

  Widget _relateds(Movie movie) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: ScrollableItems(
        future: moviesProvider.relateds(movie.id),
        title: Lang.relateds,
      ),
    );
  }

  Future<Widget> _serversDialog(BuildContext context, Movie movie) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              movie.title ?? '',
              overflow: TextOverflow.ellipsis,
            ),
            content: _videosView(movie),
          );
        });
  }

  Widget _videosView(Movie movie) {
    return FutureBuilder(
      future: moviesProvider.videos(movie.id.toString()),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
// guard clause: if there is an error it shows an refresh icon
        if (snapshot.hasError) {
          return Guards.hasErrorWithoutRefresh();
        }

// guard clause: if there is no data it shows a progress icon
        if (!snapshot.hasData) {
          return Container(
              width: Screen.width(context) * 0.50,
              height: Screen.heigth(context) * 0.25,
              child: Guards.noData());
        }

        final videos = snapshot.data;
        if (videos.length > 0) {
          return Container(
            width: Screen.width(context) * 0.50,
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: ListView.builder(
              controller: scrollController,
              shrinkWrap: true,
              itemCount: videos.length,
              itemBuilder: (context, i) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: Text(videos[i].server,
                            overflow: TextOverflow.ellipsis),
                        subtitle: Text(videos[i].lang ?? '',
                            overflow: TextOverflow.ellipsis),
                        trailing: Icon(Icons.play_circle_outline),
                        onTap: () {
                          Ads.interstitialShow();
                          moviesProvider.view(movie.id.toString());
                          Navigator.of(context).pop();
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => VideoView(videos[i].link)));
                        },
                      ),
                      Divider()
                    ],
                  ),
                );
              },
            ),
          );
        } else {
          return Container(
              width: Screen.width(context) * 0.50,
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                Lang.noServers,
                overflow: TextOverflow.clip,
              ));
        }
      },
    );
  }
}
