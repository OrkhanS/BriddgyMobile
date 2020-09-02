import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:optisend/localization/localization_constants.dart';
import 'package:optisend/models/order.dart';
import 'package:optisend/providers/auth.dart';
import 'package:optisend/widgets/order_widget.dart';
import 'package:optisend/widgets/progress_indicator_widget.dart';
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

  Future _loadData() async {
    if (nextOrderURL.toString() != "null" &&
        nextOrderURL.toString() != "FirstCall") {
      String url = nextOrderURL;
      print(url);
      try {
        await http.get(
          url,
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            "Authorization": "Token " + Provider.of<Auth>(context,listen: false).myTokenFromStorage,
          },
        ).then((response) {
          print(response.statusCode);
          Map<String, dynamic> data =
              json.decode(response.body) as Map<String, dynamic>;

          for (var i = 0; i < data["results"].length; i++) {
            _orders.add(Order.fromJson(data["results"][i]));
          }
          nextOrderURL = data["next"];
        });
      } catch (e) {
        print(e);
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
        if (orderstripsProvider.myorders.length != 0) {
          _orders = orderstripsProvider.myorders;
          if (nextOrderURL == "FirstCall") {
            nextOrderURL = orderstripsProvider.detailsMyOrder["next"];
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
                      t(context, 'my_orders'),
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold),
                    ),
                    elevation: 1,
                  ),
                ),
                Expanded(
                  child: orderstripsProvider.isloadingMyorders
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
                ProgressIndicatorWidget(show: _isfetchingnew,),
              ],
            ),
          ),
        );
      },
    );
  }
}
