import 'dart:convert';
import 'dart:io';
import 'package:flushbar/flushbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optisend/models/api.dart';
import 'package:optisend/models/order.dart';
import 'package:optisend/models/stats.dart';
import 'package:optisend/models/user.dart';
import 'package:optisend/widgets/order_item.dart';

class ProfileScreenAnother extends StatefulWidget {
  var user;
  ProfileScreenAnother({this.user});
  static const routeName = '/profile';

  @override
  _ProfileScreenAnotherState createState() => _ProfileScreenAnotherState();
}

class _ProfileScreenAnotherState extends State<ProfileScreenAnother> {
  List _reviews = [];
  Map _stats = {};
  bool reviewsNotReady = true;
  bool statsNotReady = true;
  bool ordersNotReady = true;
  User user;
  Stats stats;
  List orders = [];
  @override
  void initState() {
    user = widget.user;
    loadOrders();
    fetchAndSetReviews();
    fetchAndSetStatistics();
    super.initState();
  }

  Future fetchAndSetReviews() async {
    String url = Api.users + user.id.toString() + "/reviews/";
    final response = await http.get(
      url,
      headers: {
        HttpHeaders.CONTENT_TYPE: "application/json",
      },
    );

    if (this.mounted) {
      setState(() {
        final dataReviews = json.decode(response.body) as Map<String, dynamic>;
        _reviews = dataReviews["results"];
        reviewsNotReady = false;
      });
    }
  }

  Future loadOrders() async {
    String url = Api.orderById + user.id.toString() + '/orders/';
    final response = await http.get(
      url,
      headers: {
        HttpHeaders.CONTENT_TYPE: "application/json",
      },
    );

    if (this.mounted) {
      setState(() {
        Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        for (var i = 0; i < data["results"].length; i++) {
          orders.add(Order.fromJson(data["results"][i]));
        }
        ordersNotReady = false;
      });
    }
  }

  Future fetchAndSetStatistics() async {
    String url = Api.userStats + user.id.toString() + '/';
    final response = await http.get(
      url,
      headers: {
        HttpHeaders.CONTENT_TYPE: "application/json",
      },
    );

    if (this.mounted) {
      setState(() {
        Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        stats = Stats.fromJson(data);
        statsNotReady = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: reviewsNotReady || statsNotReady || ordersNotReady
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                    ),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(
                                Icons.chevron_left,
                                size: 21,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.menu,
                                size: 21,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Stack(
                                children: <Widget>[
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundImage: NetworkImage(
                                      "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?cs=srgb&dl=pexels-pixabay-220453.jpg&fm=jpg",
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    bottom: 5,
                                    child: Container(
                                      width: 35,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: Color.fromRGBO(255, 255, 255, 85),
                                        border: Border.all(color: Colors.green, width: 1.5),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          Icon(
                                            Icons.star,
                                            size: 12,
                                            color: Colors.green,
                                          ),
                                          Text(
                                            user.rating.toString(),
//                                        order.owner.rating.toString(),
                                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {},
                                      child: Icon(
                                        MdiIcons.shieldCheck,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Text(
                                        user.firstName + " " + user.lastName,
                                        textAlign: TextAlign.start,
                                        style: GoogleFonts.lato(
                                          textStyle: Theme.of(context).textTheme.display1,
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
//                                style: TextStyle(
//                                  fontStyle: ,
//                                  color: Colors.white,
//                                  fontWeight: FontWeight.bold,
//                                  fontSize: 20,
//                                ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                  child: Text(
                                    "Member since 10 July 2020",
                                    style: GoogleFonts.lato(
                                      textStyle: Theme.of(context).textTheme.display1,
                                      color: Colors.grey[200],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 16,
                              ),
                              Text("  Baku, Azerbaijan",
                                  style: GoogleFonts.aBeeZee(
                                    color: Colors.white,
                                    fontSize: 15,
                                  )),
                              Expanded(
                                child: SizedBox(
                                  height: 1,
                                ),
                              ),
                              RaisedButton.icon(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                color: Theme.of(context).scaffoldBackgroundColor,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                                icon: Icon(
                                  MdiIcons.chatOutline,
                                  color: Theme.of(context).primaryColor,

//                                  color: Theme.of(context).primaryColor,
                                  size: 18,
                                ),
                                label: Text(
                                  "Message",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
//                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                onPressed: () {
                                  //todo Orxan fix
//                  createRooms(tripsProvider.trips[i]["owner"]["id"]);
//                                Flushbar(
//                                  title: "Chat with " + trip.owner.firstName.toString() + " has been started!",
//                                  message: "Check Chats to see more.",
//                                  padding: const EdgeInsets.all(8),
//                                  borderRadius: 10,
//                                  duration: Duration(seconds: 5),
//                                )..show(context);
                                },
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      "\$" + stats.totalearnings.toString(),
                                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "Earned",
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      stats.totalorders.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      "Orders",
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 10,
                              color: Colors.red,
                            ),
                            Expanded(
                              child: Container(
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      stats.totalcontracts.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      "Delivered",
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, int i) {
                        return OrderWidget(
                          order: orders[i],
                          i: i,
                        );
                      },
                      itemCount: orders.length,
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
