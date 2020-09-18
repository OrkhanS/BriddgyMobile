import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:briddgy/localization/localization_constants.dart';
import 'package:briddgy/models/api.dart';
import 'package:briddgy/models/trip.dart';
import 'package:briddgy/providers/auth.dart';
import 'package:briddgy/widgets/progress_indicator_widget.dart';
import 'package:briddgy/widgets/trip_widget.dart';
import 'package:provider/provider.dart';
import 'package:briddgy/providers/ordersandtrips.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/gestures.dart';

class MyTripsScreen extends StatefulWidget {
  var token, orderstripsProvider;
  MyTripsScreen({this.token, this.orderstripsProvider});
  static const routeName = '/account/mytrips';

  @override
  _MyTripsScreenState createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  List _trips = [];
  bool isLoading = true;
  bool _isfetchingnew = false;
  String nextTripURL = "FirstCall";

  @override
  void initState() {
    if (widget.orderstripsProvider != null) {
      if (widget.orderstripsProvider.mytrips.isEmpty) {
        widget.orderstripsProvider.fetchAndSetMyTrips(widget.token);
      }
    }
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    Future _loadData() async {
      if (nextTripURL.toString() != "null" && nextTripURL.toString() != "FirstCall") {
        String url = nextTripURL;
        try {
          await http.get(
            url,
            headers: {
              HttpHeaders.contentTypeHeader: "application/json",
              "Authorization": "Token " + Provider.of<Auth>(context, listen: false).myTokenFromStorage,
            },
          ).then((response) {
            Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
            for (var i = 0; i < data["results"].length; i++) {
              _trips.add(Trip.fromJson(data["results"][i]));
            }
            nextTripURL = data["next"];
          });
        } catch (e) {}
        setState(() {
          _isfetchingnew = false;
        });
      } else {
        _isfetchingnew = false;
      }
    }

    return Consumer<OrdersTripsProvider>(
      builder: (context, orderstripsProvider, child) {
        if (orderstripsProvider.mytrips.length != 0) {
          _trips = orderstripsProvider.mytrips;
          if (nextTripURL == "FirstCall") {
            nextTripURL = orderstripsProvider.detailsMyTrip["next"];
          }
        }
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: AppBar(
                    backgroundColor: Colors.white,
                    centerTitle: true,
                    leading: IconButton(
                      color: Theme.of(context).primaryColor,
                      icon: Icon(
                        Icons.chevron_left,
                        size: 24,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    title: Text(
                      t(context, 'my-trips'),
                      style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                    ),
                    elevation: 1,
                  ),
                ),
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (!_isfetchingnew && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                        // start loading data
                        setState(() {
                          _isfetchingnew = true;
                        });
                        _loadData();
                      }
                    },
                    child: orderstripsProvider.loadedMyTrips
                        ? ListView(
                            children: <Widget>[
                              for (var i = 0; i < 5; i++) TripFadeWidget(),
                            ],
                          )
                        : ListView.builder(
                            itemBuilder: (context, int i) {
                              return TripWidget(
                                trip: _trips[i],
                                i: i,
                              );
                            },
                            itemCount: _trips.length,
                          ),
                  ),
                ),
                ProgressIndicatorWidget(
                  show: _isfetchingnew,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
