import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:optisend/screens/chat_window.dart';
import 'package:provider/provider.dart';
import './auth_screen.dart';
import '../providers/auth.dart';
import 'splash_screen.dart';

import 'package:flutter/material.dart';
import 'chat_window.dart';
import 'package:web_socket_channel/io.dart';
import 'package:optisend/providers/messages.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:badges/badges.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatsScreen extends StatefulWidget {
  final StreamController<String> streamController =
      StreamController<String>.broadcast();
  IOWebSocketChannel _channel;

  ObserverList<Function> _listeners = new ObserverList<Function>();
  var provider, token;
  ChatsScreen({this.provider, this.token});
  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  PageController pageController;
  int numberOfPages = 6;
  double viewportFraction = 0.75;
  String imageUrl;
  Map _details = {};
  List<dynamic> _messagess = [];
  bool _isOn = false;
  bool _islogged = true;
  bool _isloading = true;
  Map _messages = {};
  Map _mesaj = {};
  bool isMessagesLoaded = false;
  Future<int> roomLength;
  List _rooms = [];
  @override
  void initState() {
    pageController = PageController(viewportFraction: viewportFraction);
    super.initState();
  }

  /// ----------------------------------------------------------
  /// Fetch Messages Of User
  /// ----------------------------------------------------------
  // Future fetchAndSetMessages(int i) async {
  //   var token = widget.token;
  //   String url = "https://briddgy.herokuapp.com/api/chat/messages/?room_id=" +
  //       _rooms[i]["id"].toString();
  //   try {
  //     await http.get(
  //       url,
  //       headers: {
  //         HttpHeaders.CONTENT_TYPE: "application/json",
  //         "Authorization": "Token " + token,
  //       },
  //     ).then((response) {
  //       _mesaj = {};
  //       var dataOrders = json.decode(response.body) as Map<String, dynamic>;
  //       _mesaj.addAll(dataOrders);
  //       _mesaj['room_id'] = _rooms[i]["id"];
  //       Map tmpMessage;
  //       tmpMessage = Provider.of<Messages>(context).allAddMessages(_mesaj);
  //       _messagess.add(tmpMessage);
  //       _isloading = false;
  //     });
  //   } catch (e) {
  //     print("Some Error");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // getAvatarUrl(String a) {
    //   String helper = 'https://briddgy.herokuapp.com/media/';
    //   imageUrl =
    //       'https://moonvillageassociation.org/wp-content/uploads/2018/06/default-profile-picture1.jpg';
    //   if (a != null) {
    //     imageUrl = 'https://briddgy.herokuapp.com/media/' + a.toString() + "/";
    //   }

    //   return imageUrl;
    // }

    List<MaterialColor> colors = [
      Colors.amber,
      Colors.red,
      Colors.green,
      Colors.lightBlue,
    ];
    return Consumer<Messages>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Center(
              child: Text(
                "Chats",
                style: TextStyle(
                    color: (Theme.of(context).primaryColor),
                    fontWeight: FontWeight.bold),
              ),
            ),
            elevation: 1,
          ),
          body: Container(
            child: widget.provider.userNotLogged == true ||
                    widget.provider.chats == null
                ? Center(child: Text('You do not have chats yet'))
                : widget.provider.chatsNotLoaded == true
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: widget.provider.chats.length,
                        itemBuilder: (context, int index) {
                          return Column(
                            children: <Widget>[
                              Divider(
                                height: 12.0,
                              ),
                              ListTile(
                                leading: CircleAvatar(
                                    radius: 24.0,
                                    child: FadeInImage(
                                      image: NetworkImage(
                                          'https://toppng.com/uploads/preview/person-icon-white-icon-11553393970jgwtmsc59i.png'),
                                      placeholder: NetworkImage(
                                          'https://toppng.com/uploads/preview/person-icon-white-icon-11553393970jgwtmsc59i.png'),
                                    )),
                                title: Row(
                                  children: <Widget>[
                                    Text(
                                      widget
                                              .provider
                                              .chats[index]["members"][0]
                                                  ["first_name"]
                                              .toString() +
                                          " " +
                                          widget
                                              .provider
                                              .chats[index]["members"][0]
                                                  ["last_name"]
                                              .toString(),
                                      style: TextStyle(fontSize: 15.0),
                                    ),
                                    SizedBox(
                                      width: 16.0,
                                    ),
                                    // Text(
                                    //   widget.provider.chats[index]["date_modified"]
                                    //       .toString()
                                    //       .substring(0, 10),
                                    //   style: TextStyle(fontSize: 15.0),
                                    // ),
                                  ],
                                ),
                                subtitle: Text(
                                  "Last Message:" +
                                      "  " +
                                      timeago
                                          .format(DateTime.parse(widget.provider
                                                  .chats[index]["date_modified"]
                                                  .toString()
                                                  .substring(0, 10) +
                                              " " +
                                              widget.provider
                                                  .chats[index]["date_modified"]
                                                  .toString()
                                                  .substring(11, 26)))
                                          .toString(),
                                  style: TextStyle(fontSize: 15.0),
                                  // _messages[index]["results"][0]["text"]
                                  //   .toString().substring(0,15)
                                ),
                                trailing:
                                widget.provider.newMessages[widget.provider.chats[index]["id"]].toString() != "null" ?
                                    Badge(
                                  badgeContent: Text(widget.provider.newMessages[widget.provider.chats[index]["id"]].toString()),
                                  child: Icon(Icons.arrow_forward_ios),
                                )
                                : 
                                Icon(
                                      Icons.arrow_forward_ios,
                                      size: 14.0,
                                    ),
                                onTap: () {
                                  widget.provider.readMessages(widget.provider.chats[index]["id"]);
                                  widget.provider.fetchAndSetMessages(index);
                                  // Navigator.of(context).pushNamed('/chats/chat_window');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (__) => ChatWindow(
                                            provider: widget.provider,
                                            room: widget.provider.chats[index]["id"],
                                            user: widget.provider.chats[index]
                                                ["members"],
                                            token: widget.token)),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
          ),
        );
      },
    );
  }
}
