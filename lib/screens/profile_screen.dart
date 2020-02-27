import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import './auth_screen.dart';
import '../providers/auth.dart';
import 'splash_screen.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile';
  @override
  Widget build(BuildContext context) {
//    Widget review() {
//      return Container(
//        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//        child: Row(
//          children: <Widget>[
//            CircleAvatar(
//              radius: 30,
//
//              backgroundImage: NetworkImage(
//                  'https://images-na.ssl-images-amazon.com/images/I/81NIli1PuqL._AC_SL1500_.jpg'), //Todo: UserPic
//            ),
//            Column(
//              children: <Widget>[
//                Row(),
//                Container(
//                  child: Text(
//                      "Lorem ipsum gelsin soldan bir dene saga povorot elesin ona zehmet, amma yaxshi ushagdi xetrin chox isteyirem"),
//                ),
//              ],
//            )
//          ],
//        ),
//      );
//    }

    return Scaffold(
      appBar: AppBar(
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
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Card(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Expanded(
                            flex: 45,
                            child: CircleAvatar(
                              radius: 80,

                              backgroundImage: NetworkImage(
                                  'https://images-na.ssl-images-amazon.com/images/I/81NIli1PuqL._AC_SL1500_.jpg'), //Todo: UserPic
                            ),
                          ),
                          Expanded(
                            flex: 45,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "Orkhan",
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).primaryColor),
                                ), //Todo: Name
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Salahov",
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).primaryColor),
                                ), //Todo: Surname
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[600]),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
//                            border: BoxBorder(),
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                  ),
                                  child: Text(
                                    "edit",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 10,
                            child: Icon(
                              MdiIcons.shieldCheck,
                              color: Colors.lightGreen,
                            ),
                          )
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ListTile(
                            dense: true,
//                            leading: Icon(MdiIcons.accountMultiplePlus),
                            title: Text(
                              "Email: ",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Text(
                              "soldansaga@metu.edu.tr",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          ListTile(
                            dense: true,
//                            leading: Icon(MdiIcons.accountMultiplePlus),
                            title: Text(
                              "Phone: ",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Text(
                              "+994773121200",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          ListTile(
                            dense: true,
//                            leading: Icon(MdiIcons.accountMultiplePlus),
                            title: Text(
                              "Sent: ",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Text(
                              "20",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          ListTile(
                            dense: true,
//                            leading: Icon(MdiIcons.accountMultiplePlus),
                            title: Text(
                              "Delivered: ",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Text(
                              "13",
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
              Column(
                children: <Widget>[
                  Text(
                    "Reviews:",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  for (var x = 0; x < 5; x++)
                    ListTile(
                      contentPadding: EdgeInsets.all(10),
                      leading: CircleAvatar(
                        radius: 30,

                        backgroundImage: NetworkImage(
                            'https://images-na.ssl-images-amazon.com/images/I/81NIli1PuqL._AC_SL1500_.jpg'), //Todo: UserPic
                      ),
                      title: Row(
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: Text(
                              "Zubarina Tuxogovna ", //Todo: Name
                              softWrap: false,

                              style: TextStyle(
                                fontSize: 15,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          Icon(
                            MdiIcons.star,
                            color: Colors.orange,
                            size: 15,
                          ),
                          Text(
                            "4.5  ", //Todo: Rating

                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            " 10 Dec 2019", //Todo: Date
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                          "Lorem ipsum gelsin soldan bir dene saga povorot elesin ona zehmet, amma yaxshi ushagdi xetrin chox isteyirem"),
                      isThreeLine: true,
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
