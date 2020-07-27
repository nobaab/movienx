import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../providers/livetv_provider.dart';
import '../providers/movies_provider.dart';
import '../providers/series_provider.dart';

class Notifications {
  static final _moviesProvider = MoviesProvider();
  static final _seriesProvider = SeriesProvider();
  static final _livetvProvider = LivetvProvider();

  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  static init(GlobalKey<NavigatorState> navigatorKey) {
    //requesting permissions to the device to receive push notifications
    _firebaseMessaging.requestNotificationPermissions();

    // subscribe all customers to a topic to send global notifications.
    _firebaseMessaging.subscribeToTopic('all');

    _firebaseMessaging.configure(
        // behavior when clicking on a push notification with the application without starting
        onLaunch: (response) async {
      final data = (Platform.isIOS) ? response : response['data'];
      if (data['instanceof'] == 'movie') {
        _moviesProvider.show(data['id'].toString()).then((movie) => {
              movie.uniqueId = '${movie.id}-' + 'onLaunch',
              navigatorKey.currentState
                  .pushNamed('movie.detail', arguments: movie)
            });
      }
      if (data['instanceof'] == 'serie') {
        _seriesProvider.show(data['id'].toString()).then((serie) => {
              serie.uniqueId = '${serie.id}-' + 'onLaunch',
              navigatorKey.currentState
                  .pushNamed('serie.detail', arguments: serie)
            });
      }
      if (data['instanceof'] == 'livetv') {
        _livetvProvider.show(data['id'].toString()).then((livetv) => {
              livetv.uniqueId = '${livetv.id}-' + 'onLaunch',
              navigatorKey.currentState
                  .pushNamed('livetv.detail', arguments: livetv)
            });
      }
    },
        // behavior when clicking on a push notification with the background application
        onResume: (response) async {
      final data = (Platform.isIOS) ? response : response['data'];
      if (data['instanceof'] == 'movie') {
        _moviesProvider.show(data['id'].toString()).then((movie) => {
              movie.uniqueId = '${movie.id}-' + 'onResume',
              navigatorKey.currentState
                  .pushNamed('movie.detail', arguments: movie)
            });
      }
      if (data['instanceof'] == 'serie') {
        _seriesProvider.show(data['id'].toString()).then((serie) => {
              serie.uniqueId = '${serie.id}-' + 'onResume',
               navigatorKey.currentState
                  .pushNamed('serie.detail', arguments: serie)
            });
      }
      if (data['instanceof'] == 'livetv') {
        _livetvProvider.show(data['id'].toString()).then((livetv) => {
              livetv.uniqueId = '${livetv.id}-' + 'onResume',
              navigatorKey.currentState
                  .pushNamed('livetv.detail', arguments: livetv)
            });
      }
    });
  }
}
