import 'dart:io';
import 'package:briddgy/providers/ordersandtrips.dart';
import 'package:briddgy/widgets/components.dart';
import 'package:briddgy/widgets/order_widget.dart';
import 'package:briddgy/widgets/trip_widget.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:briddgy/localization/localization_constants.dart';
import 'package:briddgy/models/api.dart';
import 'package:briddgy/models/order.dart';
import 'package:briddgy/models/trip.dart';
import 'package:briddgy/providers/auth.dart';
import 'package:briddgy/providers/messages.dart';
import 'package:briddgy/screens/chats_screen.dart';
import 'package:briddgy/screens/profile_screen.dart';
import 'package:briddgy/screens/verify_phone_screen.dart';
import 'package:briddgy/widgets/progress_indicator_widget.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import '../main.dart';
import 'package:transparent_image/transparent_image.dart';

import 'chats_screen.dart';

class TripScreen extends StatefulWidget {
  final Trip trip;
  final int i;
  TripScreen({@required this.trip, @required this.i});
  static const routeName = '/trips/trip';
  @override
  _TripScreenState createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  Trip trip;
  bool messageDeliveryButton = true;
  Future<List<Object>> _suggestions;
  bool isMine = false;

  @override
  void initState() {
    trip = widget.trip;
    if (Provider.of<Auth>(context, listen: false).isAuth) if (trip.owner.id == Provider.of<Auth>(context, listen: false).user.id) isMine = true;
    if (isMine)
      _suggestions = fetchOrderSuggestions(trip.source.id.toString(), trip.destination.id.toString(), context);
    else
      _suggestions = fetchTripSuggestions(trip.source.id.toString(), trip.destination.id.toString(), context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            UserAppbarWidget(user: trip.owner),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          buildTripInfo(trip: trip),
                          if (Provider.of<Auth>(context, listen: false).isAuth)
                            if (trip.owner.id == Provider.of<Auth>(context, listen: false).user.id)
                              Row(
                                children: [
                                  Spacer(),
                                  DeleteButtonWidget(object: trip),
                                  SizedBox(width: 20),
                                ],
                              )
                            else
                              messageDeliveryButton
                                  ? Padding(
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
                                          Spacer(),
                                          MessageButtonWidget(user: trip.owner),
                                        ],
                                      ),
                                    )
                                  : ProgressIndicatorWidget(show: true),
                          Text(
                            isMine ? "Suggested Orders" : "Similar Trips:",
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          FutureBuilder<List<Object>>(
                            future: _suggestions,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data.length == 1 || snapshot.data.length == 0) {
                                  return Center(
                                      child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: MediaQuery.of(context).size.height * 0.2,
                                          padding: EdgeInsets.symmetric(horizontal: 40),
                                          child: SvgPicture.asset(
                                            "assets/photos/empty_order.svg",
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                          child: Text(
                                            //todo i18n
                                            "No results",
//                                    t(context, 'empty_results'),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 25,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ));
                                } else
                                  for (var x in snapshot.data) {
                                    if (x != trip) {
                                      if (x is Order) return OrderWidget(order: x);
                                      return TripWidget(trip: x);
                                    } else
                                      return SizedBox();
                                  }
                              } else if (snapshot.hasError) {
                                return Text("${snapshot.error}");
                              }

                              return Center(
                                child: CircularProgressIndicator(),
                              );
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

  Widget buildTripInfo({@required Trip trip}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Colors.grey[300],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[500].withOpacity(.3),
            offset: Offset(2, 5),
            blurRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    t(context, 'travel_information'),
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.share,
                    size: 19,
                  ),
                  onPressed: () {
                    Share.share(trip.owner.firstName +
                        t(context, 'is_traveling_from') +
                        trip.source.cityAscii +
                        " ${t(context, 'to')} " +
                        trip.destination.cityAscii +
                        ".\n" +
                        Api.tripLink +
                        trip.id.toString());
                  },
                ),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      trip.source.country,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Icon(
                  MdiIcons.airplane,
                  color: Colors.grey[700],
                  size: 30,
                ),
                Column(
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      trip.destination.country,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                )
              ],
            ),
            Divider(
              height: 13,
              thickness: .5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.date_range,
                        size: 20,
                        color: Colors.grey[700],
                      ),
                      Text(
                        t(context, 'posted_on'),
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        DateFormat("d MMM yyy").format(trip.date),
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        MdiIcons.weightKilogram,
                        size: 20,
                        color: Colors.grey[700],
                      ),
                      Text(
                        t(context, 'weight'),
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        trip.weightLimit.toString() + " ${t(context, 'kg')}",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (trip.description != 'null') Divider(),
            if (trip.description != 'null')
              Text(
                trip.description,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 15,
                  height: 1.1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
