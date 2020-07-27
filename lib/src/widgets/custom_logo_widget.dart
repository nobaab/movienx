import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_svg/svg.dart';
import '../helpers/api.dart';
import '../helpers/screen.dart';
import '../providers/settings_provider.dart';

class CustomLogo extends StatefulWidget {
  @override
  _CustomLogoState createState() => _CustomLogoState();
}

class _CustomLogoState extends State<CustomLogo>
    with AutomaticKeepAliveClientMixin<CustomLogo> {
  final SettingsProvider settingsProvider = SettingsProvider();
  Future<String> _future;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _future = settingsProvider.logoType();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasError) {
          return Container();
        }
        if (!snapshot.hasData) {
          return Container();
        }

        if (snapshot.data == 'svg') {
          return SvgPicture(
            AdvancedNetworkSvg(
                Api.url + 'image/logo', SvgPicture.svgByteDecoder,
                useDiskCache: true),
            height: Screen.logoSize(context),
          );
        } else {
          return Image(
            image: AdvancedNetworkImage(Api.url + 'image/logo',
                useDiskCache: true),
            height: Screen.logoSize(context),
          );
        }
      },
    );
  }
}
