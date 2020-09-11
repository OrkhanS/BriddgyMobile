import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:briddgy/localization/localization_constants.dart';
import 'package:briddgy/models/api.dart';
import 'package:briddgy/screens/profile_screen.dart';
import 'package:briddgy/widgets/generators.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import 'package:briddgy/models/user.dart';
import 'chay_screen1.dart';
import 'languages_screen.dart';
import 'package:share/share.dart';
import 'package:briddgy/screens/customer_support.dart';

class AccountScreen extends StatefulWidget {
  static const routeName = '/accountscreen';

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool isLoading = true;
  User user;
  var imageUrl;
  Auth auth;

  var token;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    auth = Provider.of<Auth>(context, listen: true);
    if (auth.userdetail != null) {
      user = auth.userdetail;
      token = auth.token;
      imageUrl = auth.userdetail.avatarpic == null ? Api.noPictureImage : Api.storageBucket + user.avatarpic.toString();
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
//    if (auth == null) auth = Provider<Auth>.of(context);

    if (auth.userdetail != null) {
      user = auth.userdetail;
      imageUrl = auth.userdetail.avatarpic == null ? Api.noPictureImage : Api.storageBucket + user.avatarpic.toString();
    }
    return Scaffold(
        body: SafeArea(
      child: user == null
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.max,
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
                        imageUrl == Api.noPictureImage
                            ? InitialsAvatarWidget(user.firstName.toString(), user.lastName.toString(), 70.0)
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(35.0),
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
                        VerticalDivider(),
                        Column(
                          children: <Widget>[
                            Text(
                              user.firstName + " " + user.lastName,
                              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700, color: Theme.of(context).primaryColor),
                            ),
                            Text(user.email, style: TextStyle(fontSize: 15)),
                          ],
                        ),
                        Spacer(),
                      ],
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
//                          ListTile(
//                            leading: Icon(MdiIcons.mailboxOpenOutline),
//                            title: Text(
//                              t(context, 'my-orders'),
//                              style: TextStyle(
//                                fontSize: 17,
//                                color: Colors.grey[600],
//                              ),
//                            ),
//                            trailing: Container(
//                                decoration: BoxDecoration(
//                                  borderRadius: BorderRadius.all(Radius.circular(15)),
//                                  color: Colors.grey[200],
//                                ),
//                                child: Icon(Icons.navigate_next)),
//                            onTap: () {
//                              Navigator.push(
//                                context,
//                                MaterialPageRoute(
//                                    builder: (__) => MyItems(
//                                          token: Provider.of<Auth>(context, listen: true).token,
//                                          orderstripsProvider: widget.provider,
//                                        )),
//                              );
//                            },
//                          ),
//                          ListTile(
//                            leading: Icon(MdiIcons.mapMarkerPath),
//                            title: Text(
//                              t(context, 'my-trips'),
//                              style: TextStyle(
//                                fontSize: 17,
//                                color: Colors.grey[600],
//                              ),
//                            ),
//                            trailing: Container(
//                                decoration: BoxDecoration(
//                                  borderRadius: BorderRadius.all(Radius.circular(15)),
//                                  color: Colors.grey[200],
//                                ),
//                                child: Icon(Icons.navigate_next)),
//                            onTap: () {
//                              Navigator.push(
//                                context,
//                                MaterialPageRoute(
//                                    builder: (__) => MyTrips(
//                                          token: Provider.of<Auth>(context, listen: true).token,
//                                          orderstripsProvider: widget.provider,
//                                        )),
//                              );
//                            },
//                          ),
//                          ListTile(
//                            leading: Icon(MdiIcons.scriptTextOutline),
//                            title: Text(
//                              t(context, 'my_contracts'),
//                              style: TextStyle(
//                                fontSize: 17,
//                                color: Colors.grey[600],
//                              ),
//                            ),
//                            trailing: Container(
//                                decoration: BoxDecoration(
//                                  borderRadius: BorderRadius.all(Radius.circular(15)),
//                                  color: Colors.grey[200],
//                                ),
//                                child: Icon(Icons.navigate_next)),
//                            onTap: () {
//                              Navigator.push(
//                                context,
//                                MaterialPageRoute(
//                                    builder: (__) => Contracts(
//                                          token: Provider.of<Auth>(context, listen: true).token,
//                                        )),
//                              );
//                            },
//                          ),
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
                          leading: Icon(MdiIcons.earth),
                          title: Text(
                            t(context, 'change_language'),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (__) => LanguageScreen()),
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(MdiIcons.accountMultiplePlus),
                          title: Text(
                            t(context, 'invite_friends'),
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
                            Share.share(t(context, 'share_link'));
                          },
                        ),
                        ListTile(
                          leading: Icon(MdiIcons.faceAgent),
                          title: Text(
                            t(context, 'customer_service'),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (__) => CustomerSupport()),
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.star_border),
                          onLongPress: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (__) => ChayScreen()),
                            );
                          },
                          title: Text(
                            t(context, 'rate_leave_suggestion'), //Todo: App Rating
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
                            Provider.of<Auth>(context, listen: false).logout(context);
                            Navigator.of(context).pop();

//                            Navigator.of(context).reassemble();
//                              showDialog(
//                                context: context,
//                                builder: (ctx) => AlertDialog(
////                          title: Text(''),
//                                  content: Text(
//                                    t(context, 'logout_prompt'),
//                                  ),
//                                  actions: <Widget>[
//                                    FlatButton(
//                                      child: Text(t(context, 'no')),
//                                      onPressed: () {
//                                        Navigator.of(ctx).pop();
//                                      },
//                                    ),
//                                    FlatButton(
//                                      child: Text(t(context, 'yes_let_me_out'),
//                                          style: TextStyle(
//                                            color: Colors.redAccent,
//                                          )),
//                                      onPressed: () {
//                                        Provider.of<Auth>(context, listen: false).logout(context);
//                                        Navigator.of(context).reassemble();
//                                      },
//                                    ),
//                                  ],
//                                ),
//                              );
                          },
                          title: Text(
                            t(context, 'logout'),
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
    ));
  }
}
