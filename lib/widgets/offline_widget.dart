import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:briddgy/localization/localization_constants.dart';

class OfflineWidget extends StatelessWidget {
  const OfflineWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Color(0xFFEE4400),
          child: Center(
            child: Text(
              "Offline",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        Spacer(),
        Container(
          height: 200,
          padding: EdgeInsets.all(10),
          child: SvgPicture.asset(
            "assets/photos/internet.svg",
          ),
        ),
        Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            t(context, "no_internet"),
            style: Theme.of(context).textTheme.headline4.copyWith(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ),
        Spacer(),
      ],
    );
  }
}
