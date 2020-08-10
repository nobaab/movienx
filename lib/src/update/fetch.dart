import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

//import 'package:permission_handler/permission_handler.dart';
import 'package:r_upgrade/r_upgrade.dart';

const version = 1;

void main() => runApp(UpdateFetch());

enum UpgradeMethod {
  all,
  hot,
  increment,
}

class UpdateFetch extends StatefulWidget {
  @override
  _UpdateFetchState createState() => _UpdateFetchState();
}

class _UpdateFetchState extends State<UpdateFetch> {
  int id;
  bool isAutoRequestInstall = false;

  UpgradeMethod upgradeMethod;

  GlobalKey<ScaffoldState> _state = GlobalKey();

  String iosVersion = "";

  @override
  void initState() {
    super.initState();
    RUpgrade.setDebug(true);
  }

  Widget _buildMultiPlatformWidget() {
    if (Platform.isAndroid) {
      return _buildAndroidPlatformWidget();
    } else if (Platform.isIOS) {
      return _buildIOSPlatformWidget();
    } else {
      return Container(
        child: Text('Sorry, your platform is not support'),
      );
    }
  }

  Widget _buildIOSPlatformWidget() => ListView(
        children: <Widget>[],
      );

  Widget _buildAndroidPlatformWidget() => ListView(
        children: <Widget>[
          _buildDownloadWindow(),
          Divider(),
          ListTile(
            title: Text(_getAppBarText()),
          ),
          ListTile(
            title: Text('Start full update'),
            onTap: () async {
              if (upgradeMethod != null) {
                _state.currentState
                    .showSnackBar(SnackBar(content: Text(getUpgradeMethod())));
                return;
              }

//              if (!await canReadStorage()) return;
              id = await RUpgrade.upgrade('http://149.129.55.165/movienx.apk',
                  fileName: 'MovienX.apk',
                  isAutoRequestInstall: isAutoRequestInstall,
                  notificationStyle: NotificationStyle.speechAndPlanTime,
                  useDownloadManager: false);
              upgradeMethod = UpgradeMethod.all;
              setState(() {});
            },
          ),
          ListTile(
            title: Text('Install full updates'),
            onTap: () async {
              if (upgradeMethod != UpgradeMethod.all && upgradeMethod != null) {
                _state.currentState.showSnackBar(SnackBar(
                    content: Text('Please proceed${getUpgradeMethodName()}')));
                return;
              }
              if (id == null) {
                _state.currentState.showSnackBar(SnackBar(
                    content: Text('There is currently no ID to install')));
                return;
              }
              final status = await RUpgrade.getDownloadStatus(id);

              if (status == DownloadStatus.STATUS_SUCCESSFUL) {
                bool isSuccess = await RUpgrade.install(id);
                if (isSuccess) {
                  _state.currentState.showSnackBar(
                      SnackBar(content: Text('Request succeeded')));
                }
              } else {
                _state.currentState.showSnackBar(SnackBar(
                    content: Text('The current ID has not been downloaded')));
              }
            },
          ),
          CheckboxListTile(
            value: isAutoRequestInstall,
            onChanged: (bool value) {
              setState(() {
                isAutoRequestInstall = value;
              });
            },
            title: Text('Install after downloading'),
          ),
          ListTile(
            title: Text('Keep updating'),
            onTap: () async {
              if (id == null) {
                _state.currentState.showSnackBar(SnackBar(
                    content: Text('There is currently no ID to upgrade')));
                return;
              }
              if (upgradeMethod != null) {
                _state.currentState
                    .showSnackBar(SnackBar(content: Text(getUpgradeMethod())));
                return;
              }
              await RUpgrade.upgradeWithId(id);
              setState(() {});
            },
          ),
          ListTile(
            title: Text('Pause update'),
            onTap: () async {
              bool isSuccess = await RUpgrade.pause(id);
              if (isSuccess) {
                _state.currentState.showSnackBar(
                    SnackBar(content: Text('Suspended successfully')));
                setState(() {});
              }
              print('cancel');
            },
          ),
          ListTile(
            title: Text('Cancel update'),
            onTap: () async {
              bool isSuccess = await RUpgrade.cancel(id);
              if (isSuccess) {
                _state.currentState
                    .showSnackBar(SnackBar(content: Text('Cancel success')));
                id = null;
                upgradeMethod = null;
                setState(() {});
              }
              print('cancel');
            },
          ),
        ],
      );

  int lastId;

