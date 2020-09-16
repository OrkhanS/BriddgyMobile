import 'dart:convert';
import 'dart:io';
import 'package:briddgy/providers/messages.dart';
import 'package:briddgy/widgets/offline_widget.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:briddgy/localization/localization_constants.dart';
import 'package:briddgy/models/api.dart';
import 'package:briddgy/models/trip.dart';
import 'package:briddgy/providers/auth.dart';
import 'package:briddgy/screens/verify_email_screen.dart';
import 'package:briddgy/widgets/progress_indicator_widget.dart';
import 'package:briddgy/widgets/trip_filter_bottom.dart';
import 'package:briddgy/widgets/trip_widget.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:briddgy/providers/ordersandtrips.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:briddgy/screens/add_trip_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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
  bool connectionLost = false;

  bool isLoading = true;
  bool _isfetchingnew = false;
  @override
  void initState() {
    super.initState();
  }

  List _trips = [];

  Future sortData(value, OrdersTripsProvider provider) async {
    provider.isLoadingTrips = true;
    provider.notify();
    String url = Api.trips + "?order_by=";
    if (urlFilter.isNotEmpty) {
      url = urlFilter + "&order_by=";
    }
    if (value == 0) {
      url = Api.trips + "?order_by=-date";
      nextTripURL = "FirstCall";
    } else if (value == 2) {
      url = url + "-owner";
    } else if (value == 3) {
      url = url + "weight_limit";
    }
    await http
        .get(
      url,
      headers: Provider.of<Auth>(context, listen: false).isAuth
          ? {
              HttpHeaders.contentTypeHeader: "application/json",
              "Authorization": "Token " + Provider.of<Auth>(context, listen: false).myTokenFromStorage,
            }
          : {
              HttpHeaders.contentTypeHeader: "application/json",
            },
    )
        .then((response) {
      setState(
        () {
          Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
          _trips = [];
          for (var i = 0; i < data["results"].length; i++) {
            _trips.add(Trip.fromJson(data["results"][i]));
          }
          provider.trips = _trips;
          provider.notify();
          nextTripURL = data["next"];
          provider.isLoadingTrips = false;
        },
      );
    });
  }

  FutureOr<Iterable> getSuggestions(String pattern) async {
    String url = Api.getCities + pattern;
    await http.get(
      url,
      headers: {HttpHeaders.contentTypeHeader: "application/json"},
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
          HttpHeaders.contentTypeHeader: "application/json",
          "Authorization": "Token " + tokenforROOM,
        },
      );
      widget.room.fetchAndSetRooms(widget.auth);
    }
    return null;
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

//TODO
  Future _loadData() async {
    if (nextTripURL.toString() != "null" && nextTripURL.toString() != "FirstCall") {
      String url = nextTripURL;
      try {
        await http.get(
          url,
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            "Authorization": "Token " + widget.token,
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
            //filterAndSetTrips(from, to, weight, _endtime);
            build(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersTripsProvider>(
      builder: (context, orderstripsProvider, child) {
        if (orderstripsProvider.isLoadingTrips == false) {
          _trips = orderstripsProvider.trips;
          if (nextTripURL == "FirstCall") {
            nextTripURL = orderstripsProvider.detailsTrip["next"];
          }
        }
        return Scaffold(
          resizeToAvoidBottomPadding: true,
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (widget.auth.isAuth && !widget.auth.isLoadingUserDetails) {
                if (widget.auth.userdetail.isEmailVerified) {
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
                  flushbarStyle: FlushbarStyle.FLOATING,
                  titleText: Text(
                    "Warning",
                    style: TextStyle(color: Colors.black, fontSize: 22),
                  ),
                  messageText: Text(
                    "You need to Log in to add Item!",
                    style: TextStyle(color: Colors.black),
                  ),
                  icon: Icon(MdiIcons.login),
                  backgroundColor: Colors.white,
//                  borderColor: Colors.red,
                  borderColor: Colors.grey[400],
                  margin: EdgeInsets.only(left: 20, right: 20, bottom: 30),
                  borderRadius: 10,
                  duration: Duration(seconds: 5),
                )..show(context);
              }
            },
            backgroundColor: Theme.of(context).primaryColor,
            child: Icon(Icons.add),
          ),
          bottomNavigationBar: BottomAppBar(
            notchMargin: 10,
            shape: CircularNotchedRectangle(),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: TripFilterBottomBar(ordersProvider: widget.orderstripsProvider),
            ),
          ),
          body: SafeArea(
            child: Stack(
              children: <Widget>[
                OfflineBuilder(
                  connectivityBuilder: (
                    BuildContext context,
                    ConnectivityResult connectivity,
                    Widget child,
                  ) {
                    final bool connected = connectivity != ConnectivityResult.none;
                    if (!connected)
                      connectionLost = true;
                    else {
                      if (connectionLost) {
                        widget.orderstripsProvider.fetchAndSetOrders();
                        widget.orderstripsProvider.fetchAndSetTrips();
                        Provider.of<Messages>(context, listen: false).fetchAndSetRooms(widget.auth, false);
                      }
                    }
                    return !connected
                        ? OfflineWidget()
                        : Column(
                            children: <Widget>[
//                    FilterBarTrip(ordersProvider: widget.orderstripsProvider, from: from, to: to, weight: weight),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                                  Text(
                                    orderstripsProvider.detailsTrip.isEmpty
                                        ? "${t(context, 'result_plural')}: 0"
                                        : "${t(context, 'result_plural')}: " + orderstripsProvider.detailsTrip["count"].toString(),
                                    style: TextStyle(fontSize: 15, color: Colors.grey[500], fontWeight: FontWeight.bold),
                                  ),
//                        DropdownButton(
//                          hint: Text(_value),
//                          items: [
//                            DropdownMenuItem(
//                              value: 0,
//                              child: Text(
//                                "Reset",
//                              ),
//                            ),
//                            DropdownMenuItem(
//                              value: 1,
//                              child: Text(
//                                "Ranking",
//                              ),
//                            ),
//                            DropdownMenuItem(
//                              value: 2,
//                              child: Text(
//                                "Weight",
//                              ),
//                            ),
//                          ],
//                          onChanged: (value) {
//                            sortData(value, orderstripsProvider);
//                          },
//                        ),
                                ]),
                              ),
                              Expanded(
                                child: orderstripsProvider.notLoaded != false
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
                                        child: _trips.length == 0
                                            ? Center(
                                                child: Padding(
                                                padding: const EdgeInsets.all(20.0),
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      height: MediaQuery.of(context).size.height * 0.4,
                                                      padding: EdgeInsets.symmetric(horizontal: 40),
                                                      child: SvgPicture.asset(
                                                        "assets/photos/empty_order.svg",
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                                      child: Text(
                                                        t(context, 'empty_results'),
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 25,
                                                          color: Colors.grey[500],
                                                        ),
                                                      ),
                                                    ),
                                                    Spacer(),
                                                  ],
                                                ),
                                              ))
                                            : ListView.builder(
                                                itemBuilder: (context, int i) {
                                                  return TripWidget(trip: _trips[i], i: i);
                                                },
                                                itemCount: _trips == null ? 0 : _trips.length,
                                              ),
                                      ),
                              ),
                            ],
                          );
                  },
                  child: SizedBox(),
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
