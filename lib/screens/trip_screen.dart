import 'dart:convert';
import 'dart:io';
import 'package:flushbar/flushbar.dart';
import 'package:http/http.dart' as http;
import 'package:optisend/models/api.dart';
import 'package:optisend/screens/verifyEmail_screen.dart';
import 'package:optisend/widgets/filter_bar.dart';
import 'package:optisend/widgets/trip_widget.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:optisend/providers/ordersandtrips.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:optisend/screens/add_trip_screen.dart';

class TripsScreen extends StatefulWidget {
  OrdersTripsProvider orderstripsProvider;
  var token, room, auth;
  TripsScreen({this.orderstripsProvider, this.token, this.room, this.auth});
  static const routeName = '/trip';
  @override
  _TripScreenState createState() => _TripScreenState();
}

class _TripScreenState extends State<TripsScreen> {
  bool expands = true;
  String _endtime = "Until";
  String _time = "Not set";
  DateTime startDate = DateTime.now();
  String imageUrl;
  String nextTripURL = "FirstCall";
  List _suggested = [];
  List _cities = [];
  bool flagFrom = false;
  bool flagTo = false;
  bool flagWeight = false;
  bool flagStart = false;
  String from, to;
  String weight, price;
  String _value = "Sort By";
  final formKey = new GlobalKey<FormState>();
  String urlFilter = "";

  bool isLoading = true;
  bool _isfetchingnew = false;
  @override
  void initState() {
    if (widget.orderstripsProvider.notLoaded) {
      widget.orderstripsProvider.fetchAndSetTrips();
    }
    super.initState();
  }

  List _trips = [];

  Future filterAndSetTrips(from, to, weight, _endtime) async {
    var provider = widget.orderstripsProvider;
    _endtime = null;
    urlFilter = Api.trips + "?";
    if (from != null) {
      urlFilter = urlFilter + "origin=" + from;
      flagFrom = true;
    }
    if (to != null) {
      flagFrom == false ? urlFilter = urlFilter + "dest=" + to.toString() : urlFilter = urlFilter + "&dest=" + to.toString();
      flagTo = true;
    }
    if (weight != null) {
      flagTo == false && flagFrom == false
          ? urlFilter = urlFilter + "weight=" + weight.toString()
          : urlFilter = urlFilter + "&weight=" + weight.toString();
      flagWeight = true;
    }

    if (_endtime != null) {
      flagWeight == false && flagTo == false && flagFrom == false && flagStart == false
          ? urlFilter = urlFilter + "end_date=" + _endtime.toString()
          : urlFilter = urlFilter + "&end_date=" + _endtime.toString();
      flagStart = true;
    }
    await http.get(
      urlFilter,
      headers: {HttpHeaders.CONTENT_TYPE: "application/json"},
    ).then((response) {
      setState(
        () {
          final dataOrders = json.decode(response.body) as Map<String, dynamic>;
          provider.trips = dataOrders["results"];
          provider.isLoading = false;
        },
      );
    });
  }

  Future sortData(value, OrdersTripsProvider provider) async {
    String url = Api.trips + "?order_by=";
    if (urlFilter.isNotEmpty) {
      url = urlFilter + "&order_by=";
    }
    if (value.toString().compareTo("WeightMax") == 0) {
      url = url + "-weight_limit";
    } else if (value.toString().compareTo("Ranking") == 0) {
      url = url + "-owner";
    }
    await http.get(
      url,
      headers: {
        HttpHeaders.CONTENT_TYPE: "application/json",
        "Authorization": "Token " + widget.token,
      },
    ).then((response) {
      setState(
        () {
          final dataOrders = json.decode(response.body) as Map<String, dynamic>;
          provider.trips = dataOrders["results"];
          provider.isLoading = false;
        },
      );
    });
  }