  DownloadStatus lastStatus;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _state,
        body: _buildMultiPlatformWidget(),
      ),
    );
  }

  Color getVersionColor() {
    switch (version) {
      case 1:
        return Theme.of(context).primaryColor;
      case 2:
        return Colors.black;
      case 3:
        return Colors.red;
      case 4:
        return Colors.orange;
    }
    return Theme.of(context).primaryColor;
  }

  String _getAppBarText() {
    switch (version) {
      case 1:
        return 'Installed Version = $version ${id != null ? 'id = $id' : ''}';
      case 2:
        return 'Hot upgrade version = $version ${id != null ? 'id = $id' : ''}';
      case 3:
        return 'All upgrade version = $version ${id != null ? 'id = $id' : ''}';
      case 4:
        return 'Plus upgrade version = $version ${id != null ? 'id = $id' : ''}';
    }
    return 'Unknown version  = $version ${id != null ? 'id = $id' : ''}';
  }

  Widget _buildDownloadWindow() => Container(
        height: 250,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
        ),
        child: id != null
            ? StreamBuilder(
                stream: RUpgrade.stream,
                builder: (BuildContext context,
                    AsyncSnapshot<DownloadInfo> snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          height: 150,
                          width: 150,
                          child: CircleDownloadWidget(
                            backgroundColor: snapshot.data.status ==
                                    DownloadStatus.STATUS_SUCCESSFUL
                                ? Colors.green
                                : null,
                            progress: snapshot.data.percent / 100,
                            child: Center(
                              child: Text(
                                snapshot.data.status ==
                                        DownloadStatus.STATUS_RUNNING
                                    ? getSpeech(snapshot.data.speed)
                                    : getStatus(snapshot.data.status),
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                            '${snapshot.data.planTime.toStringAsFixed(0)}sAfter completion'),
                      ],
                    );
                  } else {
                    return SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    );
                  }
                },
              )
            : Text('Waiting to download'),
      );

  String getStatus(DownloadStatus status) {
    if (status == DownloadStatus.STATUS_FAILED) {
      id = null;
      upgradeMethod = null;
      return "Download failed";
    } else if (status == DownloadStatus.STATUS_PAUSED) {
      return "Download paused";
    } else if (status == DownloadStatus.STATUS_PENDING) {
      return "Getting Resources";
    } else if (status == DownloadStatus.STATUS_RUNNING) {
      return "Downloading";
    } else if (status == DownloadStatus.STATUS_SUCCESSFUL) {
      return "Download successful";
    } else if (status == DownloadStatus.STATUS_CANCEL) {
      id = null;
      upgradeMethod = null;
      return "Download canceled";
    } else {
      id = null;
      upgradeMethod = null;
      return "unknown";
    }
  }

  String getUpgradeMethod() {
    switch (upgradeMethod) {
      case UpgradeMethod.all:
        return 'full update has started';
        break;
      case UpgradeMethod.hot:
        return 'Hot update has started';
        break;
      case UpgradeMethod.increment:
        return 'Incremental update has started';
        break;
    }
    return '';
  }

  String getUpgradeMethodName() {
    switch (upgradeMethod) {
      case UpgradeMethod.all:
        return 'full update';
        break;
      case UpgradeMethod.hot:
        return 'hot update';
        break;
      case UpgradeMethod.increment:
        return 'Incremental update';
        break;
    }
    return '';
  }

  String getSpeech(double speech) {
    String unit = 'kb/s';
    String result = speech.toStringAsFixed(2);
    if (speech > 1024 * 1024) {
      unit = 'gb/s';
      result = (speech / (1024 * 1024)).toStringAsFixed(2);
    } else if (speech > 1024) {
      unit = 'mb/s';
      result = (speech / 1024).toStringAsFixed(2);
    }
    return '$result$unit';
  }
}

class CircleDownloadWidget extends StatelessWidget {
  final double progress;
  final Widget child;
  final Color backgroundColor;

  const CircleDownloadWidget(
      {Key key, this.progress, this.child, this.backgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: CircleDownloadCustomPainter(
          backgroundColor ?? Colors.grey[400],
          Theme.of(context).primaryColor,
          progress,
        ),
        child: child,
      ),
    );
  }
}

class CircleDownloadCustomPainter extends CustomPainter {
  final Color backgroundColor;
  final Color color;
  final double progress;

  Paint mPaint;

  CircleDownloadCustomPainter(this.backgroundColor, this.color, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (mPaint == null) mPaint = Paint();
    double width = size.width;
    double height = size.height;

    Rect progressRect =
        Rect.fromLTRB(0, height * (1 - progress), width, height);
    Rect widgetRect = Rect.fromLTWH(0, 0, width, height);
    canvas.clipPath(Path()..addOval(widgetRect));

    canvas.drawRect(widgetRect, mPaint..color = backgroundColor);
    canvas.drawRect(progressRect, mPaint..color = color);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
