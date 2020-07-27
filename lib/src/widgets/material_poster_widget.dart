import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import '../models/settings_model.dart';
import 'package:provider/provider.dart';

class MaterialPoster extends StatelessWidget {
  final String heroTag;
  final String image;
  final String title;
  final bool hd;
  final Function onTap;

  MaterialPoster({
    this.heroTag,
    @required this.image,
    @required this.title,
    this.hd = false,
    @required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Settings settings = Provider.of<Settings>(context);

    return Stack(
      children: <Widget>[
        Positioned.fill(
            bottom: 0.0,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                (heroTag != null)
                    ? Hero(tag: heroTag, child: _widget())
                    : _widget(),
                if (hd)
                  Positioned(
                      top: 5.0,
                      left: 5.0,
                      child: Icon(Icons.hd, color: Colors.white60, size: 30.0)),
                if (settings.titleInPoster)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: EdgeInsets.all(5.0),
                      child: Text(
                        title,
                        style: TextStyle(
                            backgroundColor: Colors.black45,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        softWrap: true,
                      ),
                    ),
                  )
              ],
            )),
        Positioned.fill(
            child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10.0),
                  onTap: onTap,
                ))),
      ],
    );
  }

  Widget _widget() {
    return Container(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: TransitionToImage(
          image: AdvancedNetworkImage(image, useDiskCache: true),
          fit: BoxFit.cover,
          placeholder: Container(
            width: 100,
            height: 100,
            child: Center(child: Icon(Icons.error)),
          ),
          loadingWidget: Container(
            width: 100,
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}
