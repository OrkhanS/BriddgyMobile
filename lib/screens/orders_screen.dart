import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:animations/animations.dart';
import 'package:flushbar/flushbar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:optisend/models/api.dart';
import 'package:optisend/models/order.dart';
import 'package:optisend/providers/auth.dart';
import 'package:optisend/screens/add_item_screen.dart';
import 'package:optisend/screens/verify_email_screen.dart';
import 'package:optisend/widgets/order_widget.dart';
import 'package:optisend/widgets/progress_indicator_widget.dart';
import 'package:provider/provider.dart';
import 'package:optisend/widgets/filter_bar.dart';
import 'package:optisend/providers/ordersandtrips.dart';

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

  @override
  void initState() {
    if (widget.orderstripsProvider.notLoadingOrders) {
      widget.orderstripsProvider.fetchAndSetOrders();
    }
    super.initState();
  }

  String urlFilter = "";
  String _myActivity;
  String _myActivityResult;

  Future sortData(value, OrdersTripsProvider provider) async {
    provider.isLoadingOrders = true; provider.notify();
    String url = Api.orders + "?order_by=";
    if (urlFilter.isNotEmpty) {
      url = urlFilter + "&order_by=";
    }
    if(value == 0){
      url = Api.orders + "?order_by=-date";
      nextOrderURL = "FirstCall";
    }
    else if (value == 1) {
      url = url + "-owner";
    } else if (value == 2) {
      url = url + "-price";
    } else if (value == 3) {
      url = url + "weight";
    }
    await http.get(
      url,
      headers:Provider.of<Auth>(context, listen: false).isAuth
          ? {
              HttpHeaders.contentTypeHeader: "application/json",
              "Authorization": "Token " + Provider.of<Auth>(context, listen: false).myTokenFromStorage,
            }
          : {
              HttpHeaders.contentTypeHeader: "application/json",
            }, 
    ).then((response) {
      setState(
        () {
          Map<String, dynamic> data =
          json.decode(response.body) as Map<String, dynamic>;
          _orders=[];
          for (var i = 0; i < data["results"].length; i++) {
            _orders.add(Order.fromJson(data["results"][i]));
          }
          provider.orders = _orders;
          nextOrderURL = data["next"];
          provider.isLoadingOrders = false; provider.notify();
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
    String url = Api.getSuggestions + pattern;
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
//    return Form(
  Future _loadData() async {
    if (nextOrderURL.toString() != "null" && nextOrderURL.toString() != "FristCall") {
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
        if (orderstripsProvider.isLoadingOrders == false) {
          _orders = orderstripsProvider.orders;
          if (nextOrderURL == "FirstCall") {
            nextOrderURL = orderstripsProvider.detailsOrder["next"];
          }
        }

        return Scaffold(
          resizeToAvoidBottomPadding: true,
          floatingActionButton: OpenContainer(
            openElevation: 5,
            transitionDuration: Duration(milliseconds: 500),
            transitionType: ContainerTransitionType.fadeThrough,
            openBuilder: (BuildContext context, VoidCallback _) {
              return AddItemScreen();
            },
            closedElevation: 6.0,
            closedShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(56 / 2),
              ),
            ),
            closedColor: Colors.white,
            closedBuilder: (BuildContext context, VoidCallback openContainer) {
              return SizedBox(
                height: 56,
                width: 56,
                child: Center(
                  child: Icon(
                    Icons.add,
                    size: 30,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              );
            },
          ),
          body: SafeArea(
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    FilterBar(ordersProvider: orderstripsProvider, from: from, to: to, weight: weight, price: price),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                        Text(
                          orderstripsProvider.detailsOrder.isEmpty
                              ? "Results: 0"
                              : "Results: " + orderstripsProvider.detailsOrder["count"].toString(),
                          style: TextStyle(fontSize: 15, color: Colors.grey[500], fontWeight: FontWeight.bold),
                        ),
                        DropdownButton(
                          hint: Text(_value),
                          items: [
                            DropdownMenuItem(value: 0,child: Text("Reset",),),
                            DropdownMenuItem(value: 1,child: Text("Highest Ranking"),),
                            DropdownMenuItem(value: 2,child: Text("Highest Reward")),
                            DropdownMenuItem(value: 3,child: Text("Lowest Weight", ),),
                          ],
                          onChanged: (value) {
                            sortData(value, orderstripsProvider);
                          },
                        ),
                      ]),
                    ),
                    Expanded(
                      child: orderstripsProvider.notLoadingOrders
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
                              child: ListView.builder(
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
