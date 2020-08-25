import 'dart:convert';
import 'dart:io';
import 'package:flushbar/flushbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optisend/models/api.dart';
import 'package:optisend/models/order.dart';
import 'package:optisend/models/stats.dart';
import 'package:optisend/models/user.dart';
import 'package:optisend/providers/auth.dart';
import 'package:optisend/providers/messages.dart';
import 'package:optisend/screens/chats_screen.dart';
import 'package:optisend/widgets/generators.dart';
import 'package:optisend/widgets/order_widget.dart';
import 'package:optisend/widgets/progress_indicator_widget.dart';
import 'package:provider/provider.dart';

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
  bool messageButton = true;
  var imageUrl;
  @override
  void initState() {
    user = widget.user;
    imageUrl = user.avatarpic == null ? Api.noPictureImage : Api.storageBucket + user.avatarpic.toString();
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
        HttpHeaders.contentTypeHeader: "application/json",
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
        HttpHeaders.contentTypeHeader: "application/json",
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
        HttpHeaders.contentTypeHeader: "application/json",
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
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(horizontal: 10),
//              decoration: BoxDecoration(
//                borderRadius: BorderRadius.circular(8),
//                color: Colors.blueGrey,
//              ),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.chevron_left,
                          size: 21,
                          //color: Colors.white,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {},
                                child: Icon(
                                  MdiIcons.shieldCheck,
                                  color: Colors.green,
                                  size: 17,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  user.firstName + " " + user.lastName,
                                  textAlign: TextAlign.start,
                                  style: GoogleFonts.lato(
                                    textStyle: Theme.of(context).textTheme.display1,
                                    color: Colors.black,
//                                    color: Theme.of(context).primaryColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Text(
                              "Member since " + DateFormat("dd MMMM yy").format(user.date_joined).toString(),
                              style: GoogleFonts.lato(
                                color: Colors.grey[700],
//                                color: Theme.of(context).primaryColor,
                                fontSize: 14,
//                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
                        child: Stack(
                          children: <Widget>[
                            imageUrl == Api.noPictureImage
                                ? InitialsAvatarWidget(user.firstName.toString(), user.lastName.toString(), 70.0)
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(25.0),
                                    child: Image.network(
                                      imageUrl,
                                      errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                        return InitialsAvatarWidget(user.firstName.toString(), user.lastName.toString(), 70.0);
                                      },
                                      height: 70,
                                      width: 70,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                            Positioned(
                              left: 17,
                              right: 17,
                              bottom: 0,
                              child: Container(
                                height: 18,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(255, 255, 255, 30),
                                  border: Border.all(color: Colors.green, width: 1),
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
                                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 5),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.location_on,
                          color: Theme.of(context).primaryColor,
                          size: 16,
                        ),
                        Text(
                          " Baku, Azerbaijan",
                          style: GoogleFonts.aBeeZee(
                            color: Colors.grey[800],
                            fontSize: 15,
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 1,
                          ),
                        ),
                        messageButton
                            ? RaisedButton.icon(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                color: Colors.green,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                                icon: Icon(
                                  MdiIcons.chatOutline,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                label: Text(
                                  "Message",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    messageButton = false;
                                  });
                                  var auth = Provider.of<Auth>(context, listen: false);
                                  var messageProvider = Provider.of<Messages>(context, listen: false);

                                  messageProvider.createRooms(user.id, auth).whenComplete(() => {
                                        if (messageProvider.isChatRoomCreated)
                                          {
                                            setState(() {
                                              messageButton = true;
                                            }),
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (__) => ChatsScreen(provider: messageProvider, auth: auth)),
                                            ),
                                            Flushbar(
                                              title: "Success",
                                              message: "Chat with " + user.firstName.toString() + " has been started!",
                                              padding: const EdgeInsets.all(8),
                                              borderRadius: 10,
                                              duration: Duration(seconds: 3),
                                            )..show(context)
                                          }
                                        else
                                          {
                                            setState(() {
                                              messageButton = true;
                                            }),
                                            Flushbar(
                                              title: "Failure",
                                              message: "Please try again",
                                              padding: const EdgeInsets.all(8),
                                              borderRadius: 10,
                                              duration: Duration(seconds: 3),
                                            )..show(context)
                                          }
                                      });
                                },
                              )
                            : ProgressIndicatorWidget(show: true),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              statsNotReady
                                  ? Text(
                                      "\$ 0.0",
                                      style: TextStyle(
                                        color: Colors.grey[800],
//                                        color: Theme.of(context).primaryColor,
                                        fontSize: 20,
                                      ),
                                    )
                                  : Text(
                                      "\$" + stats.totalearnings.toString(),
                                      style: TextStyle(
                                        color: Colors.grey[800],
//                                        color: Theme.of(context).primaryColor,
                                        fontSize: 20,
                                      ),
                                    ),
                              Text(
                                "Earned",
                                style: TextStyle(
                                  //color: Colors.white,
                                  color: Theme.of(context).primaryColor,
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
                              statsNotReady
                                  ? Text(
                                      "0",
                                      style: TextStyle(
                                        color: Colors.grey[800],
//                                        color: Theme.of(context).primaryColor,
                                        fontSize: 20,
//                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : Text(
                                      stats.totalorders.toString(),
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        //color: Theme.of(context).primaryColor,
                                        fontSize: 20,
                                      ),
                                    ),
                              Text(
                                "Orders",
                                style: TextStyle(
//color: Colors.white,
                                  color: Theme.of(context).primaryColor,
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
                              statsNotReady
                                  ? Text(
                                      "0",
                                      style: TextStyle(
                                        color: Colors.grey[800],
//                                        color: Theme.of(context).primaryColor,
                                        fontSize: 20,
//                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : Text(
                                      stats.totalcontracts.toString(),
                                      style: TextStyle(
                                        color: Colors.grey[800],
//                                        color: Theme.of(context).primaryColor,
                                        fontSize: 20,
                                      ),
                                    ),
                              Text(
                                "Delivered",
                                style: TextStyle(
//color: Colors.white,
                                  color: Theme.of(context).primaryColor,
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
