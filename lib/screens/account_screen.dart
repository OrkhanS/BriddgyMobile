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
import 'package:share/share.dart';
import 'package:optisend/screens/customer_support.dart';

class AccountScreen extends StatelessWidget {
  static const routeName = '/accountscreen';
  var token, orderstripsProvider, auth;
  AccountScreen({this.token, this.orderstripsProvider, this.auth});
  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<Auth>(context, listen: false);
    return Scaffold(
      body:
//      auth.isAuth?
          AccountPage(
        token: token,
        auth: auth,
        provider: orderstripsProvider,
      )
//          : FutureBuilder(
//              future: auth.tryAutoLogin(),
//              builder: (ctx, authResultSnapshot) => authResultSnapshot.connectionState == ConnectionState.waiting ? SplashScreen() : AuthScreen(),
//            )
      ,
    );
  }
}

class AccountPage extends StatefulWidget {
  var token, provider, auth;
  AccountPage({this.token, this.provider, this.auth});
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: widget.auth.isNotLoadingUserDetails &&
              widget.auth.userdetail.isEmpty
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
                              builder: (__) => ProfileScreen(
                                  user: widget.auth.userdetail,
                                  token: widget.token)),
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
                                  widget.auth.userdetail["first_name"]
                                          .toString() +
                                      " " +
                                      widget.auth.userdetail["last_name"]
                                          .toString(),
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).primaryColor),
                                ),
                                Text(widget.auth.userdetail["email"].toString(),
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
                              "My Items",
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (__) => MyItems(
                                          token: widget.token,
                                          orderstripsProvider: widget.provider,
                                        )),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(MdiIcons.mapMarkerPath),
                            title: Text(
                              "My Trips",
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (__) => MyTrips(
                                          token: widget.token,
                                          orderstripsProvider: widget.provider,
                                        )),
                              );
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (__) => Contracts(
                                          token: widget.token,
                                        )),
                              );
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
                            onTap: () {
                              Share.share(
                                  "Join to the Briddgy Family https://briddgy.com");
                            },
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
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (__) => CustomerSupport()),
                              );
                            },
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
    ));
  }
}
