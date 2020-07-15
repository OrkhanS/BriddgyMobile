import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optisend/providers/auth.dart';
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
  @override
  void initState() {
    token = widget.token;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_reviews.isEmpty && _stats.isEmpty) {
      _reviews = Provider.of<Auth>(context).reviews;
      _stats = Provider.of<Auth>(context).stats;
    }
    return Scaffold(
      body: Provider.of<Auth>(context).reviewsNotReady &&
              Provider.of<Auth>(context).statsNotReady
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
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold),
                    ),
                    centerTitle: true,
                    elevation: 1,
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              CircleAvatar(
                                radius: 70,

                                backgroundImage: NetworkImage(
                                    // "https://briddgy.herokuapp.com/media/" + _user["avatarpic"].toString() +"/"
                                    "https://picsum.photos/250?image=9"), //Todo
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    MdiIcons.shieldCheck,
                                    color: Colors.lightGreen,
                                  ),
                                  Text(
                                    "  " +
                                        widget.user["first_name"].toString() +
                                        " " +
                                        widget.user["last_name"].toString(),
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ],
                              ),
                              Divider(
                                color: Colors.grey[600],
                                height: 50,
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
                                  widget.user["email"].toString(),
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
                        ],
                      ),
                    ),
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
