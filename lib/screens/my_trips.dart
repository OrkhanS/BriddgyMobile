import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optisend/models/api.dart';
import 'package:optisend/providers/auth.dart';
import 'package:optisend/widgets/trip_widget.dart';
import 'package:provider/provider.dart';
import 'package:optisend/providers/ordersandtrips.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/gestures.dart';

class MyTrips extends StatefulWidget {
  var token, orderstripsProvider;
  MyTrips({this.token, this.orderstripsProvider});
  static const routeName = '/account/mytrips';

  @override
  _MyTripsState createState() => _MyTripsState();
}

class _MyTripsState extends State<MyTrips> {
  List _trips = [];
  bool isLoading = true;
  bool _isfetchingnew = false;
  String nextTripURL = "FristCall";

  @override
  void initState() {
    if (widget.orderstripsProvider.myorders.isEmpty) {
      widget.orderstripsProvider.fetchAndSetMyTrips(widget.token);
    }
    super.initState();
  }

  @override //Todo: check
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    Future _loadData() async {
      if (nextTripURL.toString() != "null" && nextTripURL.toString() != "FristCall") {
        String url = nextTripURL;
        try {
          await http.get(
            url,
            headers: {
              HttpHeaders.CONTENT_TYPE: "application/json",
              "Authorization": "Token " + Provider.of<Auth>(context).myToken,
            },
          ).then((response) {
            var dataOrders = json.decode(response.body) as Map<String, dynamic>;
            _trips.addAll(dataOrders["results"]);
            nextTripURL = dataOrders["next"];
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
          //messageLoader = false;
        } else {
          //messageLoader = true;
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
                      "My Trips",
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
                    child: orderstripsProvider.isLoading
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
                Container(
                  height: _isfetchingnew ? 100.0 : 0.0,
                  color: Colors.transparent,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
