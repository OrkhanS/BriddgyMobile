import 'package:briddgy/screens/about_screen.dart';
import 'package:briddgy/widgets/components.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:briddgy/localization/localization_constants.dart';
import 'package:briddgy/models/api.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import 'package:briddgy/models/user.dart';
import 'chay_screen.dart';
import 'languages_screen.dart';
import 'package:share/share.dart';
import 'package:briddgy/screens/customer_support.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:briddgy/providers/auth.dart';

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

  bool picturePosting = false;
  var imageFile;

  void _openGallery(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.gallery, maxHeight: 400, maxWidth: 400);
    this.setState(() {
      imageFile = picture;
    });
    upload(context);
  }

  Future upload(context) async {
    setState(() {
      picturePosting = true;
    });
    var stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();

    var uri = Uri.parse(Api.addUserImage);
    var token = Provider.of<Auth>(context, listen: false).myTokenFromStorage;
    var request = new http.MultipartRequest("PUT", uri);
    var multipartFile = new http.MultipartFile('file', stream, length, filename: basename(imageFile.path));
    request.headers['Authorization'] = "Token " + token;

    request.files.add(multipartFile);
    var response = await request.send().then((value) {
      if (value.statusCode == 201) {
        value.stream.transform(utf8.decoder).listen((value) {
          setState(() {
            picturePosting = false;
            Provider.of<Auth>(context, listen: false).changeUserAvatar(json.decode(value)["name"].toString());
            imageUrl = Api.storageBucket + json.decode(value)["name"].toString();
          });
        });
        Flushbar(
          title: "${t(context, 'success')}!",
          backgroundColor: Colors.green[800],
          message: "${t(context, 'image_changed')}.",
          padding: const EdgeInsets.all(8),
          borderRadius: 10,
          duration: Duration(seconds: 2),
        )..show(context);
      }
    });
  }

  @override
  void initState() {
    auth = Provider.of<Auth>(this.context, listen: false);

    super.initState();
  }

  @override
  void didChangeDependencies() {
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
                        Stack(
                          children: <Widget>[
                            AvatarPicWidget(
                              user: user,
                              size: 70,
                            ),
                            Provider.of<Auth>(context, listen: false).isAuth
                                ? auth.userdetail.id == user.id
                                    ? GestureDetector(
                                        onTap: () {
                                          _openGallery(context);
                                        },
                                        child: CircleAvatar(
                                          radius: 35,
                                          backgroundColor: Color.fromRGBO(125, 125, 125, 175),
                                          child: Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      )
                                    : SizedBox()
                                : SizedBox(),
                          ],
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
//                        ListTile(
//                          leading: Icon(Icons.star_border),
//                          onLongPress: () {
//                            Navigator.push(
//                              context,
//                              MaterialPageRoute(builder: (__) => ChayScreen()),
//                            );
//                          },
//                          title: Text(
//                            t(context, 'rate_leave_suggestion'), //Todo: App Rating
//                            style: TextStyle(
//                              fontSize: 17,
//                              color: Colors.grey[600],
//                            ),
//                          ),
//                          trailing: Container(
//                              decoration: BoxDecoration(
//                                borderRadius: BorderRadius.all(Radius.circular(15)),
//                                color: Colors.grey[200],
//                              ),
//                              child: Icon(Icons.navigate_next)),
//                        ),
                        ListTile(
                          leading: Icon(Icons.info_outline),
                          onLongPress: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (__) => ChayScreen()),
                            );
                          },
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (__) => AboutScreen()),
                            );
                          },
                          title: Text(
                            t(context, 'about'), //Todo: App Rating
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
