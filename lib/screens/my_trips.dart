import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:optisend/screens/item_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:optisend/providers/ordersandtrips.dart';

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
    return Consumer<OrdersTripsProvider>(
      builder: (context, orderstripsProvider, child) {
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
              style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
            ),
            elevation: 1,
          ),
          body: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (!_isfetchingnew && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                // start loading data
                setState(() {
                  _isfetchingnew = true;
                  print("load order");
                });
                //_loadData(); todo: orxan
              }
            },
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, int i) {
                      return InkWell(
                        onTap: () => null
                        //             //Navigator.pushNamed(context, ItemScreen.routeName);
                        //             Navigator.push(
                        // context,
                        // new MaterialPageRoute(
                        //     builder: (__) => new ItemScreen(
                        //                 id:_trips[i]["id"],
                        //                 owner:_trips[i]["owner"],
                        //                 title:_trips[i]["title"],
                        //                 destination: _trips[i]["destination"],
                        //                 source: _trips[i]["source"]["city_ascii"],
                        //                 weight: _trips[i]["weight"],
                        //                 price: _trips[i]["price"],
                        //                 date: _trips[i]["date"],
                        //                 description: _trips[i]["description"],
                        //                 image: _trips[i]["orderimage"],
                        //              )));
                        ,
                        child: Container(
                          height: 140,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Card(
                            elevation: 4,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Image(
                                      image: NetworkImage("https://img.icons8.com/wired/2x/passenger-with-baggage.png"),
                                      height: 60,
                                      width: 60,
                                    )

                                    // Image.network(
                                    //         getImageUrl(_trips[i]["orderimage"])
                                    // ),
                                    ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        orderstripsProvider.mytrips[i]["owner"]["first_name"] +
                                            " " +
                                            orderstripsProvider.mytrips[i]["owner"]["last_name"], //Todo: title
                                        style: TextStyle(fontSize: 20, color: Colors.grey[600], fontWeight: FontWeight.bold),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Icon(
                                            Icons.location_on,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context).size.width * 0.35,
                                            child: RichText(
                                              text: TextSpan(
                                                text: "  " +
                                                    orderstripsProvider.mytrips[i]["source"]["city_ascii"] +
                                                    "  >  " +
                                                    orderstripsProvider.mytrips[i]["destination"]["city_ascii"], //Todo: Source -> Destination

                                                style: TextStyle(fontSize: 15, color: Colors.grey[600], fontWeight: FontWeight.normal),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.date_range,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                          Text(
                                            "  " + orderstripsProvider.mytrips[i]["date"].toString(), //Todo: date
                                            style: TextStyle(color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Icon(
                                            MdiIcons.weightKilogram, //todo: icon
//                                            (FontAwesome.suitcase),
                                            color: Theme.of(context).primaryColor,
                                          ),
                                          Text(
                                            "  " + orderstripsProvider.mytrips[i]["weight_limit"].toString(),
                                            style: TextStyle(color: Colors.grey[600]),
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
                      );
                    },
                    itemCount: orderstripsProvider.mytrips == null ? 0 : orderstripsProvider.mytrips.length,
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
