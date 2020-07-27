import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import '../helpers/screen.dart';

class CustomPoster extends StatelessWidget {
  final String heroTag;
  final String image;

  CustomPoster({this.heroTag, @required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: (Screen.isPortrait(context))
          ? Screen.heigth(context) * 0.30
          : Screen.heigth(context) * 0.70,
      margin: EdgeInsets.symmetric(horizontal: 5.0),
      child: AspectRatio(
        aspectRatio: 2.0 / 3.0,
        child: (heroTag != null)
            ? Hero(tag: heroTag, child: _widget())
            : _widget(),
      ),
    );
  }

  Widget _widget() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: TransitionToImage(
        image: AdvancedNetworkImage(image, useDiskCache: true),
        fit: BoxFit.cover,
        placeholder: Container(
            width: 100, height: 100, child: Center(child: Icon(Icons.refresh))),
        enableRefresh: true,
        loadingWidget: Container(
            width: 100,
            height: 100,
            child: Center(child: CircularProgressIndicator())),
      ),
    );
  }
}
