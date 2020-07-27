import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../helpers/lang.dart';
import '../helpers/guards.dart';
import '../widgets/material_poster_widget.dart';
import '../helpers/screen.dart';
import '../providers/series_provider.dart';

class SeriesView extends StatefulWidget {
  @override
  _SeriesViewState createState() => _SeriesViewState();
}

class _SeriesViewState extends State<SeriesView>
    with AutomaticKeepAliveClientMixin<SeriesView> {
  SeriesProvider _seriesProvider = SeriesProvider();
  final _scrollController = ScrollController();
  final _refreshController = RefreshController();
  Stream<List<Serie>> _stream;

  void _onRefresh() async {
    // monitor network fetch
    // if failed,use refreshFailed()
    _seriesProvider?.dispose();
    _seriesProvider = SeriesProvider();
    _stream = _seriesProvider.seriesStream;
    try {
      await _seriesProvider.index();
      setState(() {
        _stream = _seriesProvider.seriesStream;
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
      final index = await _seriesProvider.index();
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
    _seriesProvider.index();
    _stream = _seriesProvider.seriesStream;
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

          // build the main series view
          final series = snapshot.data;
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
                  itemCount: series.length,
                  physics: BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2.0 / 3.0,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10),
                  padding: EdgeInsets.only(
                      left: 10, right: 10, top: kToolbarHeight + 10),
                  itemBuilder: (BuildContext context, int index) {
                    series[index].uniqueId = '${series[index].id}-seriesview';
                    return MaterialPoster(
                      heroTag: series[index].uniqueId,
                      image: series[index].getPoster(),
                      title: series[index].name,
                      hd: series[index].hd,
                      onTap: () {
                        Navigator.of(context).pushNamed('serie.detail',
                            arguments: series[index]);
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
