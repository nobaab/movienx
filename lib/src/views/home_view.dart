import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../helpers/lang.dart';
import '../helpers/screen.dart';
import '../models/settings_model.dart';
import '../widgets/custom_logo_widget.dart';
import '../helpers/network.dart';
import '../helpers/search.dart';
import '../views/browser_view.dart';
import '../views/kids_view.dart';
import '../views/index_view.dart';
import '../views/livetv_view.dart';
import '../views/movies_view.dart';
import '../views/series_view.dart';

// HomeView is the widget that contains all the main views,
// displaying them within the scaffold controlled by the _body method

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  TabController _tabController;
  AnimationController _animationController;
  Animation<Offset> _animation;
  DateTime currentBackPressTime;
  int _currentTab = 0;
  final List<Widget> _listTabs = [
    IndexView(),
    BrowserView(),
    MoviesView(),
    SeriesView(),
    KidsView(),
    LivetvView()
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: _listTabs.length);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween<Offset>(begin: Offset(0.0, 0.0), end: Offset(0.0, -1.0))
        .animate(CurvedAnimation(
            curve: Curves.easeOut, parent: _animationController));
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final Settings settings = Provider.of<Settings>(context);
    // Check the network, if there is no connection it shows a snackbar.
    Network.check().then((onValue) => {
          if (!onValue)
            _scaffoldkey.currentState
                .showSnackBar(SnackBar(content: Text(Lang.noNetwork)))
        });

    return WillPopScope(
      onWillPop: () => _willPopCallback(context),
      child: Scaffold(
        key: _scaffoldkey,
        body: Stack(
          children: [
            NotificationListener<UserScrollNotification>(
              child: TabBarView(
                  children: _listTabs,
                  controller: _tabController,
                  physics: NeverScrollableScrollPhysics()),
              onNotification: (UserScrollNotification notification) {
                if (settings.appBarAnimation) {
                  if (notification.direction == ScrollDirection.reverse &&
                      notification.metrics.extentAfter > kToolbarHeight &&
                      notification.metrics.axis == Axis.vertical) {
                    _animationController.forward();
                  } else if (notification.direction ==
                      ScrollDirection.forward) {
                    _animationController.reverse();
                  }
                }
                return true;
              },
            ),
            _appbar(context)
          ],
        ),
        bottomNavigationBar: _bottomNavigationBar(settings),
      ),
    );
  }

// custom application menu, contains the logo in image or vector according to the option of settings and the iconbutton that run the search method.
  Widget _appbar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      width: Screen.width(context),
      child: SlideTransition(
        position: _animation,
        child: AppBar(
          titleSpacing: 10.0,
          title: Container(child: CustomLogo()),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(context: context, delegate: Search());
              },
            ),
          ],
        ),
      ),
    );
  }

// bottom navigation bar, when selecting, assign the index of the item to the _currentTab property. The _body method receives this property as an argument.
  Widget _bottomNavigationBar(Settings settings) {
    return BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (index) {
          setState(() {
            _currentTab = index;
            _tabController.animateTo(_currentTab);
            _animationController.reverse();
          });
        },
        type: BottomNavigationBarType.fixed,
        iconSize: 30.0,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), title: Text(Lang.home)),
          BottomNavigationBarItem(
              icon: Icon(Icons.menu), title: Text(Lang.browser)),
          BottomNavigationBarItem(
              icon: Icon(Icons.movie), title: Text(Lang.movies)),
          BottomNavigationBarItem(
              icon: Icon(Icons.tv), title: Text(Lang.series)),
          if (settings.kids)
            BottomNavigationBarItem(
                icon: Icon(Icons.child_care), title: Text(Lang.kids)),
          if (settings.livetv)
            BottomNavigationBarItem(
                icon: Icon(Icons.live_tv), title: Text(Lang.livetv))
        ]);
  }

  Future<bool> _willPopCallback(BuildContext context) async {
    DateTime now = DateTime.now();
    if (_currentTab != 1) {
      if (currentBackPressTime == null ||
          now.difference(currentBackPressTime) > Duration(seconds: 4)) {
        currentBackPressTime = now;
        _scaffoldkey.currentState
            .showSnackBar(SnackBar(content: Text(Lang.exit)));
        return Future.value(false);
      }
    }
    return Future.value(true);
  }
}
