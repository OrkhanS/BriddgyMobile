import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:briddgy/models/api.dart';
import 'package:briddgy/models/trip.dart';
import 'package:briddgy/screens/trip_screen.dart';
import 'package:briddgy/providers/auth.dart';
import 'package:briddgy/providers/ordersandtrips.dart';
import 'package:provider/provider.dart';

import 'generators.dart';

class TripWidget extends StatelessWidget {
  final Trip trip;
  final int i;
  final bool modeProfile;
  TripWidget({@required this.trip, @required this.i, this.modeProfile = false});
  var imageUrl;
  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      imageUrl = trip.owner.avatarpic == null ? Api.noPictureImage : Api.storageBucket + trip.owner.avatarpic.toString();
    }
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (__) => TripScreen(
                  trip: trip,
                ),
              ),
            );
          },
          child: Container(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedBox(
                  width: 5,
                ),
                Stack(
                  children: <Widget>[
                    modeProfile
                        ? Container(
                            width: 70,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  trip.numberOfContracts.toString(),
                                  style: TextStyle(fontSize: 25),
                                ),
                                //todo i18n
                                Text(
                                  "Active Contracts",
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                                  textAlign: TextAlign.center,
                                ),
//                                RaisedButton(
//                                  color: Colors.blue,
//                                  onPressed: () {},
//                                  child: Text("Find Orders"),
//                                )
                              ],
                            ),
                          )

//                    Text(
//                            trip.numberOfContracts.toString() ,
//                            style: Theme.of(context).textTheme.headline3,
//                          )
                        : imageUrl == Api.noPictureImage
                            ? InitialsAvatarWidget(trip.owner.firstName.toString(), trip.owner.lastName.toString(), 70.0)
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(25.0),
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
                    modeProfile
                        ? SizedBox()
                        : Positioned(
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
                VerticalDivider(),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          trip.owner.firstName + " " + trip.owner.lastName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(fontSize: 20, color: Colors.grey[600], fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                Icons.location_on,
                                color: Theme.of(context).primaryColor,
                                size: 16,
                              ),
                              Text(
                                "  " + trip.source.cityAscii + " > " + trip.destination.cityAscii + ", " + trip.destination.country,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(fontSize: 15, color: Colors.grey[600], fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.date_range,
                              color: Theme.of(context).primaryColor,
                              size: 16,
                            ),
                            Text(
                              "  " + DateFormat('dd MMMM').format(trip.date), //Todo: date
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Expanded(
                              child: SizedBox(),
                            ),
                            Icon(
                              MdiIcons.weightKilogram,
                              color: Theme.of(context).primaryColor,
                              size: 16,
                            ),
                            Text(
                              "  " + trip.weightLimit.toString() + ' kg',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[],
                        )
                      ],
                    ),
                  ),
                ),
                //todo check if I am the owner
                //todo if user is the owner, then replace the button below with delete button
                if (Provider.of<Auth>(context, listen: false).isAuth)
                  if (trip.owner.id == Provider.of<Auth>(context, listen: false).user.id)
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text("Are you sure you want to delete this order?"),
                            content: Text("This action cannot be undone"),
                            actions: <Widget>[
                              FlatButton(
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                },
                              ),
                              FlatButton(
                                child: Text('Yes,delete!'),
                                onPressed: () {
                                  var url = Api.orders + trip.id.toString() + '/';
                                  http.delete(
                                    url,
                                    headers: {
                                      HttpHeaders.contentTypeHeader: "application/json",
                                      "Authorization": "Token " + Provider.of<Auth>(context, listen: false).myTokenFromStorage,
                                    },
                                  ).then((value) {});
                                  var orderprovider = Provider.of<OrdersTripsProvider>(context, listen: false);
                                  orderprovider.myorders.removeAt(i);
                                  orderprovider.notify();
                                  Navigator.of(ctx).pop();
                                  Flushbar(
                                    flushbarStyle: FlushbarStyle.GROUNDED,
                                    titleText: Text(
                                      "Success",
                                      style: TextStyle(color: Colors.black, fontSize: 22),
                                    ),
                                    messageText: Text(
                                      "Order has been deleted",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    icon: Icon(MdiIcons.delete),
                                    backgroundColor: Colors.white,
                                    borderColor: Theme.of(context).primaryColor,
                                    padding: const EdgeInsets.all(10),
                                    margin: EdgeInsets.only(left: 20, right: 20, bottom: 50),
                                    borderRadius: 10,
                                    duration: Duration(seconds: 5),
                                  )..show(context);
                                },
                              )
                            ],
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.red[200],
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.red[400],
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.grey[200],
//                    border: Border.all(
////                      color: Colors.grey[400],
//                      width: 0.8,
//                      color: Theme.of(context).primaryColor,
//                    ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Icon(
                          Icons.chevron_right,
                          size: 25,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),

                SizedBox(width: 10),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 90.0),
          child: Divider(
            height: 4,
            color: Colors.black45,
          ),
        ),
      ],
    );
  }
}

class TripFadeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 100,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[200],
              ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 10,
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[200],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.location_on,
                            color: Colors.grey[200],
                            size: 16,
                          ),
                          Container(
                            height: 10,
                            width: 90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey[200],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.date_range,
                            color: Colors.grey[200],
                            size: 16,
                          ),
                          Container(
                            height: 10,
                            width: 90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey[200],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Icon(
                            MdiIcons.weightKilogram,
                            color: Colors.grey[200],
                            size: 16,
                          ),
                          Container(
                            height: 10,
                            width: 90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey[200],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Divider(
            height: 4,
            color: Colors.black45,
          ),
        ),
      ],
    );
  }
}

class TripSimpleWidget extends StatelessWidget {
  Trip trip;
  var i;
  var imageUrl;
  TripSimpleWidget({@required this.trip, @required this.i});
  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      imageUrl = trip.owner.avatarpic == null ? Api.noPictureImage : Api.storageBucket + trip.owner.avatarpic.toString();
    }
    return Column(
      children: <Widget>[
        Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[300],
                backgroundImage: NetworkImage(
                  imageUrl,
                ),
              ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        trip.owner.firstName + " " + trip.owner.lastName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 20, color: Colors.grey[600], fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.location_on,
                            color: Theme.of(context).primaryColor,
                            size: 16,
                          ),
                          Text(
                            "  " + trip.source.cityAscii + " > " + trip.destination.cityAscii + ", " + trip.destination.country,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(fontSize: 15, color: Colors.grey[600], fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.date_range,
                            color: Theme.of(context).primaryColor,
                            size: 16,
                          ),
                          Text(
                            "  " + DateFormat('d MMMM yyyy').format(trip.date), //Todo: date
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Icon(
                            MdiIcons.weightKilogram,
                            color: Theme.of(context).primaryColor,
                            size: 16,
                          ),
                          Text(
                            "  " + trip.weightLimit.toString() + ' kg',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Divider(
            height: 4,
            color: Colors.black45,
          ),
        ),
      ],
    );
  }
}
