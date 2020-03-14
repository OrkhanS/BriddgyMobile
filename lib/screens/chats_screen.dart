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

import 'package:timeago/timeago.dart' as timeago;

class ChatsScreen extends StatefulWidget {
  final StreamController<String> streamController =
      StreamController<String>.broadcast();
  IOWebSocketChannel _channel;

  ObserverList<Function> _listeners = new ObserverList<Function>();
  var provider, rooms, token;
  ChatsScreen({this.provider, this.rooms, this.token});
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
    setRoomsInProvider(widget.provider, widget.rooms);
  }

  setRoomsInProvider(provider, rooms) {
    _rooms = provider.allAddChats(rooms);
    fetchMessageCaller();
  }

  Future fetchMessageCaller() async {
    if (_rooms == null) {
      _islogged = false;
      return 0;
    } else {
      for (var i = 0; i < _rooms.length; i++) {
        await fetchAndSetMessages(i);
      }
    }
  }

  /// ----------------------------------------------------------
  /// Fetch Messages Of User
  /// ----------------------------------------------------------
  Future fetchAndSetMessages(int i) async {
    var token = widget.token;
    String url = "https://briddgy.herokuapp.com/api/chat/messages/?room_id=" +
        _rooms[i]["id"].toString();
    final response = await http.get(
      url,
      headers: {
        HttpHeaders.CONTENT_TYPE: "application/json",
        "Authorization": "Token " + token,
      },
    ).then((response) {
      _mesaj = {};
      var dataOrders = json.decode(response.body) as Map<String, dynamic>;
      _mesaj.addAll(dataOrders);
      _mesaj['room_id'] = _rooms[i]["id"];
      Map tmpMessage;
      tmpMessage = Provider.of<Messages>(context).allAddMessages(_mesaj);
      _messagess.add(tmpMessage);
      _isloading = false;
    });

    // Provider.of<Messages>(context, listen: false).addMessages(_mesaj);
//    todo: remove comment
  }

  /// ----------------------------------------------------------
  /// End Fetching Rooms Of User
  /// ----------------------------------------------------------

  // /// ----------------------------------------------------------
  // /// Creates the WebSocket communication
  // /// ----------------------------------------------------------
  // initCommunication() async {
  //   reset();
  //   try {
  //     widget._channel = new IOWebSocketChannel.connect(
  //         'ws://briddgy.herokuapp.com/ws/alert/?token=40694c366ab5935e997a1002fddc152c9566de90'); //todo
  //     widget._channel.stream.listen(_onReceptionOfMessageFromServer);
  //     print("Alert Connected");
  //   } catch (e) {
  //     print("Error Occured");
  //     reset();
  //   }
  // }

  // /// ----------------------------------------------------------
  // /// Closes the WebSocket communication
  // /// ----------------------------------------------------------
  // reset() {
  //   if (widget._channel != null) {
  //     if (widget._channel.sink != null) {
  //       widget._channel.sink.close();
  //       _isOn = false;
  //     }
  //   }
  // }

  // /// ---------------------------------------------------------
  // /// Adds a callback to be invoked in case of incoming
  // /// notification
  // /// ---------------------------------------------------------
  // addListener(Function callback) {
  //   widget._listeners.add(callback);
  // }

  // removeListener(Function callback) {
  //   widget._listeners.remove(callback);
  // }

  // /// ----------------------------------------------------------
  // /// Callback which is invoked each time that we are receiving
  // /// a message from the server
  // /// ----------------------------------------------------------
  // _onReceptionOfMessageFromServer(message) {
  //   _mesaj = [];

  //   _mesaj.add(json.decode(message));
  //   // if(_mesaj[0]["id"]){
  //   // Check if "ID" of image sent before, then check its room ID, search in _room and get message ID and use
  //   // it in Message Provider, find message, then add the mesaj into that
  //   // }
  //   _isOn = true;
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
        child: _islogged != true
            ? Center(child: Text('You do not have chats yet'))
            : _isloading == true
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _rooms.length,
                    itemBuilder: (context, int index) {
                      String last_message;
                      try {
                        last_message = _messagess[index][_rooms[index]["id"]]
                                ["results"][0]["text"]
                            .toString();
                        if (last_message.length > 20) {
                          last_message = last_message.substring(0, 20);
                        }
                      } catch (e) {
                        last_message = "No Message";
                      }
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
                                  _rooms[index]["members"][0]["first_name"]
                                          .toString() +
                                      " " +
                                      _rooms[index]["members"][0]["last_name"]
                                          .toString(),
                                  style: TextStyle(fontSize: 15.0),
                                ),
                                SizedBox(
                                  width: 16.0,
                                ),
                                // Text(
                                //   _rooms[index]["date_modified"]
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
                                      .format(DateTime.parse(_rooms[index]
                                                  ["date_modified"]
                                              .toString()
                                              .substring(0, 10) +
                                          " " +
                                          _rooms[index]["date_modified"]
                                              .toString()
                                              .substring(11, 26)))
                                      .toString(),
                              style: TextStyle(fontSize: 15.0),
                              // _messages[index]["results"][0]["text"]
                              //   .toString().substring(0,15)
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 14.0,
                            ),
                            onTap: () {
                              // Navigator.of(context).pushNamed('/chats/chat_window');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (__) => ChatWindow(
                                        provider: widget.provider,
                                        room: _rooms[index]["id"],
                                        user: _rooms[index]["members"],
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
  }
}
