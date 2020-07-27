import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import '../helpers/guards.dart';
import '../models/settings_model.dart';
import '../helpers/screen.dart';
import '../models/movie_model.dart';

class CarouselMovies extends StatelessWidget {
  final Future<List<Movie>> future;

  CarouselMovies({@required this.future});

  @override
  Widget build(BuildContext context) {
    final Settings settings = Provider.of<Settings>(context);
    final SwiperController _swiperController = SwiperController();

    return FutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Container(
              height: Screen.heigth(context) - kBottomNavigationBarHeight,
              child: Guards.hasErrorWithoutRefresh());
        }

        if (!snapshot.hasData) {
          return Container(
              height: Screen.heigth(context) - kBottomNavigationBarHeight,
              child: Guards.noData());
        }

        // guard clause: if the list is empty, it return a sizedbox
        if (snapshot.data.isEmpty) {
          return SizedBox(height: kToolbarHeight + 10);
        }

        final movies = snapshot.data;
        return Container(
          padding: EdgeInsets.only(bottom: 10.0),
          width: Screen.width(context),
          height: Screen.heigth(context) - kBottomNavigationBarHeight,
          child: Swiper(
            controller: _swiperController,
            autoplay: true,
            autoplayDelay: 10000,
            itemBuilder: (BuildContext context, int index) {
              return Stack(
                children: <Widget>[
                  Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      TransitionToImage(
                        height:
                            Screen.heigth(context) - kBottomNavigationBarHeight,
                        width: Screen.width(context),
                        image: AdvancedNetworkImage(
                            (Screen.isPortrait(context))
                                ? movies[index].getPoster()
                                : movies[index].getBackdrop(),
                            useDiskCache: true),
                        fit: BoxFit.fill,
                        placeholder: Container(
                            height: Screen.heigth(context) -
                                kBottomNavigationBarHeight,
                            width: Screen.width(context),
                            child: Center(
                              child: Icon(Icons.refresh),
                            )),
                        enableRefresh: true,
                        loadingWidget: Container(
                          height: Screen.heigth(context) -
                              kBottomNavigationBarHeight,
                          width: Screen.width(context),
                          child: Image(
                              image: AssetImage('assets/img/loading.gif'),
                              fit: BoxFit.fill),
                        ),
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
                      ),
                    ],
                  ),
                  if (movies[index].hd)
                    Positioned(
                        top: 85,
                        left: 10,
                        child:
                            Icon(Icons.hd, color: Colors.white60, size: 30.0)),
                  if (Screen.isLandscape(context))
                    Positioned(
                      bottom: 30,
                      left: 30,
                      child: Text(movies[index].title,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30.0,
                              backgroundColor: Colors.black12,
                              fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis),
                    )
                ],
              );
            },
            itemCount: movies.length,
            onTap: (index) {
              Navigator.pushNamed(context, 'movie.detail',
                  arguments: movies[index]);
            },
          ),
        );
      },
    );
  }
}