  FutureOr<Iterable> getSuggestions(String pattern) async {
    String url = Api.getSuggestions + pattern;
    await http.get(
      url,
      headers: {HttpHeaders.CONTENT_TYPE: "application/json"},
    ).then((response) {
      setState(
        () {
          final dataOrders = json.decode(response.body) as Map<String, dynamic>;
          _suggested = dataOrders["results"];
          isLoading = false;
        },
      );
    });
    _cities = [];
    for (var i = 0; i < _suggested.length; i++) {
      _cities.add(_suggested[i]["city_ascii"].toString() + ", " + _suggested[i]["country"].toString() + ", " + _suggested[i]["id"].toString());
    }
    return _cities;
  }

  Future createRooms(id) async {
    String tokenforROOM = widget.token;
    if (tokenforROOM != null) {
      String url = Api.itemConnectOwner + id.toString();
      final response = await http.get(
        url,
        headers: {
          HttpHeaders.CONTENT_TYPE: "application/json",
          "Authorization": "Token " + tokenforROOM,
        },
      );
      widget.room.fetchAndSetRooms(widget.auth);
    }
    return null;
  }

  @override //Todo: check
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Widget button() {
    return Padding(
      padding: const EdgeInsets.all(22.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: RaisedButton(
          color: Theme.of(context).primaryColor,

          elevation: 2,
//                            color: Theme.of(context).primaryColor,
          child: Container(
            decoration: BoxDecoration(),
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text(
                "SEARCH",
                style: TextStyle(
                  fontSize: 19,
                  color: Colors.white,
//                                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          onPressed: () {
            filterAndSetTrips(from, to, weight, _endtime);
            build(context);
          },
        ),
      ),
    );
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
              "Authorization": "Token " + widget.token,
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
      builder: (context, tripsProvider, child) {
        if (tripsProvider.trips.length != 0) {
          _trips = tripsProvider.trips;
          if (nextTripURL == "FirstCall") {
            nextTripURL = tripsProvider.detailsTrip["next"];
          }
        } else {}
        return Scaffold(
          resizeToAvoidBottomPadding: true,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (widget.auth.isAuth) {
                if (widget.auth.userdetail.isEmailVerified == true) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (__) => AddTripScreen(
                              token: widget.token,
                              orderstripsProvider: widget.orderstripsProvider,
                            )),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (__) => VerifyEmailScreen()),
                  );
                }
              } else {
                Flushbar(
                  title: "Warning",
                  message: "You need to Log in to add Item!",
                  padding: const EdgeInsets.all(8),
                  borderRadius: 10,
                  duration: Duration(seconds: 3),
                )..show(context);
              }
            },
            backgroundColor: Theme.of(context).primaryColor,
            child: Icon(Icons.add),
          ),
          body: SafeArea(
            child: Column(
              children: <Widget>[
                FilterBar(ordersProvider: widget.orderstripsProvider, from: from, to: to, weight: weight),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                    Text(
                      "Results: " + _trips.length.toString(),
                      style: TextStyle(fontSize: 15, color: Colors.grey[500], fontWeight: FontWeight.bold),
                    ),
                    DropdownButton(
                      hint: Text(_value),
                      items: [
                        DropdownMenuItem(
                          value: "Ranking",
                          child: Text(
                            "Ranking",
                          ),
                        ),
                        DropdownMenuItem(
                          value: "WeightMax",
                          child: Text(
                            "Weight Limit",
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        sortData(value, tripsProvider);
                      },
                    ),
                  ]),
                ),
                Expanded(
                  child: tripsProvider.notLoaded != false
                      ? ListView(
                          children: <Widget>[
                            for (var i = 0; i < 10; i++) TripFadeWidget(),
                          ],
                        )
                      : NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (!_isfetchingnew && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                              // start loading data
                              setState(() {
                                _isfetchingnew = true;
                              });
                              _loadData();
                            }
                          },
                          child: ListView.builder(
                            itemBuilder: (context, int i) {
                              return TripWidget(trip: _trips[i], i: i);
                            },
                            itemCount: _trips == null ? 0 : _trips.length,
                          ),
                        ),
                ),
                Container(
                  height: _isfetchingnew ? 50.0 : 0.0,
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
