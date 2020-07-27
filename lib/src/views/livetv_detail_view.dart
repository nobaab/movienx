import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import '../helpers/lang.dart';
import '../views/video_view.dart';
import '../helpers/ads.dart';
import '../helpers/network.dart';
import '../widgets/custom_sliver_appbar_widget.dart';
import '../providers/livetv_provider.dart';


class LivetvDetail extends StatefulWidget {

  @override
  _LivetvDetailState createState() => _LivetvDetailState();
}

class _LivetvDetailState extends State<LivetvDetail> {
  @override
  Widget build(BuildContext context) {
    final Livetv livetv = ModalRoute.of(context).settings.arguments;
    GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
    // Check the network, if there is no connection it shows a snackbar.
    Network.check().then((onValue) => {
          if (!onValue)
            _scaffoldkey.currentState.showSnackBar(
                new SnackBar(content: Text(Lang.noNetwork)))
        });
    Ads.interstitialLoad(context);

    return Scaffold(
      key: _scaffoldkey,
      body: CustomScrollView(
        slivers: <Widget>[
          CustomSliverAppBar(title: livetv.name, image: livetv.getBackdrop()),
          SliverList(
              delegate: SliverChildListDelegate([
            Ads.responsive(context),
            _livetvPoster(livetv),
            _livetvOverview(livetv),
            SizedBox(height: 20.0),
          ]))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        child: Icon(Icons.play_arrow),
        onPressed: () {
          Ads.interstitialShow();
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => VideoView(livetv.link, progress: false)));
        },
      ),
    );
  }

  Widget _livetvPoster(Livetv livetv) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Row(
        children: <Widget>[
          Hero(
            tag: livetv.uniqueId,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: TransitionToImage(
                height: 160,
                width: 160,
                image: AdvancedNetworkImage(livetv.getPoster(),
                    useDiskCache: true),
                fit: BoxFit.cover,
                placeholder: Container(
                    height: 160,
                    width: 100,
                    child: Center(
                      child: Icon(Icons.refresh),
                    )),
                enableRefresh: true,
                loadingWidget: Container(
                    height: 160,
                    width: 160,
                    child: Center(
                      child: CircularProgressIndicator(),
                    )),
              ),
            ),
          ),
          SizedBox(width: 20.0),
          Flexible(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(livetv.name, style: TextStyle(fontSize: 18.0)),
                ]),
          )
        ],
      ),
    );
  }

  Widget _livetvOverview(Livetv livetv) {
    return  Container(
      padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
      child: Text(livetv.overview ?? '',
          style: TextStyle(fontSize: 18.0), textAlign: TextAlign.justify),
    );
  }
}
