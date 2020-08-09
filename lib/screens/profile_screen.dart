import 'dart:convert';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optisend/models/api.dart';
import 'package:optisend/models/order.dart';
import 'package:optisend/models/stats.dart';
import 'package:optisend/models/user.dart';
import 'package:optisend/providers/auth.dart';
import 'package:optisend/widgets/order_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  var user, token;
  ProfileScreen({this.user, this.token});
  static const routeName = '/profile';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List _reviews = [];
  List _stats = [];
  String token;
  User user;
  @override
  void initState() {
    token = widget.token;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_reviews.isEmpty && !Provider.of<Auth>(context).statsNotReadyForProfile) {
      _reviews = Provider.of<Auth>(context).reviews;
      _stats = Provider.of<Auth>(context).stats;
    }
    if (user == null) {
      if (widget.user != null) {
        user = widget.user;
      }
    }
    return Scaffold(
      body: Provider.of<Auth>(context).reviewsNotReadyForProfile && Provider.of<Auth>(context).statsNotReadyForProfile
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: <Widget>[
                  AppBar(
                    backgroundColor: Colors.white,
                    leading: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.arrow_back),
                      color: Theme.of(context).primaryColor,
                    ),
                    title: Text(
                      "Profile", //Todo: User's name ??
                      style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                    ),
                    centerTitle: true,
                    elevation: 1,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Image.network(
                              "https://picsum.photos/250?image=9",
                              height: 140,
                              width: 140,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                          Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(
                                    MdiIcons.shieldCheck,
                                    color: Colors.lightGreen,
                                  ),
                                  Text(
                                    "Verified",
                                    style: TextStyle(color: Colors.green),
                                  ),
                                  Container(
                                    width: 50,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      color: Colors.green[400],
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Icon(
                                          Icons.star,
                                          size: 15,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          "4.0",
//                                        order.owner.rating.toString(),
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              Text(
                                "  " + user.firstName + " " + user.lastName,
                                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700, color: Theme.of(context).primaryColor),
                              )
                            ],
                          ),
                        ],
                      ),
                      Divider(
                        color: Colors.grey[600],
                      ),
                      ListTile(
                        dense: true,
                        title: Text(
                          "Email: ",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        title: Text(
                          "Phone: ",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: Text(
                          "Hidden", // todo add user's num
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        title: Text(
                          "Sent: ",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: Text(
                          _stats[0]["totalorders"].toString(),
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        title: Text(
                          "Delivered: ",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: Text(
                          _stats[0]["totaltrips"].toString(),
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        title: Text(
                          "Earned: ",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: Text(
                          _stats[0]["totalearnings"].toString() + "\$",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Reviews:",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Center(
                    child: Text("\n\nYou don't have reviews yet."),
                  ),
                  //   ListView.builder(
                  //     physics: const NeverScrollableScrollPhysics(),
                  //     shrinkWrap: true,
                  //     itemCount: _reviews.length,
                  //     itemBuilder: (context, int index) {
                  //       return Column(
                  //         children: <Widget>[
                  //           ListTile(
                  //             contentPadding:
                  //                 EdgeInsets.symmetric(horizontal: 20),
                  //             isThreeLine: false,
                  //             leading: CircleAvatar(
                  //               radius: 30,
                  //               backgroundImage: NetworkImage(
                  //                   'https://images-na.ssl-images-amazon.com/images/I/81NIli1PuqL._AC_SL1500_.jpg'), //Todo: UserPic
                  //             ),
                  //             title: Row(
                  //               children: <Widget>[
                  //                 Container(
                  //                   width:
                  //                       MediaQuery.of(context).size.width * 0.4,
                  //                   child: Text(
                  //                     _reviews[index]["author"]["first_name"]
                  //                             .toString() +
                  //                         " " +
                  //                         _reviews[index]["author"]["last_name"]
                  //                             .toString(), //Todo: Name
                  //                     softWrap: false,

                  //                     style: TextStyle(
                  //                       fontSize: 15,
                  //                       color: Theme.of(context).primaryColor,
                  //                     ),
                  //                   ),
                  //                 ),
                  //                 Icon(
                  //                   MdiIcons.star,
                  //                   color: Colors.orange,
                  //                   size: 15,
                  //                 ),
                  //                 Text(
                  //                   // Review and Ranking can be given separately
                  //                   "5  ", //Todo: Rating

                  //                   style: TextStyle(
                  //                     color: Colors.orange,
                  //                     fontSize: 15,
                  //                   ),
                  //                 ),
                  //                 Text(
                  //                   " 10 Dec 2019", //Todo: Date
                  //                   style: TextStyle(
                  //                     fontSize: 13,
                  //                     color: Colors.grey[500],
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //             subtitle:
                  //                 Text(_reviews[index]["comment"].toString()),
                  //           ),
                  //         ],
                  //       );
                  //     },
                  //   )
                  //
                ],
              ),
            ),
    );
  }
}

class MyProfileScreen extends StatefulWidget {
  var user;
  var token;
  MyProfileScreen({@required this.user, @required this.token});
  static const routeName = '/profile';

  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
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
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.edit,
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
