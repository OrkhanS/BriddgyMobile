import 'dart:io';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optisend/models/api.dart';
import 'package:optisend/models/order.dart';
import 'package:optisend/models/trip.dart';
import 'package:optisend/providers/auth.dart';
import 'package:optisend/screens/chats_screen.dart';
import 'package:optisend/screens/profile_screen_another.dart';
import 'package:optisend/screens/verify_phone_screen.dart';
import 'package:optisend/widgets/generators.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import '../main.dart';
import 'package:transparent_image/transparent_image.dart';

import 'chats_screen.dart';

class TripScreen extends StatefulWidget {
  Trip trip;
  TripScreen({this.trip});
  static const routeName = '/trips/trip';
  @override
  _TripScreenState createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  var _current;
  Trip trip;
  var imageUrl;
  @override
  void initState() {
    trip = widget.trip;
    imageUrl = trip.owner.avatarpic == null ? Api.noPictureImage : Api.storageBucket + trip.owner.avatarpic.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 4),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (__) => ProfileScreenAnother(
                              user: trip.owner,
                            )),
                  );
                },
                child: Row(
                  children: <Widget>[
                    IconButton(
                      color: Theme.of(context).primaryColor,
                      icon: Icon(
                        Icons.chevron_left,
                        size: 24,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Text(
                                  trip.owner.firstName + " " + trip.owner.lastName,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
//                                style: TextStyle(
//                                  fontStyle: ,
//                                  color: Colors.white,
//                                  fontWeight: FontWeight.bold,
//                                  fontSize: 20,
//                                ),
                                ),
                              ),
                              Icon(
                                MdiIcons.shieldCheck,
                                color: Colors.green,
                                size: 17,
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Text(
                              "Last online " + DateFormat.yMMMd().format(trip.owner.lastOnline),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Stack(
                        children: <Widget>[
                          imageUrl == Api.noPictureImage
                              ? InitialsAvatarWidget(trip.owner.firstName.toString(), trip.owner.lastName.toString(), 70.0)
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(40.0),
                                  child: Image.network(
                                    imageUrl,
                                    errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                      return InitialsAvatarWidget(trip.owner.firstName.toString(), trip.owner.lastName.toString(), 70.0);
                                    },
                                    height: 70,
                                    width: 70,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                          Positioned(
                            left: 17,
                            right: 17,
                            bottom: 0,
                            child: Container(
                              height: 18,
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(255, 255, 255, 30),
                                border: Border.all(color: Colors.green, width: 1),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Icon(
                                    Icons.star,
                                    size: 12,
                                    color: Colors.green,
                                  ),
                                  Text(
                                    trip.owner.rating.toString(),
                                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
//            Padding(
//              padding: EdgeInsets.symmetric(horizontal: 10),
////              child: AppBar(
////                backgroundColor: Colors.white,
////                centerTitle: true,
////                leading: IconButton(
////                  color: Theme.of(context).primaryColor,
////                  icon: Icon(
////                    Icons.chevron_left,
////                    size: 24,
////                  ),
////                  onPressed: () {
////                    Navigator.of(context).pop();
////                  },
////                ),
////                title: Text(
////                 trip.title.toString(),
////                  style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
//                ),
//                elevation: 1,
//              ),
//            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Travel Information",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.share,
                                ),
                                onPressed: () {
                                  Share.share(trip.owner.firstName +
                                      " is traveling from " +
                                      trip.source.cityAscii +
                                      " to " +
                                      trip.destination.cityAscii +
                                      ".\n" +
                                      Api.tripLink +
                                      trip.id.toString());
                                },
                              )
                            ],
                          ),
                          Divider(),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 4,
                            ),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "From:",
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: 1,
                                  ),
                                ),
                                Text(
                                  trip.source.cityAscii,
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 4,
                            ),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "To:",
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: 1,
                                  ),
                                ),
                                Text(
                                  trip.destination.cityAscii,
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 4,
                            ),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "Departure Date:",
                                  style: TextStyle(fontSize: 17, color: Colors.grey[600]),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: 1,
                                  ),
                                ),
                                Text(
                                  DateFormat('d MMMM yyyy').format(trip.date),
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 4,
                            ),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "Weight Limit:",
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: 1,
                                  ),
                                ),
                                Text(
                                  trip.weightLimit.toString() + " kg",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ), //
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "Description",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(),
                          Text(
                            "Not delivering edible orders. Thanks for understanding", //todo orxan fix after adding backend
                            style: TextStyle(fontSize: 17),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
//                                RaisedButton.icon(
//                                  padding: EdgeInsets.symmetric(horizontal: 20),
////                            color: Theme.of(context).scaffoldBackgroundColor,
//                                  color: Colors.white,
//
//                                  elevation: 2,
//                                  shape: RoundedRectangleBorder(
//                                    borderRadius: BorderRadius.circular(18.0),
//                                  ),
//                                  icon: Icon(
//                                    MdiIcons.scriptTextOutline,
////                              color: Colors.white,
//                                    color: Theme.of(context).primaryColor,
//                                    size: 18,
//                                  ),
//                                  label: Text(
//                                    " Apply for Delivery",
//                                    style: TextStyle(
//                                      fontWeight: FontWeight.bold,
////                                color: Colors.white,
//                                      color: Theme.of(context).primaryColor,
//                                    ),
//                                  ),
//                                  onPressed: () {
//                                    Navigator.push(
//                                      context,
//                                      MaterialPageRoute(builder: (__) => ApplyForOrderScreen()),
//                                    );
//                                  },
//                                ),
                          Expanded(
                            child: SizedBox(),
                          ),
                          RaisedButton.icon(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            color: Colors.green,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            icon: Icon(
                              MdiIcons.chatOutline,
                              color: Colors.white,
//                              color: Theme.of(context).primaryColor,
                              size: 18,
                            ),
                            label: Text(
                              " Message",
                              style: TextStyle(
                                fontWeight: FontWeight.w800, color: Colors.white, fontSize: 17,
//                                    color: Theme.of(context).primaryColor,
                              ),
                            ),
                            onPressed: () {
                              //todo Orxan
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _current {}
