import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../helpers/lang.dart';
import '../helpers/guards.dart';
import '../widgets/material_poster_widget.dart';
import '../helpers/screen.dart';
import '../providers/movies_provider.dart';

class MoviesView extends StatefulWidget {
  @override
  _MoviesViewState createState() => _MoviesViewState();
}

class _MoviesViewState extends State<MoviesView>
    with AutomaticKeepAliveClientMixin<MoviesView> {
  MoviesProvider _moviesProvider = MoviesProvider();
  final _scrollController = ScrollController();
  final _refreshController = RefreshController();
  Stream<List<Movie>> _stream;

  void _onRefresh() async {
    // monitor network fetch
    // if failed,use refreshFailed()
    _moviesProvider?.dispose();
    _moviesProvider = MoviesProvider();
    _stream = _moviesProvider.moviesStream;
    try {
      await _moviesProvider.index();
      setState(() {
        _stream = _moviesProvider.moviesStream;
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
      final index = await _moviesProvider.index();
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

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _moviesProvider.index();
    _stream = _moviesProvider.moviesStream;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      child: StreamBuilder(
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

          // build the main movies view
          final movies = snapshot.data;
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
                  itemCount: movies.length,
                  physics: BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2.0 / 3.0,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10),
                  padding: EdgeInsets.only(
                      left: 10, right: 10, top: kToolbarHeight + 10),
                  itemBuilder: (BuildContext context, int index) {
                    movies[index].uniqueId = '${movies[index].id}-moviesview';
                    return MaterialPoster(
                      heroTag: movies[index].uniqueId,
                      image: movies[index].getPoster(),
                      title: movies[index].title,
                      hd: movies[index].hd,
                      onTap: () {
                        Navigator.of(context).pushNamed('movie.detail',
                            arguments: movies[index]);
                      },
                    );
                  }),
            ),
          );
        },
      ),
    );
  }
}
