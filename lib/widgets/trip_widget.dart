import 'dart:io';
import 'package:briddgy/localization/localization_constants.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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

import 'components.dart';

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
    return InkWell(
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
      child: Card(
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
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          AvatarPicWidget(
                            user: trip.owner,
                          ),
                          Text(
                            trip.owner.firstName.substring(0, trip.owner.firstName.length > 8 ? 8 : trip.owner.firstName.length) +
                                " " +
                                trip.owner.lastName[0] +
                                ".",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey[900]),
                          ),
                          StaticRatingBarWidget(rating: trip.owner.rating),
                        ],
                      ),
//                modeProfile
//                    ? SizedBox()
//                    : Positioned(
//                        left: 17,
//                        right: 17,
//                        bottom: 0,
//                        child: Container(
//                          height: 18,
//                          decoration: BoxDecoration(
//                            color: Color.fromRGBO(255, 255, 255, 30),
//                            border: Border.all(color: Colors.green, width: 1),
//                            borderRadius: BorderRadius.all(
//                              Radius.circular(20),
//                            ),
//                          ),
//                          child: Row(
//                            mainAxisSize: MainAxisSize.max,
//                            mainAxisAlignment: MainAxisAlignment.spaceAround,
//                            children: <Widget>[
//                              Icon(
//                                Icons.star,
//                                size: 12,
//                                color: Colors.green,
//                              ),
//                              Text(
//                                trip.owner.rating.toString(),
//                                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
//                              )
//                            ],
//                          ),
//                        ),
//                      ),
              ],
            ),
            Container(
              margin: const EdgeInsets.all(8),
              color: Colors.grey[200],
              width: 1,
              height: 80,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t(context, 'from'),
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                trip.source.cityAscii,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
//                                    color: Theme.of(context).primaryColor,
                                ),
                              ),
                              Text(
                                trip.source.country,
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          MdiIcons.airplane,
//                            color: Theme.of(context).primaryColor,
                          color: Colors.grey[700],

                          size: 30,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                t(context, 'to'),
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                trip.destination.cityAscii,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
//                                    color: Theme.of(context).primaryColor,
                                ),
                              ),
                              Text(
                                trip.destination.country,
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          trip.weightLimit.toString() + " " + t(context, 'kg'),
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                        ),
                        Spacer(),
                        Text(
                          DateFormat("d MMM yyy").format(trip.date),
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
//                Expanded(
//                  flex: 5,
//                  child: Padding(
//                    padding: const EdgeInsets.symmetric(vertical: 4.0),
//                    child: Column(
//                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                      crossAxisAlignment: CrossAxisAlignment.start,
//                      children: <Widget>[
//                        Text(
//                          trip.owner.firstName + " " + trip.owner.lastName,
//                          overflow: TextOverflow.ellipsis,
//                          maxLines: 1,
//                          style: TextStyle(fontSize: 20, color: Colors.grey[600], fontWeight: FontWeight.bold),
//                        ),
//                        Expanded(
//                          child: Row(
//                            mainAxisAlignment: MainAxisAlignment.start,
//                            children: <Widget>[
//                              Icon(
//                                Icons.location_on,
//                                color: Theme.of(context).primaryColor,
//                                size: 16,
//                              ),
//                              Text(
//                                "  " + trip.source.cityAscii + " > " + trip.destination.cityAscii + ", " + trip.destination.country,
//                                overflow: TextOverflow.ellipsis,
//                                maxLines: 1,
//                                style: TextStyle(fontSize: 15, color: Colors.grey[600], fontWeight: FontWeight.normal),
//                              ),
//                            ],
//                          ),
//                        ),
//                        Row(
//                          children: <Widget>[
//                            Icon(
//                              Icons.date_range,
//                              color: Theme.of(context).primaryColor,
//                              size: 16,
//                            ),
//                            Text(
//                              "  " + DateFormat('dd MMMM').format(trip.date), //Todo: date
//                              style: TextStyle(color: Colors.grey[600]),
//                            ),
//                            Expanded(
//                              child: SizedBox(),
//                            ),
//                            Icon(
//                              MdiIcons.weightKilogram,
//                              color: Theme.of(context).primaryColor,
//                              size: 16,
//                            ),
//                            Text(
//                              "  " + trip.weightLimit.toString() + ' kg',
//                              style: TextStyle(color: Colors.grey[600]),
//                            ),
//                          ],
//                        ),
//                        Row(
//                          children: <Widget>[],
//                        )
//                      ],
//                    ),
//                  ),
//                ),
          ],
        ),
      ),
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
