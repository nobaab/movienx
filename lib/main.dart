import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import './src/helpers/ads.dart';
import './src/helpers/guards.dart';
import './src/helpers/notifications.dart';
import './src/models/settings_model.dart';
import './src/providers/settings_provider.dart';
import './src/views/home_view.dart';
import './src/views/livetv_detail_view.dart';
import './src/views/movie_detail_view.dart';
import './src/views/serie_detail_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsProvider = SettingsProvider();
  final settings = await settingsProvider.index();

  if (settings == null) {
    runApp(Guards.failed(onRefresh: () {
      main();
    }));
  }

  runApp(StreamApp(settings));
}

class StreamApp extends StatefulWidget {
  final Settings settings;
  StreamApp(this.settings);
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<StreamApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final analytics = FirebaseAnalytics();

  @override
  void initState() {
    timeDilation = 2;
    Notifications.init(_navigatorKey);
    Ads.init(settings: widget.settings);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<Settings>.value(
      value: widget.settings,
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        initialRoute: 'home.view',
        routes: {
          'home.view': (context) => HomeView(),
          'movie.detail': (context) => MovieDetail(),
          'serie.detail': (context) => SerieDetail(),
          'livetv.detail': (context) => LivetvDetail(),
        },
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
        title: widget.settings.appName,
        color: widget.settings.appHeaderRecentTaskColor,
        theme: ThemeData(
          brightness: (widget.settings.appColorDark) ? Brightness.dark : Brightness.light,
          primaryColor: widget.settings.appPrimaryColor,
          splashColor: widget.settings.appSplashColor.withOpacity(0.5),
          accentColor: widget.settings.appPrimaryColor,
          buttonColor: widget.settings.appButtonsColor,
          dialogTheme: DialogTheme(
            backgroundColor: widget.settings.appBackgroundColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
          ),
          backgroundColor: widget.settings.appBackgroundColor,
          canvasColor: widget.settings.bottomNavigationBarColor,
          bottomAppBarColor: widget.settings.bottomNavigationBarColor,
          appBarTheme: AppBarTheme(
            color: widget.settings.appBarColor
                .withOpacity(widget.settings.appBarOpacity),
            iconTheme: IconThemeData(color: widget.settings.appBarIconsColor),
            actionsIconTheme:
                IconThemeData(color: widget.settings.appBarIconsColor),
            textTheme: TextTheme(
                title: TextStyle(color: widget.settings.appBarTitleColor)),
          ),
          iconTheme: IconThemeData(color: widget.settings.iconsColor),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: widget.settings.appBackgroundColor.withOpacity(0.5),
            contentTextStyle: TextStyle(color: widget.settings.textColor),
          ),
          scaffoldBackgroundColor: widget.settings.appBackgroundColor,
          inputDecorationTheme: InputDecorationTheme(
              hintStyle: TextStyle(color: widget.settings.textColor)),
          textTheme: Theme.of(context).textTheme.apply(
                bodyColor: widget.settings.textColor,
                displayColor: widget.settings.textColor,
              ),
        ),
      ),
    );
  }
}
