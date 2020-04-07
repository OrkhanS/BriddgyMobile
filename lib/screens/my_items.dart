import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:optisend/screens/item_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:optisend/providers/ordersandtrips.dart';
import 'my_items_info.dart';

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
    widget.orderstripsProvider.fetchAndSetMyOrders(widget.token);
    super.initState();
  }

  @override //todo: check for future
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    Future _loadData() async {
      if (nextOrderURL.toString() != "null") {
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
          if(nextOrderURL == "FirstCall"){
            nextOrderURL = orderstripsProvider.detailsMyOrder["next"];
          }
          //messageLoader = false;
        } else {

          //messageLoader = true;
        }
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            leading: IconButton(
              color: Theme.of(context).primaryColor,
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: Text(
              "My Items",
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
            elevation: 1,
          ),
          body: orderstripsProvider.notLoaded
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
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: ListView.builder(
                          itemBuilder: (context, int i) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                    builder: (__) => new MyItemScreenInfo(
                                      id: _orders[i]["id"],
                                      owner: _orders[i]
                                          ["owner"],
                                      title: _orders[i]
                                          ["title"],
                                      destination: orderstripsProvider
                                          .myorders[i]["destination"],
                                      source: _orders[i]
                                          ["source"]["city_ascii"],
                                      weight: _orders[i]
                                          ["weight"],
                                      price: _orders[i]
                                          ["price"],
                                      date: _orders[i]
                                          ["date"],
                                      description: orderstripsProvider
                                          .myorders[i]["description"],
                                      image: _orders[i]
                                          ["orderimage"],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                height: 140,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Card(
                                  elevation: 4,
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15)),
                                          child: Image(
                                            image: NetworkImage(
                                                // "https://briddgy.herokuapp.com/media/" + _user["avatarpic"].toString() +"/"
                                                "https://picsum.photos/250?image=9"), //Todo,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              _orders[i]
                                                              ["title"]
                                                          .toString()
                                                          .length >
                                                      20
                                                  ? orderstripsProvider
                                                          .myorders[i]["title"]
                                                          .toString()
                                                          .substring(0, 20) +
                                                      "..."
                                                  : orderstripsProvider
                                                      .myorders[i]["title"]
                                                      .toString(), //Todo: title
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.grey[800],
//                                          fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Icon(
                                                  MdiIcons
                                                      .mapMarkerMultipleOutline,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                                Text(
                                                  orderstripsProvider
                                                                  .myorders[i]
                                                              ["source"]
                                                          ["city_ascii"] +
                                                      "  >  " +
                                                      orderstripsProvider
                                                                  .myorders[i]
                                                              ["destination"][
                                                          "city_ascii"], //Todo: Source -> Destination
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.grey[600],
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ),
                                              ],
                                            ),
                                            Row(
//                                        mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Icon(
                                                      MdiIcons.calendarRange,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                    ),
                                                    Text(
                                                      orderstripsProvider
                                                          .myorders[i]["date"]
                                                          .toString(), //Todo: date
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[600]),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 50,
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.attach_money,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                    ),
                                                    Text(
                                                      orderstripsProvider
                                                          .myorders[i]["price"]
                                                          .toString(), //Todo: date
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[600]),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          itemCount: _orders == null
                              ? 0
                              : _orders.length,
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
