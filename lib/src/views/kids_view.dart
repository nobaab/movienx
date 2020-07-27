import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../helpers/lang.dart';
import '../helpers/guards.dart';
import '../widgets/material_poster_widget.dart';
import '../helpers/screen.dart';
import '../providers/kids_provider.dart';

class KidsView extends StatefulWidget {
  @override
  _KidsViewState createState() => _KidsViewState();
}

class _KidsViewState extends State<KidsView>
    with AutomaticKeepAliveClientMixin<KidsView> {
  KidsProvider _kidsProvider = KidsProvider();
  final _scrollController = ScrollController();
  final _refreshController = RefreshController();
  Stream<List<dynamic>> _stream;

  void _onRefresh() async {
    // monitor network fetch
    // if failed,use refreshFailed()
    _kidsProvider?.dispose();
    _kidsProvider = KidsProvider();
    _stream = _kidsProvider.kidsStream;
    try {
      await _kidsProvider.index();
      setState(() {
        _stream = _kidsProvider.kidsStream;
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
      final index = await _kidsProvider.index();
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
    _kidsProvider.index();
    _stream = _kidsProvider.kidsStream;
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
          final kids = snapshot.data;
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
                  itemCount: kids.length,
                  physics: BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2.0 / 3.0,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10),
                  padding: EdgeInsets.only(
                      left: 10, right: 10, top: kToolbarHeight + 10),
                  itemBuilder: (BuildContext context, int index) {
                    kids[index].uniqueId = '${kids[index].id}-kidsview';
                    return MaterialPoster(
                      heroTag: kids[index].uniqueId,
                      title: (kids[index] is Movie)
                          ? kids[index].title
                          : kids[index].name,
                      image: kids[index].getPoster(),
                      hd: kids[index].hd,
                      onTap: () {
                        (kids[index] is Movie)
                            ? Navigator.of(context).pushNamed('movie.detail',
                                arguments: kids[index])
                            : Navigator.of(context).pushNamed('serie.detail',
                                arguments: kids[index]);
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
