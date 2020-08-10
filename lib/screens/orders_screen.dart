import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flushbar/flushbar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:optisend/models/api.dart';
import 'package:optisend/models/order.dart';
import 'package:optisend/providers/auth.dart';
import 'package:optisend/screens/add_item_screen.dart';
import 'package:optisend/screens/verifyEmail_screen.dart';
import 'package:optisend/widgets/order_widget.dart';
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
  String nextOrderURL;
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
    String url = Api.orders + "?order_by=";
    if (urlFilter.isNotEmpty) {
      url = urlFilter + "&order_by=";
    }
    if (value.toString().compareTo("WeightLow") == 0) {
      url = url + "weight";
    } else if (value.toString().compareTo("WeightMax") == 0) {
      url = url + "-weight";
    } else if (value.toString().compareTo("Price") == 0) {
      url = url + "-price";
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
          provider.orders = dataOrders["results"];
          provider.isLoading = false;
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

  @override //todo: check for future
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  FutureOr<Iterable> getSuggestions(String pattern) async {
    String url = Api.getSuggestions + pattern;
    await http.get(
      url,
      headers: {HttpHeaders.CONTENT_TYPE: "application/json"},
    ).then((response) {
      setState(
        () {
          Map<String, dynamic> data =
              json.decode(response.body) as Map<String, dynamic>;

          for (var i = 0; i < data["results"].length; i++) {
            _suggested.add(Order.fromJson(data["results"][i]));
          }
          // isLoading = false;
        },
      );
    });
    _cities = [];
    for (var i = 0; i < _suggested.length; i++) {
      _cities.add(_suggested[i]["city_ascii"].toString() +
          ", " +
          _suggested[i]["country"].toString() +
          ", " +
          _suggested[i]["id"].toString());
    }
    return _cities;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future filterAndSetOrders(provider, from, to, weight, price) async {
    urlFilter = Api.orders + "?";
    if (from != null) {
      urlFilter = urlFilter + "origin=" + from;
      flagFrom = true;
    }
    if (to != null) {
      flagFrom == false
          ? urlFilter = urlFilter + "dest=" + to.toString()
          : urlFilter = urlFilter + "&dest=" + to.toString();
      flagTo = true;
    }
    if (weight != null) {
      flagTo == false && flagFrom == false
          ? urlFilter = urlFilter + "weight=" + weight.toString()
          : urlFilter = urlFilter + "&weight=" + weight.toString();
      flagWeight = true;
    }
    if (price != null) {
      flagWeight == false && flagTo == false && flagFrom == false
          ? urlFilter = urlFilter + "min_price=" + price.toString()
          : urlFilter = urlFilter + "&min_price=" + price.toString();
    }
    await http.get(
      urlFilter,
      headers: {
        HttpHeaders.CONTENT_TYPE: "application/json",
        "Authorization":
            "Token " + Provider.of<Auth>(context, listen: true).token
      },
    ).then((response) {
      setState(
        () {
          final dataOrders = json.decode(response.body) as Map<String, dynamic>;
          provider.orders = dataOrders["results"];
          provider.isLoading = false;
          // _itemCount = dataOrders["count"];
        },
      );
    });
  }
//    return Form(

  @override
  Widget build(BuildContext context) {
    Future _loadData() async {
      if (nextOrderURL.toString() != "null" &&
          nextOrderURL.toString() != "FristCall") {
        String url = nextOrderURL;
        try {
          await http.get(
            url,
            headers: {
              HttpHeaders.CONTENT_TYPE: "application/json",
              "Authorization": "Token " + widget.token,
            },
          ).then((response) {
            var dataOrders = json.decode(response.body) as Map<String, dynamic>;
            _orders.addAll(dataOrders["results"]);
            nextOrderURL = dataOrders["next"];
          });
        } catch (e) {
          print("Some Error");
        }
        setState(() {
//        items.addAll( ['item 1']);
//        print('items: '+ items.toString());
          _isfetchingnew = false;
        });
      } else {
        _isfetchingnew = false;
      }
    }

    //print(widget.orderstripsProvider.orders);
    return Consumer<OrdersTripsProvider>(
      builder: (context, orderstripsProvider, child) {
        if (orderstripsProvider.isLoadingOrders == false) {
          _orders = orderstripsProvider.orders;
          if (nextOrderURL == "FirstCall") {
            nextOrderURL = orderstripsProvider.detailsOrder["next"];
          }
          //messageLoader = false;
        } else {
          //messageLoader = true;
        }

        return Scaffold(
          resizeToAvoidBottomPadding: true,
          floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            child: Icon(Icons.add),
            onPressed: () {
              if (widget.auth.isAuth) {
                if (widget.auth.userdetail.isEmailVerified == true) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (__) => AddItemScreen(
                              token: widget.token,
                              orderstripsProvider: widget.orderstripsProvider,
                            )),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (__) => AddItemScreen(
                              token: widget.token,
                              orderstripsProvider: widget.orderstripsProvider,
                            )),
                  );
                  //todo remove comments
//                  Navigator.push(
//                    context,
//                    MaterialPageRoute(builder: (__) => VerifyEmailScreen()),
//                  );
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
          ),
          body: SafeArea(
            child: Column(
              children: <Widget>[
                FilterBar(
                    ordersProvider: orderstripsProvider,
                    from: from,
                    to: to,
                    weight: weight,
                    price: price),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Results: " +
                              orderstripsProvider.orders.length.toString(),
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.bold),
                        ),
                        DropdownButton(
                          hint: Text(_value),
                          items: [
                            DropdownMenuItem(
                              value: "Ranking",
                              child: Text("Highest Ranking"),
                            ),
                            DropdownMenuItem(
                                value: "Price", child: Text("Highest Reward")),
                            DropdownMenuItem(
                              value: "WeightLow",
                              child: Text(
                                "Lowest Weight",
                              ),
                            ),
                            DropdownMenuItem(
                              value: "WeightMax",
                              child: Text(
                                "Highest Weight",
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            sortData(value, orderstripsProvider);
                          },
                        ),
                      ]),
                ),
                Expanded(
                  child: orderstripsProvider.notLoadingOrders
                      ? Center(child: CircularProgressIndicator())
                      : NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (!_isfetchingnew &&
                                scrollInfo.metrics.pixels ==
                                    scrollInfo.metrics.maxScrollExtent) {
                              // start loading data
                              setState(() {
                                _isfetchingnew = true;
                              });
                              _loadData();
                            }
                          },
                          child: ListView.builder(
                            itemBuilder: (context, int i) {
                              return OrderWidget(
                                order: _orders[i],
                                i: i,
                              );
                            },
                            itemCount: _orders.length,
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
