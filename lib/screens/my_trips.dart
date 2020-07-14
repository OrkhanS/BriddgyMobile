import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
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
    widget.orderstripsProvider.fetchAndSetMyTrips(widget.token);
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
      if (nextTripURL.toString() != "null" &&
          nextTripURL.toString() != "FristCall") {
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
              "My Trips",
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
            elevation: 1,
          ),
          body: NotificationListener<ScrollNotification>(
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
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Dismissible(
                          direction: DismissDirection.endToStart,
                          movementDuration: Duration(milliseconds: 500),
                          dragStartBehavior: DragStartBehavior.start,
                          onDismissed: (direction) {
                            //todo: delete from backend
                            orderstripsProvider.mytrips.removeAt(i);
                            Flushbar(
                              title: "Done!",
                              message: "Trip was deleted",
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 60),
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
                                  content: const Text(
                                      "Are you sure you wish to delete this item?"),
                                  actions: <Widget>[
                                    FlatButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text("DELETE")),
                                    FlatButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text("CANCEL"),
                                    ),
                                  ],
                                );
                              },
                            );
                            return res; //todo check
                          },
                          background: Container(
                            margin: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                              Colors.red[700],
                              Colors.orange[300]
                            ])),
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
                                  size: 27,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  "DELETE",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 15),
                              ],
                            ),
                          ),
                          key: ValueKey(i),
                          child: InkWell(
                            onTap: () => null,
                            child: Container(
                              height: 140,
                              child: Card(
                                elevation: 4,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Image(
                                      image: NetworkImage(
                                          "https://img.icons8.com/wired/2x/passenger-with-baggage.png"),
                                      height: 60,
                                      width: 60,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            _trips[i]["owner"]["first_name"] +
                                                " " +
                                                _trips[i]["owner"]
                                                    ["last_name"], //Todo: title
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Icon(
                                                Icons.location_on,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.35,
                                                child: RichText(
                                                  text: TextSpan(
                                                    text: "  " +
                                                        _trips[i]["source"]
                                                            ["city_ascii"] +
                                                        "  >  " +
                                                        _trips[i]["destination"]
                                                            [
                                                            "city_ascii"], //Todo: Source -> Destination

                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.grey[600],
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Icon(
                                                Icons.date_range,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                              Text(
                                                "  " +
                                                    _trips[i]["date"]
                                                        .toString(), //Todo: date
                                                style: TextStyle(
                                                    color: Colors.grey[600]),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Icon(
                                                MdiIcons
                                                    .weightKilogram, //todo: icon
//                                            (FontAwesome.suitcase),
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                              Text(
                                                "  " +
                                                    _trips[i]["weight_limit"]
                                                        .toString(),
                                                style: TextStyle(
                                                    color: Colors.grey[600]),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    // Padding(
                                    //   padding: const EdgeInsets.symmetric(vertical: 10.0),
                                    //   child: RaisedButton(
                                    //     color: Colors.white,
                                    //     onPressed: () {},
                                    //     child: Padding(
                                    //       padding: const EdgeInsets.symmetric(vertical: 20.0),
                                    //       child: Column(
                                    //         mainAxisSize: MainAxisSize.max,
                                    //         mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    //         children: <Widget>[
                                    //           Icon(
                                    //             MdiIcons.messageArrowRightOutline,
                                    //             color: Theme.of(context).primaryColor,
                                    //             size: 30,
                                    //           ),
                                    //           Text(
                                    //             "Message",
                                    //             style: TextStyle(
                                    //               fontWeight: FontWeight.bold,
                                    //               color: Theme.of(context).primaryColor,
                                    //             ),
                                    //           )
                                    //         ],
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: _trips == null ? 0 : _trips.length,
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
