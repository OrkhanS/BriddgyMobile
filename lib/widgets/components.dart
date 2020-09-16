import 'package:briddgy/localization/localization_constants.dart';
import 'package:briddgy/models/api.dart';
import 'package:briddgy/models/order.dart';
import 'package:briddgy/models/trip.dart';
import 'package:briddgy/models/user.dart';
import 'package:briddgy/providers/auth.dart';
import 'package:briddgy/providers/messages.dart';
import 'package:briddgy/providers/ordersandtrips.dart';
import 'package:briddgy/screens/chats_screen.dart';
import 'package:briddgy/screens/profile_screen.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

Color colorFor(String text) {
  var hash = 0;
  for (var i = 0; i < text.length; i++) {
    hash = text.codeUnitAt(i) + ((hash << 5) - hash);
  }
  final finalHash = hash.abs() % (256 * 256 * 256);
  final red = ((finalHash & 0xFF0000) >> 16);
  final blue = ((finalHash & 0xFF00) >> 8);
  final green = ((finalHash & 0xFF));
  final color = Color.fromRGBO(red, green, blue, 1);
  return color;
}

class InitialsAvatarWidget extends StatelessWidget {
  final String firstName, lastName;
  final double size;
  InitialsAvatarWidget(this.firstName, this.lastName, this.size);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorFor(firstName.toString()),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Center(
        child: Text(
          firstName.toString()[0].toUpperCase() + lastName.toString()[0].toUpperCase(),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}

class StaticRatingBarWidget extends StatelessWidget {
  StaticRatingBarWidget({@required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    return RatingBar(
      ignoreGestures: true,
      initialRating: rating,
      minRating: 1,
      direction: Axis.horizontal,
      glowColor: Colors.amber,
      glowRadius: .2,
      itemSize: 15,
      allowHalfRating: false,
      itemCount: 5,
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
    );
  }
}

class AvatarPicWidget extends StatelessWidget {
  AvatarPicWidget({@required this.user, this.size: 70.0});
  final User user;
  final double size;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        user.avatarpic == null
            ? InitialsAvatarWidget(user.firstName.toString(), user.lastName.toString(), size)
            : ClipRRect(
                borderRadius: BorderRadius.circular(size / 2),
                child: Image.network(
                  Api.storageBucket + user.avatarpic.toString(),
                  errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                    return InitialsAvatarWidget(user.firstName.toString(), user.lastName.toString(), size);
                  },
                  height: size,
                  width: size,
                  fit: BoxFit.cover,
                ),
              ),
        Positioned(
          child: user.online
              ? Container(
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.white, width: 3), borderRadius: BorderRadius.circular(20), color: Colors.green),
                  height: 15,
                  width: 15,
                )
              : SizedBox(),
          top: 0,
          right: 0,
        )
      ],
    );
  }
}

class UserAppbarWidget extends StatelessWidget {
  UserAppbarWidget({@required this.user});
  final User user;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (__) => ProfileScreen(
                      user: user,
                    )),
          );
        },
        child: Row(
          children: <Widget>[
            IconButton(
              color: Theme.of(context).primaryColor,
              icon: Icon(
                Icons.chevron_left,
                size: 24,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      user.firstName + " " + user.lastName,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: user.online
                        ? Text(
                            ('online'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.green[500],
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : Text(
                            t(context, 'last_online') + DateFormat.yMMMd().format(user.lastOnline),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Stack(
                    children: <Widget>[
                      AvatarPicWidget(
                        user: user,
                        size: 55,
                      ),
                    ],
                  ),
                  StaticRatingBarWidget(rating: user.rating),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DeleteButtonWidget extends StatelessWidget {
  DeleteButtonWidget({@required this.object});
  final Object object;
  @override
  Widget build(BuildContext context) {
    return RaisedButton.icon(
      padding: EdgeInsets.symmetric(horizontal: 20),
      color: Colors.red,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      icon: Icon(
        Icons.delete_outline,
        color: Colors.white,
        size: 18,
      ),
      label: Text(
        " ${t(context, 'delete')}",
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: Colors.white,
          fontSize: 17,
        ),
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(t(context, 'confirm_deletion')),
            content: Text(t(context, 'action_cant_be_undone')),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  t(context, 'cancel'),
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
              FlatButton(
                child: Text(t(context, 'yes_delete')),
                onPressed: () {
                  if (object is Order) {
                    var res = Provider.of<OrdersTripsProvider>(context, listen: false).deleteOrder(context, object);
                    print("order deleted:" + res.toString());
                  } else if (object is Trip) {
                    var res = Provider.of<OrdersTripsProvider>(context, listen: false).deleteTrip(context, object);
                    print("trip deleted:" + res.toString());
                  }

                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        );
      },
    );
  }
}

class MessageButtonWidget extends StatelessWidget {
  MessageButtonWidget({@required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    return RaisedButton.icon(
        padding: EdgeInsets.symmetric(horizontal: 20),
        color: Colors.green,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        icon: Icon(
          MdiIcons.chatOutline,
          color: Colors.white,
//                              color: Theme.of(context).primaryColor,
          size: 18,
        ),
        label: Text(
          " ${t(context, 'message')}",
          style: TextStyle(
            fontWeight: FontWeight.w800, color: Colors.white, fontSize: 17,
//                                    color: Theme.of(context).primaryColor,
          ),
        ),
        onPressed: () {
//          setState(() {
//            messageDeliveryButton = false;
//          });
          var auth = Provider.of<Auth>(context, listen: false);
          var messageProvider = Provider.of<Messages>(context, listen: false);

          messageProvider.createRooms(user.id, auth).whenComplete(() => {
                if (messageProvider.isChatRoomCreated)
                  {
//                setState(() {
//                  messageDeliveryButton = true;
//                }),
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (__) => ChatsScreen(
                                provider: messageProvider,
                                auth: auth,
                              )),
                    ),
                    Flushbar(
                      title: t(context, 'success'),
                      message: t(context, 'chat_with') + user.firstName.toString() + t(context, 'has_been_started'),
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      borderRadius: 10,
                      duration: Duration(seconds: 3),
                    )..show(context)
                  }
                else
                  {
//                setState(() {
//                  messageDeliveryButton = true;
//                }),
                    Flushbar(
                      title: t(context, 'failure'),
                      message: t(context, 'please_try_again'),
                      padding: const EdgeInsets.all(8),
                      borderRadius: 10,
                      duration: Duration(seconds: 3),
                    )..show(context)
                  }
              });
        });
  }
}
