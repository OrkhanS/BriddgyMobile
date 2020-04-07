import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:optisend/providers/ordersandtrips.dart';
import 'my_items_info.dart';
import 'package:flushbar/flushbar.dart';

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
          if (nextOrderURL == "FirstCall") {
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
              style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
            ),
            elevation: 1,
          ),
          body: orderstripsProvider.notLoaded
              ? Center(child: CircularProgressIndicator())
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
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: ListView.builder(
                          itemBuilder: (context, int i) {
                            int key = i;
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Dismissible(
                                direction: DismissDirection.endToStart,
                                movementDuration: Duration(milliseconds: 500),
                                dragStartBehavior: DragStartBehavior.start,
                                onDismissed: (direction) {
                                  //todo: delete from backend
                                  orderstripsProvider.myorders.removeAt(i);
                                  Flushbar(
                                    title: "Done!",
                                    message: "Trip was deleted",
                                    aroundPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 60),
                                    borderRadius: 10,
                                    duration: Duration(seconds: 3),
                                  )..show(context);
                                },
                                confirmDismiss: (DismissDirection direction) async {
                                  final bool res = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Confirm"),
                                        content: const Text("Are you sure you wish to delete this item?"),
                                        actions: <Widget>[
                                          FlatButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("DELETE")),
                                          FlatButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: const Text("CANCEL"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  return res; //todo check
                                },
                                background: Container(
                                  decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.red[900], Colors.red[400]])),
//                                    border: Border.all(),
//                                    borderRadius: BorderRadius.circular(5),
//                                  ),

                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(width: 40),
                                      Icon(
                                        MdiIcons.delete,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "Delete",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                                key: ValueKey(i),
                                child: Card(
                                  elevation: 4,
                                  child: Container(
                                    height: 140,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (__) => MyItemScreenInfo(
                                              id: _orders[i]["id"],
                                              owner: _orders[i]["owner"],
                                              title: _orders[i]["title"],
                                              destination: orderstripsProvider.myorders[i]["destination"],
                                              source: _orders[i]["source"]["city_ascii"],
                                              weight: _orders[i]["weight"],
                                              price: _orders[i]["price"],
                                              date: _orders[i]["date"],
                                              description: orderstripsProvider.myorders[i]["description"],
                                              image: _orders[i]["orderimage"],
                                            ),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.all(Radius.circular(15)),
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
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  _orders[i]["title"].toString().length > 20
                                                      ? orderstripsProvider.myorders[i]["title"].toString().substring(0, 20) + "..."
                                                      : orderstripsProvider.myorders[i]["title"].toString(), //Todo: title
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.grey[800],
//                                          fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Icon(
                                                      MdiIcons.mapMarkerMultipleOutline,
                                                      color: Theme.of(context).primaryColor,
                                                    ),
                                                    Text(
                                                      orderstripsProvider.myorders[i]["source"]["city_ascii"] +
                                                          "  >  " +
                                                          orderstripsProvider.myorders[i]["destination"]["city_ascii"], //Todo: Source -> Destination
                                                      style: TextStyle(fontSize: 15, color: Colors.grey[600], fontWeight: FontWeight.normal),
                                                    ),
                                                  ],
                                                ),
                                                Row(
//                                        mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  children: <Widget>[
                                                    Row(
                                                      children: <Widget>[
                                                        Icon(
                                                          MdiIcons.calendarRange,
                                                          color: Theme.of(context).primaryColor,
                                                        ),
                                                        Text(
                                                          orderstripsProvider.myorders[i]["date"].toString(), //Todo: date
                                                          style: TextStyle(color: Colors.grey[600]),
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
                                                          color: Theme.of(context).primaryColor,
                                                        ),
                                                        Text(
                                                          orderstripsProvider.myorders[i]["price"].toString(), //Todo: date
                                                          style: TextStyle(color: Colors.grey[600]),
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
                                ),
                              ),
                            );
                          },
                          itemCount: _orders == null ? 0 : _orders.length,
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
