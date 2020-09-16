import 'dart:convert';
import 'dart:io';
import 'package:briddgy/widgets/components.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:menu/menu.dart';
import 'package:briddgy/localization/localization_constants.dart';
import 'package:briddgy/models/api.dart';
import 'package:briddgy/models/chats.dart';
import 'package:briddgy/models/user.dart';
import 'package:briddgy/providers/auth.dart';
import 'package:briddgy/screens/chat_window.dart';
import 'package:briddgy/screens/report_user_screen.dart';
import 'package:briddgy/widgets/progress_indicator_widget.dart';
import 'package:provider/provider.dart';
import 'package:briddgy/models/user.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'chat_window.dart';
import 'package:briddgy/providers/messages.dart';
import 'dart:async';
import 'package:badges/badges.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatsScreen extends StatefulWidget {
  final StreamController<String> streamController = StreamController<String>.broadcast();
  var provider, auth;
  ChatsScreen({this.provider, this.auth});
  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  PageController pageController;
  int numberOfPages = 6;
  double viewportFraction = 0.75;
  bool isMessagesLoaded = false;
  Future<int> roomLength;
  List _rooms = [];
  String myid = "empty";
  bool _isfetchingnew = false;
  String nextMessagesURL = "FirstCall";

  @override
  void initState() {
    // if(widget.provider.chats.isEmpty){
    //   widget.provider.fetchAndSetRooms(widget.auth,false);
    // }
    pageController = PageController(viewportFraction: viewportFraction);
    widget.provider.isChatRoomPageActive = false;
    widget.provider.roomIDofActiveChatroom = "Empty";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // widget.provider.isChatsLoading = true;
    // widget.provider.fetchAndSetRooms(widget.auth, false);
    if (myid == "empty" && Provider.of<Auth>(context, listen: false).userdetail != null) {
      myid = Provider.of<Auth>(context, listen: false).userdetail.id.toString();
    }
    List<MaterialColor> colors = [
      Colors.amber,
      Colors.red,
      Colors.green,
      Colors.lightBlue,
    ];

    Future _loadData() async {
      if (nextMessagesURL.toString() != "null" && nextMessagesURL.toString() != "FirstCall") {
        String url = nextMessagesURL;
        try {
          await http.get(
            url,
            headers: {
              HttpHeaders.contentTypeHeader: "application/json",
              "Authorization": "Token " + Provider.of<Auth>(context, listen: false).myTokenFromStorage,
            },
          ).then((response) {
            Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
            for (var i = 0; i < data["results"].length; i++) {
              _rooms.add(Chats.fromJson(data["results"][i]));
            }
            nextMessagesURL = data["next"];
          });
        } catch (e) {
          print("Some Error");
        }
        setState(() {
          _isfetchingnew = false;
        });
      } else {
        _isfetchingnew = false;
      }
    }

    return Consumer<Messages>(
      builder: (context, provider, child) {
        if (!provider.chatsLoading) {
          _rooms = widget.provider.chats;
          if (nextMessagesURL == "FirstCall") {
            nextMessagesURL = widget.provider.chatDetails["next"];
          }
        }
        return Scaffold(
          body: SafeArea(
            child: Container(
                child: Provider.of<Auth>(context, listen: false).isAuth
                    ?
                    // if isAuth, check chats length
                    provider.chats.isEmpty && provider.chatsLoading == false
                        ?
                        // if chats is empty
                        Center(
                            child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Container(
                                  height: 400,
                                  width: 200,
                                  padding: EdgeInsets.all(10),
                                  child: SvgPicture.asset(
                                    "assets/photos/chat_bubbles.svg",
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(40.0),
                                  child: Text(
                                    t(context, 'no_chats'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 25,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                        :
                        //Check if chatsloading or not
                        provider.chatsLoading
                            ?
                            // if chats loading
                            Center(child: CircularProgressIndicator())
                            :

                            // if chats are ready to show

                            NotificationListener<ScrollNotification>(
                                onNotification: (ScrollNotification scrollInfo) {
                                  if (!_isfetchingnew && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                                    setState(() {
                                      _isfetchingnew = true;
                                    });
                                    _loadData();
                                  }
                                },
                                child: Stack(
                                  children: [
                                    ListView.builder(
                                      itemCount: _rooms.length,
                                      itemBuilder: (context, int index) {
                                        User user;
                                        user = _rooms[index].members[1].user.id.toString() == myid
                                            ? _rooms[index].members[0].user
                                            : _rooms[index].members[1].user;
//
//                                        imageUrl = user.avatarpic == null ? Api.noPictureImage : Api.storageBucket + user.avatarpic.toString();

                                        bool iscontract = false;

                                        try {
                                          var check = json.decode(_rooms[index].lastMessage.toString()) as Map<String, dynamic>;
                                          iscontract = true;
                                        } catch (e) {
                                          iscontract = false;
                                        }
                                        return InkWell(
                                          onTap: () {
                                            var room = _rooms[index];
                                            provider.readMessages(_rooms[index].id);
                                            provider.messagesLoading = true;
                                            provider.fetchAndSetMessages(index);

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (__) => ChatWindow(
                                                      provider: provider,
                                                      room: room,
                                                      user: user,
                                                      token: Provider.of<Auth>(context, listen: false).myTokenFromStorage,
                                                      auth: Provider.of<Auth>(context, listen: false))),
                                            );
                                          },
                                          child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//                                              margin: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(color: Colors.grey[300]),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  AvatarPicWidget(user: user),
                                                  SizedBox(width: 10),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          user.firstName + " " + user.lastName + "  ",
                                                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                                        ),
                                                        Text(
                                                          iscontract ? t(context, "contract") : _rooms[index].lastMessage.toString(),
                                                          textAlign: TextAlign.start,
                                                          maxLines: 2,
                                                          style: TextStyle(fontSize: 15.0, color: iscontract ? Colors.blue : Colors.grey[700]),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  provider.newMessage[_rooms[index].id] != null
                                                      ?

                                                      /// IF NEWMESSAGE ROOM IS NOT NULL, CHECKING THE LENGTH
                                                      provider.newMessage[_rooms[index].id] != 0
                                                          ?

                                                          /// IF LENGHT IS NOT 0, SHOWING THE BADGE
                                                          Badge(
                                                              badgeColor: Colors.green,
                                                              badgeContent: Text(
                                                                provider.newMessage[_rooms[index].id].toString(),
                                                                style: TextStyle(color: Colors.white),
                                                              ),
                                                              child: Container(
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                    color: Colors.grey[200],
                                                                  ),
                                                                  child: Icon(Icons.navigate_next)),
                                                            )
                                                          : Container(
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                color: Colors.grey[200],
                                                              ),
                                                              child: Icon(Icons.navigate_next))
                                                      : Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.all(Radius.circular(15)),
                                                            color: Colors.grey[200],
                                                          ),
                                                          child: Icon(Icons.navigate_next)),
                                                ],
                                              )

//                                          ListTile(
//                                            leading: imageUrl == Api.noPictureImage
//                                                ? InitialsAvatarWidget(user.firstName.toString(), user.lastName.toString(), 55.0)
//                                                : ClipRRect(
//                                                    borderRadius: BorderRadius.circular(35.0),
//                                                    child: Image.network(
//                                                      imageUrl,
//                                                      errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
//                                                        return InitialsAvatarWidget(user.firstName.toString(), user.lastName.toString(), 55.0);
//                                                      },
//                                                      height: 55,
//                                                      width: 55,
//                                                      fit: BoxFit.cover,
//                                                    ),
//                                                  ),
//                                            title: Row(
//                                              children: <Widget>[
//                                                Text(
//                                                  user.firstName + " " + user.lastName + "  ",
//                                                  style: TextStyle(fontSize: 15.0),
//                                                ),
//                                                user.online
//                                                    ? Icon(
//                                                        MdiIcons.circle,
//                                                        color: Colors.green,
//                                                        size: 12,
//                                                      )
//                                                    : SizedBox()
//                                              ],
//                                            ),
//                                            subtitle: Text(
//                                              iscontract ? t(context, "contract") : _rooms[index].lastMessage.toString(),
//                                              style: TextStyle(fontSize: 15.0, color: iscontract ? Colors.blue : Colors.grey[700]),
//                                              maxLines: 2,
//                                            ),
//                                            trailing: provider.newMessage[_rooms[index].id] != null
//                                                ?
//
//                                                /// IF NEWMESSAGE ROOM IS NOT NULL, CHECKING THE LENGTH
//                                                provider.newMessage[_rooms[index].id] != 0
//                                                    ?
//
//                                                    /// IF LENGHT IS NOT 0, SHOWING THE BADGE
//                                                    Badge(
//                                                        badgeColor: Colors.green,
//                                                        badgeContent: Text(
//                                                          provider.newMessage[_rooms[index].id].toString(),
//                                                          style: TextStyle(color: Colors.white),
//                                                        ),
//                                                        child: Container(
//                                                            decoration: BoxDecoration(
//                                                              borderRadius: BorderRadius.all(Radius.circular(15)),
//                                                              color: Colors.grey[200],
//                                                            ),
//                                                            child: Icon(Icons.navigate_next)),
//                                                      )
//                                                    : Container(
//                                                        decoration: BoxDecoration(
//                                                          borderRadius: BorderRadius.all(Radius.circular(15)),
//                                                          color: Colors.grey[200],
//                                                        ),
//                                                        child: Icon(Icons.navigate_next))
//                                                : Container(
//                                                    decoration: BoxDecoration(
//                                                      borderRadius: BorderRadius.all(Radius.circular(15)),
//                                                      color: Colors.grey[200],
//                                                    ),
//                                                    child: Icon(Icons.navigate_next)),
//                                            onTap: () {
//                                              var room = _rooms[index];
//                                              provider.readMessages(_rooms[index].id);
//                                              provider.messagesLoading = true;
//                                              provider.fetchAndSetMessages(index);
//
//                                              Navigator.push(
//                                                context,
//                                                MaterialPageRoute(
//                                                    builder: (__) => ChatWindow(
//                                                        provider: provider,
//                                                        room: room,
//                                                        user: user,
//                                                        token: Provider.of<Auth>(context, listen: false).myTokenFromStorage,
//                                                        auth: Provider.of<Auth>(context, listen: false))),
//                                              );
//                                            },
//                                          ),
                                              ),
                                        );
                                      },
                                    ),
                                    ProgressIndicatorWidget(
                                      show: _isfetchingnew,
                                    ),
                                  ],
                                ),
                              )
                    // if not isAuth
                    : Center(
                        child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Container(
                              height: 400,
                              width: 200,
                              padding: EdgeInsets.all(10),
                              child: SvgPicture.asset(
                                "assets/photos/chat_bubbles.svg",
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Text(
                                t(context, 'login_to_chat'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))),
          ),
        );
      },
    );
  }
}
