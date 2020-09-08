import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:briddgy/localization/demo_localization.dart';
import 'package:briddgy/localization/localization_constants.dart';
import 'package:briddgy/main.dart';
import 'package:briddgy/models/api.dart';
import 'package:briddgy/screens/contracts.dart';
import 'package:briddgy/screens/my_orders.dart';
import 'package:briddgy/screens/my_trips.dart';
import 'package:briddgy/screens/profile_screen.dart';
import 'package:briddgy/screens/test.dart';
import 'package:briddgy/widgets/generators.dart';
import 'package:provider/provider.dart';
import './auth_screen.dart';
import '../providers/auth.dart';
import 'package:briddgy/models/user.dart';
import 'chay_screen.dart';
import 'splash_screen.dart';
import 'package:share/share.dart';
import 'package:briddgy/screens/customer_support.dart';
import '../models/language.dart';

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
  User user;
  var imageUrl;
  @override
  void initState() {
    super.initState();
  }

  _changeLanguage(Language language) async {
    Locale _temp = await setLocale(language.languageCode);
    MyApp.setLocale(context, _temp);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.auth.userdetail != null) {
      user = widget.auth.userdetail;
      imageUrl = widget.auth.userdetail.avatarpic == null ? Api.noPictureImage : Api.storageBucket + user.avatarpic.toString();
    }
    return Scaffold(
        body: SafeArea(
      child: user == null
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
                                    user: user,
                                  )),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
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
                            Column(
                              children: <Widget>[
                                Text(
                                  user.firstName + " " + user.lastName,
                                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700, color: Theme.of(context).primaryColor),
                                ),
                                Text(user.email, style: TextStyle(fontSize: 15)),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(25)),
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
                    Card(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 3,
                      child: ListTile(
                        leading: Icon(MdiIcons.earth),
                        title: DropdownButton(
                          isExpanded: true,
                          underline: SizedBox(),
                          icon: Row(
                            children: [
                              Text(
                                t(context, 'change_language'),
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(
                                width: 40,
                              ),
                            ],
                          ),
                          items: Language.languageList()
                              .map<DropdownMenuItem<Language>>((lang) => DropdownMenuItem(
                                    value: lang,
                                    child: Row(
                                      children: <Widget>[
                                        Text(lang.name),
                                        Text(lang.flag),
                                      ],
                                    ),
                                  ))
                              .toList(),
                          onChanged: (Language language) {
                            _changeLanguage(language);
                          },
                        ),
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
                              t(context, 'my-orders'),
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
                                MaterialPageRoute(
                                    builder: (__) => MyItems(
                                          token: Provider.of<Auth>(context, listen: true).token,
                                          orderstripsProvider: widget.provider,
                                        )),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(MdiIcons.mapMarkerPath),
                            title: Text(
                              t(context, 'my-trips'),
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
                                MaterialPageRoute(
                                    builder: (__) => MyTrips(
                                          token: Provider.of<Auth>(context, listen: true).token,
                                          orderstripsProvider: widget.provider,
                                        )),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(MdiIcons.scriptTextOutline),
                            title: Text(
                              t(context, 'my_contracts'),
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
                                MaterialPageRoute(
                                    builder: (__) => Contracts(
                                          token: Provider.of<Auth>(context, listen: true).token,
                                        )),
                              );
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
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
//                          title: Text(''),
                                  content: Text(
                                    t(context, 'logout_prompt'),
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text(t(context, 'no')),
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                      },
                                    ),
                                    FlatButton(
                                      child: Text(t(context, 'yes_let_me_out'),
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                          )),
                                      onPressed: () {
                                        Provider.of<Auth>(context, listen: false).logout(context);
                                      },
                                    ),
                                  ],
                                ),
                              );
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
            ),
    ));
  }
}
