import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../helpers/lang.dart';
import '../models/settings_model.dart';
import '../providers/series_provider.dart';
import '../widgets/scrollable_items_widget.dart';
import '../providers/movies_provider.dart';
import '../widgets/carousel_movies_widget.dart';

class IndexView extends StatefulWidget {
  @override
  _IndexViewState createState() => _IndexViewState();
}

class _IndexViewState extends State<IndexView>
    with AutomaticKeepAliveClientMixin<IndexView> {
  Settings settings;
  final moviesProvider = MoviesProvider();
  final seriesProvider = SeriesProvider();
  final _refreshController = RefreshController();
  Future<List<Movie>> _futureMovieLatest;
  Future<List<Movie>> _futureMovieRecommended;
  Future<List<Movie>> _futureMoviePopular;
  Future<List<Movie>> _futureMovieRecents;
  Future<List<Serie>> _futureSerieRecommended;
  Future<List<Serie>> _futureSeriePopular;
  Future<List<Serie>> _futureSerieRecents;

  @override
  void initState() {
    super.initState();
    _futureMovieLatest = moviesProvider.latest();
    _futureMovieRecommended = moviesProvider.recommended();
    _futureMoviePopular = moviesProvider.popular();
    _futureMovieRecents = moviesProvider.recents();
    _futureSerieRecommended = seriesProvider.recommended();
    _futureSeriePopular = seriesProvider.popular();
    _futureSerieRecents = seriesProvider.recents();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SmartRefresher(
      controller: _refreshController,
      header: WaterDropMaterialHeader(),
      onRefresh: () async {
        try {
          await Future.delayed(Duration(milliseconds: 1000));
          if (mounted) {
            setState(() {
              _futureMovieLatest = moviesProvider.latest();
              _futureMovieRecommended = moviesProvider.recommended();
              _futureMoviePopular = moviesProvider.popular();
              _futureMovieRecents = moviesProvider.recents();
              _futureSerieRecommended = seriesProvider.recommended();
              _futureSeriePopular = seriesProvider.popular();
              _futureSerieRecents = seriesProvider.recents();
            });
          }
          _refreshController.refreshCompleted();
        } catch (e) {
          _refreshController.refreshFailed();
        }
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CarouselMovies(future: _futureMovieLatest),
            ScrollableItems(
                future: _futureMovieRecommended, title: Lang.recommendedMovies),
            ScrollableItems(
                future: _futureMoviePopular, title: Lang.popularMovies),
            ScrollableItems(
                future: _futureMovieRecents, title: Lang.recentlyMovies),
            ScrollableItems(
                future: _futureSerieRecommended, title: Lang.recommendedSeries),
            ScrollableItems(
                future: _futureSeriePopular, title: Lang.popularSeries),
            ScrollableItems(
                future: _futureSerieRecents, title: Lang.recentlySeries),
          ],
        ),
      ),
    );
  }
}
