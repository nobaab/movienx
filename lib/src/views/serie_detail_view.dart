import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import '../helpers/lang.dart';
import '../views/video_view.dart';
import '../providers/series_provider.dart';
import '../widgets/material_poster_widget.dart';
import '../widgets/custom_poster.dart';
import '../helpers/ads.dart';
import '../helpers/guards.dart';
import '../models/season_model.dart';
import '../widgets/custom_sliver_appbar_widget.dart';
import '../helpers/screen.dart';
import '../helpers/network.dart';
import '../models/serie_model.dart';
import '../providers/episodes_provider.dart';

class SerieDetail extends StatefulWidget {
  @override
  _SerieDetailState createState() => _SerieDetailState();
}

class _SerieDetailState extends State<SerieDetail>
    with SingleTickerProviderStateMixin {
  GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  Season _selectedSeason;
  List<DropdownMenuItem<Season>> _dropdownMenuItems;
  final episodesProvider = EpisodesProvider();
  final scrollController = ScrollController();
  final SeriesProvider _seriesProvider = SeriesProvider();
  TabController _tabBarController;

  List<DropdownMenuItem<Season>> buildDropdownMenuItems(List seasons) {
    List<DropdownMenuItem<Season>> items = List();
    for (Season season in seasons) {
      items.add(
        DropdownMenuItem(
          value: season,
          child: Text(season.name, style: Theme.of(context).textTheme.title),
        ),
      );
    }
    return items;
  }

  @override
  void initState() {
    _tabBarController = TabController(
      length: 3,
      vsync: this,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Serie serie = ModalRoute.of(context).settings.arguments;
    if (_selectedSeason == null) {
      _dropdownMenuItems = buildDropdownMenuItems(serie.seasons);
      _selectedSeason = _dropdownMenuItems[0].value;
    }

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
          controller: scrollController,
          slivers: <Widget>[
            CustomSliverAppBar(title: serie.name, image: serie.getBackdrop()),
            SliverList(
                delegate: SliverChildListDelegate([
              Ads.responsive(context),
              _seriePoster(serie),
              _overview(serie.overview ?? ''),
              Divider(),
              _selectSeason(),
              TabBar(
                controller: _tabBarController,
                onTap: (int) => setState(() {}),
                tabs: <Widget>[
                  Tab(text: Lang.episodes),
                  Tab(text: Lang.overview),
                  Tab(text: Lang.relateds),
                ],
              ),
              _widget(serie)
            ])),
          ],
        ));
  }

  Widget _widget(serie) {
    if (_tabBarController.index == 1) {
      return _overview(_selectedSeason.overview);
    } else if (_tabBarController.index == 2) {
      return _relateds(serie);
    } else {
      return _episodesView();
    }
  }

  Widget _seriePoster(Serie serie) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Row(
        children: <Widget>[
          CustomPoster(
            heroTag: serie.uniqueId,
            image: serie.getPoster(),
          ),
          SizedBox(width: 20.0),
          Flexible(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    serie.genres
                        .toString()
                        .replaceAll(RegExp(r'\['), "")
                        .replaceAll(RegExp(r'\]'), "") ?? '',
                  ),
                  Text(serie.firstAirDate ?? '', style: TextStyle(fontSize: 18.0)),
                  Text('${serie.seasons.length.toString() ?? 0} Seasons',
                      style: TextStyle(fontSize: 18.0)),
                  _voteAverage(serie),
                  (serie.previewPath != null)
                      ? RaisedButton.icon(
                          icon: Icon(Icons.play_arrow),
                          label: Text(
                            Lang.preview,
                          ),
                          color: Colors.redAccent,
                          onPressed: () {
                            Ads.interstitialShow();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    VideoView(serie.previewPath)));
                          })
                      : Container()
                ]),
          )
        ],
      ),
    );
  }

  Widget _voteAverage(Serie serie) {
    List<Widget> icons = List();
    final average = (serie.voteAverage ?? 1 / 2).round();
    for (var i = 0; i < 5; i++) {
      if (average > i) {
        icons.add(Icon(Icons.star));
      } else {
        icons.add(Icon(Icons.star_border));
      }
    }
    return Row(children: icons);
  }

  Widget _overview(String overview) {
    if (overview == null) {
      return Container(
        height: Screen.heigth(context) * 0.4,
        padding: EdgeInsets.all(15.0),
        child: Text(Lang.noInformation),
      );
    }
    return Container(
      padding: EdgeInsets.all(15.0),
      child: Text(overview,
          style: TextStyle(fontSize: 18.0), textAlign: TextAlign.justify),
    );
  }

  Widget _selectSeason() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            width: Screen.width(context) * 0.40,
            child: DropdownButton(
              isExpanded: true,
              value: _selectedSeason,
              items: _dropdownMenuItems,
              onChanged: (Season season) {
                setState(() {
                  _selectedSeason = season;
                });
              },
            ),
          ),
          CustomPoster(
            heroTag: _selectedSeason.id.toString(),
            image: _selectedSeason.getPoster(),
          ),
        ],
      ),
    );
  }

  Widget _episodesView() {
    return FutureBuilder(
      future: episodesProvider.getAll(_selectedSeason.id),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
// guard clause: if there is an error it shows an error icon with tap to refresh
        if (snapshot.hasError) {
          return Guards.hasErrorWithTap(onTap: () async {
            setState(() {});
          });
        }

// guard clause: if there is no data it shows a progress icon
        if (!snapshot.hasData) {
          return Container(
            height: Screen.heigth(context) * 0.5,
            child: Guards.noData(),
          );
        }

        final episodes = snapshot.data;

        return Container(
          child: ListView.separated(
            padding: EdgeInsets.only(bottom: 20.0),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: episodes.length,
            separatorBuilder: (BuildContext context, int index) => Divider(),
            itemBuilder: (context, i) {
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: TransitionToImage(
                    height: 52,
                    width: 92,
                    image: AdvancedNetworkImage(episodes[i].getStill(),
                        useDiskCache: true),
                    fit: BoxFit.cover,
                    placeholder: Container(
                        height: 160,
                        width: 100,
                        child: Center(
                          child: Icon(Icons.refresh),
                        )),
                    enableRefresh: true,
                    loadingWidget: Container(
                        height: 52,
                        width: 92,
                        child: Center(
                          child: CircularProgressIndicator(),
                        )),
                  ),
                ),
                title: Text(episodes[i].name ?? '',
                    overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  episodes[i].overview ?? '',
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Icon(Icons.play_circle_outline),
                onTap: () {
                  _episodeDialog(context, episodes[i]);
                },
                onLongPress: () {
                  _detailDialog(context,
                      name: episodes[i].name, overview: episodes[i].overview);
                },
              );
            },
          ),
        );
      },
    );
  }

  void _episodeDialog(BuildContext context, Episode episode) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              episode.name ?? '',
              overflow: TextOverflow.ellipsis,
            ),
            content: _videosView(episode),
          );
        });
  }

  void _detailDialog(BuildContext context, {String name, String overview}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(name ?? '', overflow: TextOverflow.clip),
              content: Text(
                overview ?? Lang.noInformation,
                overflow: TextOverflow.clip,
              ));
        });
  }

  Widget _videosView(Episode episode) {
    return FutureBuilder(
      future: episodesProvider.videos(episode.id),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
// guard clause: if there is an error it shows an error icon
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
                    child: Column(children: <Widget>[
                      ListTile(
                        title: Text(videos[i].server ?? '',
                            overflow: TextOverflow.ellipsis),
                        subtitle: Text(videos[i].lang ?? '',
                            overflow: TextOverflow.ellipsis),
                        trailing: Icon(Icons.play_circle_outline),
                        onTap: () {
                          Ads.interstitialShow();
                          episodesProvider.view(episode.id.toString());
                          Navigator.of(context).pop();
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => VideoView(videos[i].link)));
                        },
                      ),
                      Divider()
                    ]));
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

  Widget _relateds(Serie serie) {
    return FutureBuilder(
      future: _seriesProvider.relateds(serie.id.toString()),
      builder: (BuildContext context, AsyncSnapshot<List<Serie>> snapshot) {
        // guard clause: if there is an error it shows an error icon with tap to refresh
        if (snapshot.hasError) {
          return Guards.hasErrorWithTap(onTap: () async {
            setState(() {});
          });
        }

// guard clause: if there is no data it shows a progress icon
        if (!snapshot.hasData) {
          return Container(
            height: Screen.heigth(context) * 0.5,
            child: Guards.noData(),
          );
        }
        final series = snapshot.data;
        return GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount: series.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.0 / 3.0,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10),
            padding: EdgeInsets.only(left: 10, right: 10, top: 10),
            itemBuilder: (BuildContext context, int index) {
              series[index].uniqueId = '${series[index].id}-serieview';
              return MaterialPoster(
                heroTag: series[index].uniqueId,
                image: series[index].getPoster(),
                title: series[index].name,
                hd: series[index].hd,
                onTap: () {
                  Navigator.of(context)
                      .pushNamed('serie.detail', arguments: series[index]);
                },
              );
            });
      },
    );
  }
}
