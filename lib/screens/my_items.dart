import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:optisend/providers/auth.dart';
import 'package:optisend/widgets/order_widget.dart';
import 'package:provider/provider.dart';
import 'package:optisend/providers/ordersandtrips.dart';

class MyItems extends StatefulWidget {
  var token, orderstripsProvider;
  MyItems({this.token, this.orderstripsProvider});
  static const routeName = '/account/myitems';

  @override
  _MyItemsState createState() => _MyItemsState();
}

class _MyItemsState extends State<MyItems> {
  List _orders = [];
  bool isLoading = true;
  bool _isfetchingnew = false;
  String nextOrderURL = "FirstCall";

  @override
  void initState() {
    if (widget.orderstripsProvider.myorders.isEmpty) {
      widget.orderstripsProvider.fetchAndSetMyOrders(widget.token);
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
      if (nextOrderURL.toString() != "null" &&
          nextOrderURL.toString() != "FristCall") {
        String url = nextOrderURL;
        try {
          await http.get(
            url,
            headers: {
              HttpHeaders.CONTENT_TYPE: "application/json",
              "Authorization": "Token " + Provider.of<Auth>(context).myToken,
            },
          ).then((response) {
            var dataOrders = json.decode(response.body) as Map<String, dynamic>;
            _orders.addAll(dataOrders["results"]);
            nextOrderURL = dataOrders["next"];
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
        if (orderstripsProvider.myorders.length != 0) {
          _orders = orderstripsProvider.myorders;
          if (nextOrderURL == "FirstCall") {
            nextOrderURL = orderstripsProvider.detailsMyOrder["next"];
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
                      "My Orders",
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold),
                    ),
                    elevation: 1,
                  ),
                ),
                Expanded(
                  child: orderstripsProvider.notLoadedMyorders
                      ? ListView(
                          children: <Widget>[
                            for (var i = 0; i < 5; i++) OrderFadeWidget(),
                          ],
                        )
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
                            itemCount: _orders == null ? 0 : _orders.length,
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
