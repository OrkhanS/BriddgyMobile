import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:animations/animations.dart';
import 'package:briddgy/providers/messages.dart';
import 'package:briddgy/widgets/offline_widget.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:briddgy/localization/demo_localization.dart';
import 'package:briddgy/localization/localization_constants.dart';
import 'package:briddgy/models/api.dart';
import 'package:briddgy/models/order.dart';
import 'package:briddgy/providers/auth.dart';
import 'package:briddgy/screens/add_order_screen.dart';
import 'package:briddgy/screens/verify_email_screen.dart';
import 'package:briddgy/screens/verify_phone_screen.dart';
import 'package:briddgy/widgets/order_filter_bottom.dart';
import 'package:briddgy/widgets/order_widget.dart';
import 'package:briddgy/widgets/progress_indicator_widget.dart';
import 'package:provider/provider.dart';
import 'package:briddgy/providers/ordersandtrips.dart';
import 'package:briddgy/main.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';
  OrdersTripsProvider orderstripsProvider;

  var token, room, auth;
  OrdersScreen({this.orderstripsProvider, this.token, this.auth, this.room});

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool expands = false;
  var filterColor = Colors.white;
  DateTime startDate = DateTime.now();
  String imageUrl;
  bool flagFrom = false;
  bool flagTo = false;
  bool flagWeight = false;
  String from, to;
  String _value = "Sort By";
  String weight, price;
  bool _isfetchingnew = false;
  final formKey = new GlobalKey<FormState>();
  String nextOrderURL = "FirstCall";
  List _suggested = [];
  List _cities = [];
  List _orders = [];
  bool connectionLost = false;
  bool newMessage = false;

  @override
  void initState() {
    super.initState();
  }

  String urlFilter = "";
  String _myActivity;
  String _myActivityResult;

  Future sortData(value, OrdersTripsProvider provider) async {
    provider.isLoadingOrders = true;
    provider.notify();
    String url = Api.orders + "?order_by=";
    if (urlFilter.isNotEmpty) {
      url = urlFilter + "&order_by=";
    }
    if (value == 0) {
      url = Api.orders + "?order_by=-date";
      nextOrderURL = "FirstCall";
    } else if (value == 1) {
      url = url + "-owner";
    } else if (value == 2) {
      url = url + "-price";
    } else if (value == 3) {
      url = url + "weight";
    }
    provider.isLoadingOrders = true;
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
          _orders = [];
          for (var i = 0; i < data["results"].length; i++) {
            _orders.add(Order.fromJson(data["results"][i]));
          }
          provider.orders = _orders;
          nextOrderURL = data["next"];
          provider.isLoadingOrders = false;
          provider.notify();
        },
      );
    });
  }

  _saveForm() {
    var form = formKey.currentState;
    if (form.validate()) {
      form.save();
      setState(() {
        _myActivityResult = _myActivity;
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  FutureOr<Iterable> getSuggestions(String pattern) async {
    String url = Api.getCities + pattern;
    await http.get(
      url,
      headers: {HttpHeaders.contentTypeHeader: "application/json"},
    ).then((response) {
      setState(
        () {
          Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;

          for (var i = 0; i < data["results"].length; i++) {
            _suggested.add(Order.fromJson(data["results"][i]));
          }
          // isLoading = false;
        },
      );
    });
    _cities = [];
    for (var i = 0; i < _suggested.length; i++) {
      _cities.add(_suggested[i]["city_ascii"].toString() + ", " + _suggested[i]["country"].toString() + ", " + _suggested[i]["id"].toString());
    }
    return _cities;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _loadData() async {
    if (nextOrderURL.toString() != "null" && nextOrderURL.toString() != "FirstCall") {
      String url = nextOrderURL;
      try {
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
          Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
          for (var i = 0; i < data["results"].length; i++) {
            _orders.add(Order.fromJson(data["results"][i]));
          }
          nextOrderURL = data["next"];
        });
      } catch (e) {
        print("Some Error");
      }
      setState(() {
        _isfetchingnew = false;
      });
    } else {
      _isfetchingnew = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersTripsProvider>(
      builder: (context, orderstripsProvider, child) {
        _orders = [];
        _orders = orderstripsProvider.orders;
        if (nextOrderURL == "FirstCall") {
          nextOrderURL = orderstripsProvider.detailsOrder["next"];
        }
        return Scaffold(
          bottomNavigationBar: BottomAppBar(
            notchMargin: 8,
            shape: CircularNotchedRectangle(),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: OrderFilterBottomBar(ordersProvider: orderstripsProvider),
            ),
          ),
          resizeToAvoidBottomPadding: true,
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (widget.auth.isAuth && !widget.auth.isLoadingUserDetails) {
                if (widget.auth.userdetail.isEmailVerified) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (__) => AddOrderScreen()),
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
            backgroundColor: Colors.white,
            child: Icon(
              Icons.add,
              color: Theme.of(context).primaryColor,
            ),
          ),
          // OpenContainer(
          //   openElevation: 5,
          //   transitionDuration: Duration(milliseconds: 500),
          //   transitionType: ContainerTransitionType.fadeThrough,
          //   openBuilder: (BuildContext context, VoidCallback _) {
          //     return
          //   },
          //   closedElevation: 6.0,
          //   closedShape: const RoundedRectangleBorder(
          //     borderRadius: BorderRadius.all(
          //       Radius.circular(56 / 2),
          //     ),
          //   ),
          //   closedColor: Colors.white,
          //   closedBuilder: (BuildContext context, VoidCallback openContainer) {
          //     return SizedBox(
          //       height: 56,
          //       width: 56,
          //       child: Center(
          //         child: Icon(
          //           Icons.add,
          //           size: 30,
          //           color: Theme.of(context).primaryColor,
          //         ),
          //       ),
          //     );
          //   },
          // ),
          body: SafeArea(
            child: Stack(
              children: <Widget>[
//                 OfflineBuilder(
//                   connectivityBuilder: (
//                     BuildContext context,
//                     ConnectivityResult connectivity,
//                     Widget child,
//                   ) {
//                     final bool connected = connectivity != ConnectivityResult.none;
//                     if (!connected)
//                       connectionLost = true;
//                     else {
//                       if (connectionLost) {
//                         widget.orderstripsProvider.fetchAndSetOrders();
//                         widget.orderstripsProvider.fetchAndSetTrips();
//                         Provider.of<Messages>(context, listen: false).fetchAndSetRooms(widget.auth, false);
//                       }
//                     }
//                     return !connected
//                         ? OfflineWidget()
//                         : Column(
//                             children: <Widget>[
// //                    FilterBar(ordersProvider: orderstripsProvider, from: from, to: to, weight: weight, price: price),
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
//                                 child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
// //                        Expanded(child: SizedBox()),
//                                   Text(
//                                     orderstripsProvider.detailsOrder.isEmpty
//                                         ? t(context, 'result_plural') + ': 0'
//                                         : t(context, 'result_plural') + ": " + orderstripsProvider.detailsOrder["count"].toString(),
//                                     style: TextStyle(fontSize: 15, color: Colors.grey[500], fontWeight: FontWeight.bold),
//                                   ),
// //                        DropdownButton(
// //                          hint: Text(_value),
// //                          items: [
// //                            DropdownMenuItem(
// //                              value: 0,
// //                              child: Text(
// //                                "Reset",
// //                              ),
// //                            ),
// //                            DropdownMenuItem(
// //                              value: 1,
// //                              child: Text("Highest Ranking"),
// //                            ),
// //                            DropdownMenuItem(value: 2, child: Text("Highest Reward")),
// //                            DropdownMenuItem(
// //                              value: 3,
// //                              child: Text(
// //                                "Lowest Weight",
// //                              ),
// //                            ),
// //                          ],
// //                          onChanged: (value) {
// //                            sortData(value, orderstripsProvider);
// //                          },
// //                        ),
//                                 ]),
//                               ),
//                               Expanded(
//                                 child: orderstripsProvider.isLoadingOrders
//                                     ? ListView(
//                                         children: <Widget>[
//                                           for (var i = 0; i < 10; i++) OrderFadeWidget(),
//                                         ],
//                                       )
//                                     : NotificationListener<ScrollNotification>(
//                                         onNotification: (ScrollNotification scrollInfo) {
//                                           if (!_isfetchingnew && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
//                                             // start loading data
//                                             setState(() {
//                                               _isfetchingnew = true;
//                                             });
//                                             _loadData();
//
//                                             return true;
//                                           }
//                                           return false;
//                                         },
//                                         child: _orders.length == 0
//                                             ? Center(
//                                                 child: Padding(
//                                                 padding: const EdgeInsets.all(20.0),
//                                                 child: Column(
//                                                   children: [
//                                                     Container(
//                                                       height: MediaQuery.of(context).size.height * 0.3,
//                                                       padding: EdgeInsets.symmetric(horizontal: 40),
//                                                       child: SvgPicture.asset(
//                                                         "assets/photos/empty_order.svg",
//                                                       ),
//                                                     ),
//                                                     Spacer(),
//                                                     Padding(
//                                                       padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                                                       child: Text(
//                                                         t(context, 'empty_results'),
//                                                         textAlign: TextAlign.center,
//                                                         style: TextStyle(
//                                                           fontSize: 25,
//                                                           color: Colors.grey[500],
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     Spacer(),
//                                                   ],
//                                                 ),
//                                               ))
//                                             : ListView.builder(
//                                                 itemBuilder: (context, int i) {
//                                                   if (i + 1 == _orders.length)
//                                                     return Column(
//                                                       children: <Widget>[
//                                                         OrderWidget(
//                                                           order: _orders[i],
//                                                           i: i,
//                                                         ),
//                                                         SizedBox(
//                                                           height: 80,
//                                                         ),
//                                                       ],
//                                                     );
//                                                   else
//                                                     return OrderWidget(
//                                                       order: _orders[i],
//                                                       i: i,
//                                                     );
//
// //                              return OrderFadeWidget();
//                                                 },
//                                                 itemCount: _orders.length,
//                                               ),
//                                       ),
//                               ),
//                             ],
//                           );
//                   },
//                   child: SizedBox(),
//                 ),
                Column(
                  children: <Widget>[
//                    FilterBar(ordersProvider: orderstripsProvider, from: from, to: to, weight: weight, price: price),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
//                        Expanded(child: SizedBox()),
                        Text(
                          orderstripsProvider.detailsOrder.isEmpty
                              ? t(context, 'result_plural') + ': 0'
                              : t(context, 'result_plural') + ": " + orderstripsProvider.detailsOrder["count"].toString(),
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
//                              child: Text("Highest Ranking"),
//                            ),
//                            DropdownMenuItem(value: 2, child: Text("Highest Reward")),
//                            DropdownMenuItem(
//                              value: 3,
//                              child: Text(
//                                "Lowest Weight",
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
                      child: orderstripsProvider.isLoadingOrders
                          ? ListView(
                        children: <Widget>[
                          for (var i = 0; i < 10; i++) OrderFadeWidget(),
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

                            return true;
                          }
                          return false;
                        },
                        child: _orders.length == 0
                            ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Container(
                                    height: MediaQuery.of(context).size.height * 0.3,
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
                            if (i + 1 == _orders.length)
                              return Column(
                                children: <Widget>[
                                  OrderWidget(
                                    order: _orders[i],
                                    i: i,
                                  ),
                                  SizedBox(
                                    height: 80,
                                  ),
                                ],
                              );
                            else
                              return OrderWidget(
                                order: _orders[i],
                                i: i,
                              );

//                              return OrderFadeWidget();
                          },
                          itemCount: _orders.length,
                        ),
                      ),
                    ),
                  ],
                ),
                ProgressIndicatorWidget(show: _isfetchingnew),
              ],
            ),
          ),
        );
      },
    );
  }
}
