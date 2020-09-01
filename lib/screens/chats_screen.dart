import 'dart:convert';
import 'dart:io';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:menu/menu.dart';
import 'package:optisend/localization/localization_constants.dart';
import 'package:optisend/models/api.dart';
import 'package:optisend/models/chats.dart';
import 'package:optisend/widgets/generators.dart';
import 'package:optisend/models/user.dart';
import 'package:optisend/providers/auth.dart';
import 'package:optisend/screens/chat_window.dart';
import 'package:optisend/screens/profile_screen_another.dart';
import 'package:optisend/screens/report_user_screen.dart';
import 'package:optisend/widgets/progress_indicator_widget.dart';
import 'package:provider/provider.dart';
import 'package:optisend/models/user.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'chat_window.dart';
import 'package:optisend/providers/messages.dart';
import 'dart:async';
import 'package:badges/badges.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatsScreen extends StatefulWidget {
  final StreamController<String> streamController = StreamController<String>.broadcast();
  var provider, auth;
  bool shouldOpenTop = false;
  ChatsScreen({this.provider, this.auth, this.shouldOpenTop});
  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  PageController pageController;
  int numberOfPages = 6;
  double viewportFraction = 0.75;
  String imageUrl;
  bool isMessagesLoaded = false;
  Future<int> roomLength;
  List _rooms = [];
  String myid = "empty";
  bool _isfetchingnew = false;
  String nextMessagesURL = "FirstCall";

  @override
  void initState() {
    pageController = PageController(viewportFraction: viewportFraction);
    widget.provider.isChatRoomPageActive = false;
    widget.provider.roomIDofActiveChatroom = "Empty";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.provider.isChatRoomPageActive) {
      widget.provider.isChatRoomPageActive = false;
      widget.provider.roomIDofActiveChatroom = "Empty";
    }
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
      if (nextMessagesURL.toString() != "null" && nextMessagesURL.toString() != "FristCall") {
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
                        Center(child: Text(t(context, 'no_chats')))
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

                                        imageUrl = user.avatarpic == null ? Api.noPictureImage : Api.storageBucket + user.avatarpic.toString();

                                        return Column(
                                          children: <Widget>[
                                            Menu(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 7.0),
                                                child: ListTile(
                                                  leading: imageUrl == Api.noPictureImage
                                                      ? InitialsAvatarWidget(_rooms[index].members[0].user.firstName.toString(),
                                                          _rooms[index].members[0].user.lastName.toString(), 50.0)
                                                      : ClipRRect(
                                                          borderRadius: BorderRadius.circular(25.0),
                                                          child: Image.network(
                                                            imageUrl,
                                                            errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                                              return InitialsAvatarWidget(_rooms[index].members[0].user.firstName.toString(),
                                                                  _rooms[index].members[0].user.lastName.toString(), 50.0);
                                                            },
                                                            height: 50,
                                                            width: 50,
                                                            fit: BoxFit.fitWidth,
                                                          ),
                                                        ),
                                                  title: Row(
                                                    children: <Widget>[
                                                      Text(
                                                        user.firstName + " " + user.lastName,
                                                        style: TextStyle(fontSize: 15.0),
                                                      ),
                                                      SizedBox(
                                                        width: 16.0,
                                                      ),
                                                    ],
                                                  ),
                                                  subtitle: Row(
                                                    children: <Widget>[
                                                      Text(
                                                        _rooms[index].lastMessage.toString(),
                                                        style: TextStyle(fontSize: 15.0),
                                                      ),
                                                    ],
                                                  ),
                                                  trailing:
                                                      //////////////////////////////////////////////////////////////////
                                                      provider.newMessage[_rooms[index].id] != null
                                                          ?

                                                          /// IF NEWMESSAGE ROOM IS NOT NULL, CHECKING THE LENGTH
                                                          provider.newMessage[_rooms[index].id].length != 0
                                                              ?

                                                              /// IF LENGHT IS NOT 0, SHOWING THE BADGE
                                                              Badge(
                                                                  badgeContent: Text(provider.newMessage[_rooms[index].id].length.toString(),style: TextStyle(color: Colors.white),),
                                                                  child: Icon(Icons.arrow_forward_ios),
                                                                )
                                                              : Icon(
                                                                  Icons.arrow_forward_ios,
                                                                  size: 14.0,
                                                                )
                                                          : Icon(
                                                              Icons.arrow_forward_ios,
                                                              size: 14.0,
                                                            ),
                                                  //////////////////////////////////////////////////////////////////////////
                                                  onTap: () {
                                                    provider.readMessages(_rooms[index].id);
                                                    provider.messagesLoading = true;
                                                    provider.fetchAndSetMessages(index);
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (__) => ChatWindow(
                                                              provider: provider,
                                                              room: _rooms[index].members[0].room,
                                                              user: user,
                                                              token: Provider.of<Auth>(context, listen: false).myTokenFromStorage,
                                                              auth: Provider.of<Auth>(context, listen: false))),
                                                    );
                                                  },
                                                ),
                                              ),
                                              items: [
                                                MenuItem(t(context, 'info'), () {
                                                  Alert(
                                                    context: context,
                                                    type: AlertType.info,
                                                    title: t(context, 'conservtion_start') +
                                                        _rooms[index]["date_created"].toString().substring(0, 10) +
                                                        "\n",
                                                    buttons: [
                                                      DialogButton(
                                                        child: Text(
                                                          t(context, 'back'),
                                                          style: TextStyle(color: Colors.white, fontSize: 20),
                                                        ),
                                                        onPressed: () => Navigator.pop(context),
                                                        color: Color.fromRGBO(0, 179, 134, 1.0),
                                                      ),
                                                      DialogButton(
                                                        child: Text(
                                                          t(context, 'report'),
                                                          style: TextStyle(color: Colors.white, fontSize: 20),
                                                        ),
                                                        onPressed: () => {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (__) => ReportUser(
                                                                      user: _rooms[index]["members"],
                                                                      message: null,
                                                                    )),
                                                          ),
                                                        },
                                                        color: Color.fromRGBO(0, 179, 134, 1.0),
                                                      )
                                                    ],
                                                    content: Text(t(context, 'chats_cant_be_deleted')),
                                                  ).show();
                                                }),
                                              ],
                                              decoration: MenuDecoration(),
                                            ),
                                            Divider(),
                                          ],
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
                      ))

                // Provider.of<Auth>(context, listen: false).isAuth == false || provider.chats.isEmpty
                //     ? Center(child: Text('No Chats'))
                //     : provider.chatsLoading == true
                //         ? Center(child: CircularProgressIndicator())
                //         : NotificationListener<ScrollNotification>(
                //             onNotification: (ScrollNotification scrollInfo) {
                //               if (!_isfetchingnew &&
                //                   scrollInfo.metrics.pixels ==
                //                       scrollInfo.metrics.maxScrollExtent) {
                //                 // setState(() {
                //                 //   _isfetchingnew = true;
                //                 //   print("load order");
                //                 // });
                //                 //_loadData();
                //               }
                //             },
                //             child: Column(
                //               children: <Widget>[
                //                 SizedBox(
                //                   height: 15,
                //                 ),
                //                 Expanded(
                //                   child: ListView.builder(
                //                     itemCount: _rooms.length,
                //                     itemBuilder: (context, int index) {
                //                       User user = _rooms[index]
                //                                   .members[1]
                //                                   .user
                //                                   .id
                //                                   .toString() ==
                //                               myid
                //                           ? _rooms[index].members[0].user
                //                           : _rooms[index].members[1].user;
                //                       return Column(
                //                         children: <Widget>[
                //                           Menu(
                //                             child: Padding(
                //                               padding: const EdgeInsets.symmetric(
                //                                   horizontal: 7.0),
                //                               child: ListTile(
                //                                 leading: CircleAvatar(
                //                                   backgroundColor:
                //                                       Colors.grey[300],
                //                                   backgroundImage: NetworkImage(
                //                                     "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?cs=srgb&dl=pexels-pixabay-220453.jpg&fm=jpg",
                //                                   ),
                //                                 ),
                //                                 title: Row(
                //                                   children: <Widget>[
                //                                     Text(
                //                                       user.firstName +
                //                                           " " +
                //                                           user.lastName,
                //                                       style: TextStyle(
                //                                           fontSize: 15.0),
                //                                     ),
                //                                     SizedBox(
                //                                       width: 16.0,
                //                                     ),
                //                                   ],
                //                                 ),
                //                                 subtitle: Row(
                //                                   children: <Widget>[
                //                                     Text(
                //                                       "Last Message:" + "  ",
                //                                       style: TextStyle(
                //                                           fontSize: 15.0),
                //                                     ),
                //                                     Text(
                //                                       timeago
                //                                           .format(DateTime.parse(
                //                                               _rooms[index]
                //                                                       .dateModified
                //                                                       .toString()
                //                                                       .substring(
                //                                                           0, 10) +
                //                                                   " " +
                //                                                   _rooms[index]
                //                                                       .dateModified
                //                                                       .toString()
                //                                                       .substring(
                //                                                           11,
                //                                                           26)))
                //                                           .toString(),
                //                                       style: TextStyle(
                //                                           fontSize: 15.0),
                //                                     )
                //                                   ],
                //                                 ),
                //                                 trailing:
                //                                     //////////////////////////////////////////////////////////////////
                //                                     provider.newMessage[
                //                                                 _rooms[index]
                //                                                     .id] !=
                //                                             null
                //                                         ?

                //                                         /// IF NEWMESSAGE ROOM IS NOT NULL, CHECKING THE LENGTH
                //                                         provider
                //                                                     .newMessage[
                //                                                         _rooms[index]
                //                                                             .id]
                //                                                     .length !=
                //                                                 0
                //                                             ?

                //                                             /// IF LENGHT IS NOT 0, SHOWING THE BADGE
                //                                             Badge(
                //                                                 badgeContent: Text(provider
                //                                                     .newMessage[
                //                                                         _rooms[index]
                //                                                             .id]
                //                                                     .length
                //                                                     .toString()),
                //                                                 child: Icon(Icons
                //                                                     .arrow_forward_ios),
                //                                               )
                //                                             : Icon(
                //                                                 Icons
                //                                                     .arrow_forward_ios,
                //                                                 size: 14.0,
                //                                               )
                //                                         : Icon(
                //                                             Icons
                //                                                 .arrow_forward_ios,
                //                                             size: 14.0,
                //                                           ),
                //                                 //////////////////////////////////////////////////////////////////////////
                //                                 onTap: () {
                //                                   provider.readMessages(
                //                                       _rooms[index].id);
                //                                   provider
                //                                       .fetchAndSetMessages(index);
                //                                   Navigator.push(
                //                                     context,
                //                                     MaterialPageRoute(
                //                                         builder: (__) =>
                //                                             ChatWindow(
                //                                                 provider:
                //                                                     provider,
                //                                                 room: _rooms[
                //                                                         index]
                //                                                     .members[0]
                //                                                     .room,
                //                                                 user: user,
                //                                                 token:
                //                                                     Provider.of<
                //                                                         Auth>(
                //                                                     context,
                //                                                     listen:
                //                                                         false).myTokenFromStorage,
                //                                                 auth: Provider.of<
                //                                                         Auth>(
                //                                                     context,
                //                                                     listen:
                //                                                         false))),
                //                                   );
                //                                 },
                //                               ),
                //                             ),
                //                             items: [
                //                               MenuItem(
                //                                 "Profile",
                //                                 () {
                //                                   Navigator.push(
                //                                     context,
                //                                     MaterialPageRoute(
                //                                         builder: (__) =>
                //                                             ProfileScreenAnother(
                //                                               user: _rooms[index]["members"][1]["user"]
                //                                                               [
                //                                                               "id"]
                //                                                           .toString() !=
                //                                                       myid
                //                                                   ? _rooms[index][
                //                                                           "members"]
                //                                                       [1]["user"]
                //                                                   : _rooms[index][
                //                                                           "members"]
                //                                                       [0]["user"],
                //                                             )),
                //                                   );
                //                                 },
                //                               ),
                //                               MenuItem("Info", () {
                //                                 Alert(
                //                                   context: context,
                //                                   type: AlertType.info,
                //                                   title:
                //                                       "Conversation started on:  " +
                //                                           _rooms[index]
                //                                                   ["date_created"]
                //                                               .toString()
                //                                               .substring(0, 10) +
                //                                           "\n",
                //                                   buttons: [
                //                                     DialogButton(
                //                                       child: Text(
                //                                         "Back",
                //                                         style: TextStyle(
                //                                             color: Colors.white,
                //                                             fontSize: 20),
                //                                       ),
                //                                       onPressed: () =>
                //                                           Navigator.pop(context),
                //                                       color: Color.fromRGBO(
                //                                           0, 179, 134, 1.0),
                //                                     ),
                //                                     DialogButton(
                //                                       child: Text(
                //                                         "Report",
                //                                         style: TextStyle(
                //                                             color: Colors.white,
                //                                             fontSize: 20),
                //                                       ),
                //                                       onPressed: () => {
                //                                         Navigator.push(
                //                                           context,
                //                                           MaterialPageRoute(
                //                                               builder: (__) =>
                //                                                   ReportUser(
                //                                                     user: _rooms[
                //                                                             index]
                //                                                         [
                //                                                         "members"],
                //                                                     message: null,
                //                                                   )),
                //                                         ),
                //                                       },
                //                                       color: Color.fromRGBO(
                //                                           0, 179, 134, 1.0),
                //                                     )
                //                                   ],
                //                                   content: Text(
                //                                       "To keep our community more secure and as mentioned in our Privacy&Policy, you cannot remove chats.\n"),
                //                                 ).show();
                //                               }),
                //                             ],
                //                             decoration: MenuDecoration(),
                //                           ),
                //                           Divider(),
                //                         ],
                //                       );
                //                     },
                //                   ),
                //                 ),
                //                 Container(
                //                   height: _isfetchingnew ? 50.0 : 0.0,
                //                   color: Colors.transparent,
                //                   child: Center(
                //                     child: CircularProgressIndicator(),
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),

                ),
          ),
        );
      },
    );
  }
}
