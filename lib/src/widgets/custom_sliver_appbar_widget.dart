import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import '../helpers/shares.dart';
import '../helpers/screen.dart';
import '../helpers/search.dart';
import '../models/settings_model.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class CustomSliverAppBar extends StatelessWidget {
  final String title;
  final String image;

  CustomSliverAppBar({@required this.title, @required this.image});

  @override
  Widget build(BuildContext context) {
    final Settings settings = Provider.of<Settings>(context);

    return SliverAppBar(
      backgroundColor: settings.appBackgroundColor,
      expandedHeight: Screen.isPortrait(context)
          ? Screen.heigth(context) * 0.50
          : Screen.heigth(context) * 0.70,
      pinned: true,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.share),
          onPressed: () {
            Share.share(Shares.all(context, title: title));
          },
        ),
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            showSearch(context: context, delegate: Search());
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
          title: Container(
            width: Screen.width(context) * 0.50,
            child: Text(title,
                style: TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis),
          ),
          background: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              TransitionToImage(
                image: AdvancedNetworkImage(image, useDiskCache: true),
                fit: Screen.isPortrait(context) ? BoxFit.cover : BoxFit.fill,
                placeholder: Container(
                    height: Screen.isPortrait(context)
                        ? Screen.heigth(context) * 0.50
                        : Screen.heigth(context) * 0.70,
                    width: Screen.width(context),
                    child: Center(
                      child: Icon(Icons.refresh),
                    )),
                enableRefresh: true,
                loadingWidget: Container(
                    height: Screen.isPortrait(context)
                        ? Screen.heigth(context) * 0.50
                        : Screen.heigth(context) * 0.70,
                    width: Screen.width(context),
                    child: Image(
                        image: AssetImage('assets/img/loading.gif'),
                        fit: BoxFit.cover)),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter,
                    stops: [0.1, 0.6, 1.0],
                    colors: [
                      settings.appBackgroundColor.withOpacity(0.54),
                      Colors.transparent,
                      settings.appBackgroundColor
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }
}
