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

class DetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 50,

                      backgroundImage: NetworkImage(
                          'https://images-na.ssl-images-amazon.com/images/I/81NIli1PuqL._AC_SL1500_.jpg'), //Todo: UserPic
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
                          "Orkhan Salahov",
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).primaryColor),
                        ), //Todo: Username
                        Text("bolmayonez@avtow.doner"), //Todo: email
//                        RaisedButton(
//                          color: Theme.of(context).primaryColor,
//                          child: Text(
//                            "Profile",
//                            style: TextStyle(
//                                color: Colors.white,
//                                fontWeight: FontWeight.bold),
//                          ),
//                          onPressed: () {}, //Todo: navigate to profile
//                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                        color: Theme.of(context).primaryColor,
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(ProfileScreen.routeName);
                        },
                        child: Icon(
                          Icons.navigate_next,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                        "Your Parcels",
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            color: Colors.grey[200],
                          ),
                          child: Icon(Icons.navigate_next)),
                      onTap: () {
                        Navigator.of(context).pushNamed(MyItems.routeName);
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
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            color: Colors.grey[200],
                          ),
                          child: Icon(Icons.navigate_next)),
                      onTap: () {
                        Navigator.of(context).pushNamed(MyTrips.routeName);
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
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            color: Colors.grey[200],
                          ),
                          child: Icon(Icons.navigate_next)),
                      onTap: () {
                        Navigator.of(context).pushNamed(Contracts.routeName);
                      },
                    ),
                  ],
                ),
              ),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                            borderRadius: BorderRadius.all(Radius.circular(15)),
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
                            borderRadius: BorderRadius.all(Radius.circular(15)),
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
                            borderRadius: BorderRadius.all(Radius.circular(15)),
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
                                  Provider.of<Auth>(context, listen: false)
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
                            borderRadius: BorderRadius.all(Radius.circular(15)),
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
