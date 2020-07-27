import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../helpers/screen.dart';

class Guards {

  static Widget hasError(BuildContext context, {@required Function onRefresh, @required RefreshController controller}) {
    return SmartRefresher(
      onRefresh: onRefresh,
      controller: controller,
      header: WaterDropMaterialHeader(),
      enablePullDown: true,
      enablePullUp: false,
      child: SingleChildScrollView(
          child: Container(
        height: Screen.heigth(context),
        child: Center(
          child: Icon(Icons.error),
        ),
      )),
    );
  }

  static Widget hasErrorWithTap({@required Function onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        child: Center(
          child: Icon(Icons.refresh),
        ),
      ),
    );
  }

  static Widget hasErrorWithoutRefresh() {
    return Container(
      child: Center(
        child: Icon(Icons.error),
      ),
    );
  }

  static Widget noData() {
    return Center(
      child: Container(child: CircularProgressIndicator()),
    );
  }

  static Widget failed({Function onRefresh}) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 200.0,
                child: Image.asset('assets/img/no-network.png'),
              ),
              Container(
                  child: Text('Failed connect to server',
                      style: TextStyle(color: Colors.white, fontSize: 24.0))),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: onRefresh,
          child: Icon(Icons.refresh, size: 30.0),
        ),
      ),
      theme: ThemeData(accentColor: Colors.black, scaffoldBackgroundColor: Colors.black),
    );
  }
}
