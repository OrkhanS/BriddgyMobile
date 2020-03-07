import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optisend/screens/contracts.dart';
import 'package:optisend/screens/my_items.dart';
import 'package:optisend/screens/my_trips.dart';
import 'package:optisend/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import './auth_screen.dart';
import '../providers/auth.dart';
import 'splash_screen.dart';

class DetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<Auth>(context, listen: false);
    return Scaffold(
      body: auth.isAuth
          ? DetailsPage()
          : FutureBuilder(
              future: auth.tryAutoLogin(),
              builder: (ctx, authResultSnapshot) =>
                  authResultSnapshot.connectionState == ConnectionState.waiting
                      ? SplashScreen()
                      : AuthScreen(),
            ),
    );
  }
}

class DetailsPage extends StatefulWidget {
  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  Map _user = {};
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
  }

  Future fetchAndSetUserDetails() async {
    // var token = Provider.of<Auth>(context, listen: false).token;
    var token = '5463ec37d6c938ac32d7d300b6641d4df234d941';

    const url = "http://briddgy.herokuapp.com/api/users/me/";
    final response = await http.get(
      url,
      headers: {
        HttpHeaders.CONTENT_TYPE: "application/json",
        "Authorization": "Token " + token,
      },
    );

    if (this.mounted) {
      setState(() {
        final dataOrders = json.decode(response.body) as Map<String, dynamic>;
        _user = dataOrders;
        isLoading = false;
      });
    }
    return _user;
  }

  @override
  Widget build(BuildContext context) {
    fetchAndSetUserDetails();

    List<ListTile> choices = <ListTile>[
      ListTile(
        leading: Icon(
          Icons.exit_to_app,
//          color: Theme.of(context).primaryColor,
        ),
        title: Text("Logout"),
        onTap: () {
          Provider.of<Auth>(context, listen: false).logout(context);
        },
      ),
      ListTile(
        leading: Icon(Icons.settings),
        title: Text("Settings"),
      )
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Account",
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1,
//        actions: <Widget>[
//          PopupMenuButton<ListTile>(
//            icon: Icon(
//              Icons.menu,
//              color: Colors.grey[600],
//            ),
//            //onSelected: choiceAction,
//            itemBuilder: (BuildContext context) {
//              return choices.map((ListTile choice) {
//                return PopupMenuItem<ListTile>(
//                  value: choice,
//                  child: choice,
//                );
//              }).toList();
//            },
//          )
//        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (__) => ProfileScreen(user: _user)),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            CircleAvatar(
                              radius: 50,
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,

                              backgroundImage: NetworkImage(
                                  // "https://briddgy.herokuapp.com/media/" + _user["avatarpic"].toString() +"/"
                                  "https://picsum.photos/250?image=9"), //Todo: UserPic
//                  child: Image.network(
//                    'https://images-na.ssl-images-amazon.com/images/I/81NIli1PuqL._AC_SL1500_.jpg',
//                    fit: BoxFit.cover,
//                    loadingBuilder: (BuildContext context, Widget child,
//                        ImageChunkEvent loadingProgress) {
//                      if (loadingProgress == null) return child;
//                      return Center(
//                        child: CircularProgressIndicator(
//                          value: loadingProgress.expectedTotalBytes != null
//                              ? loadingProgress.cumulativeBytesLoaded /
//                                  loadingProgress.expectedTotalBytes
//                              : null,
//                        ),
//                      );
//                    },
//                  ),
                            ),
                            Column(
                              children: <Widget>[
                                Text(
                                  _user["first_name"].toString() +
                                      " " +
                                      _user["last_name"].toString(),
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).primaryColor),
                                ),
                                Text(_user["email"].toString(),
                                    style: TextStyle(fontSize: 15)),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25)),
//                                color: Theme.of(context).primaryColor,
                                color: Colors.grey[200],
                              ),
                              child: Icon(
                                Icons.navigate_next,
                                color: Colors.grey[600],
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Divider(
                        color: Colors.grey[600],
                        height: 40,
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(MdiIcons.mailboxOpenOutline),
                            title: Text(
                              "Your Items",
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  color: Colors.grey[200],
                                ),
                                child: Icon(Icons.navigate_next)),
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(MyItems.routeName);
                            },
                          ),
                          ListTile(
                            leading: Icon(MdiIcons.mapMarkerPath),
                            title: Text(
                              "Your Trips",
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  color: Colors.grey[200],
                                ),
                                child: Icon(Icons.navigate_next)),
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(MyTrips.routeName);
                            },
                          ),
                          ListTile(
                            leading: Icon(MdiIcons.scriptTextOutline),
                            title: Text(
                              "Accepted Deals",
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  color: Colors.grey[200],
                                ),
                                child: Icon(Icons.navigate_next)),
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(Contracts.routeName);
                            },
                          ),
                        ],
                      ),
                    ),
                    Card(
                      margin:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(MdiIcons.accountMultiplePlus),
                            title: Text(
                              "Invite Friends",
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  color: Colors.grey[200],
                                ),
                                child: Icon(Icons.navigate_next)),
                          ),
                          ListTile(
                            leading: Icon(MdiIcons.faceAgent),
                            title: Text(
                              "Customer Support",
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  color: Colors.grey[200],
                                ),
                                child: Icon(Icons.navigate_next)),
                          ),
                          ListTile(
                            leading: Icon(Icons.star_border),
                            title: Text(
                              "Rate/Leave suggestion", //Todo: App Rating
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  color: Colors.grey[200],
                                ),
                                child: Icon(Icons.navigate_next)),
                          ),
                          ListTile(
                            leading: Icon(MdiIcons.logoutVariant),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
//                          title: Text(''),
                                  content: Text(
                                    "Are you sure you want to Log out?",
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text('No.'),
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                      },
                                    ),
                                    FlatButton(
                                      child: Text('Yes, let me out!',
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                          )),
                                      onPressed: () {
                                        Provider.of<Auth>(context,
                                                listen: false)
                                            .logout(context);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                            title: Text(
                              "Logout",
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  color: Colors.grey[200],
                                ),
                                child: Icon(Icons.navigate_next)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
