import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../helpers/lang.dart';
import '../helpers/guards.dart';
import '../widgets/material_poster_widget.dart';
import '../providers/browser_provider.dart';
import '../helpers/screen.dart';
import '../models/genre_model.dart';
import '../models/movie_model.dart';
import '../providers/genres_provider.dart';
import '../providers/movies_provider.dart';

class BrowserView extends StatefulWidget {
  _BrowserViewState createState() => _BrowserViewState();
}

class _BrowserViewState extends State<BrowserView>
    with AutomaticKeepAliveClientMixin<BrowserView> {
  final genresProvider = GenresProvider();
  BrowserProvider _browserProvider;
  final _scrollController = ScrollController();
  DateTime currentBackPressTime;
  final _refreshController = RefreshController();
  Future<List<Genre>> _futureGenres;
  Stream<List<dynamic>> _stream;

  int _view = 0;
  int _genre = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _futureGenres = genresProvider.list();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new WillPopScope(
        child: body(_view, context),
        onWillPop: () => _willPopCallback(context));
  }

  body(int _view, BuildContext context) {
    switch (_view) {
      case 0:
        return _list();
      case 1:
        return _genreview();
      default:
        return _list();
    }
  }

  FutureBuilder _list() {
    return FutureBuilder(
      future: _futureGenres,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
// guard clause: if there is an error it shows an error icon with pull to refresh
        if (snapshot.hasError) {
          return Guards.hasError(context, controller: _refreshController,
              onRefresh: () async {
            try {
              await Future.delayed(Duration(milliseconds: 1000));
              if (mounted) {
                setState(() {
                  _futureGenres = genresProvider.list();
                });
              }
              _refreshController.refreshCompleted();
            } catch (e) {
              _refreshController.refreshFailed();
            }
          });
        }

// guard clause: if there is no data or if the data is not a genre instance list, it shows a progress icon
        if (!snapshot.hasData || snapshot.data is! List<Genre>) {
          return Guards.noData();
        }

// build a listview with all genres
        final genre = snapshot.data;
        return Container(
          padding: EdgeInsets.only(top: Screen.statusbarHeight(context)),
          child: SmartRefresher(
            controller: _refreshController,
            header: WaterDropMaterialHeader(),
            onRefresh: () async {
              try {
                await Future.delayed(Duration(milliseconds: 1000));
                if (mounted) {
                  setState(() {
                    _futureGenres = genresProvider.list();
                  });
                }
                _refreshController.refreshCompleted();
              } catch (e) {
                _refreshController.refreshFailed();
              }
            },
            child: ListView.builder(
              padding: EdgeInsets.only(
                  left: 10, right: 10, top: kToolbarHeight + 10),
              itemCount: genre.length,
              itemBuilder: (context, index) {
                return Container(
                    child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: Text(genre[index].name,
                            style: TextStyle(fontSize: 18.0)),
                        trailing: Icon(Icons.arrow_forward),
                        onTap: () {
                          setState(() {
                            _genre = genre[index].id;
                            _browserProvider = BrowserProvider();
                            _browserProvider.index(_genre.toString());
                            _stream = _browserProvider.browsersStream;
                            _view = 1;
                          });
                        },
                      ),
                      Divider(),
                    ],
                  ),
                ));
              },
            ),
          ),
        );
      },
    );
  }

  void _onRefresh() async {
    // monitor network fetch
    // if failed,use refreshFailed()
    _browserProvider?.dispose();
    _browserProvider = BrowserProvider();
    _stream = _browserProvider.browsersStream;
    try {
      await _browserProvider.index(_genre.toString());
      setState(() {
        _stream = _browserProvider.browsersStream;
        _refreshController.refreshCompleted();
        _refreshController.resetNoData();
      });
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }

  void _onLoading() async {
    // monitor network fetch
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    try {
      final index = await _browserProvider.index(_genre.toString());
      if (index && mounted) {
        setState(() {});
        _refreshController.loadComplete();
      } else {
        setState(() {
          _refreshController.loadNoData();
        });
      }
    } catch (e) {
      _refreshController.loadFailed();
    }
  }

  StreamBuilder _genreview() {
    return StreamBuilder(
      stream: _stream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        // guard clause: if there is an error it shows an error icon with pull to refresh
        if (snapshot.hasError) {
          return Guards.hasError(context,
              onRefresh: () => _onRefresh(), controller: _refreshController);
        }

        // guard clause: if there is no data it shows a progress icon
        if (!snapshot.hasData) {
          return Guards.noData();
        }

        // build the main genres view
        final items = snapshot.data;
        return Container(
          padding: EdgeInsets.only(top: Screen.statusbarHeight(context)),
          child: SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            header: WaterDropMaterialHeader(),
            footer: ClassicFooter(
              loadStyle: LoadStyle.ShowWhenLoading,
              loadingText: Lang.pullToLoadLoading,
              noDataText: Lang.pullToLoadNoData,
              idleText: Lang.pullToLoadIdle,
              failedText: Lang.pullToLoadFailed,
              canLoadingText: Lang.pullToLoadRelease,
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: GridView.builder(
                controller: _scrollController,
                itemCount: items.length,
                physics: BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.0 / 3.0,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                padding: EdgeInsets.only(
                    left: 10, right: 10, top: kToolbarHeight + 10),
                itemBuilder: (BuildContext context, int index) {
                  items[index].uniqueId = '${items[index].id}-browserview';
                  return MaterialPoster(
                    heroTag: items[index].uniqueId,
                    image: items[index].getPoster(),
                    title: (items[index] is Movie)
                        ? items[index].title
                        : items[index].name,
                    hd: items[index].hd,
                    onTap: () {
                      (items[index] is Movie)
                          ? Navigator.of(context).pushNamed('movie.detail',
                              arguments: items[index])
                          : Navigator.of(context).pushNamed('serie.detail',
                              arguments: items[index]);
                    },
                  );
                }),
          ),
        );
      },
    );
  }

//avoid closing the app by pressing back, in the view of the results instead return to the list of genres. if it is in the list of genres if you close the app.
  Future<bool> _willPopCallback(BuildContext context) async {
    DateTime now = DateTime.now();
    if (_view == 1) {
      setState(() {
        _view = 0;
        _genre = 0;
        _browserProvider = null;
        _stream = null;
      });
      return false;
    }

    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 4)) {
      currentBackPressTime = now;
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(Lang.exit)));
      return Future.value(false);
    }

    return Future.value(true);
  }
}
