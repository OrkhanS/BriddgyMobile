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

  @override
  void initState() {
    widget.orderstripsProvider.fetchAndSetMyOrders(widget.token);
    super.initState();
  }

  // Future fetchAndSetOrders() async {
  //   // var token = Provider.of<Auth>(context, listen: false).token;
  //   var token = '40694c366ab5935e997a1002fddc152c9566de90';
  //   const url = "http://briddgy.herokuapp.com/api/my/orders/";
  //   http.get(
  //     url,
  //     headers: {
  //       HttpHeaders.CONTENT_TYPE: "application/json",
  //       "Authorization": "Token " + token,
  //     },
  //   ).then((response) {
  //     setState(
  //       () {
  //         final dataOrders = json.decode(response.body) as Map<String, dynamic>;
  //         _orders = dataOrders["results"];
  //         isLoading = false;
  //       },
  //     );
  //   });
  // }

  @override //todo: check for future
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
              "My Items",
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
            elevation: 1,
          ),
          body: orderstripsProvider.notLoaded
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemBuilder: (context, int i) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          new MaterialPageRoute(
                            builder: (__) => new MyItemScreenInfo(
                              id: orderstripsProvider.myorders[i]["id"],
                              owner: orderstripsProvider.myorders[i]["owner"],
                              title: orderstripsProvider.myorders[i]["title"],
                              destination: orderstripsProvider.myorders[i]
                                  ["destination"],
                              source: orderstripsProvider.myorders[i]["source"]
                                  ["city_ascii"],
                              weight: orderstripsProvider.myorders[i]["weight"],
                              price: orderstripsProvider.myorders[i]["price"],
                              date: orderstripsProvider.myorders[i]["date"],
                              description: orderstripsProvider.myorders[i]
                                  ["description"],
                              image: orderstripsProvider.myorders[i]["orderimage"],
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      orderstripsProvider.myorders[i]["title"]
                                                  .toString()
                                                  .length >
                                              20
                                          ? orderstripsProvider.myorders[i]["title"]
                                                  .toString()
                                                  .substring(0, 20) +
                                              "..."
                                          : orderstripsProvider.myorders[i]["title"]
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
                                          MdiIcons.mapMarkerMultipleOutline,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        Text(
                                          orderstripsProvider.myorders[i]["source"]
                                                  ["city_ascii"] +
                                              "  >  " +
                                              orderstripsProvider.myorders[i]
                                                      ["destination"][
                                                  "city_ascii"], //Todo: Source -> Destination
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.normal),
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
                                              orderstripsProvider.myorders[i]["date"]
                                                  .toString(), //Todo: date
                                              style: TextStyle(
                                                  color: Colors.grey[600]),
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
                                              orderstripsProvider.myorders[i]
                                                      ["price"]
                                                  .toString(), //Todo: date
                                              style: TextStyle(
                                                  color: Colors.grey[600]),
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
                  itemCount: orderstripsProvider.myorders == null
                      ? 0
                      : orderstripsProvider.myorders.length,
                ),
        );
      },
    );
  }
}
